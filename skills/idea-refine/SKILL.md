---
name: idea-refine
description: Turn a vague idea into a concrete, actionable proposal through structured divergent then convergent thinking.
argument-hint: "[rough idea or concept]"
disable-model-invocation: true
---

Refine this idea into a concrete proposal: **$ARGUMENTS**

## Step 1: Diverge

Generate 3-4 genuinely different framings of the idea — not variations of the same approach. Vary the angle: different user, different scope (minimal vs ambitious), different mechanism, different constraint traded off. One sentence each.

## Step 2: Converge

Pick the strongest framing. State why the others were rejected in one line each — a real reason (cost, complexity, doesn't solve the actual problem), not a coin flip.

## Step 3: Concretize

Turn the winning framing into a proposal:

```
## Proposal: <name>

**What it is**: <2-3 sentences>
**Who it's for / when they'd reach for it**: <1-2 sentences>
**Scope for v1**: <what's in>
**Explicitly out of scope**: <what's deferred and why>
**Biggest risk or unknown**: <the thing most likely to be wrong>
```

## Rules

- Don't skip to Step 3. The point of diverging first is to avoid anchoring on the first idea that comes to mind.
- If the user's original idea already IS the strongest framing after divergence, say so honestly — don't manufacture a "better" alternative for the sake of it.
- Keep the whole output scannable in under a minute.
