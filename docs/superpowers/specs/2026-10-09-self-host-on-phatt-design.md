# Self-host blog.no42.org on phatt

Status: design under review. Revised 2026-10-09: Anubis protection and Ansible deployment.

## Goal

Move blog.no42.org from Netlify to phatt.labmonkeys.space.
The main driver is control: the blog runs as one more app on phatt, with the same Traefik, logs and monitoring as the other services.
Parity with every Netlify feature is not a goal.

## Success criteria

- `https://blog.no42.org` is served by phatt with a valid Let's Encrypt certificate, over IPv4 and IPv6.
- Every URL in the current `sitemap.xml` returns the same status and content as on Netlify.
- `index.xml` (RSS) and the 404 page work as before.
- `https://no42.org/<path>` and `https://www.no42.org/<path>` return a 301 to `https://blog.no42.org/<path>`.
- Publishing stays a merge to `main`. The change is live within about 5 minutes.
- Every PR gets a green or red build check in GitHub Actions.
- Browsers pass an Anubis challenge before they see the blog. Feed readers fetch every feed and the sitemap without a challenge.

## Current state

- Netlify builds `main` with Hugo 0.167.0 (`HUGO_VERSION` in `netlify.toml`) and creates a deploy preview per PR.
- DNS for `no42.org` is at INWX.
  - `blog.no42.org` is a CNAME to `blog-no42-org.netlify.com` (TTL 120).
  - `no42.org` and `www.no42.org` are A records to Netlify's load balancers (TTL about 1 hour).
  - `netlify.toml` redirects both to `https://blog.no42.org`.
  - MX and TXT records on `no42.org` belong to mail and verification services and must not change.
- phatt runs Ubuntu 26.04 on x86_64.
  - Each app lives in `/etc/docker/<name>/compose.yml` and runs as the systemd unit `docker-compose@<name>`. The unit runs `docker compose up` in the foreground with `Restart=always`.
  - Traefik v3 in `/etc/docker/ingress` owns ports 80 and 443. It reads Docker labels (`exposedbydefault=false`), redirects HTTP to HTTPS and issues certificates with the `myresolver` HTTP-01 resolver.
  - Apps join the external `public-ingress` network.
  - Anubis instance `anubis-no42` (`/etc/docker/anubis`) protects several apps through the Traefik middleware `anubis-no42@docker` (forwardAuth).
    Its policy challenges only `Mozilla|Opera` user agents, allows known good crawlers (`_allow-good`) and allows the Kuma monitor by IP (`217.154.153.205/32`).
- Anubis and the compose files of the protected apps on phatt are managed by Ansible: the `anubis` role in `~/workbench/ansible_collections/werkzeughalle`.
  - Per-host data lives in `host_vars/phatt/anubis.yaml`: `anubis_instances` (`redirect_domains`, `allow_rules`) and `anubis_managed_projects`.
  - Compose templates live in `roles/anubis/templates/managed/phatt/<project>/compose.yml.j2`.
  - The role restarts managed projects whose files changed. It does not enable the systemd unit of a new project.
  - `roles/anubis/tests/acceptance.sh` checks the protected sites in production.
- The GitHub repository `indigo423/blog.no42.org` is public.

## Decisions

| Topic | Decision | Reason |
|---|---|---|
| Deploy model | CI builds a container image and pushes it to GHCR. phatt pulls it. | GitHub needs no access to phatt. Each deploy is an immutable, inspectable artifact. Rollback means pinning a tag. |
| PR previews | None. A CI build check replaces them. Previews are local (`make serve`). | Least moving parts. Nothing extra runs on phatt. |
| Anubis | In front of the blog, through the existing `anubis-no42@docker` middleware. Feeds and the sitemap are allowed for every client. | Same protection as the other public apps. The allow rule keeps web-based feed readers working. |
| Link previews | Accepted loss for bots that send a `Mozilla` user agent, such as LinkedIn. | Allowing them would mean exempting HTML pages from the challenge. |
| phatt configuration | Ansible, in the `werkzeughalle` collection. The blog becomes a managed project of the `anubis` role. A small new role installs the update timer. | phatt stays reproducible. It follows the existing pattern for protected apps. |
| Architecture | `linux/amd64` only. | phatt is the only target. |
| DNS changes | Done by hand in the INWX UI. | One-time change. An API integration is not worth it. |

## Part 1: Build, image and CI

### Dockerfile

Multi-stage build in the repository root.

1. **Build stage:** the official Hugo image, pinned to v0.167.0 by digest. It copies the repository and runs `hugo --minify --panicOnWarning`.
   This image is the single source of the Hugo version.
2. **Runtime stage:** `nginxinc/nginx-unprivileged:alpine`, pinned by digest. It contains only the built `public/` directory and `nginx.conf`.
   It runs as non-root and listens on port 8080. No build tools are included.

The build stage must provide Hugo Extended, because Bilberry compiles Sass. The plan verifies this before the image choice is final.

A `.dockerignore` keeps the build context small: it excludes `.git`, `public/`, `docs/`, `_bmad/`, `_bmad-output/`, `.claude/`, `.idea/` and `node_modules/`.

### nginx.conf

- Serve `public/` as the document root.
- `error_page 404 /404.html`.
- `Cache-Control: public, max-age=31536000, immutable` for fingerprinted assets (file names with a content hash, as emitted by Hugo Pipes).
- Short caching (`max-age=300`) for HTML, `index.xml`, `index.json` and `sitemap.xml`.
- No TLS, no compression. Traefik handles both.

### Makefile

| Target | Action |
|---|---|
| `make build` | Build the image locally as `blog.no42.org:local`. Same path as CI and deploys. |
| `make serve` | Run `hugo server` with the local Hugo for previewing. |
| `make run` | Start the built image detached as container `blog-local` on `localhost:8080`. |
| `make stop` | Stop and remove `blog-local`. |
| `make smoke` | Run the smoke test against a running image (default `http://localhost:8080`). |

CI calls these targets and never calls `docker` or `hugo` directly.

### Smoke test

A small shell script (`scripts/smoke.sh`) that checks a base URL:

| Request | Expected |
|---|---|
| `/` | 200 |
| `/article/opennms-oci/` | 200 |
| `/index.xml` | 200, content type XML |
| `/does-not-exist/` | 404 with the Hugo 404 page |

### GitHub Actions

All actions are pinned by commit SHA with the full version in a trailing comment. Dependabot keeps them current (`github-actions` ecosystem).

- **Workflow `build` on `pull_request`:** check out with submodules, then `make build`, `make run`, `make smoke` and `make stop`. This is the required check for merging.
- **Workflow `publish` on push to `main`:** the same steps, then push to `ghcr.io/indigo423/blog.no42.org` with the tags `sha-<short-sha>` and `latest`. The push includes an SBOM and build provenance attestation.
  The workflow only gets `packages: write` and the permissions the attestation needs.

## Part 2: Runtime on phatt

All files on phatt come from the `werkzeughalle` Ansible collection. Nothing is created by hand.

### Compose project `blog`

Template `roles/anubis/templates/managed/phatt/blog/compose.yml.j2`, rendered to `/etc/docker/blog/compose.yml`:

- Service `blog`, image `ghcr.io/indigo423/blog.no42.org:latest`.
- Network `public-ingress` (external).
- Healthcheck: HTTP GET on `http://localhost:8080/`.
- The GHCR package is public, so phatt needs no registry credentials.

`host_vars/phatt/anubis.yaml` gets a new entry `{ name: blog, file: compose.yml }` at the end of `anubis_managed_projects`.

### Traefik labels

- `traefik.enable=true`, `traefik.docker.network=public-ingress`.
- Router `blog`:
  - rule ``Host(`blog.no42.org`)``, entrypoint `websecure`, `tls.certresolver=myresolver`.
  - middlewares, in this order: `anubis-no42@docker`, `blog-compress`, `blog-headers`.
- Middleware `blog-compress`: Traefik `compress`.
- Middleware `blog-headers`:
  - `stsSeconds=31536000` (same as Netlify today).
  - `contentTypeNosniff=true`.
  - `referrerPolicy=strict-origin-when-cross-origin`.
- Router `no42-redirect`:
  - rule ``Host(`no42.org`) || Host(`www.no42.org`)``, entrypoint `websecure`, `tls.certresolver=myresolver`.
  - middleware `no42-redirect`: `redirectregex` from `^https?://(www\.)?no42\.org/(.*)` to `https://blog.no42.org/${2}`, `permanent=true`.
  - No Anubis. The router only answers with a 301.
  - It points at the `blog` service. The redirect answers before the request reaches it.
- Service `blog`: `loadbalancer.server.port=8080`.

### Anubis instance `no42`

Changes in `host_vars/phatt/anubis.yaml`, instance `no42`:

- Add `blog.no42.org` to `redirect_domains`, so the challenge can send visitors back to the blog.
- Add an allow rule:

  ```yaml
  # Feed readers and sitemap fetchers, including web-based readers that send Mozilla.
  # forwardAuth passes the query string in the path, so end anchors allow '?'.
  - name: allow-blog-feeds
    hosts: [blog.no42.org]
    path_regex: '(^|/)(index\.xml|index\.json|sitemap\.xml)(\?|$)'
  ```

  This covers the main feed, every section, category and tag feed (`/<path>/index.xml`), `index.json` and `sitemap.xml`.

Everything else uses the existing policy: known good crawlers pass, the Kuma monitor passes by IP, scanner paths are denied, and `Mozilla|Opera` clients get the challenge.

### Enabling the unit

The `anubis` role restarts changed projects but does not enable new units.
The plan adds a task that enables `docker-compose@<name>.service` for every managed project (`enabled: true`). For existing projects this is a no-op.

### Updates

New role `blog-update` in the same collection, with playbook `blog-update.yaml` for host `phatt`. It installs:

- `blog-update.service` (oneshot, root):
  1. Record the current image ID of `ghcr.io/indigo423/blog.no42.org:latest`.
  2. Run `docker compose pull` in `/etc/docker/blog`.
  3. If the image ID changed, run `systemctl restart docker-compose@blog`.
  Failures are logged to the journal. The running container stays up.
- `blog-update.timer`: every 5 minutes, with `Persistent=true`. The role enables and starts it.

The service restarts the unit instead of calling `docker compose up -d`, because the unit owns a foreground `docker compose up` process.

### Rollback

Set the image to `ghcr.io/indigo423/blog.no42.org:sha-<old>` in the compose template, run the `anubis` playbook for phatt, and the role restarts the project.
For an emergency, the same change can be made by hand in `/etc/docker/blog/compose.yml` followed by `systemctl restart docker-compose@blog`. The next Ansible run then overwrites it, so the template must follow.
A pinned SHA tag never changes, so the timer does not roll it forward.
To resume normal updates, set the tag back to `latest`.

### Monitoring

Add two HTTP monitors to the existing Uptime Kuma instance:

- `https://blog.no42.org`, expecting 200. The Anubis policy allows Kuma by IP.
- `https://no42.org`, expecting a 301 to `https://blog.no42.org/`.

## Part 3: Cutover

1. **Repo PR:** Dockerfile, `nginx.conf`, Makefile, smoke test, workflows and Dependabot config. Netlify keeps serving the site. After the merge, CI publishes the first image. The owner sets the GHCR package to public in the GitHub UI.
2. **Deploy on phatt:** a PR in the `werkzeughalle` collection with the Part 2 changes.
   After review, run `ansible-playbook anubis.yaml --limit phatt` and `ansible-playbook blog-update.yaml`, with `--check --diff` first.
   The owner runs the playbooks, or explicitly allows them to be run.
   Restarting Anubis briefly interrupts the apps it protects.
3. **Verify before DNS:** with `curl --resolve blog.no42.org:443:<phatt-ip> -k`, against both the IPv4 and the IPv6 address:
   - Fetch every URL in the live `sitemap.xml` from Netlify and from phatt. Compare status codes and response bodies.
   - Use a non-browser user agent (curl's default) for the comparison. Those requests skip the challenge.
   - Check `index.xml`, the 404 page and the `no42.org` redirect.
   - With `-A 'Mozilla/5.0'`, check that `/` returns the Anubis challenge and `/index.xml` still returns the feed.
   Differences block the cutover until they are explained or fixed.
4. **DNS at INWX** (owner):
   - One day before: lower the TTL of the three records to 300.
   - `blog.no42.org`: CNAME to `phatt.labmonkeys.space`.
   - `www.no42.org`: CNAME to `phatt.labmonkeys.space`.
   - `no42.org`: A `217.154.153.205` and AAAA `2a01:239:431:f100::1`.
   - Leave all other records unchanged.
5. **After the switch:**
   - Confirm Traefik issued certificates for all three names.
   - Repeat the step 3 checks without `--resolve` and `-k`.
   - Check the response headers (HSTS, nosniff, referrer policy, compression).
   - Run `roles/anubis/tests/acceptance.sh phatt`, which now includes the blog cases.
   - Open the blog in a browser and pass the challenge once.
   - Confirm both Kuma monitors are green.
6. **Rollback window:** the Netlify site stays active for one week. If anything fails, point the three records back to their Netlify values.
7. **Cleanup after one week:** a PR removes `netlify.toml` and the Netlify badge and updates the README. The owner deletes the Netlify site.

## Failure modes

| Failure | Effect | Handling |
|---|---|---|
| CI build fails (Hugo error or warning, submodule problem) | No image is pushed. phatt keeps the last good version. | Red check on the PR or on `main`. |
| Bad image published (builds, renders wrong) | Wrong content live within 5 minutes. | Smoke test catches the obvious cases. Otherwise roll back by pinning the previous SHA tag. |
| GHCR unreachable or pull fails | No update. | Logged in the journal. The next timer run retries. |
| Container unhealthy or crashed | Site down until restart. | `Restart=always` on the unit. Kuma alerts. |
| Anubis down or unhealthy | Traefik's forwardAuth fails, so browsers get an error instead of the blog. Feeds are affected too, because every request goes through the check. | `Restart=always` on the Anubis unit. Kuma alerts. Same exposure as the other protected apps. |
| Anubis policy blocks a legitimate client | That client gets a challenge or a 403. | Add a host-scoped allow rule in `host_vars/phatt/anubis.yaml`. |
| Certificate not issued after DNS switch | TLS errors for visitors. | Detected in cutover step 5. Roll DNS back to Netlify, fix, retry. |

## Testing

- **Local:** `make build`, `make run`, `make smoke`, `make stop`.
- **CI:** the smoke test on every PR and on every push to `main`.
- **Before cutover:** the sitemap comparison against Netlify (cutover step 3).
- **Anubis:** new cases in `roles/anubis/tests/acceptance.sh` for `blog.no42.org`:
  - `/` with a `Mozilla` user agent: challenge.
  - `/index.xml`, `/tags/opennms/index.xml` and `/sitemap.xml` with a `Mozilla` user agent: pass.
  - `/` with a curl user agent: pass.
  - `https://no42.org/` and `https://www.no42.org/`: 301 to `https://blog.no42.org/`.
  The role's `render.yaml`, `test-policy.sh` and `test-compose.sh` must still pass with the new data.
- **After cutover:** the same comparison over real DNS, plus certificate, header and redirect checks.

## Out of scope

- Per-PR preview sites.
- INWX API automation.
- `arm64` images.
- Moving `bilberry-hugo-theme` to a submodule or Hugo module.
