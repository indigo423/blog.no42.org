---
title: "Guidance to Survive Monitoring"
date: "2018-08-08"
tags: [ 'open source', 'operation', 'monitoring love' ]
author: "Ronny Trommer"
noSummary: false
---

While working in the monitoring field for a long time, here are some rules I try to follow when requirements go awry.

### Rule #1: Only create an alert when human interaction is required

When you setup a monitoring, it tends to get noisy very quickly.
The problem is, people want to know everything and want to monitor everything.
You tend to build a system which sends you a lot of alarms and you will get alarm fatique.
To get most out of your monitoring solution, you have to always keep in mind Rule #1.
When you alert for something, ask yourself is it really necessary to wake some one up in the middle of the night.
There is nothing more horrible than waking someone up and it is a false alert.

If you just start with monitoring your environment, it will happen, ensure you have processes and awareness from your people it only happens ones.
As soon you start to create a monitor to test something in operation, think about what happens if this test fails?
Is there a human beeing required to get this service up?
Document what the monitor really does and provide helpful diagnostic tips as operator instructions when a service goes down.

### Rule #2: Monitor your most important services

You can monitor everything these days.
Applications give you tons of metrics.
It is hard to focus on the important things, what is the service delivery point you provide to others, this is what you need to monitor first.
This is the most important thing you should notice when it goes down.
Extend your monitoring from there downwards to more pro-active alerts.
These type of services are mostly implemented as _BlackBox Test_ or _End-to-End Test_.

When you go more in detail you start to gather metrics or implement _WhiteBox Tests_ against agents.

### Rule #3: Own your monitoring configuration

Start with an empty system, don't use pre-configured monitoring behavior.
Monitoring is testing applications, devices and complex systems running in operation.
If a test fails, you need to know how you tested it, with using predefined default configuration, you don't.
When a threshold exceeds, you have to make sure you defined those thresholds.
Additionally it will give you a system which is easier to update and less expensive to maintain.

### Rule #4: Don't use discovery in production

My personal view on monitoring is, you extend Test Driven Development with tests against services deployed in production and running in an operational mode.
You don't know which services you provide, how can you create tests and how do you provide reliable workflows when something goes down and a human beeing required to fix it.
When you discover services, you don't have a monitroing system in a reproducable and discrete state.
You'll never can ask yourself the question what do I monitor right now and what is missing.
When you detect a service the whole workflow behind is missing.
What happens when a service which was automatically detect goes down?
Who is responsible and needs to take care of when a service goes down?

When you discover a service which is for any reason not reachable - security reasons or it is down - you don't have it in monitoring, you don't get alerts, you don't have a glue.
You should be always in the situation to say: "This is what we monitor right now, this is not in monitoring for ${reason} and here are things we can improve."
Monitoring is a process similar as security.

Instead of trying to discover afterwards when things are already in production, turn it around, think about workflows to test things in monitoring in the moment you deploy them into production with modern configuration management tools.

### Rule #5: Use the right tool for the right job

Monitoring and diagnose a broken system gets very often mixed up.
As an example, when you drive a car you have a dashboard as a tool which gives you just enough information to let you focus on driving.
You task is driving from point A to B.
The car tells you how fast you drive, how much fuel you have and how much fuel you waste.
When you're car is broken you get a red alert.
To get details you have to connect a special device to diagnose what the problem really is.

A monitoring system is something like your dashboard in a car, use it to let you focus on operate services and when something got broken, don't misuse a monitoring tool to diagnose problems.
Use the right tool for the job.

### Rule #6: Four Golden Signals

There thousands of metrics you can collect.
Re-evaluate requirements and try to get back to the four golden signals., which are explained in the the [Google SRE book](https://landing.google.com/sre/book/chapters/monitoring-distributed-systems.html#xref_monitoring_golden-signals) to keep you focused. They are in a very very small nutshell:

* Latency: What is the time it takes to service a request.
* Traffic: How much demand is being placed on your system, usually something like requests per second or input/output rate.
* Errors: The rate of requests fail in three flavors: a) explicitly, e.g. HTTP 500s, b) implicitly HTTP 200 with wrong content or c) by policy, you committed to one-second and the service responses longer than 1 second are a failure.
* Saturation: How "full" is your system for capacity planning.
