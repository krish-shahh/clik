---
name: plan
description: Decompose a spec or feature description into small, independently verifiable tasks with acceptance criteria and dependency order.
argument-hint: "[spec file path, or a feature description]"
disable-model-invocation: true
allowed-tools:
  - Read
  - Glob
  - Grep
  - AskUserQuestion
---

Break down into implementable tasks: **$ARGUMENTS**

## Step 1: Read the input

If `$ARGUMENTS` is a file path, read it (a spec written by `/spec`, a PRD, an issue body). Otherwise treat it as a freeform feature description and read the relevant existing code first.

## Step 2: Decompose

Split the work into tasks that are each:
- **Small**: completable in one sitting, one focused commit.
- **Independently verifiable**: has a concrete way to check it's done (a test, a manual check).
- **Ordered by real dependency**: only mark a task blocked if it truly cannot start before another merges.

For each task, capture:
- Title (verb-first, e.g. "Add `Payment` model")
- What it builds (1-2 sentences)
- Acceptance criteria (2-4 testable checkboxes)
- Dependencies (task titles it's blocked by, or "none")

## Step 3: Present the plan

```
## Task breakdown: <feature/spec name>

1. <title>  [blocked by: none]
   - <what it builds>
   - [ ] <acceptance criterion>
   - [ ] <acceptance criterion>

2. <title>  [blocked by: #1]
   ...
```

Ask: "Does this breakdown look right? Any tasks to split, merge, or reorder?"

## Step 4: Optionally create issues

If the user confirms and the project uses GitHub issues, offer to create them with `gh issue create` in dependency order, then suggest `/start-issue` to begin the first one. Otherwise leave the breakdown as the artifact.

## Rules

- Don't create a task with no acceptance criteria — "implement the feature" is not a task, it's the whole plan.
- If a task can't be made small, that's a sign it's actually two tasks — split it, don't leave it large.
