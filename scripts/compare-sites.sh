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
# A failed sitemap fetch, or a sitemap with no URLs, exits 1.
# Per path, status codes must match. A 3xx compares the redirect target path, with
# scheme and host stripped. Any other response compares the body bytes.
# A request that fails (status 000) on either side is a DIFF.
# When both sides redirect with the same status to the same target path, that target
# is fetched once more on both sides and compared the same way. At most one hop is
# followed. The path counts once, and a DIFF names the original path and the target.
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
fetch() {
  curl -fsS -m 20 "$1" || { echo "error: cannot fetch $1" >&2; return 1; }
}

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

sitemap=$(fetch "$REF/sitemap.xml") || exit 1
: >"$tmp/raw"
if grep -q '<sitemapindex' <<<"$sitemap"; then
  for sm in $(locs <<<"$sitemap"); do
    body=$(fetch "$REF$sm") || exit 1
    locs <<<"$body" >>"$tmp/raw"
  done
else
  locs <<<"$sitemap" >>"$tmp/raw"
fi
if [[ ! -s $tmp/raw ]]; then
  echo "error: no URLs found in $REF/sitemap.xml" >&2
  exit 1
fi

{
  cat "$tmp/raw"
  printf '%s\n' / /index.xml /index.json /sitemap.xml /robots.txt /does-not-exist/
} | sort -u >"$tmp/paths"

# Fetches one path from both sides and sets ca, ra, cb, rb and why.
# why is empty when both sides match.
compare() {
  local a b
  : >"$tmp/a"
  : >"$tmp/b"
  a=$(curl -s -m 20 -o "$tmp/a" -w '%{http_code} %{redirect_url}' "$REF$1")
  b=$(curl -s -m 20 -o "$tmp/b" -w '%{http_code} %{redirect_url}' ${cand_opts[@]+"${cand_opts[@]}"} "https://$HOST$1")
  ca=${a%% *}; ra=${a#* }
  cb=${b%% *}; rb=${b#* }
  perl -0pi -e 's/<!-- This site is hosted on Netlify\..*?-->\n?//s' "$tmp/a"

  why=
  if [[ $ca == 000 || $cb == 000 ]]; then
    why=curl
  elif [[ $ca != "$cb" ]]; then
    why=status
  elif [[ $ca == 3* ]]; then
    [[ $(strip "$ra") == "$(strip "$rb")" ]] || why=redirect
  else
    cmp -s "$tmp/a" "$tmp/b" || why=body
  fi
}

n=0
d=0
while read -r p; do
  [[ -n $p ]] || continue
  n=$((n + 1))
  compare "$p"
  via=
  if [[ -z $why && $ca == 3* ]]; then
    target=$(strip "$ra")
    if [[ -n $target ]]; then
      compare "$target"
      via=" (redirect target $target)"
    fi
  fi

  if [[ -n $why ]]; then
    da=; db=
    [[ $ca == 000 ]] && da="curl failed"
    [[ $cb == 000 ]] && db="curl failed"
    [[ $ca == 3* ]] && da="-> $(strip "$ra")"
    [[ $cb == 3* ]] && db="-> $(strip "$rb")"
    [[ $why == body ]] && da=body && db=body
    echo "DIFF $p$via: reference $ca $da, candidate $cb $db"
    d=$((d + 1))
  fi
done <"$tmp/paths"

echo "$n URLs compared, $d differ"
[[ $d -eq 0 ]]
