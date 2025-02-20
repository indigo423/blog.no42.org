---
title: "Just another meaning about Business Process Monitoring"
date: "2009-11-28"
categories: ['OpenNMS']
tags: ['business-process-monitoring', 'opennms', 'bpm']
author: "Ronny Trommer"
noSummary: true
---

Zuviel Hotel ohne Internet bekommen mir irgendwie nicht wirklich gut.
Mit einem einfachen Text-Editor und viel Zeit, habe ich ein paar Gedanken zum Thema [Business Process Monitoring (BPM)](http://web.archive.org/web/20091226134837/http://en.wikipedia.org/wiki/Business_process_management#Monitoring) aufgeschrieben.
Häufig wird dies im Zusammenhang mit der Einführung eines Netzwerk-Management-Systems (NMS) oder Monitoring-Tools gesehen.

Wenn man sich im Internet zum Monitoring und Netzwerk-Management umsieht, wird man schnell feststellen, dass klassisches Netzwerk-Management und Monitoring durchgekaut scheinen und als ziemlich out gelten.
Stattdessen versuchen verschiedene Anbieter ihre NMS-Anwendungen und Tools, durch ein Feature namens "Business-Process-Monitoring" aufzuwerten.

Ich behaupte, dass jedes Management- oder Monitoring-Tool (wie bspw.: [OpenNMS](http://web.archive.org/web/20091226134837/http://www.opennms.org/), [Nagios](http://web.archive.org/web/20091226134837/http://www.nagios.org/), [Icinga](http://web.archive.org/web/20091226134837/http://www.icinga.org/), [Zabbix](http://web.archive.org/web/20091226134837/http://www.zabbix.org/), [Zenoss](http://web.archive.org/web/20091226134837/http://www.zenoss.com/) ...), mit der Fähigkeit eigene Skripte oder Programme auszuführen, zum Business Process Monitoring genutzt werden können.
Letztendlich liegt es an der Fähigkeit des Monitor-Entwicklers, wie gut er die Abläufe oder Prozesse in einem Unternehmen versteht und im Monitor (Skript/Programm) abbilden kann.
Wer nach Business Process Monitoring sucht, wird vermutlich erst einmal einen haufen [Marketing-Unterlagen](http://web.archive.org/web/20091226134837/https://h10078.www1.hp.com/cda/hpms/display/main/hpms_content.jsp?zn=bto&cp=1-11-15-25^4749_4000_100) stoßen, die nichts ausser Luftvokabular enthalten.
Das ganze ist auch ziemlich logisch, schließlich kann man den Test eines Geschäftsprozesses nicht mit einem einfachen ping-Test vergleichen.
Es gibt für die Parametrisierung eben eine ganze Menge "Kommt-ganz-darauf-an´s" zu klären. Die Wahl des Tools sehe ich daher eher zweitrangig.
Wie so oft, liegt für mich der Anbieter vorn, abgesehen vom Preis ;), der die Anforderungen am besten versteht und mit seinem Monitoring-Tool effizient umgehen kann.

Wie man sich leicht vorstellen kann, sind Business Process Monitore verhältnismässig teuer.
Das liegt daran, dass einerseits Ressourcen wie (Zeit, Personal, Dienstleister), um die Monitore zu entwickeln, andererseits auch Ressourcen wie CPU-Zeit und Lizenzen für die Anwendung oder Datenbank, benötigt werden.
Ein Business Process Monitor benötigt häufig für den Test genau die gleichen Ressourcen wie ein realer Anwender.
Bevor man sich also vollständig den [Buzzwords](http://web.archive.org/web/20091226134837/http://en.wikipedia.org/wiki/Buzzword) hingibt, sollte man sich zunächst klar machen, dass Geschäftsanwendungen, auch wenn sie [SAP](http://web.archive.org/web/20091226134837/http://en.wikipedia.org/wiki/SAP_AG#Products), [Microsoft Dynamics NAV](http://web.archive.org/web/20091226134837/http://en.wikipedia.org/wiki/Navision) etc. heißen, verteilte Netzwerk-Anwendungen sind, die eine Server- und Netzwerk-Infrastruktur benötigen und in den meisten Fällen zentralisiert aufgebaut sind.
Sorry an alle Vorstände, Geschäftsführer und BWL´er, ich weiss es würde besser gefallen, wenn man diesen ganzen Kram mit den ganzen Leuten nicht benötigen würde, geht aber leider nicht anders ;)


Monitoring layer model
TCP/IP-Schichten und deren Monitore

Die oben gezeigte Abbildung ist Anlehnung an das [TCP-Schichtmodell](http://web.archive.org/web/20091226134837/http://de.wikipedia.org/wiki/Internetprotokollfamilie#TCP.2FIP-Referenzmodell) entstanden und soll darstellen wo sich das BPM aus meiner Sicht einordnen lässt.
Die Unternehmens-Anwendungen sind also meistens über mehrere Server verteilt und hängen damit massgeblich von den Netzwerk-Schichten ab.
Es ist leicht verständlich, je höher in den Schichten überwacht wird, desto komplexer und spezieller müssen auch die Monitore sein.
Das gleiche gilt auch für die Fehlerdiagnose. Je weiter oben in den Schichten ein Fehler auftritt, desto mehr muss ein Support-Mitarbeiter wissen um den Fehler zu beheben.
Die Fehlerdiagnose erfolgt daher auch eher von unten nach oben. Die Tools ping, traceroute und nmap sind nicht ohne Grund die am Häufigsten verwendeten Tools die ein Administrator oder Support-Mitarbeiter zur Fehlerdiagnose verwendet.
Die Monitore in den unteren Schichten sind extrem günstig, da die meisten Netzwerk-Management und -Monitoring-Anwendungen fertige und leistungsfähige Monitore direkt mitbringen.

Ein ganz einfaches Beispielt sollte das hier verdeutlichen.
Sie haben einen Monitor geschrieben, der einen konkreten Anwendungsfall ihrer Geschäftsprozesse, bspw. den Abruf eines Lieferscheins oder eine Buchung, testet.
Auf dem Datenbankserver ist eine redundant ausgelegte Festplatte defekt oder ein redundanter Lüfter ist ausgefallen.
Sie werden keine Beeinträchtigung im Geschäftsprozess durch den Monitor feststellen, er funktioniert wie gewohnt.
Mit etwas Glück kann man sehen, dass die Ausführung vielleicht etwas länger dauert, der Rückschluss auf einen [RAID-Verband](http://web.archive.org/web/20091226134837/http://en.wikipedia.org/wiki/RAID) im Status ["degraded"](http://web.archive.org/web/20091226134837/http://www.dict.cc/englisch-deutsch/degraded.html) ist aber auch dem besten Netzwerk-Administrator wohl etwas zuviel abverlangt.
Der Ausfall einer weiteren Platte oder das Herunterfahren des Systems zum Schutz vor Überhitzung, wird den Geschäftsprozess dann wirklich erst beeinträchtigen, ab dann wird es meistens teuer.
Was hilft es also, wenn der komplizierteste Business-Prozesse in der letzten Abhängigkeit überwacht und getestet wird, dann im Fehlerfall aber überhaupt keine sinnvolle Hilfestellung zur Entstörung oder Eingrenzung des Problems vorliegt.
Sie haben also eine Möglichkeit durch Austausch der Festplatte oder des Lüfters zur Prävention verpasst. Die Überwachung des Business-Prozesses stellt also in meinen Augen eher am Ende der Monitoring-Kette eine Art, Qualitätssicherung dar.
Fällt ein Monitor, der einen Geschäftsprozess überwacht aus, dann haben auch letztendlich alle Redundanzen versagt und das Kind liegt schon im Brunnen. Meine Erfahrungen aus der Systembetreuung hat mir gezeigt, dass Fehler häufig in den unteren Schichten auftreten.
Bei der Einführung von BPM sollten man sich daher aus meiner Sicht, die Frage stellen ob ein Netzwerk-Management und Monitoring existiert und auch wie gewünscht funktioniert, da diese Überwachung sich implizit auch auf die Überwachung ihrer Geschäftsanwendung auswirkt.

gl & hf
