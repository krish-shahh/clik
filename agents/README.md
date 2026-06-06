# Agents

Specialized Claude instances that run in **isolated context** — they don't see your conversation history or loaded rules, only their own system prompt and tools. Claude delegates to them automatically based on the task, or you invoke one with `@agent-name`.

For the list of agents and what each reviews, see the [main README](../README.md#agents).

## Adding your own

Create a `.md` file in this directory:

```yaml
---
name: your-agent-name
description: When Claude should delegate to this agent
tools:
  - Read
  - Grep
  - Glob
  - Bash
---

Your agent's system prompt here.
```

Edit agents at the repo root, then run `scripts/sync-plugins.sh` to fold them into `plugins/clik`. See the [Claude Code docs](https://code.claude.com/docs/en/sub-agents) for all frontmatter options.
