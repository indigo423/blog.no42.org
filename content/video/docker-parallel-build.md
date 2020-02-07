---
title: "Docker and parallel builds"
date: "2016-07-09"
categories: ['Technology', 'CICD']
tags: ['docker', 'cicd']
author: "Ronny Trommer"
noSummary: true

youtube: "N3pPjYxLvkY"
---

I was listening to an interesting talk from [Laura Frank](https://twitter.com/rhein_wein) from [Codeship](https://codeship.com).
In case you build or maintain a Continuous {Integration, Delivery} environment this definitely worth watching and they describe how they used [LXC](https://linuxcontainers.org) and now [Docker](https://www.docker.com) to build their CI/CD infrastructure.

### TL;DR

Interesting to me, the description in the [YAML](https://en.wikipedia.org/wiki/YAML) file reminded me quickly on a course I needed to pass during my study in parallel computing.
The exam had one section where you had to describe parallel and sequential processes with some high level constructs.
You had to describe a given time sequence graph for processes on n processors with the primitives `BEGIN/END` for sequential parts and `COBEGIN/COEND` for parallel processes.
