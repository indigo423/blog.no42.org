---
title: "Open Source Experience"
date: "2014-11-22"
tags: ['open source', 'asciidoc', 'opennms']
author: "Ronny Trommer"
noSummary: false
---

I spend a lot of time in the [OpenNMS](http://www.opennms.org) project and I love to work in [free software](https://fsfe.org/index.en.html) and the workflows around it.
We moved with our project from [SourceForge](http://sourceforge.net/) to [GitHub](https://github.com/) a few years ago and I think it was the right decision.
There are now some established workflows in this ecosystem and they tear down borders between different open source projects and here is an example of it.

I develop with [IntelliJ IDEA](https://www.jetbrains.com/idea/) and spend currently some time working in [documentation of OpenNMS](http://docs.opennms.org/).
We have migrated from [Docbook XML](http://www.docbook.org/) format to [AsciiDoc](http://en.wikipedia.org/wiki/AsciiDoc) and started with the help of a few brave community volunteers a new documentation environment.
I’ve found a plugin for IDEA which renders AsciiDoc and gave it a try to have a better workflow working on documentation and navigating through source code in just one program.

Unfortunately I run in an error message.
The project is hosted on [GitHub](https://github.com/asciidoctor/idea-asciidoc) and I’ve opened an [issue](https://github.com/asciidoctor/idea-asciidoc/issues/16) with the version and the behavior.
They responded my question just a few hours later.

They where really helpful and asked how it was installed to avoid basic mistakes.
The issue still existed and they asked me if its possible to provide the .adoc files to reproduce the error.
This was quite easy, the documentation I work with is also public on [GitHub](https://github.com/OpenNMS/opennms/tree/develop/opennms-doc/guide-admin/src/asciidoc), so I just sent them a link to the files.
The guys figured out, the problem occurred whenever I use the source code formatting from AsciiDoc, so it was easy to create a small test file to reproduce the issue.
Beside the fact finding the reason of the problem, they created also a new release of the plugin and sent me a link in the public comments and asked if I can verify the solution.
I’ve installed the new plugin and ran unfortunately in a different error, I’ve provided a screenshot and the detailed error message.

Just a few hours later they figured out, there was a reference in [AsciidoctorJ](https://github.com/asciidoctor/asciidoctor-gradle-plugin/issues/135) a dependency of the IDEA plugin which pointed to a already fixed [issue](https://github.com/jruby/jruby/issues/1248) in JRuby dealing with white spaces in a file path.
They updated to the latest version of JRuby and provided another version of the IDEA plugin just a few hours later which fixed my problem.

Please let imagine the procedure with a similar issue in a closed source software where the issue is in a dependency of a dependency.
This issue was fixed in 5 days, they provided two releases of the plugin and they responded to my comments in maximum a day!
I paid nothing – just the time providing information of my issue – which I had anyways even I had to pay for the software and the support.
There was not one moment blaming, finger pointing and complete transparency about three different open source projects to identify and fix the problem.

Thank you for this open source experience

– or my friend Q would sing: ♪ Everything is awesome … ♪
