#!/bin/sh
# Smoke-test the POSIX git-delegation hook (no Python).
set -eu
HERE=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
HUB=$(CDPATH= cd -- "$HERE/../../.." && pwd)
HOOK="$HUB/.cursor/hooks/git-delegation-hook.sh"
STATE="$HUB/.cursor/hooks/state"
TMPDIR="${TMPDIR:-/tmp}/cursor-agent-hub-git-delegation"

chmod +x "$HOOK" 2>/dev/null || true
rm -f "$STATE"/coordinator*.active "$STATE"/coordinator-*.active 2>/dev/null || true
rm -f "$TMPDIR"/coordinator*.active "$TMPDIR"/coordinator-*.active 2>/dev/null || true

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
  "{\"hook_event_name\":\"preToolUse\",\"tool_name\":\"Task\",\"tool_input\":{\"subagent_type\":\"git-coordinator\"}}" \
  allow

expect "allow git with marker" \
  "{\"hook_event_name\":\"beforeShellExecution\",\"command\":\"git status\",\"cwd\":\"$HUB_JSON\"}" \
  allow

run "{\"hook_event_name\":\"postToolUse\",\"tool_name\":\"Task\",\"tool_input\":{\"subagent_type\":\"git-coordinator\"}}" >/dev/null

expect "git still allowed after postToolUse" \
  "{\"hook_event_name\":\"beforeShellExecution\",\"command\":\"git status\",\"cwd\":\"$HUB_JSON\"}" \
  allow

run "{\"hook_event_name\":\"subagentStop\",\"subagent_type\":\"git-coordinator\",\"subagent_id\":\"smoke\"}" >/dev/null
rm -f "$STATE"/coordinator*.active "$STATE"/coordinator-*.active 2>/dev/null || true

expect "deny git after stop" \
  "{\"hook_event_name\":\"beforeShellExecution\",\"command\":\"git status\",\"cwd\":\"$HUB_JSON\"}" \
  deny

expect "hook path is not a git command" \
  "{\"hook_event_name\":\"beforeShellExecution\",\"command\":\"python3 .cursor/hooks/git-delegation-hook.py\",\"cwd\":\"$HUB_JSON\"}" \
  allow

OTHER=$(mktemp -d "${TMPDIR:-/tmp}/not-agent-hub.XXXXXX")
mkdir "$OTHER/.git"
expect "allow git -C other repo" \
  "{\"hook_event_name\":\"beforeShellExecution\",\"command\":\"git -C $OTHER status\",\"cwd\":\"$HUB_JSON\"}" \
  allow
expect "allow git with cwd other repo" \
  "{\"hook_event_name\":\"beforeShellExecution\",\"command\":\"git status\",\"cwd\":\"$OTHER\"}" \
  allow

printf '%s\n' "OK"
