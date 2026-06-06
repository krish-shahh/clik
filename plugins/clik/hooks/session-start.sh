#!/bin/bash
# Injects dynamic project context at session start.
#
# Default (minimal): branch + dirty/clean indicator. ~5-10 tokens.
# Set CLIK_SESSION_VERBOSE=1 to also emit last commit, file count,
# staged status, stash count, and active PR info. ~30-90 tokens, plus
# a network round-trip if `gh` is installed.
#
# Feature-branch extension: when on a feature/issue-N-* branch (or when
# CLAUDE.md has an ## Active Issue section with an issue number), fetches
# the GitHub issue and injects the full ticket body into session context.
# Also prints a /done reminder so the engineer never forgets to close the loop.

# Bail early if not in a git repo (nothing useful to inject).
git rev-parse --git-dir >/dev/null 2>&1 || exit 0

VERBOSE="${CLIK_SESSION_VERBOSE:-0}"
CONTEXT=""

# Branch (essential, cheap).
BRANCH=$(git branch --show-current 2>/dev/null)
if [ -n "$BRANCH" ]; then
  CONTEXT="Branch: $BRANCH"
else
  SHORT_SHA=$(git rev-parse --short HEAD 2>/dev/null)
  [ -n "$SHORT_SHA" ] && CONTEXT="HEAD: detached at $SHORT_SHA"
fi

# Dirty indicator (binary, ~free, very useful).
if ! git diff-index --quiet HEAD -- 2>/dev/null; then
  CONTEXT="$CONTEXT | dirty"
fi

# Verbose extras (opt-in via CLIK_SESSION_VERBOSE=1).
if [ "$VERBOSE" = "1" ]; then
  LAST_COMMIT=$(git log --oneline -1 2>/dev/null)
  [ -n "$LAST_COMMIT" ] && CONTEXT="$CONTEXT | Last: $LAST_COMMIT"

  CHANGES=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  [ "$CHANGES" -gt 0 ] 2>/dev/null && CONTEXT="$CONTEXT | $CHANGES files changed"

  if ! git diff --cached --quiet 2>/dev/null; then
    CONTEXT="$CONTEXT | staged"
  fi

  STASH_COUNT=$(git stash list 2>/dev/null | wc -l | tr -d ' ')
  [ "$STASH_COUNT" -gt 0 ] 2>/dev/null && CONTEXT="$CONTEXT | $STASH_COUNT stash(es)"

  if command -v gh >/dev/null 2>&1; then
    PR_INFO=$(gh pr view --json number,title,state --jq '"PR #\(.number): \(.title) (\(.state))"' 2>/dev/null)
    [ -n "$PR_INFO" ] && CONTEXT="$CONTEXT | $PR_INFO"
  fi
fi

[ -n "$CONTEXT" ] && echo "$CONTEXT"

# ── Active issue injection ──────────────────────────────────────────────────
# Try to resolve an issue number from the branch name or CLAUDE.md.
# Only runs if gh CLI is available.

command -v gh >/dev/null 2>&1 || exit 0

ISSUE_NUMBER=""
IS_FEATURE_BRANCH=0

# 1. Parse issue number from branch name: feature/issue-42-slug → 42
if echo "$BRANCH" | grep -qE '^(feature|fix|chore)/issue-[0-9]+'; then
  ISSUE_NUMBER=$(echo "$BRANCH" | sed -E 's|^[^/]+/issue-([0-9]+).*|\1|')
  IS_FEATURE_BRANCH=1
fi

# 2. Fall back to ## Active Issue in CLAUDE.md
if [ -z "$ISSUE_NUMBER" ]; then
  CLAUDE_MD=""
  if [ -f "CLAUDE.md" ]; then
    CLAUDE_MD="CLAUDE.md"
  elif [ -f "../CLAUDE.md" ]; then
    CLAUDE_MD="../CLAUDE.md"
  fi

  if [ -n "$CLAUDE_MD" ]; then
    # Extract the issue number from "Issue #42:" or "Issue #42 " lines
    ISSUE_NUMBER=$(awk '/^## Active Issue/{found=1; next} found && /Issue #[0-9]+/{match($0,/#([0-9]+)/,a); print a[1]; exit} found && /^##/{exit}' "$CLAUDE_MD" 2>/dev/null)
  fi
fi

# 3. If we have an issue number, fetch and inject the ticket
if [ -n "$ISSUE_NUMBER" ] && [ "$ISSUE_NUMBER" != "none" ]; then
  ISSUE_JSON=$(gh issue view "$ISSUE_NUMBER" --json number,title,state 2>/dev/null)
  if [ -n "$ISSUE_JSON" ]; then
    ISSUE_TITLE=$(gh issue view "$ISSUE_NUMBER" --json title --jq '.title' 2>/dev/null)
    ISSUE_STATE=$(gh issue view "$ISSUE_NUMBER" --json state --jq '.state' 2>/dev/null)
    ISSUE_BODY=$(gh issue view "$ISSUE_NUMBER" --json body --jq '.body' 2>/dev/null)

    echo ""
    echo "Active issue #${ISSUE_NUMBER} [${ISSUE_STATE}]: ${ISSUE_TITLE}"
    if [ -n "$ISSUE_BODY" ]; then
      echo "---"
      # Emit up to 60 lines of the body to keep token cost bounded
      echo "$ISSUE_BODY" | head -60
    fi
    echo "---"
  fi
fi

# 4. Remind the engineer to run /done when on a feature branch
if [ "$IS_FEATURE_BRANCH" = "1" ]; then
  echo ""
  echo "Reminder: run /done when this issue is complete to post the completion comment and open a PR."
fi

# ── code-review-graph: auto-build if installed but graph missing ────────────
# Runs silently in the background — no output on success, one line if building.
if command -v code-review-graph >/dev/null 2>&1; then
  REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
  if [ -n "$REPO_ROOT" ] && [ ! -d "$REPO_ROOT/.codegraph" ]; then
    echo "code-review-graph: building knowledge graph for this project..."
    (cd "$REPO_ROOT" && code-review-graph build >/dev/null 2>&1 && \
      echo "code-review-graph: graph ready.") &
  fi
fi

exit 0
