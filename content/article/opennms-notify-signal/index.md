---
title: "Send notifications with Signal"
date: "2018-11-01"

tags: ['notifications','howto', 'opennms']
author: "Ronny Trommer"
noSummary: false
---

For some reasons I would like have notifications from my OpenNMS not via Mail, I want it in a separate channel on my smartphone and I don't want to pay for SMS.
I'm a [Signal](https://signal.org) user and found [signal-cli](https://github.com/AsamK/signal-cli/releases) which runs also on my CentOS 7.
Here is what is needed to use the signal-cli binary as a binary Notification Command in your OpenNMS instance.

This How-To will describe how to download the latest signal-cli tool, link it to your existing Signal account and how to configure OpenNMS to use it as a notification target.
You should have already an OpenNMS Horizon or Meridian running and you need to have a Signal account with the Signal app installed and configured on your smartphone.

#### Configuration

**Step 1: Download and extract the signal-cli tool**

We get a copy of the released files and extract the signal-cli to /opt/signal-cli on your OpenNMS server.

```bash
cd /opt
curl -L https://github.com/AsamK/signal-cli/releases/download/v0.6.0/signal-cli-0.6.0.tar.gz | tar xz
mv signal-cli-0.6.0 signal-cli
```

**Step 2: Link your existing Signal account with signal-cli**

```bash
cd /opt/signal-cli/bin
./signal-cli link -n my-opennms
tsdevice:/?uuid=ADW2cD2XjA7IX4arL9U7eQ&pub_key=BTrFfDdAJdaZ%2b%2FB05BsxelnrpQZT5sRJh2S7yb4fp1aO
```

Generate a QR Code from the link, I've used an online QR code generator [https://www.qrstuff.com](https://www.qrstuff.com).

Use "Plain Text" and use "Static - Embed text into code as-is".
Paste the tsdevice URL and download the generated QR code image.
You can now scan it with your Signal app which links your signal-cli to your account which is identified by your phone number.

Test if you can send yourself a message with (`-u` is your phone number with country code):

```bash
./signal-cli -u +4912345789 send -m "This is my first message" +4912345789
```

Important for our integration:

* `-u +4912345789`: This is the user which sends the notification
* `-m "the message": The message content which will be sent
* `+4912345789`: The phone number of the recipient, in this case I send it myself but can also be your collegue

The encryption and keys for *Signal* are stored in the home directory of your running as user which is `/root/.config`.

**Step 3: Create a wrapper script which can be used as a custom notification in OpenNMS**

To make the integration a little bit easier, I wrapped it up in a small script `/opt/signal/bin/signal-cliw.sh`

```bash
#!/bin/bash -e

SIGNAL_BINARY=/opt/signal/bin/signal-cli
LINKED_USER=+4912345789
MESSAGE="${2}"
RECIPIENT="${1}"
CONFIG=/root/.config
ERROR_LOG=/var/log/signal-cli.log

${SIGNAL_BINARY} -u "${LINKED_USER}" send -m "${MESSAGE}" "${RECIPIENT}" 2>>${ERROR_LOG}
```

Ensure the script is executable with `chmod +x signal-cliw.sh`.
You can use it now like that:

```bash
./signal-cliw.sh <target-phone-number> "<text message>"
```

**Step 4: Integration in OpenNMS**

Add a new notification command in `${OPENNMS_HOME}/etc/notificationCommands.xml`:

```xml
<command binary="true">
  <name>signal-cli</name>
    <execute>/opt/signal/bin/signal-cliw.sh</execute>
    <comment>Signal CLI</comment>
    <argument streamed="false">
      <switch>-mphone</switch>
    </argument>
    <argument streamed="false">
      <switch>-nm</switch>
    </argument>
</command>
```

As first argument for the `signal-cliw.sh` script is the *Mobile Phone* number used from a configure OpenNMS user.
The second argument we pass with `-nm` a short message text to our script which is configured in the the notification itself.
Restart OpenNMS so the changes will be applied.

**Step 5: Create a new Destination Path which uses Signal**

Create a notification *destination path* which uses your newly created *signal-cli* notification command.

[![](destination-path-thumb.png)](destination-path.gif)

**Step 6: Add a mobile phone number in your user account**

[![](mobile-number-thumb.png)](mobile-number.gif)

**Step 7: Configure a notification to use our new destination path**

[![](notification-thumb.png)](notification.gif)

**Step 8: Enable Notifications**

[![](enable-notification-thumb.png)](enable-notification.gif)

**Step 9: Test Notification**

[![](test-notification-thumb.png)](test-notification.gif)

Check if you get a notification for a node outage and a resolved message.

[![](notification-phone.png)](notification-phone.png)

#### Troubleshooting

If you have issues, to get the integration running, the *Notifd* is the main component which drives the bits and pieces in OpenNMS.
The daemon *Notifd* writes log files to `${OPENNMS_HOME/logs/notfid`.
If you need a more verbose output you can increase log output in `${OPENNMS_HOME/etc/log4j2.xml` by setting the log level from `WARN` to `DEBUG`.
The changes will be picked up automatically and you don't need a restart.

```xml
<KeyValuePair key="notifd"               value="WARN" />
```

gl & hf
