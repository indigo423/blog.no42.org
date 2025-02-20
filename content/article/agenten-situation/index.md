---
title: "Die Agenten Situation"
date: "2009-11-27"
categories: ['Monitoring', '']
tags: ['osmc', 'snmp', 'nagios', ]
author: "Ronny Trommer"
noSummary: false
---

Auf der diesjährigen [Netways OSMC](http://web.archive.org/web/20091226134837/http://www.netways.de/osmc/y2009/programm/) wurde ein guter Vortrag von [Dr. Michael Schwartzkopff](http://web.archive.org/web/20091226134837/http://www.amazon.de/Clusterbau-Hochverf%C3%BCgbarkeit-pacemaker-OpenAIS-heartbeat/dp/3897219190/ref=sr_1_1?ie=UTF8&s=books&qid=1259408003&sr=1-1) über [Net-SNMP](http://web.archive.org/web/20091226134837/http://www.net-snmp.org/) gehalten.
Bei den anschliessenden Fragen stellte ich dann jedoch ziemlich schnell fest, dass einige Teilnehmer [check_by_ssh](http://web.archive.org/web/20091226134837/http://www.nagios-wiki.de/nagios/plugins/check_by_ssh) oder eigene Plugins mit [NRPE](http://web.archive.org/web/20091226134837/http://www.nagios-wiki.de/nagios/howtos/nrpe), [NSClient](http://web.archive.org/web/20091226134837/http://nsclient.org/nscp/) gegenüber [SNMP](http://web.archive.org/web/20091226134837/http://en.wikipedia.org/wiki/Snmp) vorziehen.
Da ich dem SNMP Protokoll eher freundlich gesinnt bin, kam es nach dem Vortrag zu wirklich konstruktiven Off-Topic Gesprächen.
Eines der am häufigst genannten schwächen, neben schlechten SNMP-Agenten, ist die Verwendung von [UDP](http://web.archive.org/web/20091226134837/http://en.wikipedia.org/wiki/User_Datagram_Protocol).
Die Verwendung von UDP als verbindungsloses und unbestätigtes Transportprotokoll wird als nicht ausreichend angesehen.
Weiterhin wird "Simple" in der Bezeichnung des Protokolls nicht wirklich als "Simple" empfunden.
Da hauptsächlich Kollegen mit reichlich Erfahrung aus dem [Nagios](http://web.archive.org/web/20091226134837/http://www.nagios.org/) und [Icinga](http://web.archive.org/web/20091226134837/http://www.icinga.org/) Umfeld anwesend waren, wurden Plugins für NRPE, NSClient und check_by_ssh als bessere Alternative beschrieben.

Zunächst möchte ich jedoch erst einmal kurz beschreiben warum ich zu SNMP stehe.
Jeder Entwickler, von [Open Source](http://web.archive.org/web/20091226134837/http://www.opensource.org/docs/osd), [Fauxpen Source](http://web.archive.org/web/20091226134837/http://fauxpensource.org/) oder kommerzieller Netzwerk-Management/-Monitoring-Anwendungen, der das SNMP Protokoll ignoriert und primär auf eigene Agenten setzt hat für mich ein [fail-by-design](http://web.archive.org/web/20091226134837/http://failbydesign.com/) Logo verdient.
Die größte bestehenden Management-Infrastruktur und deren Protokolle zu ignorieren halte ich für einen Fehler.
Es wäre das gleiche, wenn heute jemand eine Netzwerkanwendung schreibt und anstatt von [TCP/IP](http://web.archive.org/web/20091226134837/http://en.wikipedia.org/wiki/TCP/IP) ein eigenes Protokoll implementiert.

Um diese vielleicht etwas harsche Meinung zu verstehen, will ich kurz beschreiben wie ich SNMP sehe und warum ich - trotz der vorhanden SNMP-Agenten SNAFU´s - dafür eine Lanze breche:
SNMP ist

* ... herstellerübergreifend existent und verfügbar.
* ... auf Geräten verfügbar, auf denen proprietäre Agenten nicht installiert werden können.
* ... skalierbar.
* ... erweiterbar.
* ... mit v3 für gehobenen Sicherheitsanforderungen geeignet ohne die Skalierbarkeit zu beeinträchtigen.
* ... dazu da um Discovery zu ermöglichen. Es können Komponenten oder Konfigurationseinstellungen, wie bspw. Partitionen, NICs, IP-Adressen etc. automatisch ermittelt werden.
* ... das einzige standardisierte und verbreitete Protokoll das Management Objekte beschreibt. Komplette MIBs können automatisch importiert werden.
* ... häufig das Non-plus-Ultra was die Bereitstellung von Managementinformationen betrifft.

Die ersten beiden Punkte stellen für mich keiner weiteren Ausführung dar.
Was den Punkt Skalierbarkeit angeht, stehen wahrscheinlich noch einige Fragezeichen im Raum.
Wie kann ein Protokoll skalieren? Stellen wir uns dazu vor, es gilt ein Netzwerk mit mehr als 10.000 Geräten umfangreich zu überwachen.
Dazu benötigen wir ein Protokoll, welches besondere Eigenschaften erfüllen muss.
Eine Anwendung wie bspw. [OpenNMS](http://web.archive.org/web/20091226134837/http://www.opennms.org/), das bis zu 1.2 Mio. SNMP Daten im Interval von 5 Minuten verarbeitet, kann diese Leistung unter anderem nur durch seinen guten SNMP-Support erreichen.

Aus meiner Sicht muss ein Management-Protokoll, A - einen geringen Kommunikations-Overhead besitzen und B so wenig wie möglich Ressourcen auf dem Management-Server als auch auf dem Agenten binden.
Die einfache Tatsache, das Monitoring auf einem TCP-basierenden Agenten zu implementieren, schränkt die Skalierbarkeit in beiden Punkten ein.
Punkt A jeder TCP-basierende Agent benötigt einen [3-Wege-Handshake](http://web.archive.org/web/20091226134837/http://www.tcpipguide.com/free/t_TCPConnectionEstablishmentProcessTheThreeWayHandsh-3.htm) um eine Kommunikation überhaupt möglichen zu machen.
Alle übertragenen Pakete werden bestätigt und falls fehlerhaft neu übertragen.
Punkt B - Für die Kommunikation über TCP wird eine Sitzung aufgebaut die vom Betriebssystem verwaltet werden muss.
Für die Dauer der Sitzung werden Ressourcen gebunden.
Wie man sehen kann ist allein die Entscheidung, ob ein Agent UDP als verbindungsloses und unbestätigtes Protokoll oder TCP als bestätigtes, verbindungsorientiertes Protokoll verwendet, für die Skalierbarkeit sehr entscheidend.

Stellen wir uns jetzt noch vor wie holen Daten für das Monitoring per [SSH](http://web.archive.org/web/20091226134837/http://en.wikipedia.org/wiki/Ssh).
Das bedeutet dann, dass über [PKI](http://web.archive.org/web/20091226134837/http://en.wikipedia.org/wiki/Public_key_infrastructure) eine sichere Verbindung hergestellt, ein Schlüsselaustausch erfolgt und zum Schluss der Verkehr zum Austausch der Daten [symmetrisch](http://web.archive.org/web/20091226134837/http://en.wikipedia.org/wiki/Symmetric-key_algorithm) verschlüsselt wird.
Ich denke es wird schnell klar, dass man hier nicht mehr von einer schlanken ressourcenschonenden Kommunikation sprechen kann.

## Warum ich bei !SNMP-Agenten erst einmal skeptisch bin

Es ist aus meiner Sicht, viel leichter einen vom Betriebssystem bereitgestellten SNMP-Agenten zu auszurollen und zu konfigurieren als 3rd-Party Agenten.
Ich kann jeden Administrator verstehen, dem es mulmig wird einen NSClient mit irgendwelchen DLL-Tricks auf einem produktiven System zu installieren.
Zumal Sicherheits- oder Fehlerpatches nicht über das Betriebssystem unterstützt und ausgeliefert werden.
Der Administrator ist dann dafür selbst verantwortlich. Zusätzlich halte ich es für verschwendete Energie die 17. Variante zu Ermittlung der CPU oder Netzwerk-Parameter in einem Skript oder Plugin zu implementieren.
Die Verteilung von 3rd-Party Agenten erfordern meines erachtens einen höheren Aufwand bei der Installation und zusätzlich wollen diese Agenten auch irgendwie aktualisiert, gepflegt und gewartet werden.
Last but not least entsteht durch die Verwendung von proprietären Agenten, eine unnötige Bindung an eine bestimmte Netzwerk-Management oder -Monitoring Anwendung.
Da es heutzutage Geräte gibt, die einzig und allein nur mit SNMP überwacht werden können, kommt es zwangsläufig zur Notwendigkeit, mehrere Management Protokolle auszurollen.
Warum dann nicht gleich SNMP?
Zusätzlich kann man in dem Beitrag ["The Many Uses of Net-SNMP"](http://web.archive.org/web/20091226134837/http://www.adventuresinoss.com/?p=1147) von Tarus Balog einen schöne Einblick bekommen, wir gut und vielseitig man Net-SNMP einsetzen kann.
Der eine oder andere Unix oder Linux Administrator wird sehen wie einfach Prozesse oder Skripte im Monitoring verwendet werden können und über SNMP in jeder belieben Management-Anwendung nutzen zu können.
Viele werden festellen dass Net-SNMP eh schon auf fast jedem Server läuft und nur vernünftig eingerichtet werden muss.

## Tricks and Traps

Der vielen Vorteilen zum Trotz, möchte ich aber nicht verschweigen, dass auch mir die Realität gezeigt hat, dass es hin und wieder nette Überraschungen gibt.
Es gibt wirklich schlechte SNMP-Agenten, die nicht stabil laufen oder sich durch fehlenden Support von SNMP v3 auszeichnen.
Administratoren werden fast immer dafür bestraft, wenn keine Marken oder Standardhardware verwendet wird.
SNMP-Agenten sind bei No-Name Produkten häufig nicht standardkonform implementiert oder extrem instabil, da Erfahrungen oder der Einsatz in großen Umgebungen nicht ausreichend getestet ist.
Die vollständige und aktuelle Beschreibung von [MIBS](http://web.archive.org/web/20091226134837/http://en.wikipedia.org/wiki/Management_Information_Base) ist nicht verfügbar und damit kann es sein, dass die SNMP-Implementierung wertlos wird.
Schönen Gruß an [Astaro](http://web.archive.org/web/20091226134837/http://www.astaro.de/) ;)
Außerdem kann es sein, dass in besonders sicheren Umgebungen mit Firewalls oder [VPNs](http://web.archive.org/web/20091226134837/http://en.wikipedia.org/wiki/Virtual_private_network), das UDP-Protokoll Schwierigkeiten bereiten kann.
An diesen speziellen Stellen in der Überwachung kann man sich zu recht Gedanken machen, mehr fällt mir dazu spontan nicht ein.
So long ...

gl & hf