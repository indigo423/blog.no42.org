---
title: "Hardening SSH for audit"
date: "2021-02-19"
categories: ['Technology', 'How-To']
tags: ['tools', 'ssh', 'security']
author: "Ronny Trommer"
noSummary: false
---

Running a server in the public requires some additional work.
Especially if you want management access via SSH for Ansible or if you want break stuff manually with fiddeling around :)

You can run an SSH audit of your public server using https://www.sshaudit.com.
This section here is a very condensed way to get an A rating.

Just use strong host key for authentication of the host

```
# file: /etc/ssh/sshd_config
HostKey /etc/ssh/ssh_host_ed25519_key
HostKey /etc/ssh/ssh_host_rsa_key
```

Delete existing keys and re-generate the RSA and ED25519 keys

```
cd /etc/ssh
rm ssh_host_*key*
ssh-keygen -t ed25519 -q -N "" -f ssh_host_ed25519_key
ssh-keygen -t rsa -b 4096 -q -N "" -f ssh_host_rsa_key
```

Restrict supported key exchange, cipher, and MAC algorithms

```
echo -e "\n# Restrict key exchange, cipher, and MAC algorithms, as per sshaudit.com\n# hardening guide.\nKexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512,diffie-hellman-group-exchange-sha256\nCiphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr\nMACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com\nHostKeyAlgorithms ssh-ed25519,ssh-ed25519-cert-v01@openssh.com,sk-ssh-ed25519@openssh.com,sk-ssh-ed25519-cert-v01@openssh.com,rsa-sha2-256,rsa-sha2-512,rsa-sha2-256-cert-v01@openssh.com,rsa-sha2-512-cert-v01@openssh.com" > /etc/ssh/sshd_config.d/ssh-audit_hardening.conf
````

Remove small Diffie-Hellman moduli

```
cp /etc/ssh/moduli /etc/ssh/moduli.backup
awk '$5 > 4095' /etc/ssh/moduli > "/etc/ssh/moduli.safe"
mv /etc/ssh/moduli.safe /etc/ssh/moduli
```

If there is no moduli file you can create it (may take hours)

```
ssh-keygen -G /etc/ssh/moduli.all -b 4096
ssh-keygen -T /etc/ssh/moduli.safe -f /etc/ssh/moduli.all
mv /etc/ssh/moduli.safe /etc/ssh/moduli
rm /etc/ssh/moduli.all
```

Restart OpenSSH server

```
systemctl restart sshd
```

Clients should use strong encryption

```
# file: /etc/ssh/ssh_config
HashKnownHosts yes
ConnectTimeout 30
KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,
    hmac-ripemd160-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,
    hmac-sha2-256,hmac-ripemd160,umac-128@openssh.com
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,
    aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
ServerAliveInterval 10
ControlMaster auto
ControlPersist yes
ControlPath ~/.ssh/socket-%r@%h:%p
```

For more details hardening SSH the following articles I've found useful:

* https://linux-audit.com/audit-and-harden-your-ssh-configuration/
* https://blog.weltraumschaf.de/blog/Hardening-Your-SSHd-with-Ansible/
* https://blog.samuel.domains/blog/security/hardening-openssh-all-in-one-place
* https://node-security.com/posts/ssh-server-hardening/
