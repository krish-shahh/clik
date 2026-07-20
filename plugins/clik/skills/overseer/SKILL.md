---
name: overseer
description: Decide which of clik's skills and agents actually apply to the current task by matching it against a short policy table of @-referenced skills, instead of leaving it to memory. Use right after `/start-issue` (what does this task need before I write code) and again right before `/done` or `/ship` (what does this diff need before it goes out).
argument-hint: "[optional: task or issue description — otherwise infers from the active issue or diff]"
disable-model-invocation: true
---

Route the current task through the policy table below and decide what applies. This skill doesn't do the work itself — it decides who should, then hands off.

## Why this exists

clik ships skills and agents individually, but nothing wires them together automatically: `/plan` doesn't know to suggest TDD, `/start-issue` doesn't know a ticket is complex enough to warrant `@architect` first, `/done` doesn't know a change is risky enough for `/doubt` or `/blast-radius`. Left alone, that's all left to memory. `/overseer` is the checkpoint other skills route through instead of leaving that decision to chance.

## How the routing works

Each row below names a condition and `@`-references the skill or agent file it routes to — the same `@path/to/file` convention used in `CLAUDE.md`/`AGENTS.md`. On Claude Code, `@path` expands the referenced file straight into context automatically. Other harnesses may not auto-expand it, so treat `@path` as an instruction either way: **when a row's condition matches, read that file (with your Read tool, if it wasn't already auto-expanded) and follow it.** Nothing here is generated or cached — every reference points straight at the real file, so it can't go stale the way a separate index could.

## Step 1: Establish the checkpoint

Figure out which checkpoint applies, from context or `$ARGUMENTS`:

- **Pre-work** — typically right after `/start-issue`. What discipline does this task need before code gets written.
- **Pre-ship** — typically right before `/done` or `/ship`. What verification does this diff need before it goes out.

If it's ambiguous, ask.

## Step 2: Match the policy table

Walk every row for the relevant checkpoint against the task. More than one can match.

### Pre-work

| Condition | Route to | Weight |
|---|---|---|
| Task touches 3+ files, introduces a new data model, or crosses an API/service boundary | @../../agents/architect.md | Required — this is `@architect`'s own stated trigger ("use before `/start-issue` on complex tickets") |
| Task adds or changes testable behavior and the repo has a test harness | @../tdd/SKILL.md | Required |
| Task is pure config, docs, or CI with no testable behavior | *(skip TDD)* | N/A — note why explicitly rather than silently skipping |
| Requirements are vague, or acceptance criteria are missing or ambiguous | @../grilling/SKILL.md (or @../grill-with-docs/SKILL.md if the repo has a `CONTEXT.md` worth sharpening alongside) | Required |
| A real design fork exists and picking wrong is expensive to reverse | @../prototype/SKILL.md or @../idea-refine/SKILL.md | Suggested |

### Pre-ship

| Condition | Route to | Weight |
|---|---|---|
| Diff touches auth, payments, migrations, data deletion, or is described as high-risk/irreversible | @../doubt/SKILL.md and @../blast-radius/SKILL.md | Required |
| Diff is more than a trivial one-line fix | @../pr-review/SKILL.md | Required |
| The diff embodies a decision that is hard to reverse, surprising without context, and the result of a real trade-off — all three | @../adr/SKILL.md | Required only when all three hold — reused from `domain-modeling`'s own three-part test rather than redefined |
| A human will review this after the fact, or it's a long/unattended run | @../show-me-your-work/SKILL.md | Suggested |
| React project | *(no action — `/ship` already gates this itself via react-doctor)* | N/A |

## Step 3: Act on the matches

Present the matches as a short checklist. For every **required** row, read the referenced file and invoke it without asking — that's the point of having a policy instead of re-litigating it every time. For **suggested** rows, ask first; the user may already have a specific reason to skip it.

Delegating the match-and-decide step to a cheap/fast subagent (e.g. `model: haiku` on Claude Code) is optional, not required — the table above is short enough to apply directly against the task description. Reach for delegation only if you want this off your main model's budget.

## Rules

- This skill is advisory scaffolding, not a hard gate like `/ship`'s react-doctor check. If the user overrides a **required** row, note the override and proceed — don't block.
- Never invoke `/ship` or `/done` themselves from here; this skill only routes to what comes *before* them.
