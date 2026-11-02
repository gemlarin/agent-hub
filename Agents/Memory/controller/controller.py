"""Only this controller commits canonical memory."""

from __future__ import annotations

import json
import os
import uuid
from pathlib import Path

from .auth import authenticate, authorize, load_credentials
from .perms import restrict_path
from .store import Store, now_iso
from .validator import validate


class MemoryController:
    def __init__(self, root: Path, max_lines: int = 95):
        self.root = Path(root)
        self.credentials_file = self.root / "credentials.json"
        self.proposals = self.root / "Proposals"
        self.audit_file = self.root / "Audit" / "audit.jsonl"
        self.store = Store(self.root, max_lines)
        self.proposals.mkdir(parents=True, exist_ok=True)
        self.audit_file.parent.mkdir(parents=True, exist_ok=True)
        restrict_path(self.proposals, directory=True)
        restrict_path(self.audit_file.parent, directory=True)

    def _agent(self, principal: str, token: str) -> dict:
        creds = load_credentials(self.credentials_file)
        return authenticate(creds, principal, token)

    def _audit(self, actor: str, action: str, details: dict) -> None:
        event = {
            "timestamp": now_iso(),
            "actor": actor,
            "action": action,
            "details": details,
        }
        with self.audit_file.open("a", encoding="utf-8") as handle:
            handle.write(json.dumps(event) + "\n")
        restrict_path(self.audit_file)

    def read_memory(self, principal: str, token: str) -> str:
        record = self._agent(principal, token)
        authorize(record, "read")
        self._audit(principal, "READ", {})
        if not self.store.memory_file.exists():
            return ""
        return self.store.memory_file.read_text(encoding="utf-8")

    def submit_proposal(self, principal: str, token: str, entry: dict) -> str:
        record = self._agent(principal, token)
        authorize(record, "propose")
        payload = dict(entry)
        payload["source"] = principal
        errors = validate(payload)
        if errors:
            self._audit(principal, "PROPOSAL_REJECTED", {"errors": errors})
            raise ValueError("; ".join(errors))
        proposal_id = str(uuid.uuid4())
        proposal = {
            "id": proposal_id,
            "submitted_by": principal,
            "created": now_iso(),
            "status": "pending",
            "entry": payload,
        }
        path = self.proposals / f"{proposal_id}.json"
        path.write_text(json.dumps(proposal, indent=2) + "\n", encoding="utf-8")
        restrict_path(path)
        self._audit(principal, "PROPOSAL_SUBMITTED", {"proposal_id": proposal_id})
        return proposal_id

    def _proposal_path(self, proposal_id: str) -> Path:
        try:
            uid = uuid.UUID(str(proposal_id))
        except (ValueError, AttributeError, TypeError):
            raise FileNotFoundError("Proposal not found") from None
        path = (self.proposals / f"{uid}.json").resolve()
        base = self.proposals.resolve()
        try:
            path.relative_to(base)
        except ValueError:
            raise FileNotFoundError("Proposal not found") from None
        if path.parent != base:
            raise FileNotFoundError("Proposal not found")
        if not path.exists():
            raise FileNotFoundError("Proposal not found")
        return path

    def list_proposals(self, principal: str, token: str) -> list[dict]:
        record = self._agent(principal, token)
        authorize(record, "approve")
        items = []
        for path in sorted(self.proposals.glob("*.json")):
            items.append(json.loads(path.read_text(encoding="utf-8")))
        self._audit(principal, "PROPOSAL_LIST", {"count": len(items)})
        return items

    def approve_proposal(self, principal: str, token: str, proposal_id: str) -> None:
        record = self._agent(principal, token)
        authorize(record, "approve")
        authorize(record, "commit")
        path = self._proposal_path(proposal_id)
        proposal = json.loads(path.read_text(encoding="utf-8"))
        if proposal.get("status") != "pending":
            raise ValueError("Proposal is not pending")
        if proposal.get("submitted_by") == principal:
            raise PermissionError("Steward cannot approve its own proposal")
        errors = validate(proposal.get("entry") or {})
        if errors:
            raise ValueError("; ".join(errors))
        entry = dict(proposal["entry"])
        entry["id"] = str(uuid.uuid4())
        entry["created"] = now_iso()
        entry["approved_by"] = principal
        entry["proposal_id"] = proposal_id
        self.store.append(entry)
        proposal["status"] = "approved"
        proposal["approved_by"] = principal
        path.write_text(json.dumps(proposal, indent=2) + "\n", encoding="utf-8")
        restrict_path(path)
        self._audit(principal, "PROPOSAL_APPROVED", {"proposal_id": proposal_id})

    def reject_proposal(self, principal: str, token: str, proposal_id: str, reason: str) -> None:
        record = self._agent(principal, token)
        authorize(record, "approve")
        path = self._proposal_path(proposal_id)
        proposal = json.loads(path.read_text(encoding="utf-8"))
        proposal["status"] = "rejected"
        proposal["rejected_by"] = principal
        proposal["reason"] = reason
        path.write_text(json.dumps(proposal, indent=2) + "\n", encoding="utf-8")
        restrict_path(path)
        self._audit(principal, "PROPOSAL_REJECTED", {"proposal_id": proposal_id, "reason": reason})

    def forget(self, principal: str, token: str, needle: str) -> int:
        record = self._agent(principal, token)
        authorize(record, "commit")
        removed = self.store.forget(needle)
        self._audit(principal, "FORGET", {"removed": removed})
        return removed
