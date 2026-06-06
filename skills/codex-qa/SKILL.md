---
name: codex-qa
description: Delegate browser / end-to-end QA to Codex CLI. Drives the running app through real user flows via a browser MCP (Playwright/Chrome), catches functional and visual regressions, and returns a bug report with repro steps, expected vs actual, and severity. Give it the flows to test and the environment/URL.
argument-hint: "[flows + environment — e.g. 'signup + checkout on http://localhost:3000']"
arguments: [plan]
disable-model-invocation: true
allowed-tools:
  - Bash(codex *)
  - Bash(git *)
  - Bash(gh *)
  - Bash(npx *)
  - Read
  - AskUserQuestion
---

Delegate **browser / end-to-end QA** to Codex — the surface Codex is strongest at. Codex drives the actual app through user journeys, observes what renders, and reports regressions. This is for *running-app* testing (clicking flows, forms, visual checks), not unit tests — use `/codex-tests` for those.

## Step 1: Check Codex is available

```bash
command -v codex >/dev/null 2>&1
```

If not found, stop with: "`codex` not found in PATH. Install it (`npm i -g @openai/codex`) and run `codex login`, then retry."

## Step 2: Ensure Codex has a browser tool

Codex needs browser access to drive the app. List its MCP servers:

```bash
codex mcp list 2>/dev/null
```

If none of them is a browser/Chrome/Playwright server, offer to add one (Playwright MCP is the most reliable, scriptable path — Computer Use has known install caveats on some CLI builds):

> "Codex has no browser tool wired up. Add the Playwright MCP server so it can drive the app? (yes/no)"

On yes:

```bash
codex mcp add playwright -- npx -y @playwright/mcp@latest
```

(If the user prefers desktop-app QA over web, they can instead install the Computer Use plugin from `codex` → plugins; note it may be unavailable on Homebrew-installed CLI builds.)

## Step 3: Gather the test plan

`$ARGUMENTS` should describe **what to test and where**. If it's empty, ask for both:

> "What should Codex QA?  
> 1. Environment / URL (e.g. `http://localhost:3000`, staging URL)  
> 2. The critical flows to exercise (e.g. sign up, log in, create project, checkout)"

Make sure the target app is actually running and reachable before proceeding — remind the user if it's a localhost URL.

## Step 4: Run the QA pass

Run Codex non-interactively. `--ask-for-approval never` is required so it doesn't stall waiting for input; `-o` captures the report.

```bash
codex exec \
  --sandbox workspace-write \
  --ask-for-approval never \
  -o /tmp/codex-qa-report.md \
  "Using your browser tools, QA the app at <URL>.

   Test these user flows, stepping through each like a real user:
   <flows>

   For EVERY bug, broken state, or visual regression you find, report:
   - Flow and step where it occurred
   - Repro steps (numbered)
   - Expected result
   - Actual result
   - Severity: blocker | high | medium | low
   - A note of any console errors or failed requests you observed

   Output a single markdown report grouped by severity, worst first.
   Do NOT modify application source code — this is a read-only QA pass."
```

Stream output so the user sees progress. When it finishes, read `/tmp/codex-qa-report.md`.

## Step 5: Triage and report

Show the user the report grouped by severity. Then offer next steps:

- For each **blocker/high** finding, offer to file a GitHub issue:
  ```bash
  gh issue create --title "<bug>" --body "<repro / expected / actual / severity>"
  ```
- Suggest `/start-issue <N>` to begin fixing, or `/codex-fix` for any isolated, reproducible one.

If Codex found nothing, say so plainly and note which flows were exercised (don't imply coverage it didn't have).

## Rules

- This is a **read-only** QA pass — Codex must not edit app source.
- The app must be running and reachable; never assume it is.
- Be honest about coverage: report exactly which flows were tested. "No bugs found in 3 flows" is not "the app is bug-free."
- Browser MCP (Playwright/Chrome) is the reliable path; only reach for Computer Use if the target is a desktop app, and warn about its CLI-build caveats.
