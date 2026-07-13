---
name: adr
description: Write an Architecture Decision Record for a significant technical decision. Use when choosing between competing approaches worth documenting for future readers.
argument-hint: "[decision title]"
disable-model-invocation: true
allowed-tools:
  - Read
  - Write
  - Glob
  - Bash(git log *)
---

Write an ADR for: **$ARGUMENTS**

## Step 1: Find the numbering

Check `docs/adr/` (or `docs/decisions/`) for existing ADRs. Use the next sequential number, zero-padded (`0001`, `0002`, ...). If the directory doesn't exist, start at `0001` and create it.

## Step 2: Draft the record

```markdown
# <NNNN>. <Decision title>

**Status**: Proposed | Accepted | Superseded by <NNNN>

## Context
<the problem or forces at play, 2-4 sentences — what made a decision necessary>

## Decision
<what was decided, stated directly>

## Alternatives considered
<other options and why each was rejected — one line each>

## Consequences
<what this makes easier, what it makes harder, and any follow-up work it creates>
```

## Step 3: Confirm and save

Show the draft to the user. Once confirmed, write it to `docs/adr/<NNNN>-<slug>.md`.

## Rules

- An ADR records a decision that was made, not a proposal still being debated — if it's not decided yet, this isn't the right skill (use `/spec` instead).
- Keep "Consequences" honest — include the real trade-offs, not just the upside.
- If this decision supersedes an earlier ADR, update that ADR's Status line to point at the new one.
