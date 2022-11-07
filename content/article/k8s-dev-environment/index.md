---
title: "A cookbook for a K8s playground"
date: "2022-02-11"
author: "Ronny Trommer"
categories: ['technology']
tags: ['k8s', 'playground']
noSummary: false
---

In my last weeks, I had to work with deployments of OpenNMS with Kubernetes.
Instead of spending dollars on cloud providers for my lab, I've bought a beefy cheap box for my home network for less than 1.500,-€ about a year ago.
It saved me probably already more than I would have spent on similar resources in the cloud for my playgrounds.
It has an Intel(R) Core(TM) i9-10880H CPU, 64 GB RAM, and 2 TB SSD which has enough steam to run VMware ESXi on it.
The main goal for this lab is, to have something you can quickly ditch into the bin and rebuild from scratch without worrying, and at the beginning of something new, you'll break it a lot for sure :)

I've quickly found [k0s](https://k0sproject.io/) which made it super easy to deploy a 3 node cluster in VMs.
All you need are 3 Ubuntu machines, SSH access, and following the ["Install using k0sctl"](https://docs.k0sproject.io/v1.23.3+k0s.0/k0sctl-install/) instructions.
With a 3 node cluster I need shared storage, I've found a few descriptions using good old NFS which sounds good for my needs.
It makes it also very easy to get access to the storage from other systems and it seems it can make my life easier.
I've used [MetalLB](https://metallb.universe.tf/) to get traffic into my cluster, which is also mentioned in the k0s docs.
It is a pretty straightforward setup when you use kustomize.

I like Traefik in my current Docker environments, especially when you use Let's Encrypt as I do.
Here is the cookbook for my future self and some people who want to break stuff as well :)

## Let's start with shared storage, NFS for the rescue

Having more than 2 K8s nodes which can run pods, gets you a bit closer to what happens in the real world.
I describe using NFS as shared storage and I've exported a shared directory in `/data`.

```
/data *(rw,no_root_squash,insecure,async,no_subtree_check,anonuid=1002,anongid=1002)
```

Installing the NFS provisioner comes with a Helm chart and is pretty straightforward.

Add the NFS storage provisioner to your Helm repository.
```
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner
```

Install and configure the NFS provisioner and adjust the `my-nfs-server` and the `/data` path accordingly. 
```
helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
  --set nfs.server=my-nfs-server \
  --set nfs.path=/data
```

## There is nothing without networking

Deploying a pod is one piece, but actual serving traffic is a different one.
[MetalLB](https://metallb.universe.tf/) is pretty awesome and offers L2 and L3 load balancing services for your cluster.
I've started with the simple L2 approach to get things done.
The fact of having a per node traffic bottleneck is a luxury problem I don't have right now :)
Configuring and deploying MetalLB is similar, I use kustomize and a `configmap.yaml` file.
Give it an IP range from your local network, and you are good to go.
I have these files in a `metallb` folder which you can dump into a GitHub repo.

```yaml
---
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 192.168.0.128-192.168.0.191

```

Create a `kustomization.yaml` in the same folder as the `configmap.yaml` file.

```yaml
---
# kustomization.yml
namespace: metallb-system

resources:
  - github.com/metallb/metallb/manifests?ref=v0.11.0
  - configmap.yaml
```
So all you need to do for a deployment is run the kustomize build command:

```yaml
cd metallb
kustomize build | kubectl apply -f -
```

## Serving HTTP with TLS

I want to deploy web services with HTTP and TLS.
I'm using [Traefik](https://doc.traefik.io/traefik/) with [Let's Encrypt](https://letsencrypt.org) in my docker-compose stacks.
I've described this use case [here](/article/docker-traefik-letsencrypt/).
Having the same in my k8s playground would be nice.

To get Let's Encrypt certificates, I've used the TLS challenge.
The traffic comes into my network with a simple port forwarding for HTTP/HTTPs to the assigned ingress service IP from my Traefik deployment.
I've stored the certificates in volume, that way I can reuse them and don't have to recreate them all the time when pods restart.
It was very helpful having two certificate resolvers, one I've called `le-staging` and the other one `le`.
I can use the `le-staging` resolver for troubleshooting and first trials, without worrying to hit the Let's Encrypt rate limits.

The default TLS options are here to get a better [SSL Labs](https://www.ssllabs.com/9) rating.

The Traefik deployment is done using a Helm chart and customize it with a `values.yaml` file:

```yaml
---
logs:
  general:
    level: INFO
  access:
    enabled: true
    format: json
persistence:
  enabled: true
  name: traefik-data
  accessMode: ReadWriteOnce
  size: 128Mi
  storageClass: nfs-client
  path: /data
resources:
  requests:
    cpu: "100m"
    memory: "50Mi"
  limits:
    cpu: "300m"
    memory: "150Mi"
tlsOptions:
  default:
    sniStrict: true
    preferServerCipherSuites: true
    minVersion: VersionTLS12
    cipherSuites:
      - TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256
      - TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
      - TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
      - TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
      - TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305
      - TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305
    curvePreferences:
      - CurveP521
      - CurveP384
additionalArguments:
  - '--global.sendanonymoususage=false'
  - '--certificatesresolvers.le-staging.acme.tlschallenge=true'
  - '--certificatesresolvers.le-staging.acme.email=<your-mail-address>'
  - '--certificatesresolvers.le-staging.acme.storage=/data/acme-staging.json'
  - '--certificatesresolvers.le-staging.acme.caserver=https://acme-staging-v02.api.letsencrypt.org/directory'
  - '--certificatesresolvers.le.acme.tlschallenge=true'
  - '--certificatesresolvers.le.acme.email=<your-mail-address>'
  - '--certificatesresolvers.le.acme.storage=/data/acme.json'
  - '--certificatesresolvers.le.acme.caserver=https://acme-v02.api.letsencrypt.org/directory'
  - '--entrypoints.web.http.redirections.entryPoint.to=:443'
  - '--entrypoints.web.http.redirections.entryPoint.scheme=https'
  - '--entrypoints.web.http.redirections.entrypoint.permanent=true'
```

So all you need now is to deploy an ingress route custom resource definition like this:

```yaml
---
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: <an-ingress-route-name>
spec:
  entryPoints:
    - websecure
  routes:
    - kind: Rule
      match: Host(`<your-fqdn-here>`)
      services:
        - kind: Service
          name: <name-of-your-service>
          port: 80
  tls:
    certResolver: le
```

Traefik takes care of the cert handling.
In case you need Let's Encrypt troubleshooting, the site [letsdebug](https://letsdebug.net/) helped me quite a lot to figure things out.
Watch out if you have IPv6 services reachable, your cluster in this setup is IPv4 only.
IPv6 is preferred which leads to weird behaviors getting Let's Encrypt certificates for FDQNs published with IPv6 in DNS.  
So hope this helps, greetings to my future self from the past and anyone else who find this useful.

gl & hf
