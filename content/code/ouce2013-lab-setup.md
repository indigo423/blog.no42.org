---
title: "OUCE 2013 Lab Setup"
date: "2013-03-15"
tags: ['events', 'ouce', 'opennms']
author: "Ronny Trommer"
noSummary: false
---

# System

* Ubuntu 12.10
* Language: English
* Keyboard Layout: English
* Login: opennms
* Pass: ouce2013

# Admins toolbox

```bash
sudo -s
apt-get install openssh-server
apt-get install vim tcpdump git-core htop joe nmap iftop
apt-get install snmp snmpd snmp-mibs-downloader
```

# Maven2 and Oracle Java 1.6

```bash
apt-get install maven2
wget http://files.opennms-edu.net/jdk-6u41-linux-x64.bin
chmod +x jdk-6u41-linux-x64.bin
./jdk-6u41-linux-x64.bin
mv jdk1.6.0_41 /opt
update-alternatives --install "/usr/bin/java" "java" "/opt/jdk1.6.0_41/bin/java" 1
update-alternatives --install "/usr/bin/javac" "javac" "/opt/jdk1.6.0_41/bin/javac" 1
update-alternatives --install "/usr/bin/javaws" "javaws" "/opt/jdk1.6.0_41/bin/javaws" 1
update-alternatives --install "/usr/bin/jar" "jar" "/opt/jdk1.6.0_41/bin/jar" 1
update-alternatives --install "/usr/lib/mozilla/plugins/mozilla-javaplugin.so" "mozilla-javaplugin.so" "/opt/jdk1.6.0_41/jre/lib/amd64/libnpjp2.so" 1
update-alternatives --config java
```

# Some privacy and data leak stuff

```bash
apt-get remove unity-lens-shopping
System Settings -> Privacy Include Online Search results OFF / Record Activity OFF
```

# Installing OpenNMS

```bash
update-alternatives --config java
vi /etc/apt/sources.list.d/opennms.list
deb http://debian.opennms.org stable main
deb-src http://debian.opennms.org stable main
wget -O - http://debian.opennms.org/OPENNMS-GPG-KEY | sudo apt-key add -
apt-get update
apt-get install opennms
echo "export JAVA_HOME=\"/opt/jdk1.6.0_41\"" >> /etc/profile
echo "export OPENNMS_HOME=\"/usr/share/opennms\"" >> /etc/profile
source /etc/profile
/usr/share/opennms/bin/runjava -s
vi /etc/postgresql/9.1/main/pg_hba.conf
file:/etc/postgresql/9.1/main/pg_hba.conf

host    all             all             127.0.0.1/32            trust
service postgresql restart
/usr/share/opennms/bin/install -dis
echo JAVA_HEAP_SIZE=768 >> /etc/opennms/opennms.conf
echo START_TIMEOUT=0 >> /etc/opennms/opennms.conf
service opennms start
apt-get install libwww-perl libxml-twig-perl
```

# iReport installieren

```bash
cd ~
wget http://files.opennms-edu.net/iReport-3.7.6.tar.gz
tar xzf iReport-3.7.6.tar.gz
mv iReport-3.7.6 /opt
chown opennms:opennms /opt/iReport-3.7.6 -R
apt-get install --no-install-recommends gnome-panel
gnome-desktop-item-edit /usr/share/applications/ --create-new
Name: iReport 3.7.6
Binary: /opt/iReport-3.7.6/bin/ireport
Icon: gnome-power-statistics.png
Comment: Jasper Reports-Report Designer
```

# Wallpaper

```bash
cd ~/Pictures
wget http://files.opennms-edu.net/wallpaper/free-software-ulf.jpg
cd /usr/share/backgrounds
wget http://files.opennms-edu.net/warty-final-ubuntu-ouce.png
sudo -i
xhost +SI:localuser:lightdm
su lightdm -s /bin/bash
gsettings set com.canonical.unity-greeter draw-user-backgrounds 'false'
gsettings set com.canonical.unity-greeter draw-grid 'false'
gsettings set com.canonical.unity-greeter background '/usr/share/backgrounds/warty-final-ubuntu-ouce.png'
```

# RRD-Tool

```bash
sudo apt-get install rrdtool
```

# Groovy

```bash
sudo -s
cd /root
wget http://files.opennms-edu.net/groovy-binary-2.1.1.zip
mv groovy-2.1.1 /opt
echo "export GROOVY_HOME=\"/opt/groovy-2.1.1\"" >> /etc/profile
source /etc/profile
ln -s /opt/groovy-2.1.1/bin/groovy /usr/local/bin/groovy
ln -s /opt/groovy-2.1.1/bin/groovyc /usr/local/bin/groovyc
ln -s /opt/groovy-2.1.1/bin/groovyConsole /usr/local/bin/groovyConsole
ln -s /opt/groovy-2.1.1/bin/groovysh /usr/local/bin/groovysh
```

# Gradle

```bash
wget http://files.opennms-edu.net/gradle-1.4-all.zip
unzip gradle-1.4-all.zip
mv gradle-1.4 /opt
echo "export GRADLE_HOME=\"/opt/gradle-1.4\"" >> /etc/profile
ln -s /opt/gradle-1.4/bin/gradle /usr/local/bin/gradle
```

# Workshop: Rule based event processing

```bash
cd ~
git clone http://www.github.com/m-schneider/ouce2013
cd ouce2013/groovy
. ./setenv.sh
cd ./non-gradle
./change-rules.sh
```

Output should look like:

```bash
Wed Mar 06 15:41:05 CET 2013 --- Current severity: 6
Wed Mar 06 15:41:05 CET 2013 --- Current priority: 2
Wed Mar 06 15:41:05 CET 2013 --- --- ---
Wed Mar 06 15:41:05 CET 2013 --- Changed severity: 7
Wed Mar 06 15:41:05 CET 2013 --- Changed priority: 1
```

# SNMPv3 Workshop

```bash
sudo apt-get install wireshark
apt-get install libsnmp-perl libnet-snmp-perl libcrypt-des-perl  libcrypt-rijndael-perl libdigest-hmac-perl libdigest-sha-perl  libcrypt-passwdmd5-perl libdigest-md5-file-perl
```

# Local Mailserver for notification

```bash
sudo apt-get install postfix
Set to: local only
postconf -e home_mailbox=Maildir/
sudo apt-get install dovecot-imapd
sudo vi /etc/dovecot/conf.d/10-mail.conf
File: /etc/dovecot/conf.d/10-mail.conf
```

```bash
mail_location = maildir:~/Maildir
Account: opennms@localhost
User: opennms
Pass: ouce2013
Server localhost
service dovecot restart
service postfix restart
Bluetooth deaktivieren:
```

```bash
sudo vi /etc/rc.local
rfkill block bluetooth
```
