#!/usr/bin/env bash
# Copyright 2026 Ronny Trommer <ronny@no42.org>
# SPDX-License-Identifier: CC-BY-NC-SA-4.0
#
# Checks a running blog image over HTTP.
# Usage: smoke.sh [base-url]   (default http://localhost:8080)
set -uo pipefail
BASE=${1:-http://localhost:8080}
fail=0

check() { # path want-code [header-regex] [body-regex]
  local path=$1 want=$2 hre=${3:-} bre=${4:-} hdr body code ok=1
  hdr=$(mktemp)
  body=$(mktemp)
  code=$(curl -s -m 10 -D "$hdr" -o "$body" -w '%{http_code}' "$BASE$path")
  [[ $code == "$want" ]] || ok=0
  [[ -z $hre ]] || tr -d '\r' <"$hdr" | grep -qiE "$hre" || ok=0
  [[ -z $bre ]] || grep -qE "$bre" "$body" || ok=0
  if ((ok)); then
    echo "ok   $path -> $code"
  else
    echo "FAIL $path: got $code, want $want${hre:+ header /$hre/}${bre:+ body /$bre/}"
    fail=1
  fi
  rm -f "$hdr" "$body"
}

check / 200 '^cache-control: public, max-age=300$' '<meta name="author" content="Ronny Trommer">'
check /article/opennms-oci/ 200 '' 'class="admonition'
check /article/opennms-oci 301 '^location: /article/opennms-oci/$'
check /index.xml 200 '^content-type: (text|application)/(rss\+)?xml'
check /tags/opennms/index.xml 200 '^content-type: (text|application)/(rss\+)?xml'
check /sitemap.xml 200 '' '<sitemapindex'
check /does-not-exist/ 404 '' '404 Page not found'

css=$(curl -s -m 10 "$BASE/" | grep -oE 'theme\.min\.[0-9a-f]{64}\.css' | head -1)
if [[ -n $css ]]; then
  check "/$css" 200 '^cache-control: public, max-age=31536000, immutable$'
else
  echo "FAIL /: no fingerprinted theme CSS linked"
  fail=1
fi

exit $fail
