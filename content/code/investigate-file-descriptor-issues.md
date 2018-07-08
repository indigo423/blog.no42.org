---
title: "Investigate file descriptor issues"
date: "2014-11-07"
tags: ['linux']
author: "Ronny Trommer"
---

If you run a centralized monitoring system in large environment you can run in some issues regarding file descriptor limits. Linux gives you very detailed information in the kernel control and information center in /proc. The soft and hard limits have effect for file and network sockets, which can end up in a too many files open exception in OpenNMS.

The default values for soft and hard limits can be checked with

```sh
ulimit -a
ulimit -a -H
```

The value is per user and each new process inherits these limits.
OpenNMS changes the hard limit during the start with the default init script and changes with

```sh
ulimit -n 20480
```

from normally `4096` to `20480`.
You can change this value by adding the following line to your `/etc/opennms/opennms.conf`.

```sh
MAXIMUM_FILE_DESCRIPTORS=40960
```

If you start OpenNMS you can see the limits for the OpenNMS JVM with

```sh
cat /proc/$(cat /var/run/opennms.pid)/limits
```

You can see how much file descriptors OpenNMS has allocated with:

```sh
ls -l /proc/$(cat /var/run/opennms.pid)/fd | wc -l
```

If you use `lsof` with the process id of OpenNMS you will see a larger number than in `/proc/pid/fd`

```sh
lsof -p $(cat /var/run/opennms.pid) | wc -l
```

The reason is memory mapped `.so` files are listed and don’t count for the configured limits and are listed with `lsof`.

```sh
lsof | grep $(cat /var/run/opennms.pid) | wc -l
```

If you want to see how many filesystem handles OpenNMS uses, you can run:

```sh
cat /proc/sys/fs/file-nr
4128	0	262144
```

you can see three values:

```sh
number of allocated file handles: 4128
number of used file handles:      0
maximum number of file handles:   262144
```
