---
title: "Docker Shell Corner Cases"
date: "2017-01-18"
tags: ['docker', 'linux']
author: "Ronny Trommer"
---

During work building [Docker](https://www.docker.com) executables, I ran in an interesting corner case.
Fortunately the [Docker IRC channel](https://docs.docker.com/opensource/get-help/) helped me to investigate with special credits to Ravensoul.

When you build a container as an [executable](https://docs.docker.com/engine/reference/builder/#/understand-how-cmd-and-entrypoint-interact) you can use the ENTRYPOINT for your binary to execute and CMD as a default overwritable argument.
In most cases the CMD is the `--help` argument to provide a useful default behavior in case you just run the container without anything specified.

In my case I've built a Ruby based executable and for the reason I need the environment variables, I've used as ENTRYPOINT the `bash -c <command>` command and used the CMD default argument `--help` like this:

```sh
ENTRYPOINT ["/bin/bash", "-c", "/path/to/myRuby"]

CMD ["--help"]
```

I've noticed the `--help` argument was not used when you just run the container.
To verify the problem and isolate the environment, I've created a small example for investigation:

```sh
FROM alpine

ENTRYPOINT ["/bin/bash", "-c", "ps"]

CMD ["--help"]
```

When I ran this container I've noticed the `ps` command is executed but not the argument `--help`.
It turned out the problem is `/bin/bash -c` usage as ENTRYPOINT.
When you execute `/bin/bash -c 'echo ${0}' myFirstArgument` you will notice the `myFirstArgument` becomes ${0} which is the name of the script itself.

```sh
man /bin/bash:
```

> If there are arguments after the string, they are assigned to the positional parameters, starting with $0

To get around this problem, I've wrapped my command in an `docker-entrypoint.sh` and used `${@}` to pass all arguments which fixed my problem.

Happy dockering.
