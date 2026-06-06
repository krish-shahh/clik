---
name: codex-tests
description: Delegate test writing to Codex CLI. Finds changed files, runs Codex non-interactively, iterates until tests pass.
argument-hint: "[file or directory — omit to use git diff]"
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
---

Delegate test writing for changed or specified code to Codex CLI.

## Step 1: Check Codex is available

```bash
command -v codex >/dev/null 2>&1
```

If not found, stop with: "`codex` not found in PATH. Make sure Codex CLI is installed and you're logged in."

## Step 2: Determine target files

If `$ARGUMENTS` is provided, use it as the target (file, directory, or glob).

Otherwise, find files changed on this branch that have no corresponding test file:
```bash
git diff main...HEAD --name-only 2>/dev/null || git diff HEAD~1...HEAD --name-only
```

Filter to source files only (exclude existing test files, fixtures, generated files). For each source file, check whether a test file already exists alongside it. Prioritize files with no test coverage at all.

Show the user the list of files to test and ask:
> "I'll write tests for these files: [list]. Proceed? (yes/no)"

Wait for confirmation.

## Step 3: Run Codex

Build the prompt from the target files list. Then run:

```bash
codex exec \
  --sandbox workspace-write --ask-for-approval never \
  "Write comprehensive tests for: [files]

  Requirements:
  - Cover happy path, edge cases, and error paths for every exported function
  - Follow the testing conventions in this project (check for existing test files to match style)
  - Tests must actually run — detect the test runner (Jest, pytest, Go test, etc.) from package.json or go.mod
  - After writing the tests, run the test suite and fix any failures
  - Do not modify source files, only create or modify test files"
```

Stream Codex output to the terminal so the user can see progress.

## Step 4: Run the test suite

After Codex finishes, verify the tests pass:

```bash
# detect and run the right test command
if [ -f package.json ]; then
  npm test 2>/dev/null || npx jest 2>/dev/null || npx vitest run
elif [ -f requirements.txt ] || [ -f pyproject.toml ]; then
  python -m pytest
elif [ -f go.mod ]; then
  go test ./...
elif [ -f Cargo.toml ]; then
  cargo test
fi
```

If tests fail, run Codex again with the failure output:

```bash
codex exec --sandbox workspace-write --ask-for-approval never \
  "The tests you wrote are failing. Fix them. Test output: [paste failure output]"
```

Retry up to 2 times. If still failing after 2 retries, tell the user and show the failure.

## Step 5: Stage and report

Stage new and modified test files:
```bash
git diff --name-only HEAD | grep -E '(test|spec)' | xargs git add
git diff --cached --name-only
```

Show the user:
- List of test files created or updated
- Test suite result (pass/fail count)
- Next step: run `/done` if all acceptance criteria are now met, or `/codex-fix` if there are still failing tests
