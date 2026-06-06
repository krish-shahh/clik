---
name: refactor
description: Safely refactor code with test coverage as a safety net
argument-hint: "[target to refactor. File, function, or pattern]"
disable-model-invocation: true
---

Refactor `$ARGUMENTS` safely.

## Process

### 1. Understand the current state
- **If code-review-graph is installed, map the blast radius FIRST** — never refactor a symbol blind. `get_impact_radius_tool` on the target, `query_graph_tool` `callers_of` to enumerate every call site you must keep working, and `tests_for` to find existing coverage. This is the difference between a safe refactor and silently breaking a caller you didn't know existed.
- Read the code and its tests
- Identify what the code does, its callers, and its dependencies
- If there are no tests, WRITE TESTS FIRST. You need a safety net before changing anything

### 2. Plan the refactoring
- State what you're changing and why (clearer naming, reduced duplication, better structure)
- List the specific transformations (extract function, inline variable, move module, etc.)
- Check: does this change any external behavior? If yes, this isn't a refactor. Reconsider.

### 3. Make changes in small, testable steps
- One transformation at a time
- Run tests after EACH step. Not at the end
- If a test breaks, undo the last step and make a smaller change

### 4. Verify
- All existing tests pass
- Lint and typecheck pass
- The public API hasn't changed (unless that was the explicit goal)
- The code is objectively simpler. Fewer lines, fewer branches, clearer names

## Rules
- If you can't run the tests, don't refactor
- Never mix refactoring with behavior changes in the same commit
- If the refactoring is large (10+ files), break it into multiple commits
