---
alwaysApply: true
---

# Context Engineering

- Load only what the current task needs. Read the specific file or function, not the whole directory, unless you're doing broad exploration.
- Don't re-read a file you already have current content for in this conversation — trust your own edits and tool results.
- When a session's context is filling with exploration that turned out to be a dead end, say so and drop it rather than carrying it forward.
- Prefer a targeted `Grep`/`Glob` over dumping a large file when you only need one symbol.
- State what you don't know instead of filling gaps with a plausible-sounding guess — an explicit "unverified" is cheaper to fix than a confident wrong answer.
