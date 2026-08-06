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

If Claude has to guess here, will it guess right? That's the bar for every section below — not "is this documented" but "could someone build the wrong thing anyway."

## Step 1: Gather context

Read the existing codebase (relevant modules, `CLAUDE.md`, recent related commits) so the spec fits real conventions instead of inventing new ones. If the ask is underspecified, use `/grilling` first rather than guessing.

## Step 2: Surface assumptions and reframe vague asks

List the assumptions being made and get confirmation before drafting — a silent assumption produces a spec that looks complete and isn't:

```
ASSUMPTIONS I'M MAKING:
1. <assumption>
2. <assumption>
→ Correct me now or I'll proceed with these.
```

If the ask is a vague requirement ("make it faster", "add search"), reframe it as specific, measurable success criteria and confirm those too before drafting:

```
REFRAMED SUCCESS CRITERIA:
- <specific, measurable target>
- <specific, measurable target>
→ Are these the right targets?
```

## Step 3: Draft the spec

```markdown
# Spec: <title>

## Objective
<what this achieves, for whom, and what success looks like — a measurable outcome, not a capability.
Bad: "A tool that helps users search their docs."
Good: "Search returns the correct doc in the top 3 results for 90% of test queries, in under 500ms.">

## Assumptions
<confirmed in Step 2>

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
- **Always**: <e.g. run tests before commit, validate inputs at every boundary>
- **Ask first**: <e.g. schema changes, new dependencies, infra config>
- **Never**: <e.g. hardcode credentials, skip validation, remove failing tests without approval>

## Open questions
<anything unresolved — or "none". An open question left unresolved here is a bug in the spec, not a detail to sort out during implementation>
```

### If this is an AI/agentic feature (LLM calls, RAG, agents, tool use)

Add these — they're where AI systems fail silently if left unspecified:

- **Data & retrieval**: what's retrieved, from where, how it's chunked/embedded, and how a retrieval miss surfaces to the user
- **Design pattern**: which shape this is — RAG, controlled workflow (LLM inside a fixed step sequence), router (LLM classifies then dispatches), human-in-the-loop, multi-agent, or fine-tuning — and why that one over the others
- **Guardrails**: input guardrail (what's rejected before it reaches the model) and output guardrail (what's flagged or blocked before it reaches the user) — each needs a concrete, measurable trigger condition, not "handle gracefully"
- **Evals**: at least one eval tied to the objective's success metric, with a scoring method (LLM-as-judge, exact match, human rating) and a passing threshold

## Step 4: Confirm and save

Show the draft to the user for edits. Once confirmed, write it to `specs/<slug>.md` (or `docs/specs/<slug>.md` if `specs/` doesn't exist as a convention yet). Follow with `/plan` to break it into tasks.

## Rules

- A spec with no "out of scope" section is incomplete — scope creep starts there.
- An assumption stated but never confirmed is the most dangerous kind of "done" — the spec looks complete and isn't.
- Don't write implementation code as part of this skill. The spec is the deliverable.
- If the codebase context contradicts the user's ask (e.g. a pattern already exists that solves this), surface that before finalizing.
- For an AI/agentic feature, the design-pattern classification and guardrails aren't optional extras — a spec without them isn't done.
