---
title: "gNMI dial-in vs. dial-out – Who picks up the phone"
date: "2026-06-16"
author: "Ronny Trommer"
categories: ['Technology', 'Streaming-Telemetry']
tags: [ 'gnmi', 'openconfig', 'telemetry', 'networking', 'monitoring' ]
noSummary: false
---

I work with people who build network monitoring systems.
SNMP Traps, NetFlow and IPFIX, BMP — in all of them the device pushes and the collector listens.
And in all of them the device reaches *out*: nothing has to connect *into* the fleet.

Then you deploy gNMI dial-in and a colleague asks why this one stream connects the other way around.
Good question, and it took me a while to give a honest answer.

## A bit of vocabulary first

In gNMI the **target** is the device running the gNMI server — it is the *publisher*.
The **collector** is the gNMI client — the *subscriber*.
The `Subscribe` RPC sets up the subscription and the data comes back in `Notification` and `Update` messages.
What you do downstream with it — message bus, time series database, Grafana — doesn't matter here.

## It's not about who sends the data

Dial-in versus dial-out is **not** about who sends the telemetry.
The device always sends the telemetry.
It is about who opens the connection, and it's named from the device's point of view, not the collector's.

* **Dial-in:** the collector opens the connection, the device accepts. `Collector ──Subscribe──▶ Target`
* **Dial-out:** the device opens the connection, the collector accepts. `Target ──connects──▶ Collector`

The publisher and subscriber roles never move, only who places the call.
That is also why "dial-in is pull" is wrong — dial-in still pushes telemetry, it just opens the channel from the collector's side.

If you want to see dial-in working end to end, I wrote up a full lab with a vJunos router and OpenNMS in [Streaming telemetry with gNMI]({{< ref "/article/gnmi-hpe-juniper" >}}).

One thing to watch out for: "dial-out" is overloaded.
The OpenConfig standard is the **gRPC-tunnel** model — the device dials a tunnel server and a normal gNMI `Subscribe` runs back over the reversed connection (Cisco IOS XE 17.11.1 and later).
The older **Cisco MDT dial-out** is a different, proprietary push transport that can carry OpenConfig models but is not gNMI.
When I say dial-out, I mean the OpenConfig standard.

## Why dial-in costs more than it looks

Dial-in works fine on its own merits. The subscription is rock solid, it scales to thousands of targets, the demo is clean.
The cost isn't in gNMI itself, it's in the seam between gNMI and everything around it.

Everywhere else in your stack the device reaches out, so your firewall rules, your NAT story, your segmentation and your high-availability runbook all assume that direction.
Dial-in is the one protocol that goes the other way, and it lands on exactly the axis your whole security posture is built around — connection direction.
That is what makes the inconsistency expensive, and it shows up as:

* **Inbound exposure.** Every monitored device has to keep a management port open for the collector to call into. Not one ACL'd port, but one on every device in the fleet.
* **Reachability.** Dial-in assumes the collector can route into and authenticate to every device. Behind carrier-grade NAT, inside a management VRF or across segmentation it often can't, or it needs a per-device hole punched.
* **Who owns what.** A collector that initiates connections has to decide which collector owns which device and keep that mapping correct. The table drifts every time you add capacity, lose a node or re-home a device, and a drifted row is telemetry you silently stopped collecting, with no alarm.

Both models also have a reconnect and re-subscribe gap on failure, dial-in is not worse there.
The difference is *where* the recovery logic lives.
Dial-in puts it in your collector control plane: re-subscribe, re-balance the load, re-establish all those outbound conversations through all those NAT'd doors.
Dial-out puts it in your routing fabric: the device re-dials a shared or anycast endpoint and re-registers wherever routing points now — a lot like a [BMP]({{< ref "/article/bgp-bmp-opennms" >}}) session, which is also long-lived and device-initiated.

## Dial-out isn't a free lunch either

Move to dial-out and the bill just goes to a different department.
You run a highly available tunnel-server endpoint as critical infrastructure.
You terminate mutual TLS and manage a device-certificate lifecycle across the whole fleet.
A mass reboot becomes a thundering herd of simultaneous re-registrations.
And you lose the ability to act on demand — no poll-now, no ad-hoc one-off query, because the device only streams what it was preconfigured to send.
That last one stings more than people expect, it's exactly what the NOC reaches for at 3 a.m. to ask one device one question right now.

## So which one

The two models are not good and bad, they are two places to keep your complexity.
Dial-in centralizes it at the collector, dial-out distributes it to the fleet.
Dial-in's tax scales with your operational maturity — runbooks, ownership tooling, a control plane you can staff.
Dial-out's tax scales with your fleet-automation maturity — certificates and reconnect behaviour on every device, where you usually have the least leverage.

So the question was never "dial-in or dial-out".
It is which connection direction you are equipped to pay for, because you are already paying for one whether it's on the budget or not.
If your strength is a mature collector control plane and you need on-demand interrogation, dial-in is fine.
If your strength is fleet automation and your security posture can't abide inbound exposure at scale, dial-out is the better buy.
As always, it depends on your requirements and use cases.

So long and gl&hf
