# Hooks

Deterministic enforcement. Unlike rules (advisory), hooks **guarantee** behavior by blocking or modifying tool calls before/after they run.

These scripts are the source of truth. `scripts/sync-plugins.sh` copies them into `plugins/clik/hooks/` and generates `plugins/clik/hooks/hooks.json`, which wires them with `${CLAUDE_PLUGIN_ROOT}` paths. Because they ship in the plugin, they fire in **every** project once `clik` is enabled at user scope — no per-project `settings.json` wiring.

See the [main README](../README.md#hooks) for the table of what each hook does.

## Adding your own

1. Add a `.sh` script here (check for `jq`, exit `0` to allow / `2` to block; read JSON on stdin).
2. Add fixtures under `tests/fixtures/<hook-name>/` (see [CONTRIBUTING](../CONTRIBUTING.md)) and run `bash hooks/tests/run-all.sh`.
3. Wire it into the `hooks.json` heredoc in `scripts/sync-plugins.sh`, then run the sync.

See the [Claude Code docs](https://code.claude.com/docs/en/hooks) for all hook events.
