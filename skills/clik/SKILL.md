---
name: clik
description: Set up clik for THIS project. With no argument it detects the stack and writes a tailored CLAUDE.md + rules + permissions. Give it a freeform context string (e.g. "CUDA kernel library that profiles with nsight", "d3 data-viz dashboard", "fastapi service with postgres") and it adapts the commands, rules, conventions, and tooling to that domain instead of generic defaults. Also wires real-time code-review-graph updates and builds the graph.
argument-hint: "[freeform project context — e.g. 'cuda kernels', 'd3 dashboard', 'fastapi + postgres service']"
arguments: [context]
disable-model-invocation: true
allowed-tools: "Bash Read Write Edit Glob Grep AskUserQuestion"
---

Set up clik for **this** project.

`$ARGUMENTS` is a **freeform description of the project** the user typed after `/clik`. Treat it as the authoritative statement of what this project is and how it should be treated — weight it ABOVE auto-detection when the two disagree. Examples: `/clik cuda kernels, runs on a remote A100 cluster`, `/clik streamlit data-viz dashboard`, `/clik rust CLI, no_std embedded target`. If it is empty, fall back entirely to stack auto-detection.

## What clik already gives you globally (do NOT re-install per project)

The `clik` plugin, enabled at user scope, already provides — in every project — all the workflow skills (`/start-issue`, `/done`, `/pr-review`, `/tdd`, `/ship`, …), the specialist agents (`@code-reviewer`, `@security-reviewer`, `@architect`, …), and the safety/format/session/graph hooks. **Do not copy skills, agents, or hooks into the project.** Your job here is only to tailor the *per-project* config: a tight `CLAUDE.md`, the right `rules/`, accurate `permissions`, and the code-review-graph wiring.

`CLAUDE.md` lives at the project root (`./CLAUDE.md`), NOT inside `.claude/`. Everything else lives in `.claude/`.

Confirm with the user via AskUserQuestion before writing or deleting anything.

## Phase 1: Detect the stack

Scan manifests and config to detect language, framework, package manager, test framework, linter/formatter, architecture, and source/test dirs. Check: `package.json`, `pyproject.toml`, `requirements.txt`, `Cargo.toml`, `go.mod`, `CMakeLists.txt`, `Makefile`, `*.cu`, `Gemfile`, `composer.json`, `build.gradle`, `pom.xml`, `Dockerfile`, notebooks (`*.ipynb`).

Detect monorepos (`workspaces`, `pnpm-workspace.yaml`, `turbo.json`, `nx.json`, multiple manifests at depth 2+). If found, ask which package(s) to focus on and prefix rule path patterns accordingly.

Check `git log --oneline -20` for commit-message style.

If the project is empty (no manifests, no source), write a minimal generic `CLAUDE.md`, tell the user customization is deferred until there's code, and stop.

## Phase 2: Decide the tailoring (reason from the context + project)

There's no recipe library — use your own judgment. From `$ARGUMENTS` plus the Phase 1 detection, work out what this project actually is and what config serves it. You already know the toolchains; apply that knowledge directly.

What good tailoring looks like (the checklist to satisfy, not a script):
- **Real commands** — the project's actual build / test / single-test / lint / format / dev commands, in the domain's real tools. A CUDA project means `nvcc`/`cmake`/`compute-sanitizer`/`ncu`, not `npm`. A data-viz project means notebook + figure-export. Reason it out from the stack and the context string.
- **Encode the non-obvious gotchas** — the domain pitfalls a competent dev would want flagged (CUDA: check every CUDA call, run sanitizers, don't assume a local GPU; ML: seed RNGs, no data leakage across the split; systems: handle every error path, run race/sanitizer tools). Only things that would change how Claude works — skip the obvious.
- **Right rules, scoped** — include the universal rules that apply, drop the ones that don't (no frontend → no `frontend.md`), and `paths:`-scope each to the project's real dirs so they only cost tokens near that code.
- **Honor the context string over detection** when they conflict.

If `$ARGUMENTS` is empty, do the same purely from detection. If it describes something niche you don't fully know, reason from first principles and say what you're unsure about.

Present the plan with AskUserQuestion:

```
Project: "$ARGUMENTS"   (or "auto-detected" if none given)
Read as: <one-line description of what this project is + how you'll tailor it>

I'll write:
- CLAUDE.md      — commands + <the few non-obvious lines>
- .claude/rules/ — <rules to include, scoped to> <dirs>
- .claude/settings.json — permissions for <toolchain>
- code-review-graph — build + real-time update wiring

Apply this? (yes / adjust / no)
```

## Phase 3: Write the per-project config

For each artifact, propose the concrete content and confirm before writing.

### 3.1 CLAUDE.md  (root; target < 25 non-blank lines, hard cap 50)

Loads every turn — keep it lean. Write:
- **Commands** — the REAL build / test / single-test / lint / format / dev commands from the detected manifest, NOT npm placeholders, in the domain's real tools (CUDA → `nvcc`/`cmake`/`compute-sanitizer`/`ncu`; data-viz → notebook + figure-export commands).
- Domain-specific **Architecture / Key Decisions / Domain Knowledge / Don'ts** lines from the project AND the user's `$ARGUMENTS` context — but only lines that are non-obvious and would change how Claude works. Delete sections with nothing to say.
- A one-line **Tools** note pointing at code-review-graph (see `.claude/rules/code-review-graph.md`).

Do not duplicate anything that lives in `rules/`.

### 3.2 .claude/rules/

Copy the universal rules from `${CLAUDE_PLUGIN_ROOT}/template/rules/` that apply, then tailor each rule's `paths:` frontmatter to the project's actual directories. Always include `code-review-graph.md`. If the domain has non-obvious practices worth enforcing, write them as a new `.claude/rules/<domain>.md` (e.g. `cuda.md`, `data-viz.md`) with `paths:` scoped to the relevant files so they only cost tokens near that code. Drop rules that don't apply (no frontend → no `frontend.md`; no DB → no `database.md`).

### 3.3 .claude/settings.json

Start from `${CLAUDE_PLUGIN_ROOT}/template/settings.json` (permissions only — hooks come from the plugin). Replace the `npm run …` allow entries with the project's real commands (its actual toolchain + detected package manager). Keep the secret `deny` rules verbatim. Add `CLAUDE.local.md` to `.gitignore`.

## Phase 4: Wire code-review-graph (real-time traversal)

This makes the graph — not random file reads — the primary way Claude navigates the code, and keeps it fresh as the code changes. Run silently; it's infrastructure.

1. Install if missing: `pip show code-review-graph >/dev/null 2>&1 || pip install code-review-graph` (try `pip3`).
2. Wire the MCP server once per machine (idempotent): `code-review-graph install --platform claude-code 2>/dev/null || true`.
3. Build the graph: `cd` to repo root and `code-review-graph build`. Skip if there's no source yet.
4. Install the git post-commit updater so edits made outside Claude (IDE, `git pull`, merges) also refresh the graph. Chain-safe — preserve any existing hook:

   ```bash
   HOOK=.git/hooks/post-commit
   if [ -d .git ]; then
     if [ -f "$HOOK" ] && ! grep -q 'clik: refresh the code-review-graph' "$HOOK"; then
       # Existing hook present — append a call to ours instead of clobbering.
       cp "$CLAUDE_PLUGIN_ROOT/hooks/git/post-commit" .git/hooks/clik-post-commit
       chmod +x .git/hooks/clik-post-commit
       printf '\n.git/hooks/clik-post-commit\n' >> "$HOOK"
     else
       cp "$CLAUDE_PLUGIN_ROOT/hooks/git/post-commit" "$HOOK"
       chmod +x "$HOOK"
     fi
   fi
   ```

The real-time edit-time updater and the session-start builder already ship with the plugin globally — nothing to install per project for those.

Tell the user Claude Code must be **restarted once** for the MCP server to activate.

> Platform tooling (Vercel, Supabase, shadcn, etc.) is intentionally out of scope — use the official Anthropic/vendor plugins and MCP servers for those. clik tailors the project's config; it doesn't reinvent platform integrations.

## Phase 5: Review, budget check, summary

- Count `CLAUDE.md` non-blank lines: `grep -cv '^[[:space:]]*$' CLAUDE.md`. Under 25 = good; 25–50 = offer trims; over 50 = block and cut the biggest sections before finishing.
- Verify rule `paths:` match real directories, permissions cover the real commands, and no rule contradicts another or `CLAUDE.md`.

Summary:

```
clik configured — read as: <one-line description of the project> (from context "$ARGUMENTS")
- CLAUDE.md: <N> non-blank lines — commands tailored for <toolchain>
- rules: <included> (dropped: <removed>)
- permissions: <toolchain>
- code-review-graph: built (<N> files) + real-time updates wired (edit hook, post-commit hook)
Restart Claude Code once to activate the graph's MCP server.
Tip: /context-budget shows the per-turn token cost of this setup.
```

## Rules

- NEVER write or delete without confirming first.
- The `$ARGUMENTS` context string wins over auto-detection when they conflict — the user knows their project.
- Keep it minimal. If a default works, leave it. A 10-line CLAUDE.md is healthy.
- If detection is uncertain, ASK rather than guess.
- Preserve manual edits already in `.claude/` — only touch what needs project-specific tailoring.
