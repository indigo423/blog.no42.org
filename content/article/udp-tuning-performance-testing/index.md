---
title: "UDP tuning and performance testing"
date: "2024-10-17"
categories: ['Linux', 'Networking']
tags: [ 'linux', 'networking', 'performance', 'syslog', 'flows', 'snmp-traps' ]
author: "Ronny Trommer"
noSummary: false
---

# Problem statement

* Ingesting UDP traffic is complicated to measure
* Packet drops, connectionless and unreliable
* Measuring on ingest on the network interface card
* How can you make sure you measure reasonably?
* You want a method to create some confidence how many UDP packets your system drops

# Create a lab environment to reproduce the problem

* Make the problem visible using with overloading a small device Raspberry Pi 3
* Use sysctl default settings
* Use something like hping3 or iperf to create a overload situation

# You can't improve what you don't measure

* Show tools like dropwatch or ss -lump or SNMP udp metrics to visualize packet drops
* Compare packets received with tcpdump vs. iperf
* Theory should show who be tcpdump should have more but not all then the sender

# Increase buffers size?

* What happens if you increase the buffer size?

# Use PF_RING

* How does the behavior change when you use PF_RING with TCPDUMP

# Conclusion

