---
title: "Zyxel vs. Vodafone Easybox with VDSL 50"
date: "2016-07-14"
categories: ['Tutorial', 'Technology']
tags: ['networking']
author: "Ronny Trommer"
noSummary: false
---

I ran in some trouble with my Vodafone _Easybox 904 xDSL_.
Even with 2Ghz and 5Ghz _WLAN_ I had regularly drops.
Had to turn on / off the _WLAN_ on the device or had to reboot it to reconnect.
Otherwise the _VDSL_ line reguarly got disconnected, also replacing the _Easybox_ from Vodafone didn't helped, so I bought a _Zyxel VMG1312-B30A_.

![Zyxel with Vodafon VDSL 50](/images/zyxel.png)

Search through the interwebs and took me a while to figure out what settings are required.
In case you want doing the same, I want to share my settings to safe you some time:

## Broadband Settings

* Type: `ADSL/VDSL over PTM`
* Mode: `Routing`
* Encapsulation: `PPPoE`
* IPv6/IPv4 Mode: `IPv4 only` *sigh*
* PPP-User: `vodafone-vdsl.komplett/vb<number>`
* PPP-Pass: `your-pass-here`
* PPPoE-Service-Name: `VODAFONE`
* VLAN: `active`
* 802.1p: `1`
* 802.1q: `7` (`7`: Telekom line, `132` for Vodafone line)
* MTU: `1492`

## Extended xDSL Settings

* ADSL over PTM: `deactivated`
* Annex J: `activated`
* PhyR US:`deactivated`
* PhyR DS: `activated`

Connection went online and speed test gives me 50 MBit downstream and 10 Mbit upstream.
I run a _tinc_ VPN to have a flat management network for all my servers and runs without any trouble so fare.
Just to mention, I don't use the _Vodafone_ voice functionality.

So far gl & hf
