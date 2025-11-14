---
title: "How Docker Broke the Internet for Me"
date: "2025-11-14"
categories: ['Technology']
tags: ['devops', 'docker']
author: "Ronny Trommer"
noSummary: false
---

We have seen two major outages in the last weeks caused by AWS and Azure networking issues.
Both outages had a significant impact on services running in the cloud and affected a large number of users.
The self-hosting people were laughing about it, but some got struck with the recent Docker 29.0.0 release.
It simply increased the minimal API version from 1.24 to 1.44.

This change broke [Traefik](https://traefik.io/traefik) and some tooling, like the [testcontainers-java](https://testcontainers.com/?language=java).
The maintainers of Traefik already released a fix, and probably created some stress for them.
A lot of issues poped up in their GitHub repository, like this one https://github.com/traefik/traefik/pull/12256.
I felt sorry for them, many users use their stuff - including me - to drive HTTP/HTTPS traffic to their websites.
It was great to see how quickly shared workarounds.
The Traefik maintainers were able to provide and ship a fix in a new release very quickly.
All you need to do is upgrade to 3.6.1, and you are good to go again.

I ran immediately in a second issue running our container based end-to-end tests with [testcontainers-java](https://testcontainers.com/?language=java).
Running the test, I was greeted with the following error message:

```plain
23:23:25.087 [main] ERROR org.testcontainers.dockerclient.DockerClientProviderStrategy - Could not find a valid Docker environment. Please check configuration. Attempted configurations were:
	UnixSocketClientProviderStrategy: failed with exception BadRequestException (Status 400: {"message":"client version 1.32 is too old. Minimum supported API version is 1.44, please upgrade your client to a newer version"}
)
	DockerDesktopClientProviderStrategy: failed with exception NullPointerException (Cannot invoke "java.nio.file.Path.toString()" because the return value of "org.testcontainers.dockerclient.DockerDesktopClientProviderStrategy.getSocketPath()" is null)As no valid configuration was found, execution cannot continue.
```

Instead of downgrading Docker, I decided to just force the minimal API version back to 1.24.
You can do this by setting the environment variable `DOCKER_API_VERSION` to `1.24`.
This way, you can continue using the latest Docker release and avoid downgrading.

I have documented the workaround in the OpenNMS Discourse forum [End-to-End and Smoke Test execution with Docker 29.0.0 is failing](https://opennms.discourse.group/t/end-to-end-and-smoketest-execution-with-docker-29-0-0-is-failing/4675?u=indigo).
The permanent fix will be upgrading our testcontainers-java dependency to at least 2.0.2 that supports the new Docker API version.

What's dazzling to me is why project maintainers haven't seen it coming.
Docker is a widely used container runtime, and changing the minimal API version is a significant change that can have far-reaching consequences.
The question to maintainers would be why that change hasn't reached maintainers earlier.
If you are affected by this issue, I hope this workaround helps you to get back on track quickly.

Happy hacking!
