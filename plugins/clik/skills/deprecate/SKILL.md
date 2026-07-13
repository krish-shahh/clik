---
name: deprecate
description: Retire old code, APIs, or systems safely — mark deprecated, migrate callers, and remove on a set timeline.
argument-hint: "[the API, function, module, or system to deprecate]"
disable-model-invocation: true
allowed-tools:
  - Read
  - Grep
  - Glob
  - Edit
  - Bash(git *)
---

Deprecate: **$ARGUMENTS**

Treat code as a liability, not an asset — every line kept past its usefulness costs future readers and maintainers.

## Step 1: Find every caller

Grep the codebase (and, if it's a public API, check for external consumers via docs or a changelog) for every call site. There is no safe deprecation without knowing the full call graph first.

## Step 2: Classify the deprecation

- **Advisory**: still works, callers should migrate on their own timeline. Warn, don't break.
- **Compulsory**: has a hard removal date because it's insecure, broken, or blocking other work. Warn loudly and set a deadline.

Ask the user which applies if it's not obvious from the reason for deprecating.

## Step 3: Mark it deprecated

- Code: `@deprecated` annotation / docstring tag naming the replacement and (for compulsory) the removal version or date.
- Runtime (if it's a live API): a deprecation warning logged or returned, not silent.
- Docs: update references to point at the replacement.

## Step 4: Migrate callers

Update every internal call site found in Step 1 to the replacement. Don't leave internal callers using the deprecated path — that undermines the deprecation and confuses the next reader.

## Step 5: Track and remove

- Advisory: leave a `TODO(owner): remove after callers migrate (#issue)` marker.
- Compulsory: track remaining external callers if visible (logs, telemetry) until zero, then remove the code entirely on the deadline — don't let "zombie" deprecated code linger indefinitely.

## Rules

- Never remove something with live internal callers still using it — Step 4 before Step 5, always.
- A deprecation with no replacement path and no removal plan isn't a deprecation, it's just a warning nobody will act on. Give it one of the two.
