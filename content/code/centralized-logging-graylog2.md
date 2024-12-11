---
title: "Centralized Logging with Graylog2"
date: "2017-11-17"
tags: ['monitoring', 'logging', 'opennms', 'java', 'syslog', 'gelf']
author: "Ronny Trommer"
---

How many times do you connect with SSH to your remote server and `cat`, `grep`, `tail` and `awk` through your logs?
It probably works for 3 servers and running a handful services, but if you have more, you should definitely spend some time to centralize your logs.

I personally prefer [Graylog2](https://www.graylog.org) which can deal very well with different log formats like [GELF](http://docs.graylog.org/en/2.3/pages/gelf.html), [Syslog RFC's](https://de.wikipedia.org/wiki/Syslog).
Just start some listener with the format and forward them to your _Graylog2_ instance.

A few servers are [NAT'ed](https://en.wikipedia.org/wiki/Network_address_translation) behind [VDSLs](https://en.wikipedia.org/wiki/VDSL) with dynamic IP's and some physical and virtual servers hosted somewhere else with static public IP's which have all running _Linux_.
This makes monitoring normally hard, so I use a fully meshed [tinc](https://www.tinc-vpn.org) VPN, so I don't have to deal a lot securing many different applications and protocols and everything is reachable in a flat private /24 IPv4 network.
To manage the server basic configuration I use [Ansible](https://www.ansible.com) and most services run as a container using [Docker](https://www.docker.com).

What is the benefit?

* The _GELF_ listener allows me to the Docker built-in driver to easily centralize containerized application logs
* [Log4j2](https://logging.apache.org/log4j/2.x/) provides a _GELF_ output as well which gives me full access to my logs from my _OpenNMS_ instances
* _Graylog2_ can parse Syslog in various RFC's which gives me centralized system logs from my Linux systems
* It is very easy to deploy the configurations with _Ansible_

## Setting up a Graylog2 Service Stack

Define a service stack using [Docker Compose](https://docs.docker.com/compose/) and get Graylog2 up and running.
Here is [docker-compose.yml file](https://gist.github.com/indigo423/b6f1594e2512fddb0e677435937e8937) I use, just download it and run `docker-compose up -d`.

The following ports get exposed:

* 9000: The Graylog2 web application
* 12201: GELF UDP listener for my Java applications
* 514: GELF UDP Syslog listener to forward my system logs

## Configure a GELF UDP and a Syslog UDP Input

With the first login in _Graylog2_ you have to create two _Inputs_.
The _GELF UDP_ input is used to receive log messages from my _OpenNMS_ applications and _Docker Daemons_ and the _Syslog UDP_ input receives my _Syslog_ messages.

![Graylog2 Input Configuration](/images/graylog2-inputs.png)

## Configure Syslog forwarder

On my systems is [rsyslog](http://www.rsyslog.com) running.
It is required to configure _rsyslogd_ and I use _Ansible_ to create a file in `/etc/rsyslog.d/50-graylog-forwarding` with following content:

```bash
if $programname == 'snmpd' and $msg contains 'statfs' then {
    stop
}

*.* @172.42.42.42:514;RSYSLOG_SyslogProtocol23Format
```

On 172.42.42.42, my Graylog2 instance is running and is listening on 514/udp.
After restarting _rsyslog_ the logs will be forwarded.
The first if-statement ensures I don't log a lot of garbage coming from `snmpd` which described more in detail in this [blog post](https://blog.no42.org/blog/cleaner-logs-docker-snmp).

## Configure OpenNMS to forward logs to Graylog2

Add Modify the `${OPENNMS_HOME/etc/log4j2.xml` and add a GELF UDP log appender which is described in our [OpenNMS Wiki](https://wiki.opennms.org/wiki/Sending_OpenNMS_Logs_to_Graylog).

All the daemons will no also forward their logs to Graylog2 via UDP and are searchable for services node labels, node ids and daemons.
Different OpenNMS instances running various versions are identified by an application_name` tag.

![Graylog2 Screenshot](/images/graylog2-screenshot.png)

## Forward Docker Container logs

To get logs from my applications running in Docker container, I have configured them to use the GELF driver by just adding this snippet to my service definition:

```yaml
logging:
  driver: "gelf"
  options:
    gelf-address: "udp://172.42.42.42:12201"
    tag: "horizon-core-web:stable"
```

The `tag` is used to identify the service, you can be as creative as you want and the `gelf-address` tells the Docker daemon where to forward the messages which is my _Graylog2_ listener input.

Happy logging and searching
