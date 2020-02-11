---
title: "UCARP and High Availability"
date: "2020-02-07"
categories: ['Technology', 'Open-Source']
tags: ['events', 'open-source', 'ucarp', 'high-availability']
author: "Ronny Trommer"
noSummary: false
---

If you have ever played with BSD you probably ran into [CARP](https://en.wikipedia.org/wiki/Common_Address_Redundancy_Protocol).
It allows you to build a high available service which is provided by two physical servers behind a virtual shared IP address.
The CARP nodes define a master and a backup system.
A master serves the content and if the master crashes, the backup system takes over automatically the virtual IP (VIP) and the client won't notice.

> **Disclaimer:**
> You should be aware this setup will not share load and increase your network throughput.
> It just used to increase availabilty and room to do maintenance without bringing your service down.

The same feature is available on Linux named [UCARP](http://manpages.ubuntu.com/manpages/trusty/man8/ucarp.8.html) which is running in user space.
This here is a short note on my futureself how this can be done quickly and maybe interesting to others.
This here is a short tutorial how to setup two Linux servers running Ubuntu 19.10 with `systemd` and setting up a VIP with ucarp.
The lab setup looks something like in the following image.

![ucarp-network](/images/carp-setup.svg)

I'll pick 192.168.178.201/24 as the virtual IP address and 192.168.178.210/24 and 192.168.178.211/24 are assigned to the physical nodes.
Install `ucarp` on both of your servers.

```bash
apt update
apt -y install ucarp
```

To work with `systemd` modify the `vip-up` and `vip-down` scripts on both of your servers:

File: `/usr/share/ucarp/vip-up`

```bash
#!/bin/sh
exec 2>/dev/null
/sbin/ip address add "$2"/32 dev "$1"
```

File: `/usr/share/ucarp/vip-down`

```bash
#!/bin/sh
exec 2>/dev/null
/sbin/ip address del "$2"/32 dev "$1"
```

Now you have to create a `systemd` unit file with the following content on both of your servers:

File. `/etc/systemd/system/ucarp.service`

```bash
[Unit]
Description=UCARP as systemd unit
After=syslog.target
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/sbin/ucarp --interface=ens33 --pass=bYaTxPw2 --srcip=192.168.178.210 --vhid=1 --addr=192.168.178.201 --shutdown --preempt --upscript=/usr/share/ucarp/vip-up --downscript=/usr/share/ucarp/vip-down -B
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

Make sure you adjust the followinc [ucarp arguments](http://manpages.ubuntu.com/manpages/trusty/man8/ucarp.8.html):

* `--interface=ens33`: interface name of the physical server
* `--pass=bYaTxPw2`: set your own shared secret as a password on both servers
* `--srcip=192.168.178.210`: the real IP address assigned to your server
* `--vhid=1`: the virtual server identifier

You can now enable and start the service with `systemctl enable ucarp` and `systemctl start ucarp`.
The IP address 192.168.178.201 should now be available.
If you want to figure out which is the master and which is the backup, you will see it in the log output from `ucarp`.
You can check this on both of your servers with watching the ucarp daemon output `journalctl -f -u ucarp`.

If you want to test it shutdown you master and the backup should immediately take over and you should see it in the log output.

So long and thanks for all the fish
