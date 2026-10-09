# Copyright 2026 Ronny Trommer <ronny@no42.org>
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

IMAGE          ?= blog.no42.org:local
PORT           ?= 8080
REGISTRY_IMAGE ?= ghcr.io/indigo423/blog.no42.org
SHA            ?= $(shell git rev-parse --short=7 HEAD)

.PHONY: build serve run stop smoke publish

build:
	docker build --pull -t $(IMAGE) .

serve:
	hugo server

run:
	docker run -d --rm --name blog-local -p $(PORT):8080 $(IMAGE)
	@for i in $$(seq 1 20); do curl -sf -o /dev/null http://localhost:$(PORT)/ && exit 0; sleep 0.5; done; \
	  echo "blog-local did not answer on port $(PORT)"; exit 1

stop:
	-docker rm -f blog-local

smoke:
	scripts/smoke.sh http://localhost:$(PORT)

publish:
	docker buildx build --push --platform linux/amd64 \
	  --sbom=true --provenance=mode=max \
	  -t $(REGISTRY_IMAGE):sha-$(SHA) -t $(REGISTRY_IMAGE):latest .
