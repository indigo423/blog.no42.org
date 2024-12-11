---
title: "Mirroring a container registry"
date: "2024-08-16"
categories: ['Container', 'How-To']
tags: [ 'container', 'registry' ]
author: "Ronny Trommer"
noSummary: false
---

I was working on an article [How to run an air gap installation of OpenNMS Horizon on Rocky Linux](https://opennms.discourse.group/t/how-to-run-an-air-gap-installation-of-opennms-horizon-on-rocky-9-linux/3363).
I ran into a similar use case and it was not about RPMs or DEB packages, it was all about container images and registries.
My question was, how can I get "all" container images into a private registry from DockerHub?
Getting your hands dirty with a private registry is something I've described in [Running a private container registry for testing](/article/local-container-registry/).
Here is a short how-to on how I did it for my future self or anyone else with a similar question.

You can get container images very easily using the tool [skopeo](https://github.com/containers/skopeo).
It can be easily installed using `apt`, `dnf`, or `brew`.
Once the tool is installed, you can use it like this to copy an image from one registry to another, using here an example with [DockerHub](https://hub.docker.com) and [Quay.io](https://quay.io).
You have to do a `skopeo login` to Quay.io to be able to push images.
Instead of Quay.io you can use your internal installed registry.
The argument `--all` fetches all architecture images for a given tag.

```bash
skopeo copy --all docker://opennms/horizon:33.0.7 docker://quay.io/labmonkeys/onms-horizon:33.0.7
```

What you will notice, `skopeo` wants the docker tag.
What if you have lots of tags you want to copy?
DockerHub has an API that allows you to fetch the tags for a given repository.
Unfortunately, it has paging you can't get all tags at once.
A little bash script around `curl` can help you with that.
If you have a lot of tags and images you want to move, you probably need to log in to DockerHub as well, because you can exceed the pull limits as an anonymous user very quickly.

```bash
#!/bin/bash

REPO="${1}" # something like opennms/horizon
# Initial URL for the first page of tags
url="https://hub.docker.com/v2/repositories/${REPO}/tags?page_size=100"

# Loop through pages
while [ "$url" != "null" ]; do
  # Fetch the current page
  response=$(curl --silent "$url")

  # Extract and print tag names
  echo "$response" | jq -r '.results[].name'
  # Get the next page URL
  url=$(echo "$response" | jq -r '.next')
done
```
Son long and happy image copying

Image by [srkcalifano](https://pixabay.com/photos/wyoming-grand-teton-teton-landscape-4786394/) from [Pixabay](https://pixabay.com/service/license-summary/)
