---
title: "SNMP vs. Prometheus – On The Wire "
date: "2022-10-26"
author: "Ronny Trommer"
categories: ['technology']
tags: ['monitoring', 'snmp', 'prometheus', 'packetcapture']
noSummary: false
---

I've been working with network monitoring tools for a long time.
Regarding legacy network devices, there is nearly a 100% probability you have to deal with SNMP.
At the University of Applied Sciences in Fulda, I worked on course material teaching students network management, and guess what – SNMP was a part of it.
However, using open-source tools, you find Prometheus and the extensible agent architecture all over the place.
Prometheus seems to be well adopted by people and writing exporters for all kinds of things.
SNMP and Prometheus agents give visibility to measurements into a system or application with totally different approaches just looking at the communication protocols they are using.

SNMP uses UDP as a connectionless protocol for communication.
Prometheus, on the other side, uses HTTP via TCP as a connection-oriented protocol.
I've been working for a long time in network monitoring, and I've seen a lot of arguments about why SNMP is great.
Here are my two favorites:

* SNMP uses not as much network bandwidth because it's very efficient.
* SNMP has a simple request/response communication pattern that lets you do the same job in less time.

I wanted to know how that is true by analyzing network communication to validate these two statements.
Additionally, I want to highlight the differences between using an SNMP or a Prometheus agent from a network communication perspective.

## Capturing data

How did I measure and what have I used.

## Analyse communication pattern

OpenNMS with SNMP vs. Prometheus

## Compiling the results

* packets per second
* bandwidth per second
* how many metrics each

## Conclusion

