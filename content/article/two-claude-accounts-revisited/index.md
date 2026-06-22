---
title: "Two Claude Accounts, Revisited"
date: "2026-06-22"
categories: ['Technology']
tags: ['ai', 'claude']
author: "Ronny Trommer"
noSummary: false
---

A while back I wrote about [using two Claude accounts side by side](/article/two-claude-accounts/).
A private subscription and a corporate team account, two config dirs and a pair of shell aliases so the tokens don't bleed into each other.
That part still works fine.
But after living with it for a few months, I learned where it falls short, so here is the grown-up version.

## Two setups drift apart

The aliases only solved which account pays.
They did nothing about how Claude behaves.
Each config dir grew its own `CLAUDE.md`, and the moment you maintain two of anything by hand, they drift.
I'd tighten a commit convention in one account and forget the other.
The work account learned a guardrail the private one never got.
What I really wanted was the same baseline everywhere, conventional commits, SHA-pinned GitHub Actions, license headers, no matter which hat I'm wearing.

## One shared baseline, imported everywhere

Claude Code lets a `CLAUDE.md` pull in other files with `@` imports.
So I stopped duplicating and created a single shared directory that both accounts read from:

```text
~/.claude-shared/
  conventions.md   # working style, commit format, CI rules
  RTK.md           # tooling I always want available
~/.claude-private/  # private account config dir
  CLAUDE.md
~/.claude-work/    # work account config dir
  CLAUDE.md
```

Each account's `CLAUDE.md` starts by importing the shared baseline:

```markdown
@~/.claude-shared/RTK.md
@~/.claude-shared/conventions.md
```

That's it.
I edit `~/.claude-shared/conventions.md` once and both accounts pick up the change on the next run.
The guardrails can't drift anymore, because there is only one copy of them.

This is also what Anthropic suggests in their [Claude Code best practices](https://code.claude.com/docs/en/best-practices).
Keep your `CLAUDE.md` files small and composable, and use imports to share common context instead of copy-pasting it around.

## Specialization without duplication

A shared baseline doesn't mean the accounts are identical.
The work account just layers its own rules after the import.
My `~/.claude-work/CLAUDE.md` adds the OpenNMS source-header rule on top of the shared conventions:

```markdown
@~/.claude-shared/RTK.md
@~/.claude-shared/conventions.md

# OpenNMS

- Java source files start with the OpenNMS header: copyright line,
  an SPDX-License-Identifier matching the repo's LICENSE, and the
  author line. The source-headers skill applies it.
```

Same guardrails everywhere, plus whatever a given context actually needs.
The private account stays lean, the work account knows about OpenNMS.

## Bigger features need more than a good prompt

The second thing I learned was about scope.
For small changes a sharp prompt is enough.
For larger features, the kind that touch several files and need a plan before any code, improvising falls apart.
Claude happily writes code, but without a spec it writes towards a target only it can see.

Two tools changed that for me.
[OpenSpec](https://github.com/Fission-AI/OpenSpec) to capture the intended change as a spec before implementation, so there is a shared and reviewable source of truth.
[BMAD-METHOD](https://github.com/bmadcode/BMAD-METHOD) to break a larger feature into structured exploration with analyst, architect and dev passes, instead of one giant ask.

The nice part is that exploration and planning happen as documents I can read and correct.
Only then does the implementation start.
Fewer wrong turns, and a record of why the code looks the way it does.

This lines up with the [best practices](https://code.claude.com/docs/en/best-practices) again.
For anything non-trivial, let Claude plan first, write the approach down, confirm it, then implement.
Spec-driven beats vibe-driven the moment a feature stops being a one-liner.

## Where I am today

Two config dirs and two aliases, so the tokens stay where they belong.
One `~/.claude-shared/` imported by both, so the guardrails can't drift.
Per-account overrides on top, so I get specialization without duplication.
And OpenSpec plus BMAD-METHOD for the larger features, planning as documents before building.

None of this is fancy.
It is just the difference between two ad-hoc setups and one system with a shared backbone.
And it is reassuring to see the same instincts written down in Anthropic's own best practices.

Happy hacking!
