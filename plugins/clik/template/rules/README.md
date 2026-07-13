# Rules

Modular instruction files Claude loads automatically. They extend `CLAUDE.md` without bloating it.

- `alwaysApply: true` — loaded every session regardless of open files. Costs tokens every turn, so keep it tight (budget: under ~30 lines each).
- `paths: [...]` — loaded only when working with files matching the globs. Free until you're near matched files.

Push anything that doesn't actively change Claude's behavior into a path-scoped rule, an agent, or out entirely. `/clik` selects the rules that apply to a project and tunes their `paths:` to its real directories. These also install at user scope (`~/.claude/rules/`) to apply across all projects.

The current rules: `code-quality` and `testing` (always-on), and `security`, `error-handling`, `database`, `frontend`, `observability` (path-scoped).

## Adding your own

```yaml
---
alwaysApply: true        # OR:  paths: ["src/your-area/**"]
---

# Your Rule Name
- Instructions here
```

See the [Claude Code docs](https://code.claude.com/docs/en/memory#path-specific-rules) for glob syntax.
