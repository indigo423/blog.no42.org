---
title: "Containers and Capabilities"
date: "2022-07-14"
author: "Ronny Trommer"
categories: ['technology']
tags: ['k8s', 'container', 'linux']
noSummary: false
---

I have to work with container images from time to time, and sometimes I need to do networking stuff.
Of course, you want to do this as an unprivileged user.
Especially when you mix and match with Docker or Kubernetes, it gets sometimes a bit tricky and a lot of people in our community including myself struggled on this part.
To document it for my future-self and the ones interested – here is my scenario.
I need regularly two things when I run OpenNMS tools in containers:

* *ICMP*: There is some optimized C code using JNI which runs from the Java Virtual Machine and needs to deal with ICMP echo requests and replies
* *Privileged ports*: I want to bind to privileged ports for industry standard applications, e.g. receive Syslogs or SNMP Traps.
                      To bind a listener to port `514/UDP` and `162/UDP`, it requires some extra permission for your application.

## Short version when you use containers

If you run containers where you switch the user id, all capabilities are dropped.
Yes, even the ones you have specified in your security context.

There are two ways to get around:
* Use `setcap` and add capabilities to your binary in the OCI file system.
  It will be not affected by the `--cap-drop ALL` mechanism which is happening when a user is changed.
  The two capabilities needed are *CAP_NET_RAW* for ICMP and *CAP_NET_BIND_SERVICE* to bind a privileged port.
* Modify kernel parameters which allows users in certain groups to deal with ICMP datagrams with `sysctls net_group_ping`.
  To bind a privileged port you redefine what unprivileged ports are by modifying `net.ipv4.ip_unprivileged_port_start`

Kernel parameters need to be set on container runtime, the responsibility is on the person who runs the container.
Capabilities can be backed into the file system of your OCI and your OCI publisher can do it for you.

# TL;DR

---

## ICMP to the user

You probably have used `ping` gazillion times as a non-root user without any issues, which is probably the reason you ever really cared :)
The Linux distribution you are using has solved that problem for you.
Usually, there are ways several ways to achieve this:

1. Set the *setuid* on the executive binary for the owner on the ´ping` binary which is owned by root.
   With *setuid* it runs as the user who owns the binary file instead of the user who executes it.
2. Add the *CAP_NET_RAW* capability to the binary `ping` in the file system using `setcap CAP_NET_RAW+ep /usr/bin/ping`.
3. Give the user access to the ICMP datagram socket using the `net.ipv4.ping_group_range`.
   It gives the user just enough permissions to work with ICMP echo requests and replies.
   The permission is granted by specifying a group id range.
   If your user is in a group with an id in that range, you can use it.
   When you run on old Kernels, you won't have this option with `net.ipv4.ping_group_range`.
   It was introduced [around 2011](https://lore.kernel.org/lkml/1305325333.3120.36.camel@edumazet-laptop/) and is a bit hard to find in the Linux kernel releases.

Running ping as root using *setuid* is a bad idea, which is the reason you'll find option 2 or 3 are applied in modern Linux distributions.
If your binary needs to deal with ICMP echo requests and replies as a non-root user, you can choose between these options.
They have some pros/cons as always, here some from a security perspective:
* *Option 1:* Is not an option, if the binary is owned by root it runs as root and this is what you don't want :)
* *Option 2:* Ok-ish, *CAP_NET_RAW* gives you more permissions than you need, your binary can manipulate raw network data, e.g. spoofing the source IPs.
  If you just need ICMP echo requests/replies, it's more than you need but at least it's not root :)
* *Option 3:* Just enough to deal with ICMP echo requests and replies, I would recommend this.

## Bind privileged ports

Normal users are not allowed bind listeners to ports below < 1024.
This is a security feature and the idea was if you connect your browser to port 80, it means there is at least a person involved who needs more permissions on the system than a regular user and is therefore more trustworthy.
No comments here, it was defined a long time ago, and we have to deal with it.
I'll skip the option with `setuid`, because it is not an option :)
* *Option 1:* Redefine what unprivileged ports are by using `sysctl` and `net.ipv4.ip_unprivileged_port_start`.
  Let's say unprivileged ports start at 0 and not at 1024 :)
* *Option 2:* Use the *CAP_NET_BIND_SERVICE* capability to allow the listener to bind to a privileged port.

## Capabilities vs. Kernel parameter

We can get the required desired behavior with [capabilities](https://man7.org/linux/man-pages/man7/capabilities.7.html) or, by modifying [Kernel parameters](https://wiki.archlinux.org/title/sysctl).
Capabilities can be given to a process when *execve* is called (ambient capability), or through a permissions stored in the file system (`setcap CAP_NET_BIND_SERVICE+ep /path/to/binary`).

Kernel parameters can be set with `sysctl` temporarily or permanently to survive a system reboot.
If you run processes in containers you share the Kernel with the underlying host.
You are probably allowed to set a specific set of kernel parameters at runtime when you start the container.

## Containers to the rescue

If you run a container and switch the user id to a non-privileged user, by using the `USER` directive in your Dockerfile or using a security context `runAsUser` all capabilities are dropped.
That means also the capabilities you have set with the security context.
To solve the problem with ambient capabilities there is an enhancement in K8s created as [KEP 2763](https://github.com/kubernetes/enhancements/issues/2763).

I would like to give some kudos to the people in the [Container Talks](https://matrix.to/#/#containers:shivering-isles.com?via=shivering-isles.com&via=matrix.org&via=matrix.allmende.io) channel who helped me a lot to figure things out.

gl & hf
