---
name: doubt
description: Adversarial fresh-context review of a specific in-flight decision or claim. Use when stakes are high (production, security, irreversible) or a confident-sounding answer deserves stress-testing before you commit to it.
argument-hint: "[the decision, claim, or approach to stress-test]"
disable-model-invocation: true
---

Stress-test this decision: **$ARGUMENTS**

## Process

### 1. CLAIM
State the decision or claim precisely, in one or two sentences. If it's ambiguous, resolve the ambiguity explicitly before doubting it — you can't doubt a moving target.

### 2. EXTRACT
List every assumption the claim depends on — about the data, the environment, the caller, the framework's behavior, or the requirements. Be exhaustive; the failure is usually in an assumption nobody stated out loud.

### 3. DOUBT
For each assumption, build the strongest case that it's wrong. Check it against the actual code, docs, or data — don't doubt from memory. Ask: what would have to be true for this claim to fail?

### 4. RECONCILE
For each doubt:
- **Survives**: the assumption holds, evidence cited.
- **Fails**: the claim needs to change — state how.
- **Uncertain**: flag it explicitly as unverified; don't round it up to "probably fine."

### 5. STOP
Give a final verdict: **Confirmed** (proceed as planned), **Revise** (here's the change), or **Escalate** (genuinely needs the user's judgment call, not more analysis).

## Rules

- This is adversarial by design — the goal is finding the failure, not confirming the decision. Don't soften a real doubt to be agreeable.
- Ground every doubt in something checkable (code, docs, test output), not hypothetical worry.
- If nothing survives scrutiny, say the decision needs to change — don't hedge to avoid delivering bad news.
