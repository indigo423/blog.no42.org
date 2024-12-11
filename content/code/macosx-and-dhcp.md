---
title: "Mac OS X and DHCP is screwing your Host Name"
date: "2016-08-12"
tags: ['macosx', 'networking']
author: "Ronny Trommer"
---

I’m using _Mac OS X_ with [iterm2](https://www.iterm2.com/index.html), [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh) and spend 75% of my time in those terminals.
It is totally annoying to me if I connect to a _DHCP_ network and it screws up my hostname.
Especially when I'm used to looking at the prompt which tells me the host I'm connected to.

![term2](/images/terminal.png)

It is possible to fix your computer name for several things using the `scutil` command which requires administration permissions.
I've found a link to the [Mac OS X Server Worksheet](http://images.apple.com/server/docs/Worksheet_v10.4.pdf) which explains a few things in more detail.
Here is what I did to prevent my computer changing the host name.

User Friendly Name, showed in _Sharing Preference Panel_

```bash
sudo scutil --set ComputerName blinky
```

SSH and Remote login

```bash
sudo scutil --set HostName blinky
```

Name for _Bonjour_, e.g. _Airdrop_

```bash
sudo scutil --set LocalHostName blinky
```

In hope this helps and hope I'll find the page again when I forgot how to do it :)
