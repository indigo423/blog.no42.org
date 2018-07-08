---
title: "RRDtool graph improvement"
date: "2014-03-18"
tags: ['opennms', 'rrdtool']
author: "Ronny Trommer"
---

If you have [OpenNMS](http://www.opennms.org/) with [RRDtool](http://www.rrdtool.org/) running, you can improve the whole rendering a little bit just by replacing the `command.prefix` in the following files:

* `snmp-graph.properties`
* `snmp-adhoc-graph.properties`
* `response-graph.properties`
* `response-adhoc-graph.properties`

```sh
command.prefix=/usr/bin/rrdtool graph - --imgformat PNG --font DEFAULT:7 --font TITLE:10 --start {startTime} --end {endTime} -E --width=1000 --height=180
```

I don’t like the stamp size graphs in OpenNMS, so I changed it for all.
It could be problematic if you have grouped graph report (KSC report).
So if you have trouble, you can just remove the –width and –height parameter.
The command will also overwrite the width and height for all graphs, so they have all the same size.
You have to be careful if you have KSC reports with multiple columns.
If you have RRDtool running, you can improve the graphs with anti-aliasing using a few additional parameters:

```sh
command.prefix=/usr/bin/rrdtool graph - --imgformat PNG -R normal --font-render-mode normal -l 0 -E --font DEFAULT:7 --font TITLE:10 --start {startTime} --end {endTime} -c ARROW#5e5e5e --width=1000 --height=180
```

![Default graph without anti-aliasing](/images/rrd-graph-default.png)

![Default graph without anti-aliasing](/images/rrd-graph-antialiased.png)
