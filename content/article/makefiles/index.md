---
title: "Go away or I replace you with a Makefile"
date: "2025-04-08"
categories: ['CI/CD', 'Development' ]
tags: [ 'continues-integration' , 'cicd', 'make', 'Makefile' ]
author: "Ronny Trommer"
noSummary: false
---

I remember the first time I tried to get an open-source project compiled and deployed.
The distribution of Linux at this point was [Slackware](https://en.wikipedia.org/wiki/Slackware).
Build or installation instructions didn't exist, and without handholding on IRC, it would not have been possible for me.
That was 30 years ago, people in IRC were very self-selected, patient, and helpful.
When you have skilled patient people in IRC and you can communicate what you did, what exactly failed, and what you would have expected - your learning experience is pretty impressive.
Nevertheless, it does not scale well.
People nowadays expect things to work with a click of a button.
They are even not keen on reading clear instructions.

The complexity of building, assembling, and deploying open-source apps from source hasn't changed since then.
People address this problem in 4 phases:
1. Documenting the build and assembly procedure and leave it to the user to copy & paste the commands in the right order
2. Write a program in Perl, Python, Bash or any other scripting language they are familiar with
3. Encode everything in a collection of scripts into a YAML file of the maintainer's choice for a CI/CD
4. Create Makefiles

## 1. Documentation

This is typically the best starting point.
When you are a maintainer, walk in the shoes of someone stumbling on your GitHub repository.
What he needs to get your source code up and running is a great exercise.
It will unravel friction quickly.
When your project grows, and you add a lot of "ifs" and "it depends" to your instruction, you probably go into phase 2.

## 2. Write something to make it easier

When you have people with a strong empathy for developers in your community, they will solve this problem with the tools they know the best.
Usually, they write programs in scripting languages like Bash, Perl, or Python.
When they have some empathy for someone external deploying and maintaining the application, they pick something generic like Bash and try not to get too many other dependencies in.
I had a lot of frustration with getting a Perl or Python environment set up to run programs, to build and assemble Java applications - it can be insane :)
These programs grow from useful tools into full-grown pets and get very expensive to maintain.
CI/CD pipelines for the rescue.

## 3. CI/CD's for the rescue

Having cheap CI/CD pipelines available, we can automate our way out of this mess.
You don't want to throw away the time you spent in phase 2. You are going to wrap all that with a bunch of other scripts into some yaml file in your new shiny CI/CD.
At some point in time, you get the workflow going from build, test, package, and release until you can deploy it.
In projects with a certain age, this can take some time to get there.
You will probably end up in a situation where every developer is now pushing a commit to a remote repo and has to wait until the CI/CD pipeline finishes.

![](https://imgs.xkcd.com/comics/compiling.png)

This is because a developer can't do things locally.
There is no quick feedback loop, everything is now heavily tight to your very specific flavor of CI/CD.
Nobody ever can think about migrating from CI/CD tool A to a cheaper and better CI/CD tool B.
This is the point in time when you realize you need to go back to square 1.

## 4. Find the right abstraction

What you learned in phases 2 and 3 is that you want to degenerate your CI/CD just to be the trigger to your pipeline logic.
You want to give developers the possibility to do as much as possible locally in a short feedback cycle.
The interface for building, testing, packaging, or deploying things locally and in the CI/CD should be the same.
Makefiles can help you find the right abstraction.
Here is what you can get if you spend time figuring out the right abstraction between scripts or Makefiles shipped in a repo and your CI/CD:

* Consistency, what a developer runs locally to build, test and deploys is the same what the CI/CD does. If something breaks, it can be fixed before it gets pushed to repository.
* Decoupling of project-specific commands from CI/CD config, e.g. if you allow a user to run `make oci` to create container image, you can replace docker with podman without changing the build interface for the user and the CI/CD.
* Simplified CI/CD, the commands to build or test the code are behind a generic `make test` or `make app123` goal. Repetition and errors missing build arguments can be avoided.
* Documentation, Makefiles can be self-documenting. You can test your repository usability by just running `git clone <repo> <dir> && cd <dir> && make`. If you don't get something a user can work with, you can improve it.
* Migration flexibility, when you use your CI/CD just to trigger the pipeline process, you reduce the switching cost of your CI/CD pipeline tool dramatically.

This blog post is just for myself if someone asks me, why do I provide a Makefile in my GitHub repository, the CI/CD does it anyway.

gl&hf

Image by [Jirreaux Hiroé](https://pixabay.com/users/jirreaux-14740159/?utm_source=link-attribution&utm_medium=referral&utm_campaign=image&utm_content=5633768) from [Pixabay](https://pixabay.com//?utm_source=link-attribution&utm_medium=referral&utm_campaign=image&utm_content=5633768)
