---
title: "Using Two Claude Accounts Side by Side"
date: "2026-04-01"
categories: ['Technology']
tags: ['ai', 'claude']
author: "Ronny Trommer"
noSummary: false
---

Just something a few might be interested in.
I'm in a fortunate situation where I have a private Claude account and also signed in to a corporate Claude team account.

I would like to make sure I spent the tokens from the work subscription only on work-related items and the tokens from my private account on my own stuff.
What works for me pretty well is having two Claude config dirs and a shell alias like this:

```bash
alias claude-work="CLAUDE_CONFIG_DIR=~/.claude-work claude"
alias claude-private="CLAUDE_CONFIG_DIR=~/.claude-private claude"
```
