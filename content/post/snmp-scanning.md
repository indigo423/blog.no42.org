---
title: "Scanning for SNMP communities"
date: "2018-03-02"
categories:
    - "post"
tags:
    - "snmp"
    - "nmap"
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

Adding devices into monitoring system is easy.
Getting all the right SNMP communities for them is harder.
People don't give you the right community string or forget to open firewall ports.

If you have to test a lot of IP's against various IP addresses you can use `nmap` and a community list file as an input.

Be aware you talk about permission to run this test otherwise somebody can get angry when you try to brute-force community strings against their devices.

Create a file with the communities you want to test, in this example we call it `snmpcommunities.lst`.

```
indigo@blinky ~ cat snmpcommunities.lst
wtfgoaway
public
```

Scan a network with the community strings goes like this:

```
sudo nmap -sU -p161 --script snmp-brute 172.24.23.0/24 \
  --script-args snmp-brute.communitiesdb=./snmpcommunities.lst
```

The output is a list with IP addresses and the working SNMP communities:

```
Starting Nmap 7.60 ( https://nmap.org ) at 2018-03-02 16:57 CET
Nmap scan report for 172.24.23.100
Host is up (0.061s latency).

PORT    STATE SERVICE
161/udp open  snmp
| snmp-brute:
|_  wtfgoaway - Valid credentials
MAC Address: 0E:29:0C:FE:50:89 (Unknown)

Nmap scan report for 172.24.23.101
Host is up (0.060s latency).

PORT    STATE SERVICE
161/udp open  snmp
| snmp-brute:
|_  wtfgoaway - Valid credentials
MAC Address: 0E:29:0C:8A:2B:8A (Unknown)

Nmap scan report for 172.24.23.103
Host is up (0.056s latency).

PORT    STATE         SERVICE
161/udp open|filtered snmp
MAC Address: 0E:29:0C:F0:BD:95 (Unknown)

Nmap scan report for 172.24.23.104
Host is up (0.038s latency).

PORT    STATE SERVICE
161/udp open  snmp
| snmp-brute:
|_  wtfgoaway - Valid credentials
MAC Address: 0E:29:0C:CF:57:16 (Unknown)

Nmap scan report for 172.24.23.106
Host is up (0.073s latency).

PORT    STATE SERVICE
161/udp open  snmp
| snmp-brute:
|_  wtfgoaway - Valid credentials
MAC Address: 0E:29:0C:FB:A7:C4 (Unknown)

Nmap scan report for 172.24.23.3
Host is up (0.087s latency).

PORT    STATE SERVICE
161/udp open  snmp
| snmp-brute:
|_  public - Valid credentials

Nmap done: 256 IP addresses (6 hosts up) scanned in 15.44 seconds
```

If you want to use this information in other applications or scripts you can create an XML output with adding `-oX snmp-result.xml`.
