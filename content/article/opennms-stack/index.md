---
title: "Quick manual Kafka OpenNMS stack"
date: "2021-08-05"
categories: ['OpenNMS', 'Tutorial', 'Just-The-Fun-Parts']
tags: ['howto', 'opennms']
author: "Ronny Trommer"
noSummary: false
---

We have gathered a few ready-to-run Docker stacks in our public [stack-play](www.github.com/opennms-forge/stack-play) GitHub repository. 
But sometimes you need Kafka, Zookeeper and OpenNMS quickly on a baremetal deployment without Docker.
Here a few quick notes how to get the bare minimum up and running.

## Zookeeper

Install OpenJDK 11 JRE

```terminal
sudo apt install -y openjdk-11-jre
```

Create a user for zookeeper

```terminal
sudo adduser --system --home /opt/zookeeper --disabled-login zookeeper
```

Create a logs directory

```terminal
sudo mkdir /var/log/zookeeper
sudo chown zookeeper:nogroup /var/log/zookeeper -R
```

Install zookeeper

```terminal
curl -L https://downloads.apache.org/zookeeper/zookeeper-3.7.0/apache-zookeeper-3.7.0-bin.tar.gz | tar xz
sudo mv apache-zookeeper-3.7.0-bin/* /opt/zookeeper && rm -r apache-zookeeper-3.7.0-bin/
sudo chown zookeeper:nogroup /opt/zookeeper -R
sudo mkdir /var/zookeeper
sudo chown zookeeper:nogroup /var/zookeeper -R
```

Configure Zookeeper

```terminal
sudo -u zookeeper vi /opt/zookeeper/conf/zoo.cfg
```

```bash
tickTime=2000
dataDir=/var/zookeeper
clientPort=2181

## Metrics Providers
#
# https://prometheus.io Metrics Exporter
#metricsProvider.className=org.apache.zookeeper.metrics.prometheus.PrometheusMetricsProvider
#metricsProvider.httpPort=7000
#metricsProvider.exportJvmInfo=true

## Running a replicated Zookeeper
#initLimit=5
#syncLimit=2
#server.1=zoo1:2888:3888
#server.2=zoo2:2888:3888
#server.3=zoo3:2888:3888
```

Create Zookeepr system unit

```terminal
sudo vi /etc/systemd/system/zookeeper.service
```

```bash
[Unit]
Requires=network.target remote-fs.target
After=network.target remote-fs.target

[Service]
Type=simple
User=zookeeper
Group=nogroup
ExecStart=/opt/zookeeper/bin/zkServer.sh start-foreground
ExecStop=/opt/zookeeper/bin/zkServer.sh stop
Restart=on-abnormal

[Install]
WantedBy=multi-user.target
```

Reload systemd and run Zookeeper

```terminal
sudo systemctl daemon-reload
sudo systemctl enable --now zookeeper
```

## Kafka

Install OpenJDK 11 JRE

```terminal
sudo apt install -y openjdk-11-jre
```

Create a user for Kafka

```terminal
sudo adduser --system --home /opt/kafka --disabled-login kafka
```

Create logs directory

```terminal
sudo mkdir /var/log/kafka
sudo chown kafka:nogroup /var/log/kafka -R
```

Install Kafka

```terminal
curl https://downloads.apache.org/kafka/2.8.0/kafka_2.13-2.8.0.tgz | tar xz
sudo mv kafka_2.13-2.8.0/* /opt/kafka && rm -r kafka_2.13-2.8.0
sudo chown kafka:nogroup /opt/kafka -R
```

Configure log directory

```terminal
vi /opt/kafka/config/server.properties
```

```terminal
log.dirs=/var/log/kafka
```

Create sytem unit

```bash
[Unit]
Requires=zookeeper.service
After=zookeeper.service

[Service]
Type=simple
User=kafka
Group=nogroup
ExecStart=/bin/sh -c '/opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties > /var/log/kafka/kafka.log 2>&1'
ExecStop=/opt/kafka/bin/kafka-server-stop.sh
Restart=on-abnormal

[Install]
WantedBy=multi-user.target
```

Reload systemd and run Zookeeper

```terminal
sudo systemctl daemon-reload
sudo systemctl enable --now zookeeper
```

## OpenNMS Horizon

Install OpenJDK 11 JDK

```terminal
apt update && apt -y install openjdk-11-jdk
```

Run the OpenNMS installer

```terminal
wget https://raw.githubusercontent.com/opennms-forge/opennms-install/master/bootstrap-debian.sh
bash bootstrap-debian.sh
```
