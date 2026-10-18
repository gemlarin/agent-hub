#!/usr/bin/env bash
# Git delegation hooks for agent-hub.
# - beforeShellExecution: block git/gh unless a git-coordinator subagent is active.
# - subagentStart/Stop: track coordinator sessions (see .cursor/hooks/state/).
# Limitation: while coordinator is active, the parent could still run git in the same window;
# rules + git-coordinator remain the primary enforcement.

set -euo pipefail

PY="${PYTHON:-/usr/bin/python3}"
if ! command -v "$PY" >/dev/null 2>&1; then
  PY="$(command -v python3)"
fi

exec "$PY" - "$@" <<'PY'
import json
import re
import sys
from pathlib import Path

raw = sys.stdin.read()
try:
    data = json.loads(raw) if raw.strip() else {}
except json.JSONDecodeError:
    data = {}
event = data.get("hook_event_name", "")
roots = data.get("workspace_roots") or []
hub = Path(roots[0]) if roots else Path.cwd()
state_dir = hub / ".cursor" / "hooks" / "state"
state_dir.mkdir(parents=True, exist_ok=True)

DENY_USER = "Git and gh are delegated to the git-coordinator subagent."
DENY_AGENT = (
    "Do not run git or gh in the parent shell. "
    "Delegate to subagent_type git-coordinator and use the Git Report."
)


def emit(obj: dict) -> None:
    print(json.dumps(obj))


def allow_shell() -> None:
    emit({"permission": "allow"})


def deny_shell() -> None:
    emit(
        {
            "permission": "deny",
            "user_message": DENY_USER,
            "agent_message": DENY_AGENT,
        }
    )


def coordinator_active() -> bool:
    return any(state_dir.glob("coordinator-*.active"))


def git_or_gh_command(command: str) -> bool:
    return bool(re.search(r"(^|[;&|]\s*|\s)(git|gh)\b", command))


if event == "sessionStart":
    for f in state_dir.glob("coordinator-*.active"):
        f.unlink(missing_ok=True)
    sys.exit(0)

if event == "subagentStart":
    if data.get("subagent_type") == "git-coordinator":
        sid = data.get("subagent_id") or "unknown"
        parent = data.get("parent_conversation_id") or ""
        (state_dir / f"coordinator-{sid}.active").write_text(parent, encoding="utf-8")
    emit({"permission": "allow"})
    sys.exit(0)

if event == "subagentStop":
    if data.get("subagent_type") == "git-coordinator":
        sid = data.get("subagent_id") or "unknown"
        path = state_dir / f"coordinator-{sid}.active"
        if path.is_file():
            path.unlink()
    sys.exit(0)

if event == "beforeShellExecution":
    cmd = data.get("command") or ""
    if not git_or_gh_command(cmd):
        allow_shell()
        sys.exit(0)
    if coordinator_active():
        allow_shell()
    else:
        deny_shell()
    sys.exit(0)

# Unknown event: allow
if event in ("afterShellExecution",):
    sys.exit(0)

# Matcher-scoped beforeShellExecution may receive empty stdin; still require JSON.
if not event:
    cmd = data.get("command") or ""
    if coordinator_active():
        allow_shell()
    elif git_or_gh_command(cmd) or not cmd:
        deny_shell()
    else:
        allow_shell()
    sys.exit(0)

sys.exit(0)
PY
