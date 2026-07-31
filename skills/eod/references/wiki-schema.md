# Wiki schema

Karpathy's [LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f), adapted for daily EOD ingestion instead of source-document ingestion. Raw sources here are your Claude sessions and git history — both already persisted elsewhere (`~/.claude/projects/`, git itself) — so there's no `raw/` layer to duplicate; the wiki only holds what the agent synthesizes.

## Layout

```
<wiki>/
├── index.md            # catalog: one line per page, kept current
├── log.md               # append-only chronological record of every /eod run
├── eod/
│   └── YYYY-MM-DD.md    # one file per day — the shareable note (see eod-template.md)
├── projects/
│   └── <repo-name>.md   # one file per project — the durable entity page
└── entities/
    ├── jira/<TICKET-KEY>.md   # e.g. entities/jira/PROJ-123.md
    ├── docs/<slug>.md          # documents mentioned in conversation
    └── people/<slug>.md        # only if a person comes up enough to earn a page
```

## `projects/<repo-name>.md`

Three parts, each revised differently:

```markdown
# <repo-name>

<one-paragraph summary of what this project is and its current state — revised
in place when the state actually shifts, not appended to>

## Open

- [ ] <item> — raised <date>
- [x] <item> — raised <date>, closed <date>

## Log

### <date>
<what changed, why, what's still open — one entry per day worked on this project>

### <earlier date>
<...>
```

The summary block is the only part of the page revised in place. `## Open` is a running checklist — items get checked off (never deleted) when resolved, and new ones get appended when raised; this is what carries priorities forward into the next day's EOD note. `## Log` is append-only, newest entry on top — a wrong or outdated claim gets a new dated entry that says so, never a silent edit to an old one.

## `entities/<type>/<name>.md`

For things you talked about that live outside your own repos — a Jira/Linear ticket, a named document, an email thread. Extracted from what you actually typed in the session (no outside API calls) — a stub, not a mirror of the source system:

```markdown
# <TICKET-KEY or document/thread name>

<one line: what it is, first seen <date>>

## Mentions

- <date> — <one-line context of what was said or decided>, see [eod/<date>](../../eod/<date>.md)
```

Same append-only rule as a project's `## Log`: new mentions add a line, nothing already there gets rewritten.

## `log.md`

One line per `/eod` run, consistent prefix so it stays `grep`-able:

```
## [2026-07-31] eod | clik
## [2026-07-30] eod | clik, some-other-project
```

## `index.md`

```markdown
# Index

## Projects
- [clik](projects/clik.md) — <one-line summary, kept current>

## Entities
- [PROJ-123](entities/jira/PROJ-123.md) — <one-line gist>

## EOD notes
- [2026-07-31](eod/2026-07-31.md)
```
