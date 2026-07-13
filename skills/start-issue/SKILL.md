---
name: start-issue
description: Pick up a GitHub issue, create the feature branch, update CLAUDE.md, and assign yourself. Add --worktree to work in an isolated git worktree (juggle multiple issues without stashing, keep main clean).
argument-hint: "[issue number] [--worktree]"
disable-model-invocation: true
allowed-tools:
  - Bash(git *)
  - Bash(gh *)
  - Read
  - Edit
---

Start working on a GitHub issue: create the branch, update `CLAUDE.md`, and assign the issue.

## Mode

Check `$ARGUMENTS` for `--worktree` (strip it before parsing the issue number).

- **Default**: create the feature branch in the current working copy and switch to it.
- **`--worktree`**: create the branch in a separate, isolated git worktree (`../<repo>-issue-<N>`). Use this to work several issues in parallel without stashing, and to keep your main checkout untouched. All later steps then operate inside that worktree directory.

## Step 1: Resolve the issue number

If `$ARGUMENTS` is a number, use it directly.

If `$ARGUMENTS` is empty, list open issues for the user to pick from:
```bash
gh issue list --state open --limit 20
```

Ask the user which issue to start. Wait for their answer.

## Step 2: Fetch issue details

```bash
gh issue view <number> --json number,title,body,labels,assignees,milestone
```

Display the issue title and body so the user can see what they're taking on.

## Step 3: Check for blocking issues

Check the issue body for "Blocked by: #N" references. For each referenced issue:
```bash
gh issue view <ref-number> --json state,title
```

If any blocking issue is still open, warn the user:
> "Warning: this issue is blocked by #<N> (<title>), which is still open. Proceed anyway? (yes/no)"

Wait for confirmation before continuing.

## Step 4: Create the branch

Ensure you are on the latest main:
```bash
git checkout main 2>/dev/null || git checkout master
git pull origin main 2>/dev/null || git pull origin master
```

Build the branch name: `feature/issue-<number>-<slug>` where `<slug>` is the issue title lowercased, spaces replaced with hyphens, non-alphanumeric characters stripped, truncated to 40 characters.

Example: issue 42 "Add user authentication" → `feature/issue-42-add-user-authentication`

**Default (branch in place):**
```bash
git checkout -b feature/issue-<number>-<slug>
git push -u origin feature/issue-<number>-<slug>
```

**`--worktree` (isolated working copy):** create the branch in a sibling worktree directory and run the rest of the skill from there. Don't switch the current checkout's branch.
```bash
WT="../$(basename "$PWD")-issue-<number>"
git worktree add -b feature/issue-<number>-<slug> "$WT" "$(git rev-parse --abbrev-ref HEAD)"
git -C "$WT" push -u origin feature/issue-<number>-<slug>
```
Tell the user the worktree path and that they should `cd "$WT"` to work there. Steps 5–6 (`CLAUDE.md`, assignment) operate inside `$WT`. When the issue is done and merged, clean it up with `git worktree remove "$WT"`.

## Step 5: Update CLAUDE.md

Read `CLAUDE.md`. Find the `## Active Issue` section. Replace its content with:

```markdown
## Active Issue

Issue #<number>: <title>

<full issue body verbatim>
```

If there is no `## Active Issue` section, append it at the end of the file.

## Step 6: Assign the issue

```bash
gh issue edit <number> --add-assignee @me
```

## Step 7: Report back

Tell the user:
- Branch created: `feature/issue-<number>-<slug>` (and, in `--worktree` mode, the worktree path + the `cd` to enter it)
- Issue #<number> assigned to them
- The acceptance criteria (extracted from the issue body), formatted as a checklist
- Reminder: run `/done` when the work is complete (and, for a worktree, `git worktree remove` after merge)
