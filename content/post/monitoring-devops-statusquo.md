---
title: "Monitoring DevOps and the Status Quo"
date: "2017-03-09"
categories:
    - "post"
tags:
    - "monitoring"
    - "devops"
    - "docker"
    - "cultur"
cardheaderimage: "/images/default.jpg"
cardbackground: "#263654"
"author":
    name: "Ronny Trommer"
    description: "Writer of stuff"
    website: "https://blog.no42.org"
    email: "ronny@no42.org"
    twitter: "https://twitter.com/indigo423"
    github: "https://github.com/indigo423"
    image: "/images/avatar-64x64.png"
---

As most of us noticed a few companies changed our perspective how to develop software and deploy them as a service.
There are quite a few changes between selling every year a box with 10 CD's and develop and deliver your software as a service.
This article is a collection of thoughts and ideas I had and wanted to be written.

## Who cares about a version number?

User give a shit about version numbers anymore, all what matters needs to be focused on the user.
Great user experience, functionality and a good "Effort-to-Outcome" ratio to solve your problems will make your software successful.

Usability improvements, features and fixes are delivered immediately and this is where all the fuzz about continuous delivery and the devops culture kicks in.

## Pets and Cattle

The virtualisation technology forced hardware manufacturer to change their mindsets to make their boxes to behave as good cattle instead of being a pet. The same will happen to Linux distributions and configuration management tools with the fuzz about containers, I believe they didn't really noticed yet.
You want hardware as commodity, you need a Linux kernel as commodity and the diversity and history of Linux distributions are in your way.

All the ugly ifdefs in configuration management tools just make your service run on a specific distributions using yum, apt, or apk and the nasty glue you have to write to configure your service to run in a container is still painful. Applications aren't often built to run in such environments and you have to hack a lot of stuff - but this is a whole different story.

## Monitoring is important

Everybody tells you monitoring is an important thing.
You can only improve what you measure and you need to know where things go down the hill.

Current monitoring tools felt behind with todays needs.
Most of them allow you only to think in terms of bare metal boxes like hosts and IP addresses. Some tools do only one part, the performance management XOR fault management and you need both. In case you have two, you have to maintain and glue two tools together and you want alerting - and you don't want to maintain them twice.

## Monitoring needs to change

Monitoring tools need to be changed to be part of the software development and service deployment process.

Most of them are built by people with operation background and not software development background. We need more software development background in monitoring tools. The operation background is often quite good. 

We should make monitoring a part in our Test suits. Why not define an "Operation Test" behind an "Integration Test" and let it run in your monitoring tool?
Additionally monitoring people should make clear for the user what is the difference between "Performance Management" and "Application Profiling".

Monitoring people should adapt the terms like whitebox and blackbox testing for operational services. For examples when you test the error code of a landing page for a web application it is a blackbox test. When you measure internal application specific entities with JMX you have white box test.

## Fight against Alarm Fatigue

Monitoring applications tend to overmonitor your environment by default. You measure a lot, it tells you a lot but you oversee the important things in all the noise. The signal to noise ratio is too high and people become alarm fatigue. Rule #1 in alerting: "Notify only someone when human interaction is really necessary."

## Applications and Monitoring

With deploying services in containers the whole idea of provisioning need to be changed.
Monitoring tools should allow you to model "Application Service" with associated performance- and availability metrics. The alerting should also be possible on those "Application Services". Performance metrics and operational tests are driven by high level services mostly through ReST API's. Containers will come and go providing resources to this "Application Service". They can't no longer be treated as long living hosts with a static assigned IP address.

## Monitoring need to be more intelligent

When talking about intelligence, everybody is thinking about Artificial Intelligence. It is much simpler in monitoring, cause they are ridicolous stupid at the moment and you don't have to throw AI against the problem.
Diagnose from bottom up, low complexity to higher complexity, which means also cheap to expensive in the sense of needed hardware and network resources.
We want to monitor high level services, a monitoring tool can help diagnosing a problem by himself and can provide a lot of useful information, for example:

We test a 200 OK code on https://mycloudy.webapp.acme.com for 200 OK with a timeout of 2 seconds.

Instead of just giving a "Service Down", the monitoring tool can diagnose itself with a few cheap and simple tests.
Diagnose the problem from the perspective of the monitoring system to give a NOC guy an overview what went wrong and safe him time.
Just an example for the test above, was the connection refused or was the HTTP error code just something else than 200 OK?

### Connection refused

1. Can IPv4/IPv6 addresses be looked up by the host name cloudy.webapp.acme.com?
2. Can the IPv4/IPv6 addresses be reached over ICMP?
3. If not was is the trace route output for IPv4/IPv6 addresses
4. If possible give me a link to logs from last hop nodes in the time area +/- service polling interval
5. When they can be reached is the TCP port 443 port open
6. If not give me a link to warning+ logs from the web server in the time area +/- service polling interval

### Not 200 OK

1. Use the resolved IPv4/IPv6 address of the web server and give me  a link to warning+ logs from the web server in time area +/- service polling interval

This is not something where you need a rocket scientist for.

Most of the things are configured in permanent monitoring, e.g. ICMP or DNS lookups, but are mostly just necessary when you need to diagnose a problem. You only care about them, when a high level application service fails. You can do a similar thing with response times. You really care about your application response time for a longer period of time. Just when it went through the roof you have to ask immediately, was the network path slow (ICMP)? Was the name lookup slow(DNS)? Was the web server response slow(HTTP)?
