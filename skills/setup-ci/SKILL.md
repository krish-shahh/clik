---
name: setup-ci
description: Scaffold a GitHub Actions CI workflow tailored to the detected stack. Test, lint, typecheck on every PR.
argument-hint: ""
disable-model-invocation: true
allowed-tools:
  - Bash(git *)
  - Bash(gh *)
  - Read
  - Write
  - Glob
---

Scaffold a GitHub Actions CI workflow for this project.

## Step 1: Check prerequisites

```bash
gh auth status
git remote -v
```

If no GitHub remote, stop and tell the user to push to GitHub first or run `/init-project`.

Check if CI already exists:
```bash
ls .github/workflows/ 2>/dev/null
```

If a `ci.yml` or equivalent already exists, read it, show it to the user, and ask:
> "A CI workflow already exists. Replace it, extend it, or cancel? (replace/extend/cancel)"

Wait for their answer.

## Step 2: Detect the stack

Read key config files to determine language, package manager, test runner, and linter:

```bash
# Node/JS/TS
cat package.json 2>/dev/null | grep -E '"scripts"|"engines"|"devDependencies"' -A 5
# Python
cat pyproject.toml 2>/dev/null || cat requirements.txt 2>/dev/null | head -20
cat setup.cfg 2>/dev/null | grep -E 'tool:pytest|flake8|ruff' -A 3
# Go
cat go.mod 2>/dev/null | head -5
# Rust
cat Cargo.toml 2>/dev/null | head -10
```

Determine:
- **Runtime version**: Node version from `.nvmrc`, `.node-version`, or `package.json#engines`; Python from `.python-version` or `pyproject.toml`; Go version from `go.mod`
- **Package manager**: `npm` / `yarn` / `pnpm` (check for lockfiles); `pip` / `uv` / `poetry`
- **Test runner**: Jest / Vitest / pytest / Go test / cargo test (check `package.json#scripts.test`)
- **Linter**: ESLint / Biome / Ruff / flake8 / golangci-lint
- **Typecheck**: `tsc` / `pyright` / `mypy`

## Step 3: Show the proposed CI config and confirm

Draft the workflow file and show it to the user:

```yaml
name: CI

on:
  push:
    branches: [main, master]
  pull_request:
    branches: [main, master]

jobs:
  ci:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      # runtime setup
      - name: Set up <runtime>
        uses: actions/setup-<runtime>@v4
        with:
          <runtime>-version: '<detected-version>'

      # install
      - name: Install dependencies
        run: <install-command>

      # lint (fail fast)
      - name: Lint
        run: <lint-command>

      # typecheck
      - name: Type check
        run: <typecheck-command>
        if: <only if typecheck detected>

      # test
      - name: Test
        run: <test-command>
```

Ask the user:
> "Does this CI config look right? I'll create `.github/workflows/ci.yml`. Confirm or edit."

Wait for confirmation.

## Step 4: Write the file

```bash
mkdir -p .github/workflows
```

Write the confirmed YAML to `.github/workflows/ci.yml`.

## Step 5: Commit and push

```bash
git add .github/workflows/ci.yml
git commit -m "ci: add GitHub Actions CI workflow"
git push
```

## Step 6: Report back

Tell the user:
- File created: `.github/workflows/ci.yml`
- CI will run on every push to main and every PR
- Link to Actions tab: `https://github.com/<owner>/<repo>/actions`
- Tip: add a status badge to README.md with `![CI](https://github.com/<owner>/<repo>/actions/workflows/ci.yml/badge.svg)`
