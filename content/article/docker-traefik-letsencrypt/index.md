---
title: "OpenNMS Horizon, Docker, Traefik and Let's Encrypt"
date: "2021-08-11"
categories: ['Technology']
tags: ['tools']
author: "Ronny Trommer"
noSummary: false
---
I work from home more than 6 years now and especially when you have to test a few things you start looking around.
If you've heard about k8s, k{0,3}s or Microk8s but you don't want to use it running your private blog and
you find yourself in a spot where the benefits running stuff in containers justifying the pain - this article might be something for you :)

My use case is, providing public facing web sites for my own stuff.
The setting is pretty straight forward and always the same.
You want to make XYZ web application publicly available with a Let's Encrypt TLS certificate.
Setting up TLS in XYZ web application is always differently weird and painful.
Keep it as it is lock it down and use a TLS reverse proxy instead.

The TLS reverse proxy I've named TLS ingress and used mostly nginx for it.
What I've found cumbersome was the certbot TLS Let's Encrypt dance and never liked the setup nor the maintenance.
I've ditched nginx for this job a while ago and use [Traefik](https://doc.traefik.io) in my container environments as TLS ingress pretty happily.

The Traefik killer features for me:

* Let's Encrypt built-in, I just don't have to care anymore
* Dynamic event driven service discovery using the Docker daemon when you run on the same box
* Simple configuration by just annotating my app containers with labels

If you want to give it a try, here an example running OpenNMS Horizon behind Traefik.
In this example here you run both on the same box.

I create a dedicated network bridge on my Linux box which has all the external traffic between Traefik an the app containers.

```console
docker create network public-ingress
```

Here is my `ingress` service described in a `docker-compose.yaml` which I have in a `ingress` folder.
I've created `systemd` service unit to start it up on system boot.

Replace the Let's Encrypt mail address `YOUR-MAIL-HERE` in the following configuration:

```yaml
---
version: '3'

networks:
  public-ingress:
    external: true

services:
  ingress:
    image: "traefik:v2.4"
    container_name: ingress
    command:
      - "--log.filePath=/logs/traefik.log"
      - "--metrics.prometheus=true"
      - "--metrics.prometheus.addServicesLabels=true"
      - "--accesslog=true"
      - "--accesslog.filepath=/logs/access.log"
      - "--entryPoints.metrics.address=:8082"
      - "--metrics.prometheus.entryPoint=metrics"
      - "--log.level=INFO"
      - "--api.insecure=true"
      - "--providers.docker=true"
      - "--providers.docker.exposedbydefault=false"
      - "--entrypoints.web.address=:80"
      - "--entrypoints.web.http.redirections.entrypoint.to=websecure"
      - "--entrypoints.web.http.redirections.entrypoint.scheme=https"
      - "--entrypoints.websecure.address=:443"
      - "--certificatesresolvers.myresolver.acme.httpchallenge=true"
      - "--certificatesresolvers.myresolver.acme.httpchallenge.entrypoint=web"
      # - "--certificatesresolvers.myresolver.acme.caserver=https://acme-staging-v02.api.letsencrypt.org/directory"
      - "--certificatesresolvers.myresolver.acme.email=YOUR-MAIL-HERE"
      - "--certificatesresolvers.myresolver.acme.storage=/letsencrypt/acme.json"
    volumes:
      - '/var/run/docker.sock:/var/run/docker.sock:ro'
      - './letsencrypt:/letsencrypt'
      - './logs:/logs'
    networks:
      - public-ingress
    ports:
      - "80:80/tcp"
      - "8082:8082/tcp"
      - "443:443/tcp"
```

If you just want to fiddle around and get yourself familiar how Traefik obtains TLS certificates and hand shakes, you can uncomment the CA server line above.
You will use now the staging environment and you don't get temporarily locked out for hitting the API endpoints too often.
I monitor Traefik with Prometheus, you can remove this parts if you want.

We have some [OpenNMS stacks preconfigured](https://github.com/opennms-forge/stack-play/tree/master/minimal-horizon) and explain it on a minimal example.
Set your OpenNMS web UI to use `https` instead of `http` by creating a properties file.
When you use the stack-play example you can do it like this:

```console
cd minimal-horizon
mkdir ./container-fs/opt/opennms-overlay/etc/opennms.properties.d
echo "opennms.web.base-url = https://%x%c/" > ./container-fs/opt/opennms-overlay/etc/opennms.properties.d/jetty.properties
```

Annotate OpenNMS Horizon container with the following labels.
You have to replace `YOUR-FQDN-HERE` with the public DNS name you want to have your OpenNMS reachable.
There is no reason for static port publishing anymore more, traefik routes it for you based on the `traefik.port` label.

```yaml
---
    ports:
      ## DELETE ME!!!
      ## - "8980:8980/tcp"
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.horizon.rule=Host(`YOUR-FQDN-HERE`)"
      - "traefik.http.routers.horizon.entrypoints=websecure"
      - "traefik.http.routers.horizon.tls.certresolver=myresolver"
      - "traefik.http.middlewares.sslheader.headers.customrequestheaders.X-Forwarded-Proto=https"
      - "traefik.port=8980"
```

As soon you start OpenNMS Horizon, Traefik gets notified and does all the Let's Encrypt certificate handling for your Horizon host.

So long and thanks for all the fish ...
