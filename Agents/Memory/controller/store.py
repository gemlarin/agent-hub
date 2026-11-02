"""Structured canonical store. Markdown is a generated view."""

from __future__ import annotations

import json
import os
import threading
from contextlib import contextmanager
from datetime import datetime, timezone
from pathlib import Path

from .perms import restrict_path

SECTIONS = {
    "preference": "Preferences",
    "decision": "Active projects",
    "fact": "Solutions & conventions",
    "technical_context": "Solutions & conventions",
    "blocker": "Blockers",
}


class Store:
    def __init__(self, root: Path, max_lines: int):
        self.root = Path(root)
        self.max_lines = max_lines
        self.store_file = self.root / "store.json"
        self.memory_file = self.root / "MEMORY.md"
        self._thread_lock = threading.RLock()
        self._lock_path = self.root / ".store.lock"

    @contextmanager
    def _guard(self):
        with self._thread_lock:
            self._lock_path.parent.mkdir(parents=True, exist_ok=True)
            handle = open(self._lock_path, "a+b")
            try:
                _lock_file(handle)
                yield
            finally:
                _unlock_file(handle)
                handle.close()

    def load(self) -> dict:
        with self._guard():
            return self._load()

    def _load(self) -> dict:
        if not self.store_file.exists():
            return {"version": 1, "entries": []}
        return json.loads(self.store_file.read_text(encoding="utf-8"))

    def save(self, data: dict) -> None:
        with self._guard():
            self._save(data)

    def save_store_only(self, data: dict) -> None:
        """Write store.json and leave MEMORY.md unchanged."""
        with self._guard():
            data = dict(data)
            data["version"] = 1
            self._atomic_write(self.store_file, json.dumps(data, indent=2) + "\n")
            restrict_path(self.store_file)

    def _save(self, data: dict) -> None:
        data = dict(data)
        data["version"] = 1
        entries = list(data.get("entries") or [])
        rendered = self.render(entries)
        while rendered.count("\n") + 1 > self.max_lines and entries:
            entries.pop(0)
            rendered = self.render(entries)
        data["entries"] = entries
        self._atomic_write(self.store_file, json.dumps(data, indent=2) + "\n")
        self._atomic_write(self.memory_file, rendered)
        restrict_path(self.store_file)
        restrict_path(self.memory_file)

    def append(self, entry: dict) -> None:
        with self._guard():
            data = self._load()
            entries = [e for e in data.get("entries") or [] if e.get("content") != entry.get("content")]
            entries.append(entry)
            data["entries"] = entries
            self._save(data)

    def forget(self, needle: str) -> int:
        text = (needle or "").strip()
        if not text:
            raise ValueError("Forget needle is empty")
        with self._guard():
            data = self._load()
            before = data.get("entries") or []
            after = [
                e
                for e in before
                if text.lower() != str(e.get("content") or "").strip().lower()
            ]
            data["entries"] = after
            self._save(data)
            return len(before) - len(after)

    def render(self, entries: list[dict]) -> str:
        grouped = {title: [] for title in ("Preferences", "Active projects", "Solutions & conventions", "Blockers")}
        for entry in entries:
            title = SECTIONS.get(entry.get("type"), "Solutions & conventions")
            grouped.setdefault(title, []).append(entry)
        lines = [
            "# MEMORY.md",
            "",
            "> Private cross-session memory. Never commit this file.",
            "",
        ]
        for title, items in grouped.items():
            lines.append(f"## {title}")
            if not items:
                lines.append("")
                continue
            for item in items:
                lines.append(f"- {item.get('content', '').strip()}")
            lines.append("")
        return "\n".join(lines).rstrip() + "\n"

    def _atomic_write(self, path: Path, text: str) -> None:
        path.parent.mkdir(parents=True, exist_ok=True)
        temp = path.with_suffix(path.suffix + ".tmp")
        with temp.open("w", encoding="utf-8") as handle:
            handle.write(text)
            handle.flush()
            os.fsync(handle.fileno())
        os.replace(temp, path)


def _lock_file(handle) -> None:
    if os.name == "nt":
        import msvcrt

        handle.seek(0)
        msvcrt.locking(handle.fileno(), msvcrt.LK_LOCK, 1)
        return
    import fcntl

    fcntl.flock(handle.fileno(), fcntl.LOCK_EX)


def _unlock_file(handle) -> None:
    if os.name == "nt":
        import msvcrt

        handle.seek(0)
        try:
            msvcrt.locking(handle.fileno(), msvcrt.LK_UNLCK, 1)
        except OSError:
            pass
        return
    import fcntl

    fcntl.flock(handle.fileno(), fcntl.LOCK_UN)


def now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()
