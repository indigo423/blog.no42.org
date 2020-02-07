---
title: "Docker, Java, Signals and Pid 1"
date: "2019-02-20"
categories: ['Container', 'Technology']
tags: ['java', 'docker', 'signals']
author: "Ronny Trommer"
noSummary: false
---

Running a Java application in a container seems to be very easy.
The devil is in the details and I want to shed some light on the PID 1 problem when you run Java applications in containers.
In a general running applications in containers should not have any state so you just don't care, but reality is different forces you to have to.

Signals are used to a running process to behave in a certain ways.
Some can be caught by a running process and give people possibilities to implement logic to shutdown the application gracefully.
A common case is to terminate a process nicely sending a `SIGTERM` to the process identified by the process id using the tool `ps`.

So when you issue the command `kill <pid>` you send a SIGTERM to a process.
When you have a process running in foreground and you hit `CTRL + C` you send the signal `SIGINT` to the process.

### Java application and signals

Let's see what this means with a very simple example.
We have a small Java application, running an infinite loop in foreground.
Here is the simple sample code.

{{< gist indigo423 53b9060d9e36c138e4a4a91f55343e05 >}}

Compile it with `javac Main.java` and run it with `java Main` and you will this here:

```
indigo@blinky ~/pid-example $ java Main
I'm doing some work ...
I'm doing some work ...
I'm doing some work ...
```

No we want to terminate it and hit `CTRL + C` and display the exit code with `echo $?`.

```
indigo@blinky ~/pid-example $ java Main
I'm doing some work ...
I'm doing some work ...
I'm doing some work ...
^C%
indigo@blinky ~/pid-example $ echo $?
130
```

The JVM exits with error code 130 tells us it was terminated with `CTRL + C` and the JVM handled for us a `SIGINT`.

Now we try a different approach and terminate our Java app with sending a `SIGTERM`.
Start the program and open a second terminal, identify the Java process id (pid) and issue the command `kill <pid>` and show the exit code.

```
indigo@blinky ~/pid-example $ java Main
I'm doing some work ...
I'm doing some work ...
I'm doing some work ...
indigo@blinky ~/pid-example $ echo $?
143
```

The JVM handled the `SIGTERM` for us and returned it with exit code `143`.

Your Linux operating system has a crowbar in your toolbox which is the `KILL` signal, it is one of the signals you can't listen for in your application.
If you try to register a handler for a `KILL` signal your JVM will throw you a runtime exception like this:

```
Exception in thread "main" java.lang.IllegalArgumentException: Signal already used by VM or OS: SIGKILL
	at sun.misc.Signal.handle(Signal.java:166)
	at Main.handleSignal(Main.java:26)
	at Main.main(Main.java:8)
```

When you kill your application with `kill -s KILL <pid>` it will give you an exit code `137`.

### Handle the terminate signal

Now extend our little program and simulate some logic to handle the `TERM` signal and exit our program normal by returning exit code `0`.


{{< gist indigo423 cb8994b506934970d5a9784e130351cb >}}

We compile and run it again, identify the PID and kill it with `kill <pid>` and we get following result:

```
indigo@blinky ~/pid-example $ java Main
I'm doing some work ...
I'm doing some work ...
I'm doing some work ...
Signal received: TERM
Shutdown initiated
indigo@blinky ~/pid-example $ echo $?
0
```

### Dockerize our little app

Ok we have now a pretty good idea how it behaves on our local system.
What happens when we run the application in a Docker container image.
We use the `Main.class` as an artifact and just run it in a Java container image with a Dockerfile.

{{< gist indigo423 c76ad4d53200eff4052b039dbaa9217d >}}

The `java` binary becomes the entrypoint and we use a default argument `-h`.
By default the working directory is `/`.
We can run our application by passing the application name as the first argument and overwrite `-h`.

Let's build the image and run our application and run it.

```
indigo@blinky ~/pid-example $ docker build -t test .
Sending build context to Docker daemon  7.168kB
Step 1/4 : FROM openjdk:11-slim
 ---> 20be262dd659
Step 2/4 : COPY Main.class /
 ---> 27dc84a91282
Step 3/4 : ENTRYPOINT ["java"]
 ---> Running in a87fdb2ed9c4
Removing intermediate container a87fdb2ed9c4
 ---> 7bc71866d0b2
Step 4/4 : CMD ["-h"]
 ---> Running in 9ff5086f1c2b
Removing intermediate container 9ff5086f1c2b
 ---> efe92a0f9f78
Successfully built efe92a0f9f78
Successfully tagged test:latest
indigo@blinky ~/pid-example $ docker run test Main
I'm doing some work ...
I'm doing some work ...
I'm doing some work ...
```

Ok now send some signals into the running container similar what we did in our local example.
Instead of `kill` we use `docker kill` and instead of the process ID we use the container id which can be identified with `docker ps`.
The exit state is persisted of stopped containers can be shown with `docker ps -a` 

Let's kill the running container and check the exit code:

```
indigo@blinky ~/pid-example $ docker kill <container-id>
indigo@blinky ~/pid-example $ docker ps -a
```

Now you may wonder, you see the exit state as `Exited (137) About a minute ago`.
By default `docker kill` is sending the `KILL` signal and not `TERM`.
This is one of the first notions of, applications in containers don't care about state and get killed with a crowbar by default.

Ok we run again and we send a `TERM` signal and see what happens:

```
indigo@blinky ~/pid-example $ docker run test Main
I'm doing some work ...
I'm doing some work ...
I'm doing some work ...
```

Now we send a `TERM` signal:

```
indigo@blinky ~/pid-example $ docker kill -s TERM <container-id>
```

and voila we shutdown gracefully

```
I'm doing some work ...
Signal received: TERM
Shutdown initiated
```

So there is `docker stop` and how does it work?
If you want to be nice to your application use `docker stop <container-id>` it will send a `TERM` signal and gives your application 10 seconds by default to terminate gracefully otherwise it get's killed with the `KILL` signal.

### Process Ids inside the running container

We run our application with containers in an isolated space.
Let's extend our little example  a little bit to see what runs inside.
We have to add the `ps` command in the Docker image.

{{< gist indigo423 e8cb5a91454305db30f70576c335b482 >}}


Now we extend our Java program with a method to list all running processes inside the container with it's process ids.


{{< gist indigo423 edaf83b61eea5670fc172d8b9dd12d09 >}}


We compile the Java class, build a new image and run the app in our container:

```
indigo@blinky ~/pid-example $ javac Main.java
indigo@blinky ~/pid-example $ docker build -t test .
indigo@blinky ~/pid-example $ docker run test Main
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.2 5824432 35544 ?       Ssl  13:30   0:00 java Main
root        23  0.0  0.0  38384  3072 ?        R    13:30   0:00 ps aux
I'm doing some work ...
I'm doing some work ... 
```

We can see our Java application got PID 1 and it has forked the ps command which got PID 23.

### Using Scripts as Entrypoint and PID 1

Some applications are not suited for this use-case and require some logic before the can be started.
A common pattern is the entrypoint script approache.
Instead of calling the program directly we use a shell script which gives us some control to influence who the application is started.
Let's modify our container image using a very simple entry point script.

{{< gist indigo423 07aae0ad15f54ceafb2b668d0b410227 >}}

We make the `entrypoint.sh` executable and add it to our Docker image.

{{< gist indigo423 a2349b1a0739faed6b4e0942b1f97a2c >}}

The entry point script will now take care of starting our application.

```
indigo@blinky ~/pid-example $ chmod +x entrypoint
indigo@blinky ~/pid-example $ docker build -t test .
indigo@blinky ~/pid-example $ docker run test
Running entry point script
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.0   4288   724 ?        Ss   13:53   0:00 sh /entrypoint.sh
root         7  0.0  0.2 5824432 35328 ?       Sl   13:53   0:00 java Main
root        24  0.0  0.0  38384  3096 ?        R    13:53   0:00 ps aux
I'm doing some work ...
I'm doing some work ...
I'm doing some work ...
I'm doing some work ...
```

We can see now, the PID 1 is our entry point script.
The Java process gets forked and gets PID 7.
Let's stop it with `docker stop <container-id>`.

```
indigo@blinky ~/pid-example $ docker stop e67b0b239f59
e67b0b239f59
```

What you will notice, your application does not get the `SIGTERM` and it takes 10 seconds until it got killed with `SIGKILL`.

The important part here, is the PID 1 in the container image has the responsibility to deal with signals.
Your entry point script doesn't whereas running the JVM as PID 1 in the example above does and we broke the behaviour of our little app.

### Exec for the win

When you are familiar with Linux bash you know the `exec` command.
Instead of forking a new process from the existing bash it replaces the shell.
We change our entry point script slightly and see what happens. 

{{< gist indigo423 742664640198093bc84e0b1609a996b1 >}}

We rebuild the container and run the image and run the `docker stop <container-id>` command.

```plain
indigo@blinky ~/pid-example $ docker build -t test .
indigo@blinky ~/pid-example $ docker run test
Running entry point script
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1 21.0  0.2 5824432 36552 ?       Ssl  14:08   0:00 java Main
root        23  0.0  0.0  38384  3112 ?        R    14:08   0:00 ps aux
I'm doing some work ...
I'm doing some work ...
I'm doing some work ...
I'm doing some work ...
Signal received: TERM
Shutdown initiated
```

Now we are back in business, the entry point bash got replaced by the Java process and can deal with the signal.

### I don't want to be PID 1

In Linux PID 1 has some additional responsibilities.
There are described very nicely in the article [Docker and the PID 1 zombie reaping problem](https://blog.phusion.nl/2015/01/20/docker-and-the-pid-1-zombie-reaping-problem/).
So there are cases you don't want to be PID 1 cause you don't know how to deal with this problems.

In Docker you can run a tiny init process which deals with this things for you.
Additionally it forwards signals.
All you need is to run `--init` in your `docker run` command.
You can send a `docker stop` and your Java application can deal with the `SIGTERM` to stop gracefully.

```
indigo@blinky ~/pid-example $ docker run --init test
Running entry point script
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.0   1044     4 ?        Ss   14:16   0:00 /dev/init -- /entrypoint.sh
root         7  0.0  0.2 5824432 36588 ?       Sl   14:16   0:00 java Main
root        24  0.0  0.0  38384  3192 ?        R    14:16   0:00 ps aux
I'm doing some work ...
I'm doing some work ...
Signal received: TERM
Shutdown initiated
```
