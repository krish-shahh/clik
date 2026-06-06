---
name: init-project
description: Scaffold a new project with a GitHub repo, initial commit, and a CLAUDE.md ready for /clik.
argument-hint: "[optional: existing repo URL]"
disable-model-invocation: true
allowed-tools:
  - Bash(git *)
  - Bash(gh *)
  - Read
  - Write
  - Edit
  - Glob
---

Initialize a new project with a GitHub repo, a scaffolded `CLAUDE.md`, and an initial commit.

## Step 1: Verify gh CLI

```bash
gh --version
gh auth status
```

If `gh` is not installed, stop and tell the user:
> "gh CLI is not installed. Install it from https://cli.github.com then run `gh auth login`."

If not authenticated, stop and tell the user:
> "gh CLI is not authenticated. Run `gh auth login` and follow the prompts."

## Step 2: Determine the repo

Check `$ARGUMENTS` first. If it contains a GitHub URL (e.g. `https://github.com/owner/repo`), use it as the remote origin and skip repo creation.

Otherwise, ask the user one question:
> "Create a new GitHub repo or connect to an existing one? Reply with:
> - `new` to create a new repo (I'll prompt for the name)
> - A GitHub URL to use an existing repo"

Wait for the response.

**If `new`**: ask for the repo name and visibility:
> "What should the repo be named, and should it be public or private?"

Then create it:
```bash
gh repo create <name> --<public|private> --clone=false --description "<name>"
```

Capture the repo URL from the output. Then set up the remote:
```bash
git init
git remote add origin <url>
```

**If URL provided**: set up the remote (or verify it already exists):
```bash
git remote get-url origin 2>/dev/null || git remote add origin <url>
```

## Step 3: Check existing state

```bash
git log --oneline -5 2>/dev/null || echo "no commits yet"
ls -la
```

Read any existing `CLAUDE.md` if present.

## Step 4: Scaffold CLAUDE.md

If `CLAUDE.md` already exists, check whether it has `## Active Issue` and `## Stack` sections. If not, add them.

If `CLAUDE.md` does not exist, create it with this template:

```markdown
## Stack

> Fill in: language, framework, runtime version, package manager, test runner, linter.

## Commands

```bash
# Build

# Test

# Lint & Format

# Dev
```

## Architecture

> Fill in: non-obvious architectural decisions. Don't describe files; Claude can explore.

## Active Issue

<!-- Managed by /start-issue and /done. Do not edit manually. -->
none

## Workflow

- Branch naming: `feature/issue-N-slug` (e.g. `feature/issue-42-add-auth`)
- Run `/start-issue <N>` to pick up a ticket and create the branch
- Run `/done` when the work is complete to post the completion comment and open a PR
```

Show the file to the user and ask:
> "Does this CLAUDE.md look right? Any sections to adjust before I commit?"

Wait for confirmation.

## Step 5: Initial commit and push

Stage and commit:
```bash
git add CLAUDE.md
git diff --cached --quiet || git commit -m "chore: init project with CLAUDE.md"
```

If there are other files (code, README, etc.), stage and commit them too before pushing. Never stage `.env*`, `*.key`, `*.pem`, `node_modules/`, or build output.

Push to the remote:
```bash
git push -u origin main 2>/dev/null || git push -u origin master 2>/dev/null || git push -u origin HEAD
```

## Step 6: Report back

Tell the user:
- The repo URL
- That `CLAUDE.md` is committed with `## Active Issue` and `## Stack` stubs
- Next step: run `/clik` to tailor the project's config to its stack, then `@architect` to plan the first feature and `/start-issue` to begin
