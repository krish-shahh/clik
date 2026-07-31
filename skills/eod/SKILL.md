---
name: eod
description: End-of-day brain dump — turn today's Claude Code sessions, git activity, and code changes into a shareable status update with priorities carried forward from yesterday, and file the durable parts (project status, open items, Jira/doc/email mentions) into a persistent personal wiki (Karpathy's LLM Wiki pattern).
argument-hint: "[hours — default: since local midnight]"
disable-model-invocation: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - AskUserQuestion
  - Bash(git *)
  - Bash(gh *)
  - Bash(find *)
  - Bash(jq *)
  - Bash(date *)
  - Bash(mkdir *)
---

Turn today's work into two things: a shareable end-of-day update (paste into Slack or a 1:1), and a durable entry in your personal wiki — a small, LLM-maintained knowledge base that compounds day over day instead of being re-derived from scratch each time. Follows Karpathy's [LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f): raw sources stay untouched, the wiki is what the agent writes and revises. See `references/wiki-schema.md` for the full layout.

## Step 0: Find or set up the wiki

Read `~/.claude/eod-wiki-path` if it exists — its contents are the wiki's absolute path.

If it doesn't exist, this is a first run: ask the user where the wiki should live (`AskUserQuestion`), defaulting to `~/wiki`. Once they answer, write their choice to `~/.claude/eod-wiki-path` (just the path, nothing else) so future runs don't ask again.

Ensure the wiki has the structure in `references/wiki-schema.md`, creating anything missing. If `<wiki>/.git` doesn't exist, `git init` it silently — local history only, never push anywhere unless the user explicitly asks.

## Step 1: Determine the time window

If `$ARGUMENTS` is a number, treat it as hours and use `now - N hours` as the window start.
Otherwise default to **local midnight today** — this is an end-of-day doc, not a rolling window like `/standup`.

## Step 2: Gather today's raw material

**Claude sessions** (today's conversations in this project — the project slug is the cwd with `/` replaced by `-`):

```bash
SLUG=$(pwd | sed 's/\//-/g')
for f in ~/.claude/projects/"$SLUG"/*.jsonl; do
  jq -c --arg since "$SINCE" '
    select(.timestamp >= $since) |
    select(.type=="user" or .type=="assistant") |
    select(.message.content != null) |
    {ts: .timestamp, role: .message.role,
     text: (if (.message.content|type)=="string" then .message.content
            else [.message.content[]? | select(.type=="text") | .text] | join(" ") end)} |
    select(.text != "" and .text != null)
  ' "$f" 2>/dev/null
done
```

This yields a chronological stream of what you actually asked for and what got done. Read it for substance, not verbatim quoting — skip pure tool chatter and look for the decisions, dead ends, and things resolved.

**Git activity:**

```bash
git log --since="$SINCE" --author="$(git config user.email)" --stat --oneline --all
git diff --stat                          # uncommitted work in progress
git status --porcelain                   # untracked/staged state
```

**GitHub activity** (if `gh` is available and authenticated): reuse the merged-PR / open-PR / closed-issue queries from `/standup`.

**Repo context:** current branch, and — if this project already has a wiki page (`<wiki>/projects/<repo-name>.md`) — read its `## Open` list and last couple of `## Log` entries so today's update can reference what changed rather than restate it.

**Entity mentions:** while reading the session text from Step 2, note anything you talked about that lives outside this repo — Jira/Linear ticket keys (pattern like `[A-Z]{2,}-\d+`), named documents, email threads. This is extraction from what you actually typed, never a live lookup against Jira/Gmail/Drive — a stub page, not a mirror of the source system.

## Step 3: Write the EOD note

Fill `references/eod-template.md`'s structure with today's real content — Priorities carried over (from each touched project's `## Open` list, oldest first), Wins, FYIs, Things to discuss (come with a recommendation, not just a problem), and a status table per project touched today. Be concrete: reference commit SHAs, PR/issue numbers, file paths, and ticket keys. Skip a section entirely if it has nothing in it.

Save it to `<wiki>/eod/<YYYY-MM-DD>.md`. If today's file already exists (re-running `/eod` later in the day), merge in the new material rather than duplicating what's already captured.

## Step 4: File the durable parts into the wiki

For each project touched today:

1. Open (or create) `<wiki>/projects/<repo-name>.md`.
2. **Append** a dated entry under its `## Log` — what changed, why, what's still open. Never rewrite or delete prior entries; if something earlier turned out wrong, add a new entry that supersedes it and says so.
3. Update `## Open`: check off (`- [x]`) items resolved today — never delete a checked item — and append any new open items raised today. This is what carries priorities into tomorrow's EOD note.
4. Update the page's top summary block only if the project's overall state actually shifted (new status, new owner, scope change) — this is the one part of the page revised in place, not appended to.

For each entity mentioned today (Step 2):

5. Open (or create) `<wiki>/entities/<type>/<name>.md` and **append** a dated line under `## Mentions` linking back to today's `eod/<date>.md`. Same append-only rule as a project log.

Then:

6. Update `<wiki>/index.md` — one line per project and entity page touched, summaries kept current.
7. Append one line to `<wiki>/log.md`: `## [<date>] eod | <repo-name(s) touched>` plus a one-line gist. Keep the prefix consistent so the file stays `grep`-able.

## Step 5: Output

Print the EOD note (Step 3's content) to the user, ready to paste into Slack or a 1:1 doc. Then report in one line which wiki files were touched (created vs. appended), including any entity pages.

## Rules

- The wiki is the durable layer; the EOD note is the disposable/shareable one. Don't let ephemera (a typo fixed, a false start) make it into `projects/*.md` or `entities/*.md` — that belongs in `eod/*.md` at most.
- Never edit history in `log.md`, a project page's prior `## Log` entries, or an entity page's prior `## Mentions`. Append-only; corrections are new entries. `## Open` checkboxes are the one exception — flipping `[ ]` to `[x]` in place is how items resolve.
- Entity extraction is text-mining what you actually typed in the session — never a live call to Jira, Gmail, or Drive. If a mention is ambiguous (unclear if it's a real ticket key or just caps in a sentence), skip it rather than guess.
- If nothing happened today (no commits, no sessions, no diffs), say so honestly and skip the wiki writes — don't manufacture content.
- Keep `<wiki>/` local-only by default. Only push it somewhere if the user explicitly asks.
