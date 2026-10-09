# Copyright 2026 Ronny Trommer <ronny@no42.org>
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

# The Hugo version lives here and nowhere else.
FROM ghcr.io/gohugoio/hugo:v0.167.0@sha256:7bb99a126eddeea8fbfaacedc5ef6708805411bdeaa01e668405a137fd02d048 AS build
# Hugo writes resources/_gen and a lock file into the source tree.
USER root
WORKDIR /src
COPY . .
RUN hugo --panicOnWarning --destination /public

FROM nginxinc/nginx-unprivileged:1.31-alpine@sha256:b9241c6e7b8e9a862f129d8d4199ab64b10390949a78bdd5603379b32c844083
LABEL org.opencontainers.image.source="https://github.com/indigo423/blog.no42.org"
LABEL org.opencontainers.image.description="blog.no42.org static site"
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /public /usr/share/nginx/html
EXPOSE 8080
