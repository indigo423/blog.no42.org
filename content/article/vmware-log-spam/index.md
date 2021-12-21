---
title: "VMware multipathd log spam"
date: "2021-04-07"
categories: ['Technology']
tags: ['vmware', 'ubuntu']
author: "Ronny Trommer"
noSummary: false
---

While I was deploying Loki with Promtail I've seen a lot of log spam from Ubuntu virtual machines in my VMware environment.
As a note to myself and for some others who want cleaner system logs – here is what I've found to get rid of it.

The log entries look like these here:

```shell
2021-04-07 20:14:21 opennms-bgp multipathd[693]: sda: failed to get sgio uid: No such file or directory
2021-04-07 20:14:21 opennms-bgp multipathd[693]: sda: failed to get sysfs uid: Invalid argument
2021-04-07 20:14:21 opennms-bgp multipathd[693]: sda: failed to get udev uid: Invalid argument
2021-04-07 20:14:21 opennms-bgp multipathd[693]: sda: add missing path
```

The [best article](https://www.suse.com/support/kb/doc/?id=000016951) I've found was from SUSE describing the problems source.
In a nutshell, VMware doesn't provide information needed by `udev` to generate the `/dev/disk/by-id`.
To solve the problem you have to set in the Virtual Machine the attribute `disk.EnableUUID=true`.
For the reason I have a few VM's it's pretty tidious to do all these things manually.

I've came along [govc](https://github.com/vmware/govmomi/tree/master/govc) which is a command line tool for VMware which uses the vCenter API.
The tool itself is written in golang which gives you some freedom of choice with pre-compiled binaries for the AMD64 architecture, if you use other operating systems.
As I'm running on OSX it's a no-brainer to install it with [homebrew](https://brew.sh).

```shell
brew install govc
```

For access and authentication to you vCenter you can export the environment variable `GOVC_URL` like this.

```shell
export GOVC_URL="https://administrator@vpshere.local:mypass@myvCenter:/sdk"
```

If you don't provide trusted SSL certificates and want to accept the default insecure SSL certificates in your lab environment you can set the `GOVC_INSECURE` environment to `true`.

```shell
export GOVC_INSECURE="true"
```

You can test your setup with running `govc about` and you should see something like this:

```shell
FullName:     VMware vCenter Server 7.0.1 build-17005016
Name:         VMware vCenter Server
Vendor:       VMware, Inc.
Version:      7.0.1
Build:        17005016
OS type:      linux-x64
API type:     VirtualCenter
API version:  7.0.1.1
Product ID:   vpx
UUID:         11f1cb7e-6767-5b66-81dc-328701bb3b42
```

To solve the problem described in the knowledge base article, you can use now simple bash loop to set the attribute in all your VMs.
If you have fancy VM names with special characters or whitespaces, it's the best you fetch the UUIDs first.

Here an example to get the UUID from one of my VMs:

```shell
govc vm.info /Labmonkeys-DC/vm/cortex
```

You can set it now with `-vm.uuid` instead of the `-vm` argument.

```shell
govc vm.change -e="disk.EnableUUID=TRUE" -vm.uuid="564d19e5-b64e-1a59-5986-9e417ace343b"
```

Here is the one liner to enable the UUID disk attribute by the VM name:

```shell
for vm in $(govc ls vm); do govc vm.change -e="disk.EnableUUID=TRUE" -vm="${vm}"; done
```

The setting is only applied after power-cycling the virtual machine.

gl & hf
