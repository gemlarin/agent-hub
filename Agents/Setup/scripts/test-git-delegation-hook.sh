#!/usr/bin/env bash
# Smoke-test git delegation hook without running git/gh in this process.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
HOOK="$ROOT/.cursor/hooks/git-delegation-hook.py"
STATE="$ROOT/.cursor/hooks/state"
PY="${PYTHON:-/usr/bin/python3}"

rm -f "$STATE"/coordinator-*.active

expect() {
  local label="$1" payload="$2" needle="$3"
  echo "== $label =="
  local out
  out="$(printf '%s' "$payload" | "$PY" "$HOOK")"
  echo "$out"
  case "$out" in
    *"$needle"*) ;;
    *)
      echo "FAIL: expected $needle" >&2
      exit 1
      ;;
  esac
}

ROOT_JSON="$ROOT"
expect "deny git without marker" \
  "{\"hook_event_name\":\"beforeShellExecution\",\"command\":\"git status\",\"workspace_roots\":[\"$ROOT_JSON\"]}" \
  '"permission": "deny"'

expect "activate via CallDynamicTool preToolUse" \
  "{\"hook_event_name\":\"preToolUse\",\"tool_name\":\"CallDynamicTool\",\"tool_use_id\":\"smoke-1\",\"tool_input\":{\"namespace\":\"cursor\",\"toolName\":\"Task\",\"arguments\":{\"subagent_type\":\"git-coordinator\"}},\"workspace_roots\":[\"$ROOT_JSON\"]}" \
  '"permission": "allow"'

marker_count="$("$PY" - "$ROOT" <<'PY'
import hashlib, sys, tempfile
from pathlib import Path
hub = Path(sys.argv[1]).resolve()
digest = hashlib.sha256(str(hub).encode()).hexdigest()[:16]
dirs = [hub / ".cursor" / "hooks" / "state", Path(tempfile.gettempdir()) / "cursor-agent-hub-git-delegation" / digest]
n = 0
for d in dirs:
    n += len(list(d.glob("coordinator-*.active"))) if d.is_dir() else 0
print(n)
PY
)"
if [[ "$marker_count" -lt 1 ]]; then
  echo "FAIL: expected coordinator marker after preToolUse" >&2
  ls -la "$STATE" >&2
  exit 1
fi

expect "allow git with marker" \
  "{\"hook_event_name\":\"beforeShellExecution\",\"command\":\"git status\",\"workspace_roots\":[\"$ROOT_JSON\"]}" \
  '"permission": "allow"'

expect "activate via native Task preToolUse" \
  "{\"hook_event_name\":\"preToolUse\",\"tool_name\":\"Task\",\"tool_use_id\":\"smoke-2\",\"tool_input\":{\"subagent_type\":\"git-coordinator\"},\"workspace_roots\":[\"$ROOT_JSON\"]}" \
  '"permission": "allow"'

expect "activate via subagentStart" \
  "{\"hook_event_name\":\"subagentStart\",\"subagent_type\":\"git-coordinator\",\"subagent_id\":\"smoke-3\",\"workspace_roots\":[\"$ROOT_JSON\"]}" \
  '"permission": "allow"'

printf '%s' "{\"hook_event_name\":\"postToolUse\",\"tool_name\":\"CallDynamicTool\",\"tool_use_id\":\"smoke-1\",\"tool_input\":{\"namespace\":\"cursor\",\"toolName\":\"Task\",\"arguments\":{\"subagent_type\":\"git-coordinator\"}},\"workspace_roots\":[\"$ROOT_JSON\"]}" | "$PY" "$HOOK" >/dev/null
printf '%s' "{\"hook_event_name\":\"postToolUse\",\"tool_name\":\"Task\",\"tool_use_id\":\"smoke-2\",\"tool_input\":{\"subagent_type\":\"git-coordinator\"},\"workspace_roots\":[\"$ROOT_JSON\"]}" | "$PY" "$HOOK" >/dev/null
printf '%s' "{\"hook_event_name\":\"subagentStop\",\"subagent_type\":\"git-coordinator\",\"subagent_id\":\"smoke-3\",\"workspace_roots\":[\"$ROOT_JSON\"]}" | "$PY" "$HOOK" >/dev/null

marker_count="$("$PY" - "$ROOT" <<'PY'
import hashlib, sys, tempfile
from pathlib import Path
hub = Path(sys.argv[1]).resolve()
digest = hashlib.sha256(str(hub).encode()).hexdigest()[:16]
dirs = [hub / ".cursor" / "hooks" / "state", Path(tempfile.gettempdir()) / "cursor-agent-hub-git-delegation" / digest]
n = 0
for d in dirs:
    n += len(list(d.glob("coordinator-*.active"))) if d.is_dir() else 0
print(n)
PY
)"
if [[ "$marker_count" -ne 0 ]]; then
  echo "FAIL: expected markers cleared (still $marker_count)" >&2
  exit 1
fi

expect "deny git after markers cleared" \
  "{\"hook_event_name\":\"beforeShellExecution\",\"command\":\"git status\",\"workspace_roots\":[\"$ROOT_JSON\"]}" \
  '"permission": "deny"'

echo "OK"
