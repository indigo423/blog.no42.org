---
title: "OpenNMS SNMP Monitor - You have found a secret"
date: "2009-12-11"
categories: ['OpenNMS']
tags: ['business-process-monitoring', 'opennms', 'bpm']
author: "Ronny Trommer"
noSummary: true
---

In [OpenNMS](http://web.archive.org/web/20091226134837/http://www.opennms.org/) wurde seit der Version 1.6.3 der [SNMP Monitor](http://web.archive.org/web/20091226134837/http://www.opennms.org/index.php/SNMP_Monitor) erweitert und die neuen Features sind [Release-Notes Beschreibung](http://web.archive.org/web/20091226134837/http://www.opennms.org/documentation/ReleaseNotesStable.html#opennms-1.6.3) vielleicht ein wenig untergegangen.
Die erweiterten Funktionen haben sich für mich als hilfreich erwiesen und sind mir einen Blog-Eintrag wert.
Die [OpenNMS Wiki Seite](http://web.archive.org/web/20091226134837/http://www.opennms.org/index.php/SNMP_Monitor) sind an der Stelle sehr gut dokumentiert und aktualisiert worden.
Grob zusammengefaßt sind folgende Funktionen erweitert worden:

* Es können jetzt optional komplette SNMP Tabellen anstatt von einzelnen OIDs überwacht werden
* Es kann die Anzahl eines gewünschten Status gezählt und gegen einen Schwellwert geprüft werden
* Die Fehlermeldung lässt sich über ein Template sprechend parametrisieren

Im folgenden wird die Einrichtung am Beispiel eines Monitors für ISDN B-Kanäle gezeigt.
Häufig werden Notfall-Dialup Verbindungen eingerichtet, wenn Internet Verbindungen oder VPNs nicht mehr möglich sind.
Mit diesem Monitor werden alle B-Kanäle überwacht, sobald eine Einwahl stattfindet und ein B-Kanal verwendet wird, fällt der Monitor herunter und informiert den Administrator, dass ein Benutzer oder Standort auf ISDN-Backup läuft.
Sollte eigentlich für alle Geräte funktionieren, welche die [ISDN-MIB](http://web.archive.org/web/20091226134837/http://www.oidview.com/mibs/0/ISDN-MIB.html) unterstützen.
Der abgefragte Tabelle ist übrigens isdnBearerOperStatus.
Zuerst wird dazu in der capsd-configuration.xml ein Dienst eingerichtet:

```xml
<protocol-plugin protocol="All-ISDN-Backup" class-name="org.opennms.netmgt.capsd.plugins.LoopPlugin" scan="on">
  <property key="ip-match" value="{ip-adresse-isdn-backup-router}" />
  <property key="is-supported" value="true" />
</protocol-plugin>
```

Der Monitor im pollerd sieht dann wie folgt aus:

```xml
<service name="All-ISDN-Backup" interval="300000" user-defined="false" status="on">
  <parameter key="retry" value="6" />
  <parameter key="timeout" value="4950" />
  <parameter key="port" value="161" />
  <parameter key="oid" value=".1.3.6.1.2.1.10.20.1.2.1.1.2" />
  <parameter key="walk" value="true" />
  <parameter key="operator" value="=" />
  <parameter key="operand" value="1" />
  <parameter key="match-all" value="true" />
  <parameter key="reason-template"
       value="One or more backup ISDN channels are active. \
    The state should be idle(${operand}) the observed value is ${observedValue}. \
    Syntax: idle(1), connecting(2), connected(3), active(4) " />
</service>
...
<monitor service="All-ISDN-Backup" class-name="org.opennms.netmgt.poller.monitors.SnmpMonitor"/>
```

Anstatt `key="match-all value="true"` kann auch der Wert `value="count"` gesetzt werden, zählt der Monitor die Abweichungen und man kann auf Schwellen prüfen.
Die Schwellen werden mit zusätzlichen Parametern `<parameter key="minimum" value="3">` sowie `<parameter key="maximum" value="10" />` gesetzt werden.

gl&hf
