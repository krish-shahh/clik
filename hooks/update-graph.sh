#!/bin/bash
# Keeps the code-review-graph knowledge graph fresh in near-real-time.
#
# PostToolUse hook for Edit|Write. After Claude edits a source file, this
# incrementally rebuilds the graph IN THE BACKGROUND so the next traversal
# (get_minimal_context_tool, get_impact_radius_tool, query_graph_tool) sees
# the change. Non-blocking: it forks and exits immediately, so it never adds
# latency to the edit. Contributes zero tokens on the common path.
#
# Coalescing: a single mkdir-based lock ensures only one rebuild runs at a
# time. Rapid successive edits collapse into one rebuild that picks up the
# latest state, instead of stacking N rebuilds.
#
# No-ops silently when: jq is missing, code-review-graph is not installed,
# the file is not source code, or no graph exists yet (SessionStart builds
# the first one).

command -v jq >/dev/null 2>&1 || exit 0
command -v code-review-graph >/dev/null 2>&1 || exit 0

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
[ -z "$FILE_PATH" ] && exit 0

# Only react to source files the graph actually indexes.
case "$FILE_PATH" in
  *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs|*.py|*.go|*.rs|*.java|*.rb|*.c|*.cc|*.cpp|*.cu|*.cuh|*.h|*.hpp|*.cs|*.kt|*.swift|*.php|*.scala) ;;
  *) exit 0 ;;
esac

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
[ -z "$REPO_ROOT" ] && exit 0
# Only update if a graph already exists; first build is SessionStart's job.
[ -d "$REPO_ROOT/.codegraph" ] || exit 0

LOCK="$REPO_ROOT/.codegraph/.clik-update.lock"

# Fork the rebuild so the edit returns instantly.
(
  # Coalesce: if a rebuild is already in flight, let it pick up our change.
  if mkdir "$LOCK" 2>/dev/null; then
    trap 'rmdir "$LOCK" 2>/dev/null' EXIT
    # Brief settle window so a burst of edits folds into one rebuild.
    sleep 1
    cd "$REPO_ROOT" && code-review-graph build >/dev/null 2>&1
  fi
) >/dev/null 2>&1 &

exit 0
