#!/usr/bin/env python3
"""Git delegation hooks for agent-hub.

beforeShellExecution: block git/gh unless git-coordinator is active.
subagentStart / preToolUse: write coordinator-*.active under .cursor/hooks/state/.

Limitation: while a coordinator marker exists, the parent could still run git
in the same window; rules + git-coordinator remain the primary enforcement.
"""

from __future__ import annotations

import hashlib
import json
import re
import sys
import tempfile
import time
from pathlib import Path

MAX_MARKER_AGE_SEC = 4 * 3600

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


def load_payload() -> dict:
    raw = sys.stdin.read()
    try:
        return json.loads(raw) if raw.strip() else {}
    except json.JSONDecodeError:
        return {}


def resolve_hub(roots: list) -> Path:
    candidates = [Path(r) for r in roots] if roots else [Path.cwd()]
    for path in candidates:
        if (path / ".cursor" / "hooks.json").is_file():
            return path
    return candidates[0]


def parse_object(value) -> dict:
    if isinstance(value, str):
        try:
            value = json.loads(value)
        except json.JSONDecodeError:
            return {}
    return value if isinstance(value, dict) else {}


def git_or_gh_command(command: str) -> bool:
    """True for git/gh invocations on POSIX and Windows (git.exe, quoted paths)."""
    return bool(
        re.search(
            r"(^|[\s;&|'\"\\/])(git|gh)(\.exe)?(\s|$)",
            command,
            flags=re.IGNORECASE,
        )
    )


def coordinator_marker_id(data: dict) -> str:
    raw = (
        data.get("subagent_id")
        or data.get("tool_use_id")
        or data.get("conversation_id")
        or "unknown"
    )
    return re.sub(r"[^A-Za-z0-9._-]+", "-", str(raw))[:80]


def is_git_coordinator_spawn(data: dict) -> bool:
    if data.get("subagent_type") == "git-coordinator":
        return True

    tool_name = data.get("tool_name") or ""
    tool_input = parse_object(data.get("tool_input"))

    if tool_name == "Task":
        st = tool_input.get("subagent_type") or tool_input.get("subagentType")
        return st == "git-coordinator"

    if tool_name in ("CallDynamicTool", "call_dynamic_tool"):
        ns = tool_input.get("namespace") or ""
        tn = tool_input.get("toolName") or tool_input.get("tool_name") or ""
        args = parse_object(tool_input.get("arguments") or tool_input.get("args"))
        st = args.get("subagent_type") or args.get("subagentType")
        return ns == "cursor" and tn == "Task" and st == "git-coordinator"

    return False


def marker_dirs(hub: Path) -> list:
    digest = hashlib.sha256(str(hub.resolve()).encode()).hexdigest()[:16]
    return [
        hub / ".cursor" / "hooks" / "state",
        Path(tempfile.gettempdir()) / "cursor-agent-hub-git-delegation" / digest,
    ]


def ensure_writable(path: Path) -> bool:
    try:
        path.mkdir(parents=True, exist_ok=True)
        probe = path / ".write-ok"
        probe.write_text("ok", encoding="utf-8")
        probe.unlink(missing_ok=True)
        return True
    except OSError:
        return False


def prune_stale_markers(state_dirs: list) -> None:
    now = time.time()
    for state_dir in state_dirs:
        if not state_dir.is_dir():
            continue
        for path in state_dir.glob("coordinator-*.active"):
            try:
                if now - path.stat().st_mtime > MAX_MARKER_AGE_SEC:
                    path.unlink(missing_ok=True)
            except OSError:
                pass


def coordinator_active(state_dirs: list) -> bool:
    prune_stale_markers(state_dirs)
    return any(
        state_dir.is_dir() and any(state_dir.glob("coordinator-*.active"))
        for state_dir in state_dirs
    )


def activate_coordinator(state_dirs: list, data: dict, marker_id: str) -> None:
    note = data.get("parent_conversation_id") or data.get("conversation_id") or ""
    wrote = False
    for state_dir in state_dirs:
        if not ensure_writable(state_dir):
            continue
        (state_dir / f"coordinator-{marker_id}.active").write_text(note, encoding="utf-8")
        wrote = True
        break
    if not wrote:
        print("git-delegation-hook: could not write coordinator marker", file=sys.stderr)


def deactivate_coordinator(state_dirs: list, marker_id: str | None = None) -> None:
    for state_dir in state_dirs:
        if not state_dir.is_dir():
            continue
        if marker_id:
            (state_dir / f"coordinator-{marker_id}.active").unlink(missing_ok=True)
        else:
            for path in state_dir.glob("coordinator-*.active"):
                path.unlink(missing_ok=True)


def main() -> int:
    data = load_payload()
    event = data.get("hook_event_name") or ""
    hub = resolve_hub(data.get("workspace_roots") or [])
    state_dirs = marker_dirs(hub)

    if event == "sessionStart":
        deactivate_coordinator(state_dirs)
        return 0

    if event == "preToolUse":
        if is_git_coordinator_spawn(data):
            activate_coordinator(state_dirs, data, coordinator_marker_id(data))
        allow_shell()
        return 0

    if event in ("postToolUse", "postToolUseFailure"):
        if is_git_coordinator_spawn(data):
            deactivate_coordinator(state_dirs, coordinator_marker_id(data))
        return 0

    if event == "subagentStart":
        if is_git_coordinator_spawn(data):
            activate_coordinator(state_dirs, data, coordinator_marker_id(data))
        allow_shell()
        return 0

    if event == "subagentStop":
        if is_git_coordinator_spawn(data):
            sid = data.get("subagent_id")
            if sid:
                deactivate_coordinator(state_dirs, coordinator_marker_id(data))
            else:
                deactivate_coordinator(state_dirs)
        return 0

    if event == "beforeShellExecution":
        cmd = data.get("command") or ""
        if not git_or_gh_command(cmd):
            allow_shell()
            return 0
        if coordinator_active(state_dirs):
            allow_shell()
        else:
            deny_shell()
        return 0

    if event in ("afterShellExecution",):
        return 0

    # Empty or unknown payload: fail closed only for git/gh command text.
    cmd = data.get("command") or ""
    if git_or_gh_command(cmd):
        if coordinator_active(state_dirs):
            allow_shell()
        else:
            deny_shell()
        return 0
    if not event:
        deny_shell()
        return 0
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
