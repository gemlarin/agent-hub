#!/usr/bin/env python3
"""Create the structured memory store, permissions, and per-agent tokens.

Works on macOS and Windows. Does not print tokens. Plaintext tokens go to
the OS secret store (Keychain / Credential Manager), not a file.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "Agents" / "Memory"))

from controller.auth import DEFAULT_POLICIES, write_credentials  # noqa: E402
from controller.perms import restrict_path  # noqa: E402
from controller.secrets import parse_tokens_env, shred_file, store_token  # noqa: E402
from controller.store import Store  # noqa: E402


def ensure_writable_root(root: Path) -> None:
    abs_root = Path(os.path.abspath(root))
    if os.name == "nt":
        drive = abs_root.drive
        if drive and not Path(f"{drive}\\").exists():
            raise SystemExit(f"Drive {drive} is not available")
    else:
        parts = abs_root.parts
        if len(parts) >= 3 and parts[1] == "Volumes":
            volume = Path(parts[0]) / parts[1] / parts[2]
            if not os.path.ismount(str(volume)):
                raise SystemExit(f"{volume} is not mounted. Plug in the disk before installing.")
    try:
        root.mkdir(parents=True, exist_ok=True)
    except PermissionError as err:
        raise SystemExit(f"Cannot create {root}: {err}") from err


def parse_config() -> tuple[Path, int]:
    config = ROOT / "Agents" / "Settings" / "CONFIG.md"
    if not config.exists():
        raise SystemExit("Agents/Settings/CONFIG.md is missing")
    text = config.read_text(encoding="utf-8")
    match = re.search(r"\*\*MEMORY\.md path:\*\*\s*`([^`]+)`", text)
    if not match:
        raise SystemExit("MEMORY.md path is not set in CONFIG.md")
    raw = match.group(1).strip()
    if raw == "/absolute/path/to/MEMORY.md":
        raise SystemExit("Set MEMORY.md path before installing")
    path = Path(raw).expanduser()
    cap = 80
    match = re.search(r"\*\*Memory max lines:\*\*\s*`?(\d+)`?", text)
    if match:
        cap = int(match.group(1))
    return path, cap


def migrate_markdown(path: Path) -> list[dict]:
    if not path.exists():
        return []
    text = path.read_text(encoding="utf-8")
    section = "fact"
    mapping = {
        "preferences": "preference",
        "active projects": "decision",
        "solutions & conventions": "technical_context",
        "blockers": "blocker",
    }
    entries = []
    for line in text.splitlines():
        heading = line.strip().lower()
        if heading.startswith("## "):
            section = mapping.get(heading[3:].strip(), "fact")
            continue
        if line.startswith("- "):
            content = line[2:].strip()
            if content and content not in {"(none yet)", "(none)"}:
                entries.append(
                    {
                        "type": section,
                        "scope": "global",
                        "source": "installer",
                        "content": content,
                    }
                )
    return entries


def write_launchd(root: Path, python: str, plist: Path) -> None:
    memory_pkg = ROOT / "Agents" / "Memory"
    body = f"""<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>dev.gemlarin.memory-controller</string>
  <key>WorkingDirectory</key>
  <string>{memory_pkg}</string>
  <key>ProgramArguments</key>
  <array>
    <string>{python}</string>
    <string>-m</string>
    <string>controller.service</string>
  </array>
  <key>EnvironmentVariables</key>
  <dict>
    <key>MEMORY_ROOT</key>
    <string>{root}</string>
    <key>PYTHONPATH</key>
    <string>{memory_pkg}</string>
  </dict>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
</dict>
</plist>
"""
    plist.write_text(body, encoding="utf-8")
    restrict_path(plist)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", help="Override memory root directory")
    parser.add_argument("--launchd", action="store_true", help="Write a macOS LaunchAgent plist")
    parser.add_argument(
        "--rotate-tokens",
        action="store_true",
        help="Replace credentials.json and OS-store tokens",
    )
    parser.add_argument("--source", help="Existing MEMORY.md to migrate")
    ns = parser.parse_args()
    memory_md, cap = parse_config()
    root = Path(ns.root).expanduser().resolve() if ns.root else memory_md.parent.resolve()
    source = Path(ns.source).expanduser() if ns.source else memory_md
    if ns.source:
        source = source.resolve()
        if not source.is_file():
            raise SystemExit(f"Source MEMORY.md not found: {source}")
    ensure_writable_root(root)
    restrict_path(root, directory=True)

    proposals = root / "Proposals"
    audit = root / "Audit"
    proposals.mkdir(exist_ok=True)
    audit.mkdir(exist_ok=True)
    restrict_path(proposals, directory=True)
    restrict_path(audit, directory=True)

    creds = root / "credentials.json"
    env_path = root / "tokens.env"
    wrote_tokens = False
    if creds.exists() and not ns.rotate_tokens:
        print("Keeping existing credentials.json (pass --rotate-tokens to replace).")
        if env_path.exists():
            migrated = parse_tokens_env(env_path, list(DEFAULT_POLICIES))
            for name, token in migrated.items():
                store_token(name, token)
            shred_file(env_path)
            print("Moved tokens into the OS secret store and removed tokens.env.")
    else:
        write_credentials(creds)
        restrict_path(creds)
        wrote_tokens = True
        if env_path.exists():
            shred_file(env_path)

    store = Store(root, cap)
    existing = store.load()
    if not existing.get("entries"):
        migrated = migrate_markdown(source)
        from controller.store import now_iso
        import uuid

        entries = []
        for item in migrated:
            entries.append(
                {
                    **item,
                    "id": str(uuid.uuid4()),
                    "created": now_iso(),
                    "approved_by": "installer",
                    "proposal_id": "migrated",
                }
            )
        existing["entries"] = entries
        store.save(existing)
        print(f"Migrated {len(entries)} entries from {source}")
    else:
        store.save(existing)

    if ns.launchd and os.name == "posix" and sys.platform == "darwin":
        plist = Path.home() / "Library" / "LaunchAgents" / "dev.gemlarin.memory-controller.plist"
        plist.parent.mkdir(parents=True, exist_ok=True)
        write_launchd(root, sys.executable, plist)

    print(f"Memory root: {root}")
    if wrote_tokens:
        print("Tokens stored in the OS secret store. Do not paste them into chat.")
    print("Agents must call the controller CLI; they must not open store.json.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
