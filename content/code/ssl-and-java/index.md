---
title: "SSL and Java"
date: "2018-11-26"
tags: ['ssl', 'java', 'ldaps', 'letsencrypt']
author: "Ronny Trommer"
noSummary: false
---

Running applications with a current Java is not a big deal thanks [Let's Encrypt](https://letsencrypt.org/).
This article describes what happens if you want to authenticate your OpenNMS against LDAP using SSL with a self-certified certificate.

First of all I assume you have confiured verything so you can authenticate against _LDAP_ in plaintext and you got a role mapping as you wanted it.
If not you can have a look [here](https://blog.no42.org/code/horizon-ldap-authentication/).

So the naive approach would be, just changing the line in your `activeDirectory.xml` from

```xml
<beans:value>ldap://your-ads.example.org:389/</beans:value>
```

to 

```xml
<beans:value>ldaps://your-ads.example.org:636/</beans:value>
```

but unfortunately you will notice an exception in your `${OPENNMS_HOME}/logs/web.log` with the following content:

```
sun.security.validator.ValidatorException: PKIX path building failed: sun.security.provider.certpath.SunCertPathBuilderException: unable to find valid certification path to requested target
	at sun.security.validator.PKIXValidator.doBuild(PKIXValidator.java:387)
	at sun.security.validator.PKIXValidator.engineValidate(PKIXValidator.java:292)
	at sun.security.validator.Validator.validate(Validator.java:260)
	at sun.security.ssl.X509TrustManagerImpl.validate(X509TrustManagerImpl.java:324)
	at sun.security.ssl.X509TrustManagerImpl.checkTrusted(X509TrustManagerImpl.java:229)
	at sun.security.ssl.X509TrustManagerImpl.checkServerTrusted(X509TrustManagerImpl.java:124)
	at sun.security.ssl.ClientHandshaker.serverCertificate(ClientHandshaker.java:1351)
	at sun.security.ssl.ClientHandshaker.processMessage(ClientHandshaker.java:156)
	at sun.security.ssl.Handshaker.processLoop(Handshaker.java:925)
	at sun.security.ssl.Handshaker.process_record(Handshaker.java:860)
	at sun.security.ssl.SSLSocketImpl.readRecord(SSLSocketImpl.java:1043)
	at sun.security.ssl.SSLSocketImpl.performInitialHandshake(SSLSocketImpl.java:1343)
	at sun.security.ssl.SSLSocketImpl.writeRecord(SSLSocketImpl.java:728)
	at sun.security.ssl.AppOutputStream.write(AppOutputStream.java:123)
	at sun.security.ssl.AppOutputStream.write(AppOutputStream.java:138)
	at SSLPoke.main(SSLPoke.java:31)
Caused by: sun.security.provider.certpath.SunCertPathBuilderException: unable to find valid certification path to requested target
	at sun.security.provider.certpath.SunCertPathBuilder.build(SunCertPathBuilder.java:145)
	at sun.security.provider.certpath.SunCertPathBuilder.engineBuild(SunCertPathBuilder.java:131)
	at java.security.cert.CertPathBuilder.build(CertPathBuilder.java:280)
	at sun.security.validator.PKIXValidator.doBuild(PKIXValidator.java:382)
	... 15 more
```

This means your certificate is not trusted by the Java Virtual machine and you have to import self-signed certificate and make it available to your Java Virtual Machine.

***Step 1: Optain the certificate from the server***

```bash
openssl \
  s_client \ 
  -showcerts \ 
  -connect your-ads.example.org:636 \ 
  -servername your-ads.example.org \ 
  < /dev/null \ 
  > my-certificate.cert
```

The certificate is downloaded and stored in your current directory named `my-certificate.cert`.

***Step 2: Create a trust-store file with your cerfiticate***

```bash
keytool \
  -import \ 
  -v \ 
  -trustcacerts \ 
  -alias your-ads.example.org \ 
  -file my-certificate.cert \ 
  -keystore /opt/opennms/etc/trust-store.jks
```

A trust store file is created in your OpenNMS Horizon configuration directory.
You will be asked for a password when you create the trust-store file, remember the password, if you need to add more certificates you need this password.


***Step 3: Test if your trust store file works***

Download a SSL Poke test class which can be easily executed and allows you to verify your trust store file.

```
wget https://confluence.atlassian.com/kb/files/779355358/779355357/1/1441897666313/SSLPoke.class
```

Run the SSL test using the your custom trust store file using the following command:

```
java -Djavax.net.debug=ssl -Djavax.net.ssl.trustStore=<path/to/your/trust-store.jks> SSLPoke your-ads.example.org 636
Successfully connected
```

When you use this trust store you can now connect to your Active Directory server.

***Step 4: Configure OpenNMS to use your trust store file***

On startup you can add Java options in `${OPENNMS_HOME}/etc/opennms.conf` with adding the following content:

```
ADDITIONAL_MANAGER_OPTIONS="${ADDITIONAL_MANAGER_OPTIONS} -Djavax.net.ssl.trustStore=/path/to/trust-store.jks"
```

If you run with Docker you have to inject the trust-store file into the container image.
You can use the etc-overlay for example and set your Java options in a `JAVA_OPTS` environment variable like this:
Here a short example where the `turst-store.jks` file is in a local directory on your host named `etc-overlay` and is mounted into the container.

```yaml
---
version: '3.4'
.
.
services:
  horizon:
    .
    environment:
      - JAVA_OPTS=-Djavax.net.ssl.trustStore=/opt/opennms/etc/trust-store.jks
    volumes:
      - ./etc-overlay:/opt/opennms-etc-overlay
```

### Caveats

You should be aware there is a catch using a custom trust store file, your JVM trusts now ***only*** those certificates in your trust store.
If you want to add them globally to the Java Virtual Machine certificates you need to add them to the global `%JAVA_HOME%\lib\security\cacerts` of your Java installation.


```bash
keytool \
  -import \ 
  -v \ 
  -trustcacerts \ 
  -alias your-ads.example.org \ 
  -storepass changeit \
  -noprompt \
  -file my-certificate.cert \ 
  -keystore ${JAVA_HOME}\lib\security\cacerts
```

This way all Java applications using this JVM will trust your certificates in addtion to the ones coming with the Java Virtual Machine.

So long gl & hf
