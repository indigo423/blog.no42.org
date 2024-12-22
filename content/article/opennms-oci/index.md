---
title: "Building container images for OpenNMS"
date: "2024-12-22"
categories: ['Monitoring', 'How-To', 'OpenNMS', 'OCI']
tags: ['opennms', 'secrets', 'vault', 'docker', 'container', 'oci']
author: "Ronny Trommer"
noSummary: false
---

The previous [article]({{< ref "/article/auf-die-harte-tour" >}}) described how you can build and compile OpenNMS Horizon from source.
This section explains how you build container images (OCI) from the source artifacts.

## Deploy base image as foundation

Running OpenNMS Horizon core, Minion, or Sentinels in a container requires shared components.
Some of them are a) the JDK base image, b) some useful tools, and c) JICMP, and JICMP6.

The JDK is shared with Core, Minion, and Sentinel.
JICMP, and JICMP6 are required for Core and Minion.
To manage these dependencies, we have a [deploy-base image](https://github.com/OpenNMS/deploy-base/blob/variant/ubi/Dockerfile.tpl) created which covers the main requirements running the Core, Minion, and Sentinel server processes.
Getting an efficient size was a goal and a [multi-stage](https://docs.docker.com/build/building/multi-stage/) build approach was chosen to address it.
The fist

> [!TIP]
> The maintainer switched to a Red Hat universal base image as the main OS. It is managed in the branch ***variant/ubi***.
> The master branch still has the Ubuntu base image which isn't used at this point.
> The main reason is getting the OCI images OpenShift friendly.

The first stage `core` is a preparation stage installing some tools needed in production.
The second stage `binary-build` is compiling JICMP and JICMP6 from the source.
It allows us to build the container image for multiple architectures more easily.
The third stage is assembling the production image, with just the build artifacts from the `binary-build` stage and the tools from preparing the `core` image.
Helping with configuring the services in a container, we install `confd` as an interface to allow users to inject configs more easily.

This deploy-base image is the foundation for the Core, Minion, and Sentinel container images.

## Building the container images

You need first to compile and assemble OpenNMS Horizon from the source with the deployment target `/opt/openms`.
The container build instructions can be found in the `opennms-container` subdirectory of the checked-out source tree.

```bash
tree -L 2
.
├── Makefile
├── README.md
├── common.mk
├── core
│   ├── CONFD_README.md
│   ├── Dockerfile
│   ├── Makefile
│   ├── container-fs
│   ├── images
│   ├── plugins
│   ├── plugins.sh
│   ├── rpms
│   └── tarball-root
├── minion
│   ├── CONFD_README.md
│   ├── Dockerfile
│   ├── MINION_CONFIG_SCHEMA_README.md
│   ├── Makefile
│   ├── container-fs
│   ├── images
│   ├── minion-config-schema.yml.in
│   └── plugins.sh
└── sentinel
    ├── Dockerfile
    ├── Makefile
    ├── container-fs
    ├── images
    ├── plugins
    ├── plugins.sh
    └── rpms
```

Building each container image follows the same procedure.
Switch into the `opennms-container` directory as a base.

> [!NOTE]
> The example shows the build for version `33.0.10-SNAPSHOT` which is defined in the root `pom.xml`.
> If you want to build a different version you need to replace that version string accordingly.

> [!NOTE]
> The Makefile for the docker build command, uses docker buildx and doesn't work reliably other than in the CircleCI CI/CD environment.
> The steps below explain the instructions so you understand better what's happening under the hood.

### Build the Core container image

Switch to the directory.

```bash
cd core
mkdir tarball-root
tar -x -z --strip-components 0 -C ./tarball-root -f ../../opennms-full-assembly/target/opennms-full-assembly-33.0.10-SNAPSHOT-core.tar.gz
docker build -t my-core .
```

### Build the Minion container image

```bash
cd minion
mkdir tarball-root
tar -x -z --strip-components 1 -C ./tarball-root -f ../../opennms-assemblies/minion/target/org.opennms.assemblies.minion-33.0.10-SNAPSHOT-minion.tar.gz
make minion-config-schema.yml
docker build -t my-minion .
```

### Build the Sentinel container image

```bash
cd sentinel
mkdir tarball-root
tar -x -z --strip-components 1 -C ./tarball-root -f ../../opennms-assemblies/sentinel/target/org.opennms.assemblies.sentinel-33.0.10-SNAPSHOT-sentinel.tar.gz
docker build -t my-sentinel .
```

These steps should give you the Core, Minion, and Sentinel container images in your local registry.
Tag and push them with the registry and repo you like.

So long, and thanks for all the fish.

Image by [Valdas Miskinis](https://pixabay.com/de/users/valdasmiskinis-12049839/?utm_source=link-attribution&utm_medium=referral&utm_campaign=image&utm_content=4203677) from [Pixabay](https://pixabay.com/de//?utm_source=link-attribution&utm_medium=referral&utm_campaign=image&utm_content=4203677)