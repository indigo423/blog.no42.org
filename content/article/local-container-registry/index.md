---
title: "Running a private container registry for testing"
date: "2023-02-14"
categories: ['container', 'microservices', 'homelab', 'tls' ]
tags: [ 'container' , 'tls', 'registry', 'ssl', 'dns' ]
author: "Ronny Trommer"
noSummary: false
---

When I signed up for my DockerHub account in 2013, I never thought sooner than later everything ends up in a container image as it is today. DockerHub was the first public free as in free beer registry to distribute your container images. Containers are now everywhere, and DockerHub, a corporate entity running and funding DockerHub, introduced usage limits for the free tier and started commercializing its registry service. I need to play with software in a micro-service architecture on a platform like Kubernetes, and these limits can be daunting.

In this guide, I want to remind myself how to run a local private registry in a home lab with a valid TLS certificate using Let’s Encrypt. The registry is on a private network, and I use the Let’s Encrypt DNS challenge mechanism to get a valid certificate. As an example, I control DNS for the no42.org domain, and I want to use cri.no42.org as my internal home lab registry.
To keep it simple, I describe it with docker-compose.

I’ve created a local project directory `registry` which contains all the files I need to run it. The directory structure is like the following:

```bash
❯ tree -L 3
.
├── certs
│   └── cri.no42.org
│       ├── cert1.pem
│       ├── chain1.pem
│       ├── fullchain1.pem
│       └── privkey1.pem
├── docker-compose.yml
└── registry
    └── docker
        └── registry
```

The `certs` directory contains the certificates and the key from Let’s Encrypt. The `registry` folder persists the data for the registry and the metadata. I run the registry on 443, allowing me to use it with docker pull | push natively.

```yaml
---
version: '3'
services:
  registry:
    image: registry:2
    container_name: registry
    environment:
      - REGISTRY_HTTP_ADDR=0.0.0.0:443
      - REGISTRY_HTTP_TLS_CERTIFICATE=/certs/cr.no42.org/fullchain1.pem
      - REGISTRY_HTTP_TLS_KEY=/certs/cr.no42.org/privkey1.pem
    volumes:
      - ./registry:/var/lib/registry
      - ./certs:/certs
    ports:
      - '443:443/tcp'
```

Before running the registry I need certificates. 

```
cd certs
docker run -it -v $(pwd):/etc/letsencrypt/archive certbot/certbot certonly --preferred-challenges dns --manual
```

Following the interactive dialog and entered the domain I wanted to use. I get prompted to create a DNS TXT record to verify ownership with something like this:

```
_acme-challenge.cri.no42.org.

with the following value:

WDvzxagOMbe4GSSR75rIvcYNUw14TWZyCY9egDJCEmA
```

I would recommend using a short TTL like 300s when you create the TXT record. It will make it easier if you make a mistake and you have to redo it again. They provide a [handy link](https://toolbox.googleapps.com/apps/dig/#TXT/_acme-challenge.cri.no42.org) which allows verifying if the text record is populated accordingly.
Another method is using your local DNS resolver using a command like this:

```
nslookup -type=TXT _acme-challenge.cri.no42.org
```

When I receive the certificate and keys on my disk, I need to verify the file names and directory paths match with the environment variables in the `docker-compose.yml` file:

```yaml
environment:
  - REGISTRY_HTTP_TLS_CERTIFICATE=/certs/cri.no42.org/fullchain1.pem
  - REGISTRY_HTTP_TLS_KEY=/certs/cri.no42.org/privkey1.pem
```

Make sure the name resolution for the internal registry host is working. In my case `cri.no42.org` resolves to an internal address. When the registry is running you can verify the certificate with your browser connecting to https://cri.no42.org. It is an empty page but you should connect to it with HTTPS without any complains.

I can now use the registry with tagging the images accordingly, like here in this quick example:

```
docker pull busybox
docker tag busybox cri.no42.org/busybox
docker push cri.no42.org/busybox
```

gl & hf


Image by [Ro Ma](https://pixabay.com/users/roma1880-2180741/?utm_source=link-attribution&amp;utm_medium=referral&amp;utm_campaign=image&amp;utm_content=3859388) from [Pixabay](https://pixabay.com//?utm_source=link-attribution&amp;utm_medium=referral&amp;utm_campaign=image&amp;utm_content=3859388)
