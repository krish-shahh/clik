---
name: codex-fix
description: Delegate an isolated, reproducible bug to Codex CLI. Feed it the error, Codex fixes and verifies. Use for type errors, failing tests, lint failures — anything with a clear error message.
argument-hint: "[error message, failing test name, or issue number]"
disable-model-invocation: true
allowed-tools:
  - Bash(git *)
  - Bash(codex *)
  - Bash(npm *)
  - Bash(npx *)
  - Bash(python *)
  - Bash(python3 *)
  - Bash(pytest *)
  - Bash(go *)
  - Bash(cargo *)
  - Bash(gh *)
---

Delegate an isolated, reproducible bug to Codex CLI and verify the fix.

## When to use this vs /debug-fix

- **`/codex-fix`**: error has a clear message, root cause is probably local (type error, failing assertion, import error, lint rule). Let Codex fix it while you work on something else.
- **`/debug-fix`**: bug requires investigation, reasoning across files, or understanding system behavior. Handle it yourself.

## Step 1: Check Codex is available

```bash
command -v codex >/dev/null 2>&1
```

If not found, stop with: "`codex` not found in PATH. Make sure Codex CLI is installed and you're logged in."

## Step 2: Gather the error

If `$ARGUMENTS` is an issue number, fetch it:
```bash
gh issue view <number> --json title,body
```

If `$ARGUMENTS` is an error string, use it directly.

If `$ARGUMENTS` is empty, ask:
> "What's the error? Paste the error message, test failure output, or describe the bug."

Wait for their answer.

Also capture current test output to give Codex full context:
```bash
npm test 2>&1 | tail -50
# or: python -m pytest 2>&1 | tail -50
# or: go test ./... 2>&1 | tail -50
```

## Step 3: Confirm scope is appropriate

Check the error. If it touches more than 3 files or requires architectural reasoning, warn the user:
> "This looks broader than a quick fix — /debug-fix might be more effective. Proceed with Codex anyway? (yes/no)"

Wait for confirmation.

## Step 4: Run Codex

```bash
codex exec \
  --sandbox workspace-write \
  "Fix the following error. Do not change any logic that isn't directly related to this error.
   Run the test suite after fixing to verify the fix works and doesn't break anything else.

   Error:
   [full error message / test failure output]"
```

Stream output so the user can see what Codex is doing.

## Step 5: Verify

Run the full test suite:
```bash
npm test 2>/dev/null || python -m pytest 2>/dev/null || go test ./... 2>/dev/null || cargo test 2>/dev/null
```

If the fix introduced new failures, run Codex one more time:
```bash
codex exec --sandbox workspace-write \
  "Your fix broke other tests. Original error is fixed but new failures appeared: [new failures]. Fix those without breaking the original fix."
```

If it fails again, stop and tell the user what Codex tried. Suggest using `/debug-fix` for a manual investigation.

## Step 6: Stage and report

Stage the changed files:
```bash
git diff --name-only | xargs git add
```

Show the user:
- Files modified by Codex
- Test suite result
- Suggestion: run `/ship` to commit, or `/done` if this closes the active issue
