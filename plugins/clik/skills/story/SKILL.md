---
name: story
description: Frame built software into a customer-ready demo story. Delegates to the sales-engineer agent and writes a demo narrative for a feature, PR, or the whole project.
argument-hint: "[feature | PR # | 'project'] [client/audience scope]"
disable-model-invocation: true
---

Frame recent or existing work as a customer demo story by delegating to `@sales-engineer` and writing the result to a story artifact.

## Verbosity

Check `$ARGUMENTS` for the word `verbose`. Strip it from the argument string before parsing the rest.

- **Default**: terse story (wow + five-beat arc + tailoring, one line each).
- **`verbose`**: full talk-track with feature -> "so what" mapping and per-stakeholder detail.

Pass `verbose` through to the `sales-engineer` agent call only if the user asked for it.

## Step 1: Parse the target and scope

Parse `$ARGUMENTS`:

- **Target** (first token or phrase): a feature name, a PR number (`123` or `#123`), or the literal `project` for the whole codebase.
- **Client/audience scope** (remainder): the customer, use case, or stakeholder mix to frame the story for. If omitted, ask the user or proceed with an explicit "no scope given" assumption noted in the output.

## Step 2: Gather context

- If code-review-graph is installed, use `get_minimal_context_tool` or `detect_changes_tool` to scope to the relevant area instead of reading the whole repo.
- Otherwise: for a PR number, `gh pr view` / `gh pr diff`; for a feature name, grep for it; for `project`, read the README and top-level structure.

## Step 3: Delegate to the sales-engineer agent

Invoke `@sales-engineer` with:
- The target and what it does (from Step 2's context)
- The client/audience scope
- The verbosity flag, if set

## Step 4: Write the artifact and summarize

Write the agent's returned story to `STORY.md` at the repo root (or `demo/<slug>.story.md` if a `demo/` directory already exists). Then print a terse summary of the wow moment and the next step to the user.
