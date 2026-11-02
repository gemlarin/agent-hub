"""Treat every proposal as untrusted input."""

from __future__ import annotations

import re

SECRET_PATTERNS = [
    r"-----BEGIN .*PRIVATE KEY-----",
    r"(?i)(api[_-]?key|password|secret|token|bearer|ssh-rsa|ssh-ed25519)\s*[:=]\s*\S+",
    r"(?i)\b(sk-|ghp_|github_pat_|xox[baprs]-)\S+",
]

PII_PATTERNS = [
    r"\b\d{3}-\d{2}-\d{4}\b",
    r"\b(?:\d[ -]*?){13,19}\b",
]

REQUIRED_FIELDS = ["type", "scope", "source", "content"]

ALLOWED_TYPES = {
    "fact",
    "preference",
    "decision",
    "technical_context",
    "blocker",
}

ALLOWED_SCOPES = {
    "global",
    "project",
    "agent",
}


def validate(entry: dict) -> list[str]:
    errors: list[str] = []
    if not isinstance(entry, dict):
        return ["Entry must be an object"]

    for field in REQUIRED_FIELDS:
        if not str(entry.get(field) or "").strip():
            errors.append(f"Missing field: {field}")

    if entry.get("type") not in ALLOWED_TYPES:
        errors.append("Invalid memory type")

    if entry.get("scope") not in ALLOWED_SCOPES:
        errors.append("Invalid memory scope")

    content = str(entry.get("content") or "").strip()
    if "\n" in content:
        errors.append("Content must be one line")
    if len(content) > 400:
        errors.append("Content is too long")

    blob = " ".join(str(v) for v in entry.values())
    for pattern in SECRET_PATTERNS + PII_PATTERNS:
        if re.search(pattern, blob):
            errors.append("Potential secret or PII detected")
            break

    return errors
