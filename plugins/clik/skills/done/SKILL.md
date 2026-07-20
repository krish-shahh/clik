---
name: done
description: Close the active issue with a completion comment, open a PR, and queue the next task.
argument-hint: ""
disable-model-invocation: true
allowed-tools:
  - Bash(git *)
  - Bash(gh *)
  - Read
  - Edit
---

Wrap up the current issue: verify acceptance criteria, post a completion comment, close the issue, open a PR, and queue the next task.

If `/overseer` hasn't run yet for this diff, recommend it before continuing — it decides whether this change needs `/doubt`, `/blast-radius`, or `/pr-review` first. Don't block on it; note the recommendation and proceed if the user wants to skip straight to closing out.

## Step 1: Resolve the issue number

Try the branch name first:
```bash
git branch --show-current
```

Parse `feature/issue-<N>-<slug>` → issue number is `N`.

If the branch name doesn't match the pattern, read `CLAUDE.md` and look for the `## Active Issue` section. Parse the issue number from `Issue #<N>:` on the first line.

If no issue number can be found, ask the user:
> "What issue number are you closing? (e.g. 42)"

Wait for their answer.

## Step 2: Fetch the issue and diff

```bash
gh issue view <number> --json number,title,body,labels,milestone
git diff main...HEAD
git log main..HEAD --oneline
```

Parse the acceptance criteria from the issue body — look for the `## Acceptance criteria` section and its `- [ ]` checkboxes.

## Step 3: Check acceptance criteria

For each acceptance criterion, evaluate whether the git diff contains evidence it was met. Check:
- New or modified tests (for "should be tested" criteria)
- New files or functions mentioned in the criterion
- Relevant code patterns or changes

Mark each criterion: ✅ met, ⚠️ uncertain, ❌ not met.

If any criterion is marked ❌, warn the user:
> "These acceptance criteria appear unmet: [list]. Continue anyway? (yes/no)"

Wait for confirmation before continuing.

## Step 4: Draft the completion comment

Draft the following comment and show it to the user for review:

```markdown
## Completed: <issue title>

### What was built
<2-3 sentences describing what was implemented>

### How it was done
<Brief technical approach — key decisions, patterns used>

### Files changed
<bullet list of created/modified files with one-line description each>

### Acceptance criteria
<repeat the checklist with ✅ / ⚠️ / ❌ for each item>

### Decisions made
<Non-obvious choices made during implementation and why>

### Watch out for
<Gotchas, edge cases, or constraints the next person should know>

### Follow-up issues
<Any new issues discovered during this work that should be tracked — or "none">
```

Ask the user:
> "Does this completion comment look right? Edit or confirm to post it."

Wait for confirmation. Apply any requested edits.

## Step 5: Create follow-up issues

If the completion comment lists follow-up issues, create them now before closing:
```bash
gh issue create \
  --title "<follow-up title>" \
  --body "<brief description>\n\nSpun out from #<original-number> during implementation." \
  --label "feature"
```

Capture the new issue numbers and note them in the comment.

## Step 6: Post the comment and close

Post the confirmed comment:
```bash
gh issue comment <number> --body "<confirmed comment>"
```

Close the issue:
```bash
gh issue close <number>
```

## Step 7: Clear active issue in CLAUDE.md

Read `CLAUDE.md`. Find the `## Active Issue` section. Replace its content with:
```markdown
## Active Issue

<!-- Managed by /start-issue and /done. Do not edit manually. -->
none
```

## Step 8: Push branch and open PR

```bash
git push origin HEAD
```

Create a PR:
```bash
gh pr create \
  --title "<issue title> (#<number>)" \
  --body "Closes #<number>

## Summary
<2-4 bullet points from the completion comment>

## Test plan
<How to verify — from the acceptance criteria>

🤖 Generated with [Claude Code](https://claude.com/claude-code)" \
  --base main
```

Show the PR URL.

## Step 9: Show next tasks

```bash
gh issue list --state open --limit 10
```

Show the list and tell the user:
> "Issue #<number> closed. Run `/start-issue <N>` to pick up the next task."
