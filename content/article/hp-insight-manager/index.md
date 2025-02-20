---
title: "OpenNMS meets HP InsightManager"
date: "2009-12-10"
author: "Ronny Trommer"
categories: ['OpenNMS', 'HP', 'How-To']
tags: [ 'opennms', 'snmp', 'hp', 'ilo' ]
noSummary: false
---

Nach einer relativ langen Nacht und etlichen Stunden [asterisk](http://web.archive.org/web/20091226134837/http://www.asterisk.org/)-[iaxmodem](http://web.archive.org/web/20091226134837/http://iaxmodem.sourceforge.net/)-[hylafax](http://web.archive.org/web/20091226134837/http://www.hylafax.org/content/Main_Page) debugging habe ich die gunst der Stunde genutzt und die vorbildlich konfigurierten [HP InsightManager](http://web.archive.org/web/20091226134837/http://h18013.www1.hp.com/products/servers/management/hpsim/index.html?jumpid=go/hpsim) genauer angesehen.
Die folgenden [SNMP-OIDs](http://web.archive.org/web/20091226134837/http://en.wikipedia.org/wiki/Simple_Network_Management_Protocol) haben sich aus meiner Sicht für die Überwachung als sinnvoll ergeben:

**CPQIDA-MIB**

| Name              | OID                          |
|:------------------|:-----------------------------|
| cpqDaSpareStatus  | .1.3.6.1.4.1.232.3.2.4.1.1.3 |
| cpqDaLogDrvStatus | .1.3.6.1.4.1.232.3.2.3.1.1.4 |
| cpqDaPhyDrvStatus | .1.3.6.1.4.1.232.3.2.5.1.1.6 |

CPQHLTH-MIB

| Name                         | OID                            |
|:-----------------------------|:-------------------------------|
| cpqHeThermalTempStatus       | .1.3.6.1.4.1.232.6.2.6.3.0     |
| cpqHeThermalSystemFanStatus  | .1.3.6.1.4.1.232.6.2.6.4.0     |
| cpqHeThermalCpuFanStatus     | .1.3.6.1.4.1.232.6.2.6.5.0     |
| cpqHeFltTolPowerSupplyStatus | .1.3.6.1.4.1.232.6.2.9.3.1.5   |
| cpqHeResMemModuleCondition   | .1.3.6.1.4.1.232.6.2.14.11.1.5 |


Die MIBS können von der [ByteSphere MIB-Online Datenbank](http://web.archive.org/web/20091226134837/http://www.oidview.com/mibs/232/md-232-1.html) heruntergeladen werden.
Für die Überwachung habe ich den SNMP-Monitor verwendet wie er in der Version ab 1.6.4 mit der Möglichkeit zum SNMP-Table Monitoring bietet.
Die vollständige Konfiguration ist im [OpenNMS Wiki HP InsightManager](http://web.archive.org/web/20091226134837/http://www.opennms.org/wiki/HP_Insight_Manager) dokumentiert und beschrieben.
Für den ein oder anderen sollten damit defekte Lüfter, RAID-Verbände und andere Überraschungen keine Probleme mehr darstellen.

gl & hf
