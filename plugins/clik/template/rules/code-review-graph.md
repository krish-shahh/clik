---
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
  - "**/*.jsx"
  - "**/*.py"
  - "**/*.go"
  - "**/*.rs"
  - "**/*.java"
  - "**/*.rb"
  - "src/**"
  - "lib/**"
  - "app/**"
  - "pkg/**"
---

# code-review-graph

The knowledge graph is your **primary way to navigate this codebase** — not a fallback. It is a structural index of every symbol, call edge, import, and test, so you traverse the code by *relationships* (who calls this, what it depends on, what tests cover it) instead of reading files at random and guessing. The graph is kept fresh automatically — rebuilt after Claude edits a file, after each commit, and at session start — so it reflects the current code.

These rules apply when code-review-graph is installed. If `get_minimal_context_tool` returns an error, fall back to normal file reads.

## Default to graph traversal, not file scanning

For any task that involves reading or understanding code, reach for the graph FIRST:

- `get_minimal_context_tool` — the minimal set of files and symbols a task needs. Start here.
- `semantic_search_nodes_tool` — find a function/class/symbol by name or concept, instead of `Grep`.
- `query_graph_tool` / `traverse_graph_tool` — walk `callers_of`, `callees_of`, `imports_of`, `tests_for`, `dependencies` to follow the code by structure.
- `get_architecture_overview_tool` — the high-level shape before diving in.

Do NOT call Read, Glob, or Grep on source files until you have queried the graph and checked whether the answer is already there. Only fall back to direct file reads for files the graph explicitly lists under "Additional relevant files" or when the graph returns no results.

## Before any refactor or PR review

Call `get_impact_radius_tool` on the files or functions you are about to change. This tells you what else in the codebase depends on them — their blast radius — so you do not introduce regressions by changing code others rely on.

Do not start a refactor without knowing the blast radius first.

## Before /pr-review

Call `detect_changes_tool` before dispatching reviewer agents. It returns a risk-scored analysis of every changed file, including structural context (callers, dependents, test coverage). Pass the result to each reviewer agent so they can scope their review to the actual impact set — not the entire repo.

## Before modifying any function

Call `query_graph_tool` with `pattern: "callers_of"` for the function you are about to change. Also call with `pattern: "tests_for"` to see existing test coverage. If callers exist that you had not planned to update, surface them to the user before proceeding.

## If you get a "graph not found" error

Call `build_or_update_graph_tool` immediately and wait for it to complete, then retry the original tool call. Do not ask the user to do this manually.
