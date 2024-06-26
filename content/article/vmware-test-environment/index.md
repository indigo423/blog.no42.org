---
title: "Setting up a VMware Test environment"
date: "2021-08-04"
categories: ['Technology']
tags: ['tools']
author: "Ronny Trommer"
noSummary: false
---

To test functions like importing OVA files in VMware ESXi and with vCenter the trial phase and a local deployment can be used. You need the following requirements:

* VMware Workstation on Windows or VMware Fusion on Mac OSX
* VMware Hypervisor ISO image to install the ESXi host system
* VMware vCenter ISO image for local deployment

If you just want to learn how it works you can get a 60 days trial license registering an account on VMware.
I had to manually select a Bridged network for the ESXi server. The vCenter appliance used a Bridge network by default. connected them to a bridged network. You can use DHCP if you want, but you need to make sure they get the same IP addresses afterwards.

## Installing VMware ESXi 7.0.1 Hyper Visor
Create a virtual machine in VMware Fusion and choose VMware ESX 7 and later

![](01-choose-disk.webp)

I've choosen the defaults, the 142 GB is a disc which is thin provisioned and allocates the storage as needed. It is slower but for simple OVA import tests it is enough.

![](02-choose-os.webp)

Attach a CD/DVD drive and insert the VMware-VMvisor installer ISO and connect it.

![](03-choose-iso.webp)

Start the virtual machine and go through the installer

![](04-eula.webp)

![](05-storage-device.webp)

Set a root password and remember it. It will be the same for the ESXi web user interface.

![](06-root-password.webp)

When you have to press F11 it is also used on Mac OSX. You can use the "Virtual Machine -> Send Key -> F11" function from the VMware menu bar

![](07-confirm-install.webp)

After first boot you see the IP address assigned to the server

![](08-esx-login.webp)

You can now login by just going to the IP address with using https://. The server comes with a self signed certificate which you have to set.

![](09-esx-ssl-warning.webp)

Login with root and the password you have set during your installation

![](10-esx-ui.webp)

Voila! You can now deploy an OVA directly to the VMware ESXi host system

## Setting up VMware vCenter

You can deploy a VMware vCenter 7.0 appliance from an OVA file in VMware Fusion.

Mount the ISO file and you will find the vCenter appliance in the "vcsa" directory.

![](11-vcsa-ova.webp)

Add a new virtual machine and select "Import" and select the OVA file from the mounted ISO file

![](12-fusion-import.webp)

I use a "Tiny vCenter Server" which uses ~10GB RAM

![](13-deployment-option.webp)

You can prepopulate some credentials and passwords, you can set it later if you want.

![](14-additional-settings.webp)

On first startup you can login to the console and you have to set a password.

![](15-vcsa-root-password.webp)


### Initializing vCenter

You can now login to the Web UI with https://your-ip:5480 and finish the initial vCenter setup procedure. Use Firefox or Chrome as a browser. Login is the root password you have set in the console.

![](16-vcsa-ssl-warning.webp)

![](17-vcsa-getting-started.webp)

![](18-vcsa-introduction.webp)

You create a SSO account for the vCenter domain like this:

![](19-vcsa-sso.webp)

When I click save I got kicked out of the session. I had to relogin with the root password I've set in the console.

![](20-login-vcenter.webp)

After that I was back in business and could proceed with the installation

![](21-complete.webp)

If you want to use DNS names for the ESXi host or the VCSA appliance, you have to make sure you have a local DNS server running which resolves everything correctly. The vCenter will fail and get stuck in the installation phase here:

![](22-setup-progress.webp)

When the setup is finished close the installer and the appliance will reboot

![](23-setup-complete.webp)

### Creating a Data Center and add an ESXi Host

The vCenter appliance has 2 user interfaces a) an administration interface for the appliance itself on port 5480 and the vCenter application just on https:// port 443

Login to the vCenter application

![](24-vcsa-login.webp)

Create a Datacenter and add the ESXi host to the data center by IP address if you don't have DNS set up

![](25-create-data-center.webp)

You have to provide the root password from the ESXi appliance

![](26-add-host.webp)

Accept the self-signed certificate

![](27-esx-ssh-fingerprint.webp)

![](28-host-summary.webp)

The lockdown mode enforces settings to be made with the vCenter. For testing purposes it might be helpful to leave it disabled for now. This way you can also login to the ESXi host web ui and do things there as well.

![](29-esx-lockdown.webp)

You can now deploy an OVF/OVA file in the data center

![](30-deploy-vm.webp)

gl & hf
