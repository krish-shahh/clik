# clik

A complete Claude Code setup you enable **once** and get in **every** project: specialist review agents, workflow skills, safety/format hooks, and a code-graph that Claude navigates instead of reading files at random. Then run `/clik` in any repo to tailor its `CLAUDE.md`, rules, and tooling to what that project actually is — generic by default, or CUDA / data-viz / ML / web / backend / systems on request.

Two layers:

- **Global layer** — the `clik` plugin, enabled at user scope, ships every skill, agent, and hook to every project automatically. No per-project copying.
- **Per-project layer** — `/clik [context]` writes a lean, tailored `CLAUDE.md` + rules + permissions for the repo you're in, and wires the code-graph.

## Install (once, for all projects)

In Claude Code:

```
/plugin marketplace add krish-shahh/clik
/plugin install clik@clik
```

Choose **user** scope when prompted so it applies to every project. Restart Claude Code once.

Or set it declaratively in `~/.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "clik": { "source": { "source": "github", "repo": "krish-shahh/clik" } }
  },
  "enabledPlugins": ["clik@clik"]
}
```

That alone gives you — in every project — all the skills, the `@code-reviewer` / `@security-reviewer` / `@architect` agents, and hooks that block dangerous commands, scan for secrets, protect sensitive files, auto-format on save, and keep the code-graph fresh.

### Recommended: secret-protection at user scope

Plugins can't ship permission rules, so add the universal secret `deny` block to `~/.claude/settings.json` once (covers every project):

```json
{
  "permissions": {
    "deny": [
      "Read(**/.env)", "Read(**/.env.*)", "Read(**/secrets/**)", "Read(**/*.pem)", "Read(**/*.key)",
      "Write(**/.env)", "Write(**/.env.*)", "Write(**/secrets/**)", "Write(**/*.pem)", "Write(**/*.key)",
      "Edit(**/.env)", "Edit(**/.env.*)", "Edit(**/secrets/**)", "Edit(**/*.pem)", "Edit(**/*.key)"
    ]
  }
}
```

## Tailor a project: `/clik`

`/clik` takes a **freeform context string** describing the project. With no argument it auto-detects the stack and applies generic defaults; with context it adapts the commands, rules, conventions, and tooling to that domain — so you're never stuck with `npm`-shaped defaults on a CUDA project.

```
/clik                                          # detect stack, generic setup
/clik cuda kernels, profiled with nsight, runs on a remote A100 cluster
/clik streamlit data-viz dashboard
/clik fastapi service with postgres + alembic
/clik rust CLI, no_std embedded target
```

It writes a tight `CLAUDE.md` (real build/test/lint commands for your toolchain), the relevant `.claude/rules/`, accurate `permissions`, builds the code-graph, and installs a git `post-commit` hook so the graph stays current. The context string wins over auto-detection when they disagree — you know your project.

There's no recipe library — `/clik` reasons from your context string plus the actual project and decides directly: a CUDA project gets `nvcc`/`compute-sanitizer`/`ncu` commands and a kernel-safety rule; a data-viz project gets notebook/figure commands and reproducibility rules; a Rust service gets `cargo`/clippy and an error-handling rule. The skill carries a short "what good tailoring looks like" checklist (real commands, scoped rules, encode the non-obvious gotchas, drop what doesn't apply) — not a static profile per domain to maintain.

## code-review-graph: traverse, don't scan

clik leans on [`code-review-graph`](https://pypi.org/project/code-review-graph/) — a structural index of every symbol, call edge, import, and test. The bundled rule makes the graph Claude's **primary way to navigate code**: it queries `get_minimal_context_tool`, `semantic_search_nodes_tool`, and `query_graph_tool` (callers / callees / tests / impact) before ever reaching for Grep or random file reads. That's faster, cheaper in tokens, and structurally aware.

The graph is kept **fresh in real time**:

- **after Claude edits a file** — an async `PostToolUse` hook incrementally rebuilds in the background (`hooks/update-graph.sh`), so the next traversal sees the change with zero added latency.
- **after every commit** — a git `post-commit` hook (`hooks/git/post-commit`, installed by `/clik`) catches edits made outside Claude (your IDE, `git pull`, merges).
- **at session start** — builds the graph if it's missing.

## Skills

Invoked with `/name`. All manual-only except `/test-writer`.

| Command | Args | Description |
|---|---|---|
| `/clik` | `[context]` | Tailor this project's CLAUDE.md, rules, permissions, and code-graph to its domain. |
| `/init-project` | `[repo URL]` | Create/connect a GitHub repo, scaffold `CLAUDE.md`, commit and push. |
| `/start-issue` | `[issue #]` | Create `feature/issue-N-slug`, capture graph context, update `## Active Issue`. |
| `/done` | — | Check ACs against the diff, get blast radius, post completion comment, close issue, open PR. |
| `/pr-review` | `[PR #, "staged", file]` | Graph-scoped review via specialist agents; unified severity-ranked report. |
| `/tdd` | `[feature]` | Strict red-green-refactor loop, commit after each cycle. |
| `/refactor` | `[target]` | Safe refactor with tests as a net; never mixes refactor with behavior change. |
| `/debug-fix` | `[issue/error] [--fast]` | Reproduce → investigate → regression test → fix. `--fast` = hotfix mode. |
| `/codex-tests` | `[file/dir]` | Delegate test-writing to Codex; iterate until green. |
| `/codex-fix` | `[error]` | Delegate an isolated reproducible bug to Codex. |
| `/codex-qa` | `[flows + env]` | Browser/E2E QA via Codex — drive user flows, catch regressions, report repro + severity. |
| `/ship` | `[msg]` | Stage, commit (skipping secrets), push, open PR — confirmed at each step. |
| `/setup-ci` | — | Scaffold a GitHub Actions CI for the detected stack. |
| `/deploy` | `[vercel\|railway\|fly\|render]` | Detect stack, scaffold config, walk env-var checklist, deploy. |
| `/standup` | `[hours]` | Standup from git + GitHub activity. Default 24h. |
| `/explain` | `[file/fn]` | Summary, mental model, ASCII diagram, modification guide. |
| `/test-writer` | *(auto)* | Comprehensive tests for new/changed code. The only auto-triggering skill. |
| `/context-budget` | `[--api]` | Per-turn token cost of your `.claude/` config. |
| `/code-review-graph-setup` | — | Install + wire + build the graph (normally handled by `/clik`). |

> **Platform tooling is intentionally out of scope.** Vercel, Supabase, shadcn, Stripe, etc. are better served by the official Anthropic/vendor plugins and MCP servers. clik tailors your project's config and ships the review/workflow kit — it doesn't reinvent platform integrations.

## Agents

Auto-delegated by skills, or invoke directly with `@name`.

| Agent | Used for |
|---|---|
| `@architect` | Implementation plan before coding a complex feature. |
| `@code-reviewer` | Off-by-ones, null derefs, logic bugs, race conditions, error gaps. |
| `@security-reviewer` | Injection, auth, data exposure, crypto, input validation. |
| `@performance-reviewer` | N+1s, leaks, blocking I/O, re-renders, lock contention. |
| `@frontend-designer` | Production UI with design tokens, a11y, no generic AI aesthetics. |
| `@doc-reviewer` | Docs vs source drift, stale refs, missing params. |

## Rules

Modular, mostly path-scoped so they only cost tokens near matching files: `code-quality`, `testing`, `error-handling`, `security`, `database`, `observability`, `frontend`, `code-review-graph`. `/clik` selects and path-tunes the relevant ones per project.

## Hooks

Ship in the plugin (`plugins/clik/hooks/hooks.json`) and fire in every project once enabled:

| Hook | Event | Does |
|---|---|---|
| `protect-files` | PreToolUse Edit/Write | Block edits to secrets, keys, lockfiles, generated files. |
| `scan-secrets` | PreToolUse Edit/Write | Detect credentials in file content. |
| `warn-large-files` | PreToolUse Edit/Write | Block writes to build artifacts and binaries. |
| `block-dangerous-commands` | PreToolUse Bash | Block push-to-main, force push, `rm -rf /`, `DROP TABLE`, `curl \| sudo`. |
| `format-on-save` | PostToolUse Edit/Write | Auto-format (Prettier/Black/Ruff/Biome/rustfmt/gofmt). |
| `update-graph` | PostToolUse Edit/Write | Async incremental code-graph refresh. |
| `session-start` | SessionStart | Branch + dirty state, active issue body, builds graph if missing. |

## Repo layout

Single source of truth at the root; `scripts/sync-plugins.sh` generates the plugin folders (CI enforces they stay in sync).

```
clik/
├── .claude-plugin/marketplace.json   # marketplace catalog
├── agents/        # source: specialist subagents
├── skills/        # source: slash-command skills (incl. the clik/ setup skill)
├── rules/         # source: modular rules
├── hooks/         # source: hook scripts + git/post-commit + tests/
├── plugins/clik/  # generated: the one comprehensive plugin (skills+agents+hooks+template)
└── scripts/sync-plugins.sh
```

## Requirements

- **Claude Code** with `gh` authenticated (`gh auth login`)
- **code-review-graph** — `pip install code-review-graph` (auto-installed by `/clik`)
- **Codex CLI** in PATH (`codex login`) — for `/codex-tests` and `/codex-fix`
- `jq` — `brew install jq` / `apt install jq` (used by hooks)

## License

MIT. Use it, fork it, adapt it. See [LICENSE](LICENSE).
