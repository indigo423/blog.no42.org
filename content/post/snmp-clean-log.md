---
title: "Cleaner log with Docker and SNMP"
date: "2017-05-19"
categories:
    - "post"
tags:
    - "logging"
    - "snmp"
    - "netsnmp"
    - "docker"
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

Centralizing logs is important as soon you have more than 2 servers.
In my environment the bare metal is monitored with [Net-SNMP](http://www.net-snmp.org) and my services are deployed as containers with [Docker](https://www.docker.com).
All system logs are sent to a [Graylog2](https://www.graylog.org) instance and I quickly noticed a few ugly entries caused by `snmpd`.

```
Cannot statfs /run/docker/netns/...: Permission denied
```

You will notice a few of them.
First approach try to increase the logging level in `/etc/default/snmpd` from SNMP daemon with

```
SNMPDOPTS='-Ls3d -Lf /dev/null -u snmp -g snmp -I -smux,mteTrigger,mteTriggerConf -p /run/snmpd.pid'
```

The [man page](http://www.net-snmp.org/docs/man/snmpd.html) from Net-SNMP described the logging and I've increased with `-Ls3d` the level to "Error" instead of "Warning", but it didn't help.
I researched in the web and found this topic in [Red Hats Bugzilla](https://bugzilla.redhat.com/show_bug.cgi?id=1314610#c10).

It turns out `snmpd` is reading `/proc/mount` and runs `statfs` and logs an error.
One of the [authors](https://blog.emeidi.com/2017/02/19/elk-snmpd-cannot-statfs/) in the comment section found a solution to use `rsyslog` filtering this type of message with:

```
if $programname == 'snmpd' and $msg contains 'statfs' then {
    stop
}
```

The result is now a much cleaner log with less garbage.

Happy Logging