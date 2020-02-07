---
title: "Docker build and cache invalidation"
date: "2019-05-15"
categories: ['Container', 'Technology']
tags: ['docker', 'caching']
author: "Ronny Trommer"
noSummary: false
---

Right now I'm working with my work mates @opennms integrating the docker image building in our CI/CD environment.
We build our container image based on CentOS and we noticed the caching doesn't work for ${reasons}.

Running a `docker build -t myimage .` ended up always in installing packages from the official yum repositories even we haven't changed anything in the Dockerfile.

To understand things better, I went back to drawing board and started with a simple example and rebuilding things step by step to understand when gets the docker build cache unnecessarily invalidated.

The section [Leverage build cache](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#leverage-build-cache) with especially this section was important to me:

> Aside from the ADD and COPY commands, cache checking does not look at the files in the container to determine a cache match. For example, when processing a RUN apt-get -y update command the files updated in the container are not examined to determine if a cache hit exists. In that case just the command string itself is used to find a match.

So this means the outcome of a RUN command doesn't invalidate a cache it's purely checked against the command string itself to find a match.

So lets start with a simple example:

{{< gist indigo423 f9bda3e15d68c37ac454e39b3e508853 >}}

Ok testing the build, the initial build works as expected and downloads wget from CentOS mirrors and installs it.
The second run hits the caches and finishes in under a second.

[![Caching yum install](https://asciinema.org/a/246322.svg)](https://asciinema.org/a/246322)

We can now change the output in our last echo command and it will use the cache for the yum install wget command. Only the last layer would be rebuild which is quick and works as expected.

We have added some build arguments when running in CI/CD which injects some information like the build number which ends up in labels, so we can give some hints which build created this artefact you have running.

{{< gist indigo423 15bf81f434f518a7ca40407aad2bc142 >}}

Running without any changes is not a big deal and caching works as expected.

[![Caching with build argument](https://asciinema.org/a/246332.svg)](https://asciinema.org/a/246332)

Ok what happens if we inject a build argument like the build number and what is the effect on the cache.

[![Effect on cache with argument](https://asciinema.org/a/246353.svg)](https://asciinema.org/a/246353)

By observing the behaviour, you can see changing the build argument invalidates the layer above the RUN directive, which has as consequence to rebuild all following layers. 

If you move the Line 3 `ARG BUILD_NUMBER` to the end right before the LABEL you can change it and you get cache hits from the more expensive tasks at the top.

{{< gist indigo423 44543ab21fc690bba0ba77827a112176>}}

In conclusion order in Dockerfile matters and it make sense to group logical commands in RUN statements to make caching more efficient while working on your Dockerfiles.

Happy caching.














