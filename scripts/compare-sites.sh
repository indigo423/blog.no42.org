#!/usr/bin/env bash
# Copyright 2026 Ronny Trommer <ronny@no42.org>
# SPDX-License-Identifier: CC-BY-NC-SA-4.0
#
# Compares every sitemap URL between a reference and a candidate.
# Usage: compare-sites.sh [candidate-ip]
#   REF       reference base URL (default https://blog-no42-org.netlify.app)
#   candidate https://blog.no42.org, sent to candidate-ip with --resolve and -k when given
# Paths come from $REF/sitemap.xml. A sitemap index is expanded one level, and a flat
# urlset is used as is. Six fixed paths are added.
# Per path, status codes must match. A 3xx compares the redirect target path, with
# scheme and host stripped. Any other response compares the body bytes.
# The Netlify-injected comment is removed from the reference body before comparing.
# Uses curl's default user agent, which Anubis does not challenge.
set -uo pipefail
REF=${REF:-https://blog-no42-org.netlify.app}
HOST=blog.no42.org
IP=${1:-}

cand_opts=()
if [[ -n $IP ]]; then
  addr=$IP
  [[ $IP == *:* ]] && addr="[$IP]"
  cand_opts=(--resolve "$HOST:443:$addr" -k)
fi

locs() { grep -oE '<loc>[^<]+</loc>' | sed -E "s#</?loc>##g; s#^https://$HOST##"; }
strip() { sed -E 's#^https?://[^/]+##' <<<"$1"; }

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

{
  sitemap=$(curl -s -m 20 "$REF/sitemap.xml")
  if grep -q '<sitemapindex' <<<"$sitemap"; then
    for sm in $(locs <<<"$sitemap"); do
      curl -s -m 20 "$REF$sm" | locs
    done
  else
    locs <<<"$sitemap"
  fi
  printf '%s\n' / /index.xml /index.json /sitemap.xml /robots.txt /does-not-exist/
} | sort -u >"$tmp/paths"

n=0
d=0
while read -r p; do
  [[ -n $p ]] || continue
  n=$((n + 1))
  a=$(curl -s -m 20 -o "$tmp/a" -w '%{http_code} %{redirect_url}' "$REF$p")
  b=$(curl -s -m 20 -o "$tmp/b" -w '%{http_code} %{redirect_url}' ${cand_opts[@]+"${cand_opts[@]}"} "https://$HOST$p")
  ca=${a%% *}; ra=${a#* }
  cb=${b%% *}; rb=${b#* }
  perl -0pi -e 's/<!-- This site is hosted on Netlify\..*?-->\n?//s' "$tmp/a"

  why=
  if [[ $ca != "$cb" ]]; then
    why=status
  elif [[ $ca == 3* ]]; then
    [[ $(strip "$ra") == "$(strip "$rb")" ]] || why=redirect
  else
    cmp -s "$tmp/a" "$tmp/b" || why=body
  fi

  if [[ -n $why ]]; then
    da=; db=
    [[ $ca == 3* ]] && da="-> $(strip "$ra")"
    [[ $cb == 3* ]] && db="-> $(strip "$rb")"
    [[ $why == body ]] && da=body && db=body
    echo "DIFF $p: reference $ca $da, candidate $cb $db"
    d=$((d + 1))
  fi
done <"$tmp/paths"

echo "$n URLs compared, $d differ"
[[ $d -eq 0 ]]
