---
title: "NetBox in Kubernetes"
date: "2026-07-07"
tags: ['netbox', 'container', 'kubernetes', 'k8s']
author: "Ronny Trommer"
---

I really like [NetBox](https://netboxlabs.com/) and call myself a NetBox [noob](https://de.wikipedia.org/wiki/Neuling#Noob/Boon) too dangerous in many places.
I'm currently working on my first [NetBox plugin for OpenNMS](https://github.com/no42-org/netbox-opennms-plugin).
I run a mix of workloads on classic virtual machines and also in Kubernetes with containers.
The Plugin - NetBox - Kubernetes situation hit me quickly.
I’m in the lucky situation of having known [Peter Eckel](https://github.com/peteeckel) for a very long time.
He is the maintainer of the [NetBox DNS Plugin](https://github.com/sys4/netbox-plugin-dns) and his valuable advice to me was: 

> “If you really know what you are doing, otherwise don’t.”

He explained from his experience what he would do instead, and how the way the application is built creates some difficulties.
That made me curious enough to dig a bit deeper.
Here is what I learned while I researched this topic and chatting with him on the sideline about this topic.

In the beginning, the internet makes it sound simple: “Just use the Helm chart, inject your plugins via environment variables, and let it rip!”
Don't fall for it.
Here is a critical look at why NetBox and Kubernetes inherently clash, why the "plug-and-play container" promise breaks down.

### The Real NetBox Architecture (Hint: It’s Not a Microservice)

The biggest mistake newcomers make when trying to dockerize NetBox is ignoring its heritage.
If you take the installation instructions from the NetBox documentation and cut-and-paste them onto a clean Linux Virtual Machine, you get a beautifully working environment in minutes.
Why? Because NetBox is a classic, monolithic Django application.
It relies on a tightly coupled stack:
* The Web App: Django served via Gunicorn/Uvicorn.
* The Database: PostgreSQL.
* The Cache/Queue: Redis.
* The Asynchronous Workers: Django RQ.
* The Maintenance: Periodic housekeeping cron jobs.

When you spin up a VM, you see exactly how these pieces talk to each other.
When you instantly jump into Kubernetes, these pieces are abstracted into separate Pods, Services, and Persistent Volume Claims (PVCs).
When a Redis connection times out or a database lock occurs, a beginner has no visibility into why, because they missed the fundamentals of the Django state machine.

### The Plugin Nightmare: Django Isn't Dynamic

In modern SaaS tools, adding a plugin is a matter of clicking "Install" in a web UI or dropping a .jar file into a directory. NetBox plugins do not work this way. NetBox plugins are Django apps.
This introduces three structural architectural headaches for container environments:
* No Dynamic Loading: Plugins cannot be loaded on the fly. A plugin's Python code must physically reside in the environment’s site-packages before the Django process initializes. Furthermore, it must be hardcoded into the configuration.py file under the PLUGINS array.
* Database Schema Hijacking: NetBox plugins bring their own database models. This means they require database migrations (manage.py migrate). Running migrations dynamically at container startup across a distributed, auto-scaling Kubernetes cluster is a recipe for database locks and race conditions.
* No Lifecycle API: There is no built-in plugin manager API to gracefully handle plugin activation, deactivation, or schema rollbacks.

### The "Franken-Container" Anti-Pattern
To get around the static nature of Django, many engineers try to force-feed plugins to official NetBox containers at runtime.
They use *initContainers* or *entrypoint* scripts that execute `pip install netbox-plugin-xyz` when the Pod boots.

This is a critical anti-pattern that results in fragile "Franken-containers" and introduces severe operational risks.

#### The Bloat & Security Tax
Many NetBox plugins rely on external Python dependencies that require C-extensions.
To compile them, `pip` needs tools like `gcc`, `musl-dev`, or `libpq-dev`.
If you leave these compilers inside your production container, you drastically bloat your image size and massively expand your security attack surface.

#### Skyrocketing Startup Latency
If Kubernetes needs to reschedule a NetBox Pod due to a node failure or a Horizontal Pod Autoscaler (HPA) trigger, the new Pod has to reach out to PyPI, download the plugin, compile the C-extensions, and then start the application.
Your startup latency goes from seconds to minutes.
This completely breaks Kubernetes' self-healing capabilities.

#### Breaking Immutability
Containers should be completely immutable.
If you rely on fetching plugins from PyPI at boot time, what happens if PyPI goes down?
Or if an upstream dependency changes its version underneath you?
Suddenly, a routine Pod restart turns into a production outage because your container cannot build itself at runtime.

#### The Component Synchronization Problem
NetBox splits its workload across multiple distinct processes. In Kubernetes, this means you typically have:

1. Web Pods (handling user traffic)
2. RQ Worker Pods (handling background jobs like webhooks and script executions)
3. Housekeeping Pods (handling nightly cleanups)

Every single one of these components must run the exact same plugins.

**The Crash Scenario:** If a user triggers a background job provided by a plugin, the web application enqueues the job in Redis.
An RQ worker later dequeues it and attempts to import the job's callable.
If the worker environment does not have the same plugin available (or otherwise cannot import it), the job will fail with an ImportError or ModuleNotFoundError.
Depending on how the application and worker are configured, this may simply fail the job or may cause the worker process to terminate and be restarted.

Keeping these disjointed pods perfectly in sync using runtime installation scripts is a logistical nightmare.

### The Solution: The Immutable Image Pattern
Does this mean you shouldn't run NetBox in Kubernetes?
Absolutely not.
It scales beautifully in K8s—but only if you respect its architecture.
If you want to run NetBox in containers with plugins, stop trying to fix it at runtime.
You must shift everything to the build phase.
Instead of using the stock NetBox image and injecting plugins via Helm values, you have to bake your own custom, immutable image using a Dockerfile.

**Why this works**

* Errors Fail Fast: If a plugin fails to compile, it fails on your CI/CD server, not in your production cluster.
* Instant Boot Times: The Pods contain everything they need. Kubernetes can scale them up or restart them instantly.
* Perfect Sync: You deploy this single custom image tag to your Web, Worker, and Housekeeping deployments simultaneously via Helm. Total component alignment is guaranteed.

### Conclusion: A Luxurious Problem to Have

This strict architectural boundary explains exactly why issues like [netbox-chart#173](https://github.com/netbox-community/netbox-chart/issues/173) and related pull requests in netbox-docker get answered and ultimately closed the way they do.
Maintainers aren't being stubborn when they refuse to build dynamic plugin loaders or runtime hooks into the official images.
They are simply enforcing cloud-native reality: A container must be fully defined at build time.
Expecting a Kubernetes chart to safely install, compile, and sync random third-party software across a distributed cluster at runtime goes against the core philosophy of container orchestration.

Let's look at the bright side.
The reason this friction occurs so frequently is because of the sheer explosion of incredible community-driven plugins available for NetBox—covering everything from DNS management to BGP topology mapping.
Having so many amazing features available that we are forced to rethink and professionalize our container build pipelines is, quite frankly, a luxurious problem to have.
Treat NetBox like the immutable, compiled artifact it wants to be, respect the build phase, and your Kubernetes deployment will be rock solid.
