"""Credentials live on disk, not in the model context."""

from __future__ import annotations

import hashlib
import hmac
import json
import secrets
from pathlib import Path

from .perms import restrict_path
from .secrets import store_token

CLIENT = {
    "read": True,
    "propose": True,
    "approve": False,
    "commit": False,
}

DEFAULT_POLICIES = {
    "main_agent": dict(CLIENT),
    "research_scout": dict(CLIENT),
    "code_reviewer": dict(CLIENT),
    "code_sweeper": dict(CLIENT),
    "web_researcher": dict(CLIENT),
    "git_coordinator": dict(CLIENT),
    "hub_installer": dict(CLIENT),
    "job_finder": dict(CLIENT),
    "memory_steward": {
        "read": True,
        "propose": True,
        "approve": True,
        "commit": True,
    },
}


def hash_token(token: str) -> str:
    return hashlib.sha256(token.encode("utf-8")).hexdigest()


def load_credentials(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def authenticate(credentials: dict, principal: str, token: str) -> dict:
    agents = credentials.get("agents") or {}
    record = agents.get(principal)
    if not record:
        raise PermissionError("Unknown agent")
    expected = record.get("token_sha256") or ""
    given = hash_token(token or "")
    if not expected or not hmac.compare_digest(expected, given):
        raise PermissionError("Authentication failed")
    return record


def authorize(record: dict, action: str) -> None:
    perms = record.get("permissions") or {}
    if not perms.get(action):
        raise PermissionError(f"Not allowed to {action}")


def write_credentials(path: Path, policies: dict | None = None) -> dict:
    """Create hashed credentials. Plaintext tokens go to the OS secret store only."""
    policies = policies or DEFAULT_POLICIES
    tokens: dict[str, str] = {}
    agents = {}
    for name, permissions in policies.items():
        token = secrets.token_urlsafe(32)
        tokens[name] = token
        agents[name] = {
            "token_sha256": hash_token(token),
            "permissions": dict(permissions),
        }
        store_token(name, token)
    payload = {"version": 1, "agents": agents}
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    restrict_path(path)
    return tokens
