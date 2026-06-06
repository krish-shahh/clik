# clik domain profiles

Each profile is a tailoring recipe the `/clik` skill reads to adapt a project's
config to a specific kind of work — so `/clik cuda` doesn't leave you with
generic `npm`-shaped tooling.

`/clik` picks a profile by combining the user's freeform context string
(`/clik <context>`) with auto-detected stack signals, matching against each
profile's `Match:` line. Multiple profiles can be merged (e.g. a FastAPI + React
app). If nothing fits, `/clik` synthesizes a config from first principles using
this same structure and offers to save it here as a new profile.

## Profile format

```
# <Name> profile
Match: <keywords, file signals, and stacks that select this profile>

## Commands        # the CLAUDE.md command block, in this domain's real tools
## Rules           # which universal rules from template/rules/ to include
## Domain rules    # extra rule content → .claude/rules/<name>.md (path-scoped)
## Permissions     # settings.json allow entries for this toolchain
## Gotchas         # domain pitfalls worth encoding so Claude avoids them
```

## Adding a profile

Drop a new `<name>.md` here following the format above. Keep it tight — these
are recipes, not essays. PRs welcome.
