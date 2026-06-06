#!/usr/bin/env bash
# Generates the marketplace's plugin folders from the single source of truth at
# the repo root (agents/ skills/ rules/ hooks/ settings.json CLAUDE.md).
#
# Plugins must be self-contained — Claude Code copies each plugin into a cache
# on install and paths can't escape the plugin root — so every agent/skill/hook
# physically lives inside its plugin folder. Edit the root copies; run this to
# propagate.
#
# It produces:
#   1. Granular per-feature plugins      plugins/<name>/{agents,skills}/...
#   2. The comprehensive `clik` plugin   plugins/clik/{skills,agents,hooks,template}
#      — enable this one at user scope and you get every skill, agent, and the
#        safety/format/session/graph hooks in EVERY project.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
shopt -s nullglob

echo "==> granular plugins"
# agents/<name>.md -> plugins/<name>/agents/<name>.md
for f in agents/*.md; do
  name="$(basename "$f" .md)"; [ "$name" = "README" ] && continue
  mkdir -p "plugins/$name/agents"; cp "$f" "plugins/$name/agents/$name.md"
done
# skills/<name>/ -> plugins/<name>/skills/<name>/   (the clik skill is handled below)
for d in skills/*/; do
  name="$(basename "$d")"; [ "$name" = "clik" ] && continue
  [ -f "${d}SKILL.md" ] || continue
  mkdir -p "plugins/$name/skills/$name"
  cp -R "${d}." "plugins/$name/skills/$name/"
done

echo "==> comprehensive clik plugin"
PLUGIN="plugins/clik"
# Keep the static .claude-plugin/plugin.json; regenerate everything else.
rm -rf "$PLUGIN/skills" "$PLUGIN/agents" "$PLUGIN/hooks" "$PLUGIN/template"
mkdir -p "$PLUGIN/skills" "$PLUGIN/agents" "$PLUGIN/hooks" "$PLUGIN/template"

# All skills (incl. clik + its profiles) and all agents travel with the plugin.
for d in skills/*/; do
  name="$(basename "$d")"; [ -f "${d}SKILL.md" ] || continue
  mkdir -p "$PLUGIN/skills/$name"; cp -R "${d}." "$PLUGIN/skills/$name/"
done
for f in agents/*.md; do [ "$(basename "$f")" = "README.md" ] && continue; cp "$f" "$PLUGIN/agents/"; done

# Hook scripts (not the test suite) + the git hook template.
for s in hooks/*.sh; do cp "$s" "$PLUGIN/hooks/"; done
[ -d hooks/git ] && { mkdir -p "$PLUGIN/hooks/git"; cp hooks/git/* "$PLUGIN/hooks/git/"; }
chmod +x "$PLUGIN"/hooks/*.sh "$PLUGIN"/hooks/git/* 2>/dev/null || true

# Plugin hook manifest. ${CLAUDE_PLUGIN_ROOT} is set by Claude Code to the
# plugin's install dir, so these fire in every project the plugin is enabled in
# — no per-project settings.json wiring, no $CLAUDE_PROJECT_DIR breakage.
cat > "$PLUGIN/hooks/hooks.json" <<'JSON'
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          { "type": "command", "command": "${CLAUDE_PLUGIN_ROOT}/hooks/protect-files.sh", "timeout": 5000, "statusMessage": "Checking file protections..." },
          { "type": "command", "command": "${CLAUDE_PLUGIN_ROOT}/hooks/warn-large-files.sh", "timeout": 5000, "statusMessage": "Checking for build artifacts..." },
          { "type": "command", "command": "${CLAUDE_PLUGIN_ROOT}/hooks/scan-secrets.sh", "timeout": 5000, "statusMessage": "Scanning for secrets..." }
        ]
      },
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": "${CLAUDE_PLUGIN_ROOT}/hooks/block-dangerous-commands.sh", "timeout": 5000, "statusMessage": "Checking command safety..." }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          { "type": "command", "command": "${CLAUDE_PLUGIN_ROOT}/hooks/format-on-save.sh", "timeout": 15000, "statusMessage": "Formatting..." },
          { "type": "command", "command": "${CLAUDE_PLUGIN_ROOT}/hooks/update-graph.sh", "timeout": 5000, "async": true, "statusMessage": "Refreshing code graph..." }
        ]
      }
    ],
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          { "type": "command", "command": "${CLAUDE_PLUGIN_ROOT}/hooks/session-start.sh", "timeout": 5000, "statusMessage": "Loading project context..." }
        ]
      }
    ],
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          { "type": "command", "command": "which osascript >/dev/null 2>&1 && osascript -e 'display notification \"Claude Code needs your attention\" with title \"Claude Code\"' || which notify-send >/dev/null 2>&1 && notify-send 'Claude Code' 'Claude Code needs your attention' || true" }
        ]
      }
    ]
  }
}
JSON

# Per-project template the /clik skill writes into a project: rules + a CLAUDE.md
# starting point + permissions-only settings. NO skills/agents/hooks — those are
# global via the plugin.
cp -R rules "$PLUGIN/template/rules"
cp settings.json "$PLUGIN/template/settings.json"
cp CLAUDE.md "$PLUGIN/template/CLAUDE.md"
[ -f CLAUDE.local.md.example ] && cp CLAUDE.local.md.example "$PLUGIN/template/"

echo "Done. clik plugin: $(ls "$PLUGIN/skills" | wc -l | tr -d ' ') skills, $(ls "$PLUGIN/agents" | wc -l | tr -d ' ') agents, hooks.json + template."
