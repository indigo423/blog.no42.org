---
title: "Net-SNMP version 3 and OpenNMS"
date: "2017-09-22"
tags: ['opennms', 'snmp']
author: "Ronny Trommer"
---

To monitor your systems you rely heavily on SNMP, it gives out of the box a lot of possibilities getting important performance and status information.

The main topic security is often not considered.
SNMP version 1 and 2c transmit everything in plain text over the wire.
There is also no user, password authentication method, just a shared community string which gives access to the information.
To address these problems [SNMP v3](http://en.wikipedia.org/wiki/Simple_Network_Management_Protocol#SNMPv3) was introduced.

The Linux Net-SNMP agent supports SNMP v3 and OpenNMS does as well, so nothing prevents us to use encryption and user authentication.

WARNING: I assume Net-SNMP uses _[SHA-1](https://shattered.io)_ which is secure anymore.
As far I know today, there is no implementation for [Net-SNMP available](https://sourceforge.net/p/net-snmp/mailman/message/34004358/) which supports SHA-2 with a 256-bit hash.

Nevertheless here is the way to configure SNMP v3.
It is still better than sending everything over the wire in plain text.
In critical environments, I would definitely consider adding mechanisms to isolate and protect the management network from the rest of the world on network layers to reduce the attack vector.

## Make your Net-SNMP configuration modular

Today, people running configuration management tools rolling out configurations to a lot of systems.
Net-SNMP gives you the possibility to use an include drop-in folder to extend the default configuration, which is very handy to include device dependent configuration snippets.

All you have to do is to add the following line in your `snmpd.conf`

```sh
includeDir /etc/snmp/conf.d
```

All files ending with `.conf` will now be added to your Net-SNMP configuration.
This makes it using configuration management tools to add device dependent disk, process or log monitoring directives without mangling one large `snmpd.conf` with variables.

## How to configure Net-SNMP with SNMP v3

The first step, create a user with password and tell the agent what methods for encryption and signature should be used with:

```sh
createUser monitor SHA 0p3nnm5423 AES opennmsopennms rouser monitor priv .1.3.6.1.2.1
```

The command creates a user named `monitor` and uses [SHA](http://en.wikipedia.org/wiki/SHA) as  [Message Authentication Code](http://en.wikipedia.org/wiki/HMAC).
For encryption you have the choice between [DES](http://en.wikipedia.org/wiki/Data_Encryption_Standard) and [AES](http://en.wikipedia.org/wiki/Advanced_Encryption_Standard) , I would recommend the newer AES encryption method.
I can recommend using something like [apg](http://linux.die.net/man/1/apg) to create better passwords.

Once you added the configuration you have to restart the Net-SNMP daemon and you can test it with the following command:

```sh
snmpget -v 3 -u monitor -l authPriv -a SHA -A 0p3nnm5423 -x AES -X opennmsopennms localhost .1.3.6.1.2.1.1.6.0
```

You should be able to get the system location.
Next, you can configure OpenNMS to use SNMP v3 for your IP address or a whole range in the Web UI by going to "Admin -> Configure SNMP Community by IP".

That's it – happy monitoring.
