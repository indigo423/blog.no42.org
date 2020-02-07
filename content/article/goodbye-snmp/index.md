---
title: "He's dead, Jim"
date: "2018-07-30"
author: "Ronny Trommer"
categories: ['Technology']
tags: [ 'snmp', 'monitoring' ]
noSummary: false
---

If you operate networks there is a big chance you had to deal with SNMP - the Simple Network Management Protocol.
If you ever wondered where it came from, it started with a big bang.

> On October 27, 1980, there was an unusual occurrence on the ARPANET.
> For a period of several hours, the network appeared  to be unusable, due to what was later diagnosed as a high priority software process running out of control.
> Network-wide disturbances are extremely unusual in the ARPANET (none has occurred in several years), and as a result, many people have expressed interest in learning more about the etiology of this particular incident.

The first post-mortem written in [RFC 789](https://tools.ietf.org/html/rfc789.html) expressed a need to manage and monitor a complex networks.

If you dig around in dusty RFC drafts, you can find some for _HEMS_ a High-Level Entity Management System described in [RFC 1021](https://tools.ietf.org/html/rfc1021).
Later the draft for the Simple Gateway Monitoring Protocol (SGMP) was published as a research project in [RFC 1028](https://tools.ietf.org/html/rfc1028).
In August 1988 when I was 10 years old, _SNMP_ got his first draft in [RFC 1067](https://tools.ietf.org/html/rfc1067) and became the successor of _SGMP_.

### 14 years later ...

In the early years of 2000 it became quite clear, that _SNMP_ was mainly used just for monitoring and not to configure network equipment as planned.
On the 4th until 6th June 2002 the Internet Architecture Board [IAB] had a meeting and discussed the status quo.
The full protocol can be read in [RFC 3535](https://tools.ietf.org/html/rfc3535).
The interesting things are in Section [3](https://tools.ietf.org/html/rfc3535#section-3), [4](https://tools.ietf.org/html/rfc3535#section-4) and [6](https://tools.ietf.org/html/rfc3535#section-6).

In a nutshell, they figured out _SNMP_ was not usable to configure devices, you should still better use the _CLI_.
They recommended to stop forcing working groups to provide writeable _MIB_ modules.
The decided to build a group to investigate why _MIBS_ are still crap.
The figured out, nobody wants _ASN.1_ and decided to form a group to develop and standardize a XML-based device and configuration management technology.

They basically documented already in 2002 why _SNMP_ is no fun to use.
The whole tool chain has not evolved and was adapted to new programming languages people want to use.

_Juniper Networks_ used an XML-based network management approach at a similar time when the _IAB_ discovered the problems with the current status quo and broad it to the _IETF_.
The result is the first version of the _NETCONF_ protocol published in 2006 as [RFC 4741](https://tools.ietf.org/html/rfc4741).
With _NETCONF_ as transport they needed to model things and this is where [YANG](https://en.wikipedia.org/wiki/YANG) as a data modelling language comes into play.

### Configuration, Discovery and Polling

Using _SNMP_ is in first place quite simple and follows the Client/Server approach.
The network management system is the Server and the _SNMP_ Agent on the network device is the client.

One goal of _SNMP_ was to make devices and configuration discoverable.
That means a network monitoring system can go and see how many disks or network interfaces are installed and how they are configured.
You can also go further and ask in a regular base how many bytes where transferred or how full is your disk

This design implies a specific design for a monitoring system which needs to build a centralized inventory about those entities with a life cycle.
This works for very static networks.
You can try to keep the inventory in sync by polling the SNMP agents on a regular base, but you can imagine, the bigger and more dynamic a network gets, the more often your world will fell apart.
For a monitoring system is this very critical, cause the information provided get less and less trustworthy and this is where you start to think replacing your current monitoring system with a different one.

For the reason of the bad implementation of _SNMP_ a lot of monitoring tools deploy their own agents and reimplement these functionality with proprietary protocols which made their world better, but not for all of us.
Additionally the world has changed dramatically since the last years with virtualization and deploying and running applications in containers.
The infrastructure changes now so often and is so dynamic, there is no chance to poll all these things from a central scheduled place and provide an up-to-date inventory.

Generic tools which configure devices over _SNMP_ are hard to find and/or expensive.
It is like peak and poke registers and it has nothing to do with a declearitive approach to define a maintainable configuration state.
Not speaking of all the problems described in _RFC 3535_.

### The Tool-Situation

In early days the [ISO - International Organization for Standardization](https://en.wikipedia.org/wiki/International_Organization_for_Standardization) categorized the management in functional areas for short [FCAPS](https://en.wikipedia.org/wiki/FCAPS):

* Fault
* Configuration
* Accounting
* Performance
* Security

As you can imagine just a single area in his own is huge.
To get a checkmark on all of the you have to look at the tools of the _Big Four_ with BMC, CA, HP and IBM.
So in reality you don't by one tool from one of these vendors, they try to sell you many tools they bought during the time and munched together as a solution.

The Open Source world followed more or less the one tool for a job approach.
Monitoring tools do mainly their job in the fault- and performance-management area.
A lot of them can read _SNMP_ but they don't fully rely on it and bring mostly also their own agents.

Configuration management tools like [Ansible](https://www.ansible.com), [SaltStack](https://saltstack.com), [Chef](https://www.chef.io) and [Puppet](https://puppet.com) are pretty much the industry standard for configuration management.
... and guess what, instead of using _SNMP_ they come all with their own agents.

### to be continued ...

Nevertheless, _SNMP_ is still the only agent available which is shipped with your cheap hardware and this is the reason why we still don't have fancy things.
But the days are numbered and if you look at all the things happening in next generation technologies e.g. Server Virtualization, Containerization, SDN, NFV, you won't find _SNMP_ and you have to face it, _SNMP_ is dead.
The new world in monitoring is model driven streaming telemetry which pushes data and is not polled and this is covered in another article.
