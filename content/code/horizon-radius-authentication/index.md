---
title: "Authenticate OpenNMS Horizon with FreeRADIUS"
date: "2018-07-22"
categories: ['Tutorial', 'OpenNMS']
tags: ['opennms', 'docker', 'radius', 'freeradius']
author: "Ronny Trommer"
noSummary: false
---

Centralized authentication is a core service as soon you have a network with more than 3 computers.
This article is about how to authenticate a OpenNMS Horizon 22.0.2 using RADIUS provided by a FreeRADIUS service.

In this example the FreeRADIUS server is configured to provide 3 users.
A dictionary is configured which returns 2 roles, _ROLE\_USER_ and _ROLE\_ADMIN_ which can be used to decide which security role is assigned in the OpenNMS Horizon Web UI.

To run the services locally, you can use all components in a [Docker Compose](https://github.com/indigo423/opennms-radius-auth/blob/master/docker-compose.yml) defined service stack.

***Step 1: Checkout the repository***

```sh
git clone https://github.com/indigo423/opennms-radius-auth.git
cd opennms-radius-auth
```

***Step 2: Initialize the service stack***

```
docker-compose up -d
```

***Step 3: Install OpenNMS Horizon Plugin protocol for RADIUS and restart***

```sh
docker-compose exec horizon yum install -y opennms-plugin-protocol-radius
docker-compose stop horizon
docker-compose up -d
```

You can now login with 4 users:

* `admin`/`admin`: Default initial admin user defined in `users.xml`
* `user1`/`u5er1p455`: RADIUS user in security role _ROLE\_ADMIN_ and _ROLE\_USER_
* `user2`/`u5er2p455`: RADIUS user in security role _ROLE\_USER_
* `user3`/`u5er3p455`: RADIUS user without security role, this user falls back into _ROLE\_USER_.

### Configuration FreeRADIUS

The FreeRADIUS configuration is built with the following configuration files:

```yaml
volumes:
  - ./freeradius/dictionary.opennms:/etc/raddb/dictionary.opennms <1>
  - ./freeradius/dictionary:/etc/raddb/dictionary <2>
  - ./freeradius/clients.conf:/etc/raddb/clients.conf <3>
  - ./freeradius/users:/etc/raddb/users <4>
```
1. Reply authentication message with a security role
2. Include the `dictionary.opennms` on startup of `radiusd`
3. Define IP range and shared secret to allow communication with RADIUS server
4. User with passwords and assigned security roles

### Configuration OpenNMS Horizon

```yaml
volumes:
  - ./jetty-overlay:/opt/opennms-jetty-webinf-overlay <1>
```
1. Authentication configuration for the Jetty Webapp

Enable `externalAuthenticationProvider in `applicationContext-spring-security.xml`

```xml
  <authentication-manager alias="authenticationManager">
    <!-- If a user is pre-authenticated, make sure their user details are populated correctly. -->
    <authentication-provider ref="preauthAuthProvider" />
    <!-- Use our custom authentication provider -->
    <authentication-provider ref="hybridAuthenticationProvider" />
    <!-- To enable external (e.g. LDAP, RADIUS) authentication, uncomment the following.
         You must also rename and customize exactly ONE of the example files in the
         spring-security.d subdirectory. -->
    <authentication-provider ref="externalAuthenticationProvider" />
  </authentication-manager>
  ```

Create a RADIUS configuration for Authentication in `spring-security.d/radius.xml`
```xml
  <beans:bean id="externalAuthenticationProvider" class="org.opennms.protocols.radius.springsecurity.RadiusAuthenticationProvider">
    <beans:constructor-arg value="freeradius"/> <1>
    <beans:constructor-arg value="SECRET"/> <2>
    <beans:property name="port" value="1812"/> <3>
    <beans:property name="timeout" value="5"/> <4>
    <beans:property name="retries" value="3"/> <5>
    <beans:property name="authTypeClass"><beans:bean class="net.jradius.client.auth.PAPAuthenticator"/></beans:property> <6>
    <beans:property name="defaultRoles" value="ROLE_USER"/> <7>
    <beans:property name="rolesAttribute" value="Unknown-VSAttribute(5813:1)"/> <8>
  </beans:bean>
```
1. Hostname or IP address of the RADIUS server
2. Shared secret for communication
3. Port RADIUS server is listening
4. Timeout for RADIUS requests
5. Retries for RADIUS requests
6. PAP authentication for clear text passwords
7. Define default role when no role is assigned
8. Attribute which is used to assign security roles