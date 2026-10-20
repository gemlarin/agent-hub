#!/bin/sh
# Smoke-test the POSIX git-delegation hook (no Python).
set -eu
HERE=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
HUB=$(CDPATH= cd -- "$HERE/../../.." && pwd)
HOOK="$HUB/.cursor/hooks/git-delegation-hook.sh"
STATE="$HUB/.cursor/hooks/state"
TMPDIR="${TMPDIR:-/tmp}/cursor-agent-hub-git-delegation"

WORK=$(mktemp -d "${TMPDIR:-/tmp}/git-hook-test.XXXXXX")
export TMPDIR="$WORK"
MARKER_TMP="$WORK/cursor-agent-hub-git-delegation"
OTHER=""
cleanup() {
  rm -rf "$WORK"
  [ -n "$OTHER" ] && rm -rf "$OTHER"
}
trap cleanup EXIT

chmod +x "$HOOK" 2>/dev/null || true
rm -f "$STATE"/coordinator.active "$STATE"/coordinator-*.active 2>/dev/null || true
rm -rf "$MARKER_TMP"

run() {
  printf '%s' "$1" | /bin/sh "$HOOK"
}

expect() {
  label=$1
  payload=$2
  want=$3
  out=$(run "$payload")
  printf '%s\n' "== $label =="
  printf '%s\n' "$out"
  printf '%s' "$out" | grep -q "\"permission\":\"$want\"" || {
    printf '%s\n' "FAIL: expected permission=$want" >&2
    exit 1
  }
}

HUB_JSON=$HUB
expect "deny git without marker" \
  "{\"hook_event_name\":\"beforeShellExecution\",\"command\":\"git status\",\"cwd\":\"$HUB_JSON\"}" \
  deny

expect "activate via Task preToolUse" \
  "{\"hook_event_name\":\"preToolUse\",\"tool_name\":\"Task\",\"subagent_id\":\"smoke\",\"tool_input\":{\"subagent_type\":\"git-coordinator\"}}" \
  allow

expect "allow git with marker" \
  "{\"hook_event_name\":\"beforeShellExecution\",\"command\":\"git status\",\"cwd\":\"$HUB_JSON\"}" \
  allow

run "{\"hook_event_name\":\"postToolUse\",\"tool_name\":\"Task\",\"tool_input\":{\"subagent_type\":\"git-coordinator\"}}" >/dev/null

expect "git still allowed after postToolUse" \
  "{\"hook_event_name\":\"beforeShellExecution\",\"command\":\"git status\",\"cwd\":\"$HUB_JSON\"}" \
  allow

run "{\"hook_event_name\":\"subagentStop\",\"subagent_type\":\"git-coordinator\",\"subagent_id\":\"smoke\"}" >/dev/null

expect "deny git after stop" \
  "{\"hook_event_name\":\"beforeShellExecution\",\"command\":\"git status\",\"cwd\":\"$HUB_JSON\"}" \
  deny

expect "mentioning git-coordinator does not activate" \
  "{\"hook_event_name\":\"preToolUse\",\"tool_name\":\"Task\",\"subagent_id\":\"other\",\"tool_input\":{\"subagent_type\":\"code-sweeper\",\"prompt\":\"read git-coordinator.md\"}}" \
  allow

expect "deny git after a different specialist" \
  "{\"hook_event_name\":\"beforeShellExecution\",\"command\":\"git status\",\"cwd\":\"$HUB_JSON\"}" \
  deny

mkdir -p "$STATE"
printf '%s\n' old >"$STATE/coordinator-old.active"
if date -v-5H +%Y%m%d%H%M >/dev/null 2>&1; then
  touch -t "$(date -v-5H +%Y%m%d%H%M.%S)" "$STATE/coordinator-old.active"
else
  touch -d '5 hours ago' "$STATE/coordinator-old.active"
fi
expect "deny git when the marker is stale" \
  "{\"hook_event_name\":\"beforeShellExecution\",\"command\":\"git status\",\"cwd\":\"$HUB_JSON\"}" \
  deny

expect "activate via CallDynamicTool" \
  "{\"hook_event_name\":\"preToolUse\",\"tool_name\":\"CallDynamicTool\",\"subagent_id\":\"dyn\",\"tool_input\":{\"namespace\":\"cursor\",\"toolName\":\"Task\",\"arguments\":{\"subagent_type\":\"git-coordinator\"}}}" \
  allow

expect "allow git after CallDynamicTool" \
  "{\"hook_event_name\":\"beforeShellExecution\",\"command\":\"git status\",\"cwd\":\"$HUB_JSON\"}" \
  allow

run "{\"hook_event_name\":\"subagentStop\",\"subagent_type\":\"git-coordinator\",\"subagent_id\":\"dyn\"}" >/dev/null

expect "deny git after CallDynamicTool stops" \
  "{\"hook_event_name\":\"beforeShellExecution\",\"command\":\"git status\",\"cwd\":\"$HUB_JSON\"}" \
  deny

expect "hook path is not a git command" \
  "{\"hook_event_name\":\"beforeShellExecution\",\"command\":\"python3 .cursor/hooks/git-delegation-hook.py\",\"cwd\":\"$HUB_JSON\"}" \
  allow

OTHER="$WORK/other-repo"
mkdir -p "$OTHER/.git"
expect "allow git -C other repo" \
  "{\"hook_event_name\":\"beforeShellExecution\",\"command\":\"git -C $OTHER status\",\"cwd\":\"$HUB_JSON\"}" \
  allow
QUOTED="$WORK/other repo"
mkdir -p "$QUOTED/.git"
expect "allow quoted git -C other repo" \
  "{\"hook_event_name\":\"beforeShellExecution\",\"command\":\"git -C \\\"$QUOTED\\\" status\",\"cwd\":\"$HUB_JSON\"}" \
  allow
expect "allow git with cwd other repo" \
  "{\"hook_event_name\":\"beforeShellExecution\",\"command\":\"git status\",\"cwd\":\"$OTHER\"}" \
  allow

printf '%s\n' "OK"
