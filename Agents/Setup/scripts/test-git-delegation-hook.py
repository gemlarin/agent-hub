#!/usr/bin/env python3
"""OS-agnostic smoke test for the git-delegation hook (no git/gh subprocess)."""

from __future__ import annotations

import hashlib
import json
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
HOOK = ROOT / ".cursor" / "hooks" / "git-delegation-hook.py"
STATE = ROOT / ".cursor" / "hooks" / "state"


def marker_dirs() -> list:
    digest = hashlib.sha256(str(ROOT.resolve()).encode()).hexdigest()[:16]
    return [
        STATE,
        Path(tempfile.gettempdir()) / "cursor-agent-hub-git-delegation" / digest,
    ]


def marker_count() -> int:
    n = 0
    for d in marker_dirs():
        if d.is_dir():
            n += len(list(d.glob("coordinator-*.active")))
    return n


def clear_markers() -> None:
    for d in marker_dirs():
        if not d.is_dir():
            continue
        for p in d.glob("coordinator-*.active"):
            p.unlink(missing_ok=True)


def run_hook(payload: dict) -> dict:
    proc = subprocess.run(
        [sys.executable, str(HOOK)],
        input=json.dumps(payload),
        capture_output=True,
        text=True,
        check=False,
    )
    if proc.returncode != 0:
        raise SystemExit(
            f"hook exited {proc.returncode}\nstdout={proc.stdout}\nstderr={proc.stderr}"
        )
    line = (proc.stdout or "").strip().splitlines()
    if not line:
        return {}
    return json.loads(line[-1])


def expect(label: str, payload: dict, permission: str) -> None:
    print(f"== {label} ==")
    out = run_hook(payload)
    print(json.dumps(out))
    if out.get("permission") != permission:
        raise SystemExit(f"FAIL: expected permission={permission}, got {out}")


def shell(command: str) -> dict:
    return {
        "hook_event_name": "beforeShellExecution",
        "command": command,
        "workspace_roots": [str(ROOT)],
    }


def assert_git_detection() -> None:
    import importlib.util

    spec = importlib.util.spec_from_file_location("git_delegation_hook", HOOK)
    mod = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(mod)
    detect = mod.git_or_gh_command
    assert detect("git status")
    assert detect("git.exe status")
    assert detect(r"C:\Program Files\Git\cmd\git.exe status")
    assert detect("gh pr create")
    assert not detect("python3 .cursor/hooks/git-delegation-hook.py")
    assert not detect("echo hello")


def main() -> int:
    assert_git_detection()
    clear_markers()
    expect("deny git without marker", shell("git status"), "deny")
    expect(
        "deny git.exe without marker",
        shell(r"C:\Program Files\Git\cmd\git.exe status"),
        "deny",
    )
    expect(
        "activate via CallDynamicTool preToolUse",
        {
            "hook_event_name": "preToolUse",
            "tool_name": "CallDynamicTool",
            "tool_use_id": "smoke-1",
            "tool_input": {
                "namespace": "cursor",
                "toolName": "Task",
                "arguments": {"subagent_type": "git-coordinator"},
            },
            "workspace_roots": [str(ROOT)],
        },
        "allow",
    )
    if marker_count() < 1:
        raise SystemExit("FAIL: expected coordinator marker after preToolUse")
    expect("allow git with marker", shell("git status"), "allow")
    expect("allow git.exe with marker", shell("git.exe status"), "allow")
    expect(
        "activate via native Task preToolUse",
        {
            "hook_event_name": "preToolUse",
            "tool_name": "Task",
            "tool_use_id": "smoke-2",
            "tool_input": {"subagent_type": "git-coordinator"},
            "workspace_roots": [str(ROOT)],
        },
        "allow",
    )
    expect(
        "activate via subagentStart",
        {
            "hook_event_name": "subagentStart",
            "subagent_type": "git-coordinator",
            "subagent_id": "smoke-3",
            "workspace_roots": [str(ROOT)],
        },
        "allow",
    )
    run_hook(
        {
            "hook_event_name": "postToolUse",
            "tool_name": "CallDynamicTool",
            "tool_use_id": "smoke-1",
            "tool_input": {
                "namespace": "cursor",
                "toolName": "Task",
                "arguments": {"subagent_type": "git-coordinator"},
            },
            "workspace_roots": [str(ROOT)],
        }
    )
    run_hook(
        {
            "hook_event_name": "postToolUse",
            "tool_name": "Task",
            "tool_use_id": "smoke-2",
            "tool_input": {"subagent_type": "git-coordinator"},
            "workspace_roots": [str(ROOT)],
        }
    )
    run_hook(
        {
            "hook_event_name": "subagentStop",
            "subagent_type": "git-coordinator",
            "subagent_id": "smoke-3",
            "workspace_roots": [str(ROOT)],
        }
    )
    if marker_count() != 0:
        raise SystemExit(f"FAIL: expected markers cleared (still {marker_count()})")
    expect("deny git after markers cleared", shell("git status"), "deny")
    expect(
        "hook path is not a git command",
        shell("python3 .cursor/hooks/git-delegation-hook.py"),
        "allow",
    )
    print("OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
