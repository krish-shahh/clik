---
name: standup
description: Generate a standup update from the last 24h of git activity, closed issues, and open PRs.
argument-hint: "[hours — default 24]"
disable-model-invocation: true
allowed-tools:
  - Bash(git *)
  - Bash(gh *)
---

Generate a standup update from recent git and GitHub activity.

## Step 1: Determine the time window

If `$ARGUMENTS` is a number, use it as hours (e.g. `/standup 48` for the last 2 days).
Default: 24 hours.

## Step 2: Gather activity

Run all of these:

```bash
# Commits by this author in the time window
git log --since="${HOURS} hours ago" --author="$(git config user.email)" --oneline --all

# Issues closed in the time window (assigned to me)
gh issue list --assignee @me --state closed --limit 20 \
  --json number,title,closedAt \
  --jq ".[] | select(.closedAt > \"$(date -u -v-${HOURS}H +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -d '${HOURS} hours ago' +%Y-%m-%dT%H:%M:%SZ)\")"

# Open PRs authored by me
gh pr list --author @me --state open --json number,title,url,isDraft \
  --jq '.[] | "#\(.number) \(.title)\(if .isDraft then " [draft]" else "" end)"'

# Merged PRs in time window
gh pr list --author @me --state merged --limit 10 \
  --json number,title,mergedAt \
  --jq ".[] | select(.mergedAt > \"$(date -u -v-${HOURS}H +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -d '${HOURS} hours ago' +%Y-%m-%dT%H:%M:%SZ)\")"

# Open issues assigned to me marked as blocked
gh issue list --assignee @me --state open --label blocked \
  --json number,title \
  --jq '.[] | "- Blocked: #\(.number) \(.title)"'

# Active issue from CLAUDE.md
grep -A1 "^## Active Issue" CLAUDE.md 2>/dev/null | tail -1
```

## Step 3: Format the standup

Synthesize into a compact standup update in this format:

```
**Yesterday / Since last standup**
- <what was completed — closed issues, merged PRs, significant commits>

**Today**
- <what's in progress — open PRs, active issue from CLAUDE.md>

**Blockers**
- <blocked issues, or "none">
```

Rules:
- Be concrete: reference issue/PR numbers
- Keep each bullet to one line
- Omit sections that have nothing in them (no blockers → skip the section entirely)
- Don't include trivial commits (merge commits, version bumps, typo fixes) unless there's nothing else
- If there's no activity at all, say so honestly: "No commits or issues in the last N hours."

## Step 4: Output

Print the standup update, ready to paste into Slack, Linear, or wherever the team communicates.
