# Skills

Slash commands you invoke with `/name`. They run in the main conversation, so they see all loaded rules and `CLAUDE.md`.

- `disable-model-invocation: true` → manual only; you type `/name` to trigger.
- Without that flag, Claude can also trigger the skill automatically when relevant (only `/test-writer` does).

For the full list of skills and what each does, see the [main README](../README.md#skills). The setup skill `/clik` tailors a project's config to its stack and wires the code-graph.

## Adding your own

```
your-skill/
└── SKILL.md
```

```yaml
---
name: your-skill
description: What it does and when to use it
argument-hint: "[optional args]"
disable-model-invocation: true
---

Your instructions. Use $ARGUMENTS for user input.
```

Edit skills at the repo root, then run `scripts/sync-plugins.sh` to fold them into `plugins/clik`. See the [Claude Code docs](https://code.claude.com/docs/en/skills) for all frontmatter options.
