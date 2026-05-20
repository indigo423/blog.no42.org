---
title: "Blitsbom, browser-only SBOM viewer"
date: "2026-05-20"
categories: ['Technology']
tags: ['sbom', 'devops', 'selfhosting', 'open source']
author: "Ronny Trommer"
noSummary: false
---
I had to scratch one of my itches.
I have to work with SBOMs and I couldn't find something, so I'm announcing blitsbom — a browser-only SBOM viewer.
Software Bills of Materials are everywhere now.
Procurement asks for one. Compliance wants one filed.
A regulator's auditor will, at some point, want to look at one.
The trouble is that the moment you actually want to read an SBOM — to skim what's in a build, see which components are copyleft — your options are oddly bad.
You either ship the file off to a SaaS scanner, install a heavyweight platform, or squint at 280,000 lines of JSON in your editor.

Blitsbom is the alternative for the "I just want to look at this" case.
Drop a bom.json onto a web page, get a clean, searchable view of the dependencies, hand it to legal as a CSV.
That's the whole product. No account, no upload, no install.

What it does

- Reads CycloneDX (1.4 / 1.5 / 1.6) and SPDX (2.2 / 2.3) in JSON. Format is auto-detected.
- Resolves SPDX LicenseRef-* entries against ~13 common license signatures so they don't all flatten into "Proprietary."
- Classifies each component's license into FSF categories — Public Domain, Permissive, Copyleft, Strong Copyleft, Proprietary, Undeclared — and renders a donut chart you can click to drill in.
- Sortable, searchable component table. Filter by category, license, scope, type, severity. Filter state is encoded in the URL so you can paste a link to "Apache-2.0 components with high-severity CVEs" and the recipient sees exactly that view.
- Optional VEX overlay: drop a CycloneDX VEX file (from Grype, Trivy, or OSV-Scanner) on top of the SBOM to attach CVE data, severity badges, and a severity facet — without ever touching the network.
- CSV export of the filtered view, RFC 4180, opens cleanly in Excel.

The thing that makes it different

Every byte stays in your browser.
The page works with the network cable unplugged.
No telemetry, no CDN fonts, no outbound calls — there's a build-time purity-check that fails CI if anyone accidentally introduces one.
You can literally double-click dist/index.html, and it just works.
For regulated environments, that's the whole point.
There is no backend.

Two ways to run it:

1. No server at all

```plain
# Grab the latest release artifact + checksum
mkdir blitsbom && cd blitsbom
curl -fLO https://github.com/no42-org/blitsbom/releases/latest/download/dist.zip
curl -fLO https://github.com/no42-org/blitsbom/releases/latest/download/dist.zip.sha512

# Verify integrity (exits non-zero if the bundle was tampered with)
sha512sum -c dist.zip.sha512
```

```plain
unzip dist.zip
open index.html      # macOS
xdg-open index.html  # Linux
```

2. Docker, against a published image
```plain
docker run --rm -p 8080:80 ghcr.io/no42-org/blitsbom:latest
```

Where to find it

- Repository: https://github.com/no42-org/blitsbom
- Demo: https://blitsbom.eu
- License: MIT
- Issues, requests, weird SBOMs that crash it: GitHub issues are open. CycloneDX XML and SPDX 3.x aren't supported yet — file an issue if you need them.

If you've been wanting a way to just look at an SBOM without onboarding a platform, give it a try.
Drop a file on the page.
That's it.
