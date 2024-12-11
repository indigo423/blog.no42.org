---
title: "Dealing with secrets in OpenNMS Horizon"
date: "2024-12-11"
categories: ['Monitoring', 'How-To', 'OpenNMS']
tags: ['opennms', 'secrets', 'vault']
author: "Ronny Trommer"
noSummary: false
mermaid: true
---

Dealing with secrets in a monitoring platform is a tedious task.
In OpenNMS Horizon/Meridian (OpenNMS for short), are some places where you have just one option, and some with various options.
This article should help you to get an idea where you need to deal with secrets and credentials.
Secrets in OpenNMS are used for the following use cases:

1. System accounts for the OpenNMS itself, e.g. PostgreSQL as the database, Elasticsearch or Kafka
2. Access to monitored devices or application endpoints
3. Access to the monitoring application as a user
4. Access to the ReST API for integration

## System accounts for OpenNMS internal services

OpenNMS Horizon leverages other tools to perform it's monitoring tasks.
The PostgreSQL database is used to store Events, Alarms, Notifications, and the monitoring inventory.
Access to the PostgreSQL database is configured in the `opennms-datasources.xml`.
To give OpenNMS access to your database you have configure three types of credentials:

* Connection with permission to do administrative tasks, e.g. initializing the database during installation and changing the database schema on updates. This is usually configured as `opennms-admin` with the username `postgres` and 
* Connection with

{{< mermaid >}}
flowchart LR
y("👫 You") --> h{"🤝 Found this helpful?"}
h --> |Yes| r[/"⭐ Check out my featured posts!"/]
h --> |No| su[/"📝 Suggest changes by clicking near the title"/]
click r "/categories/featured" _blank
{{< /mermaid >}}
