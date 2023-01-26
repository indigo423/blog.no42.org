---
title: "Build pmacct on Mac OSX from source"
date: "2023-01-26"
categories: ['Monitoring']
tags: ['netflow', 'pmacct']
author: "Ronny Trommer"
noSummary: false
---

I need a way to generate real-world NetFlow data, and [pmacct](http://www.pmacct.net/) is a great tool that helped me with various things. I couldn't find a precompiled package so I have compiled it from the source myself. To get it running on my MacBook Pro with Apple Silicon, I had to jump through a few hoops to get it running. Here is a quick guide to making it work for someone else, including my future self :)

Install some build dependencies using [Homebrew](https://brew.sh/).

```bash
brew install autoconf automake librdkafka
```

Clone the Git repository and change into the `pmacct` directory.
```bash
git clone https://github.com/pmacct/pmacct.git
cd pmacct
```

Add the librdkafka header files to your search path.
```bash
export C_INCLUDE_PATH=/opt/homebrew/Cellar/librdkafka/2.0.2/include
export LIBRARY_PATH=/opt/homebrew/Cellar/librdkafka/2.0.2/lib
```
You need to adapt the version number, at the point in time, I got version 2.0.2 installed.

Run the configure and make commands to build the tool.
```bash
./autogen.sh
./configure
make
```

The binary files are `src` directory. If you want to install them run `make install` and they will be copied to `/usr/local/bin`. You need root permissions to do it.

You can run it now with `./pmacctd -f /path/to/your/pmacctd.conf`.

gl&hf
