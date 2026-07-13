---
name: interview
description: One-question-at-a-time interview that extracts what the user actually wants instead of what they think they should want. Use when a request is underspecified, or the user says "interview me" / "grill me".
argument-hint: "[topic or feature to interview about]"
disable-model-invocation: true
---

Interview the user about: **$ARGUMENTS**

## Process

1. Ask exactly ONE question at a time. Never bundle multiple questions into one message.
2. Start broad (what problem does this solve, who's it for) and narrow with each answer (specific behavior, edge cases, constraints).
3. After each answer, silently update your confidence (0-100%) that you understand what to build.
4. Keep asking until confidence reaches ~95%, or the user says to stop.
5. Prefer questions that would change what gets built. Skip questions whose answer wouldn't change the implementation.

## Rules

- Never ask a question you could answer by reading the existing code first — check before asking.
- If an answer reveals the original ask was solving the wrong problem, say so directly and ask whether to keep going.
- Don't pad questions with preamble. One sentence, then the question.

## Output

When confidence hits ~95% (or the user stops the interview), summarize what you learned as a short spec:

```
## Understood requirements

**Problem**: <one line>
**Who**: <one line>
**Must do**: <bullets>
**Must not do / out of scope**: <bullets>
**Open questions** (if any): <bullets — things still unresolved>
```

Ask the user to confirm before starting implementation.
