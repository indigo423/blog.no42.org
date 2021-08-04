---
title: "Installing Node Exporter on Linux"
date: "2021-03-11"
categories: ['Technology', 'Open-Source']
tags: ['prometheus', 'opennms']
author: "Ronny Trommer"
noSummary: false
---

In OpenNMS Horizon 28+ is now a [PrometheusCollector](https://docs.opennms.com/horizon/28.0.1/operation/performance-data-collection/collectors/prometheus.html) available.
It scrapes the metrics from the provided exporter pages and allows to add data collections.
As of speaking today it is not 100% feature complete, scraping data types like histograms is not implemented yet.
If you want to play around here is a quick way to get the Linux [Node_Exporter](https://github.com/prometheus/node_exporter) installed.

### Download Node_Exporter

```
wget https://github.com/prometheus/node_exporter/releases/download/v1.2.0/node_exporter-1.2.0.linux-amd64.tar.gz
tar xzf node_exporter-1.2.0.linux-amd64.tar.gz
mv node_exporter-1.2.0.linux-amd64/node_exporter /usr/local/bin
mkdir -p /var/lib/node_exporter
```

### Authentication

Save the following python script to a file named `gen-pass.py`, (requires `apt install python3-bcrypt`)

```python
import getpass
import bcrypt

password = getpass.getpass("password: ")
hashed_password = bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt())
print(hashed_password.decode())
```

To create a password hash run it with:

```
python3 gen-pass.py
```

You should get a prompt for the password and use the hash in your basic auth configuration.

### Create basic config

File: `/etc/node_exporter/config.yaml`

```
basic_auth_users:
  prometheus: $2b$09$jlnZqhti2frPWS69U8XmM.vwy6K0J5R0kmaCSb4IvNBXNXOlIKAC.
```

### Create systemd unit

File: `/etc/systemd/system/node_exporter.service`
```
[Unit]
Description=Prometheus Node Exporter
After=network-online.target

[Service]
Type=simple
User=node-exp
Group=node-exp
ExecStart=/usr/local/bin/node_exporter \
    --collector.systemd \
    --collector.textfile \
    --collector.textfile.directory=/var/lib/node_exporter \
    --web.config=/etc/node_exporter/config.yaml \
    --web.listen-address=0.0.0.0:9100

SyslogIdentifier=node_exporter
Restart=always
RestartSec=1
StartLimitInterval=0

ProtectHome=yes
NoNewPrivileges=yes

ProtectSystem=strict
ProtectControlGroups=true
ProtectKernelModules=true
ProtectKernelTunables=yes

[Install]
WantedBy=multi-user.target
```

1. Reload systemd with `systemctl deaemon-reload`
2. Start up with `systemctl enable --now node_exporter.service`
