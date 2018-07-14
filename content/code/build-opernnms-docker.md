---
title: "Build OpenNMS with Docker"
date: "2018-07-14"
tags: ['opennms', 'docker', 'cicd', 'java']
author: "Ronny Trommer"
noSummary: false
---

Being able to compiling an Open Source project is important.
You can change the code, so you should also able to build it.

Why is there a dedicated Docker image for the build environment?
The dependencies running a pre-build OpenNMS Horizon distribution and compiling from source are different.
To build OpenNMS Horizon you need Apache Maven and to compile JICMP, JRRD you need a C compiler environment.
This is nothing you want to carry when you just want to run OpenNMS Horizon.

The build environment for OpenNMS depends on the following components and is easiest built on a Linux CentOS 7 environment.

What do you need to compile OpenNMS:

* Linux with git
* OpenJDK Development Kit 8
* Apache Maven
* gcc with C++ build environment
* When you want to run OpenNMS you need at least JRRD, JICMP and PostgreSQL

Docker is a great way to bundle these dependencies into a runnable build image.
As soon you have a box which has a running Docker daemon running you can use our [Docker Build Environment](https://hub.docker.com/r/opennms/build-env) to compile and build OpenNMS Horizon from source and you can run it in a isolated Docker environment.

### The Basics to Build and Assemble

This example gives you the possiblity to build and run multiple branches, so every branch gets his own directory with the branch name as a namespace.

Step 1: Make a workspace directory where we mess around.
```sh
cd ${HOME}
mkdir workspace
cd workspace
```

Step 2: Checkout the OpenNMS Horizon source code from GitHub
```sh
git clone https://github.com/OpenNMS/opennms.git develop/opennms
# Develop is checkout by default, if you want a custom branch check it out with git checkout origin/<branch-name>
```

Step 3: Compile OpenNMS Horizon and tag the running docker instance to make it easier to identify the running build process
```sh
docker run --rm \
    -l "branch=develop" \
    -v $(pwd)/develop/opennms:/usr/src/opennms \
    -v $(pwd)/m2:/root/.m2 \
    -v $(pwd)/develop/m2:/root/.m2/repository/org/opennms \
    opennms/build-env:latest /usr/bin/perl compile.pl -DskipTests
```

Step 4: Assemble OpenNMS Horizon so it can be started from /opt/opennms
```sh
docker run --rm \
    -l "branch=develop" \
    -v $(pwd)/develop/opennms:/usr/src/opennms \
    -v $(pwd)/m2:/root/.m2 \
    -v $(pwd)/develop/m2:/root/.m2/repository/org/opennms \
    opennms/build-env:latest /usr/bin/perl ./assemble.pl -DskipTests -p dir -Dopennms.home=/opt/opennms
```

### Dealing with Maven Home

The Maven home directory is the place where all Java dependencies are downloaded.
The first build will take a while, cause all these dependencies needs to be downloaded and are cached in the home directory of the user who compiles it.
In our case this is in the container `/root/.m2`.

You notice in the `docker run` commands, we create a global m2 directory.
So it needs to be populated once and can be reused in every other branch we build.

```sh
-v $(pwd)/m2:/root/.m2 \
```

Maven artifacts are stored by version numbers.
For the reason branches forked from develop have all the same version number `23.0.0-SNAPSHOT`.
If you want to build multiple branches they can mess things up.
So we have to isolate all OpenNMS related artifacts from each other.
We just mount `.m2/repository/org/opennms` directory to a dedicated place in the branch directory.

```sh
-v $(pwd)/develop/m2:/root/.m2/repository/org/opennms \
```

That way we can leverage from a shared local Maven repository and have branch specific places for OpenNMS Horizon artifacts.

I've put things described here in a convinient little [bash script](https://gist.github.com/indigo423/013599281a7771fc200aacb5a7a614ae) which can be run from a workspace directory.

```sh
./docker-build.sh -b jira/NMS-9858
```

It will checkout the source code, build and assemble for a given branch.

### Running with Docker

So now you have built and assembled everything you want to start it.
You can use the `opennms/build-env:latest` image also to start a built OpenNMS Horizon.
It has the same `docker-entrypoint.sh` as the [Docker image](https://hub.docker.com/r/opennms/horizon-core-web/) you can use with the pre-installed one.
The `build-env` image gives freedom to run things, you have to call it explicitly in the `command` section in your `docker-compose.yml` file.

```yaml
command: ["/docker-entrypoint.sh", "-s"]
```

We assembled the compiled source code to run in `/opt/opennms`, so we can just mount it in the right place.

```yaml
volumes:
  - ./opennms/target/opennms-23.0.0-SNAPSHOT:/opt/opennms
```

You can download a working [docker-compose.yml](https://gist.github.com/indigo423/56550d7f74be263b2ed37bb68fd6a806) and adjust to your needs.
It is built to run from a branch directory.
The ports for the webapp are published to dynamic addresses, so you can run multiple instances on one machine.
You can see the port mapping by running `docker ps`, in this example the TCP port 32787 is mapped to the Horizon webapp and you can access the webui with http://hostip:32787.

Happy Dockering
