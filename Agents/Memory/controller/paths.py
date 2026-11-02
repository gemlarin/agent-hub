"""Resolve the memory root from CONFIG.md without printing secrets."""

from __future__ import annotations

import os
import re
from pathlib import Path


def hub_root() -> Path:
    return Path(__file__).resolve().parents[3]


def parse_config(config: Path) -> tuple[Path | None, int | None]:
    if not config.exists():
        return None, None
    text = config.read_text(encoding="utf-8")
    path = None
    cap = None
    match = re.search(r"\*\*MEMORY\.md path:\*\*\s*`([^`]+)`", text)
    if match:
        raw = match.group(1).strip()
        if raw and raw != "/absolute/path/to/MEMORY.md":
            path = Path(raw).expanduser()
    match = re.search(r"\*\*Memory max lines:\*\*\s*`?(\d+)`?", text)
    if match:
        cap = int(match.group(1))
    return path, cap


def resolve_root_and_cap(root: str | None = None) -> tuple[Path, int]:
    env_root = os.environ.get("MEMORY_ROOT")
    config = hub_root() / "Agents" / "Settings" / "CONFIG.md"
    cfg_path, cfg_cap = parse_config(config)
    cap = cfg_cap or 80
    if root:
        return Path(root).expanduser().resolve(), cap
    if env_root:
        return Path(env_root).expanduser().resolve(), cap
    if cfg_path:
        return cfg_path.parent.resolve(), cap
    raise SystemExit("Set MEMORY.md path in Agents/Settings/CONFIG.md")
