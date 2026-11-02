"""Owner-only file permissions on macOS, Linux, and Windows."""

from __future__ import annotations

import os
import subprocess
from pathlib import Path


def restrict_path(path: Path, directory: bool = False) -> None:
    path = Path(path)
    if os.name == "nt":
        _restrict_windows(path, directory)
        return
    mode = 0o700 if directory else 0o600
    os.chmod(path, mode)


def _restrict_windows(path: Path, directory: bool) -> None:
    user = os.environ.get("USERNAME") or os.environ.get("USER")
    if not user:
        raise RuntimeError("USERNAME is not set")
    rights = "(OI)(CI)F" if directory else "F"
    subprocess.run(
        ["icacls", str(path), "/inheritance:r", "/grant:r", f"{user}:{rights}"],
        check=True,
        capture_output=True,
        text=True,
    )
