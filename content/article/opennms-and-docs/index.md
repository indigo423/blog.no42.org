---
title: "OpenNMS and Documentation"
date: "2014-07-15"
categories: ['OpenNMS', 'Technology']
tags: ['documentation', 'opennms']
author: "Ronny Trommer"
noSummary: false
---

To help the OpenNMS project I spent a year together with Alexander Finger and Klaus Thielking-Riechert writing an [OpenNMS book](http://www.dpunkt.de/buecher/3194.html).
We started with a development version of for 1.8 and tried to find a mixture between consistent slow changing and new concepts in 1.8.
It was kind a complicated thing and from my point of view not perfectly done.
Nevertheless I’ve thought about something like: "It’s about time writing a second edition covering the topics in coming 1.14?"
The problem I’ve with books, it doesn’t allow contribution and hasn’t a really long life cycle.
So I’ve decided instead of spending a year again writing a book, I want something which is more helpful to the project itself.

During my visits on different conferences like FroSCON, Linuxtage in Chemnitz and LinuxTag in Berlin, I tried to get in talks and met people working in the community area.
Two things I’ve quickly recognized, one was the Open Stack project, which did a really cool job communicating about how to contribute in their project.
The second one was a talk from [Mikey Ariel](http://www.linuxtag.org/2014/de/programm/vortragsdetails/?eventid=1338) a technical writer and documentarian at Red Hat, Inc. on LinuxTag in Berlin.

To get some feedback, I started an open discussion about documentation in the OpenNMS project with attendees at OUCE 2014 in Southampton.
I was very happy and we had a very constructive conversation and people seems interested to help the project here.
The status quo of our documentation is currently MediaWiki based collection of unstructured sometimes category tagged pages.
On one side it makes it easy for people creating content and there is quite a lot of good stuff in the Wiki, but on the other side it is hard to find things.
You have always exactly to know what term you have to search for and makes it hard to get an idea what OpenNMS is capable of.
To address this issue I decided to spend the week at DevJam on OpenNMS documentation and my friend Markus von Rüden helped me a lot.
He is a developer from hell and helped me a lot evaluating technologies and gave important input how to establish a process in an agile environment.

A few weeks later I got in contact with a guy worked at Juniper with OpenNMS and he asked to help us with this topic.
I was amazed and used his positive feedback as trigger to get a documentation meeting set up.
We used the [opennms-discuss](https://lists.sourceforge.net/lists/listinfo/opennms-discuss) and move now this topic to [opennms-docs](https://lists.sourceforge.net/lists/listinfo/opennms-docs) mailing list.
I’ve suggested a Google Hangout where we could explain a little about the experience we had what we have figured out during DevJam.

We have basically divided the documentation in two parts:

* Wiki based documentation for tutorials and integration of OpenNMS with external devices, applications etc.
* Source code based documentation which gives a complete reference how to configure things which is tightly based on a version of OpenNMS

For each of this components we created a Jira component to track issues against:

* Source code based [documentation](http://issues.opennms.org/browse/NMS/component/10011)
* Wiki based [documentation](http://issues.opennms.org/browse/NMS/component/11654)

We started with a simple doable task like, [document all existing monitors in OpenNMS](http://issues.opennms.org/browse/NMS-6634) with default, values and possible configuration parameters.
It is our first little project we use to establish and model the process and also building the ["How to contribute to documentation guide"](http://www.opennms.org/wiki/How_to_contribute_to_documentation) which is currently a work in progress.
The guys helping at the docs suggested to have a bi-weekley meeting and so I’ll drop a doodle at the opennms-docs mailing list to get a next appointment set up.
If you are interested in join, the opennms-docs is a low traffic mailing list and this is the place to be in the loop if you are interested on this topic.

Thanks for reading and I’m excited about the help you guys who want to help

Have a nice day.
