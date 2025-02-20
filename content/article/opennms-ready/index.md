---
title: "OpenNMS ready?"
date: "2009-12-03"
categories: ['Monitoring', 'OpenNMS']
tags: ['opennms', 'snmp']
author: "Ronny Trommer"
noSummary: false
---

Es gibt Dinge die werden einem bei der Einführung eines NMS häufig nicht gesagt, ganz ohne Arbeit gehts leider nicht.
Die alleinige Installation eines Netzwerk-Management-Systems ist, neben der eigentlichen Auswahl - die schon ziemlich nervenaufreibend sein kann, nur die halbe Miete.
Mit dem Einsatz eines [NMS](http://web.archive.org/web/20091226134837/http://en.wikipedia.org/wiki/Simple_Network_Management_Protocol) wollen [SNMP-Agenten](http://web.archive.org/web/20091226134837/http://en.wikipedia.org/wiki/Simple_Network_Management_Protocol) befragt, [SNMP-Traps](http://web.archive.org/web/20091226134837/http://en.wikipedia.org/wiki/Simple_Network_Management_Protocol) und [Syslog](http://web.archive.org/web/20091226134837/http://en.wikipedia.org/wiki/Syslog) Events empfangen und ausgewertet werden.
Um von einem NMS richtig profitieren zu können, kommen also nicht darum herum, sich mit Ihren Geräten und Netzwerk-Komponenten zu beschäftigen.
Die folgende, nicht unbedingt vollständige Aufzählung, können als Hilfestellung bei der Einführung von [OpenNMS](http://web.archive.org/web/20091226134837/http://www.opennms.org/) oder einem jeden anderen NMS hilfreich sein.

* Erstellen Sie eine Standardkonfiguration für Ihre SNMP-Agenten. Für OpenNMS reicht eine "read-only" community die am besten nicht "public" ist. Versuchen Sie Version 2c zu priorisieren, wenn nichts anderes geht auf Version 1 zurückgreifen. Überlegen Sie sich ob SNMP Version 3 für Sie in Frage kommt und entsprechend von den Agenten unterstützt wird.
* Überlegen Sie sich welche Geräte über Syslog oder SNMP-Traps zentral protokolliert werden sollen. Bei Geräten die beides unterstützen, entscheiden Sie sich für eine Variante. Bei der Wahl der Events vom Gerät gesendet werden soll gilt: "Weniger ist manchmal mehr". Nur wirklich kritische Events machen häufig sinn. Notfalls an einem Gerät exemplarisch austesten und dann entscheiden ob Syslog oder SNMP-Traps besser geeignet ist. Legen Sie eine entsprechende Konfiguration zum roll-out für SNMP-Traps oder Syslog fest.
* Prüfen Sie ob Ihre Geräte einem Namensschema entsprechen und diese auf den Geräten selbst und im [DNS](http://web.archive.org/web/20091226134837/http://en.wikipedia.org/wiki/Domain_Name_System) korrekt eingetragen sind. Für OpenNMS kann im Wiki unter [Regeln und Filter](http://web.archive.org/web/20091226134837/http://www.opennms.org/wiki/Filters) für Inspiration gesorgt werden um Geräte zu gruppieren. Solche Schemas sind häufig pflegeleichter als die manuelle Zuordnung über [Surveillance-Categories](http://web.archive.org/web/20091226134837/http://www.opennms.org/wiki/Categories).
* Stellen Sie sicher, dass vom NMS-Server alle relevanten Anwendungen und Geräte erreicht werden können (Firewalls, Routing etc.)
* Bei Linux oder Unix-Systemen mit SNMP können Partitionen und Prozesse ohne große Umstände überwachte werden (direktive "disk" und "proc"). Berücksichtigen Sie die Einstellungen beim ausrollen Ihrer SNMP-Konfiguration.
* Prüfen Sie welche SNMP-Agenten welche SNMP-Versionen und Konfigurationen unterstützen. Ein [Skript](http://web.archive.org/web/20091226134837/http://www.opennms.org/wiki/Script:_Multiple_SNMP_Community_String) aus dem OpenNMS Wiki kann Ihnen hilfreich sein und sehr schnell zeigen, welche Communities in welcher Version auf den IP-Adressen verwendet werden kann.
* Überlegen Sie sich wie Sie Geräte eintragen wollen, manuelles Provisioning oder über automatisches Discovery.
* Geräte mit redundanten oder virtuellen IP-Adressen können im Discovery Schwierigkeiten bereiten. Isolieren Sie diese Geräte und betrachten Sie diese gesondert, meistens müssen diese Geräte manuell im NMS bereitgestellt werden.
* Verlieren Sie sich nicht in den Details beim Monitoring von komplexen Abläufen. Bei der Einrichtung von Monitoren hilft das [KISS-Prinzip](http://web.archive.org/web/20091226134837/http://en.wikipedia.org/wiki/Keep_it_simple_stupid).

Ich gehe nicht davon aus, dass die Liste vollständig kann aber für den ein oder anderen ein Anhaltspunkt sein.
Wie man sieht, sollte man sich über die eine oder andere Sache Gedanken machen.
Angefangen von Netzwerk-Komponenten wie [Router](http://web.archive.org/web/20091226134837/http://en.wikipedia.org/wiki/Router), [Switches](http://web.archive.org/web/20091226134837/http://en.wikipedia.org/wiki/Network_switch), [USVs](http://web.archive.org/web/20091226134837/http://en.wikipedia.org/wiki/Uninterruptible_power_supply) oder [Firewalls](http://web.archive.org/web/20091226134837/http://en.wikipedia.org/wiki/Firewall) bis hin zu Anwendungsprotokollen, können sehr viele Informationen genutzt werden, die zur Verbesserung der Netzwerkqualität verwendet werden können.

gl & hf
