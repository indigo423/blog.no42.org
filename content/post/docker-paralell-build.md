---
title: "Docker and parallel builds"
date: "2016-07-09"
categories:
    - "post"
tags:
    - "docker"
    - "continuous integration"
    - "continuous deployment"
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

I was listening to an interesting talk from [Laura Frank](https://twitter.com/rhein_wein) from [Codeship](https://codeship.com).
In case you build or maintain a Continuous {Integration, Delivery} environment this definitely worth watching and they describe how they used [LXC](https://linuxcontainers.org) and now [Docker](https://www.docker.com) to build their CI/CD infrastructure.

[![IMAGE ALT TEXT HERE](https://img.youtube.com/vi/N3pPjYxLvkY/0.jpg)](https://www.youtube.com/watch?v=N3pPjYxLvkY)

### TL;DR

Interesting to me, the description in the [YAML](https://en.wikipedia.org/wiki/YAML) file reminded me quickly on a course I needed to pass during my study in parallel computing.
The exam had one section where you had to describe parallel and sequential processes with some high level constructs.
You had to describe a given time sequence graph for processes on n processors with the primitives `BEGIN/END` for sequential parts and `COBEGIN/COEND` for parallel processes.
