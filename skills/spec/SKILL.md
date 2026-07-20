---
name: spec
description: Write a PRD before any code — objectives, structure, conventions, testing approach, and boundaries. Use when starting a new project, feature, or significant change.
argument-hint: "[feature or project name]"
disable-model-invocation: true
allowed-tools:
  - Read
  - Write
  - Glob
  - Grep
  - AskUserQuestion
---

Write a spec for: **$ARGUMENTS**

## Step 1: Gather context

Read the existing codebase (relevant modules, `CLAUDE.md`, recent related commits) so the spec fits real conventions instead of inventing new ones. If the ask is underspecified, use `/grilling` first rather than guessing.

## Step 2: Draft the spec

```markdown
# Spec: <title>

## Objective
<what this achieves and why, 2-3 sentences>

## Scope
**In scope**: <bullets>
**Out of scope**: <bullets — explicit, not just omitted>

## Approach
<the chosen technical approach, and what alternatives were ruled out and why>

## Structure
<files/modules to create or change — concrete paths, not vague areas>

## Conventions
<naming, error handling, or patterns this feature must follow from the existing codebase>

## Testing
<what needs test coverage and at what level — unit, integration, e2e>

## Boundaries
<what this explicitly must NOT break or touch>

## Open questions
<anything unresolved — or "none">
```

## Step 3: Confirm and save

Show the draft to the user for edits. Once confirmed, write it to `specs/<slug>.md` (or `docs/specs/<slug>.md` if `specs/` doesn't exist as a convention yet).

## Rules

- A spec with no "out of scope" section is incomplete — scope creep starts there.
- Don't write implementation code as part of this skill. The spec is the deliverable.
- If the codebase context contradicts the user's ask (e.g. a pattern already exists that solves this), surface that before finalizing.
