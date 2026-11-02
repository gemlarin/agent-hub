"""CLI for the memory controller. Agents pass id via env. Tokens stay in the OS store."""

from __future__ import annotations

import argparse
import json
import os
import sys

from .controller import MemoryController
from .paths import resolve_root_and_cap
from .secrets import load_token


def _auth(ns) -> tuple[str, str]:
    principal = ns.agent or os.environ.get("MEMORY_AGENT_ID") or ""
    if not principal:
        raise SystemExit("Set MEMORY_AGENT_ID")
    token = os.environ.get("MEMORY_AGENT_TOKEN") or ""
    if not token:
        token = load_token(principal)
    return principal, token


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(prog="memory-controller")
    parser.add_argument("--root", help="Memory root directory")
    parser.add_argument("--agent", help="Agent id (else MEMORY_AGENT_ID)")
    sub = parser.add_subparsers(dest="cmd", required=True)

    sub.add_parser("read")
    propose = sub.add_parser("propose")
    propose.add_argument("--type", required=True)
    propose.add_argument("--scope", required=True)
    propose.add_argument("--content", required=True)
    pending = sub.add_parser("pending")
    approve = sub.add_parser("approve")
    approve.add_argument("proposal_id")
    reject = sub.add_parser("reject")
    reject.add_argument("proposal_id")
    reject.add_argument("--reason", default="rejected")
    forget = sub.add_parser("forget")
    forget.add_argument("needle")

    ns = parser.parse_args(argv)
    root, cap = resolve_root_and_cap(ns.root)
    ctl = MemoryController(root, cap)
    principal, token = _auth(ns)

    try:
        if ns.cmd == "read":
            sys.stdout.write(ctl.read_memory(principal, token))
            return 0
        if ns.cmd == "propose":
            pid = ctl.submit_proposal(
                principal,
                token,
                {
                    "type": ns.type,
                    "scope": ns.scope,
                    "source": principal,
                    "content": ns.content,
                },
            )
            print(pid)
            return 0
        if ns.cmd == "pending":
            print(json.dumps(ctl.list_proposals(principal, token), indent=2))
            return 0
        if ns.cmd == "approve":
            ctl.approve_proposal(principal, token, ns.proposal_id)
            print("approved")
            return 0
        if ns.cmd == "reject":
            ctl.reject_proposal(principal, token, ns.proposal_id, ns.reason)
            print("rejected")
            return 0
        if ns.cmd == "forget":
            removed = ctl.forget(principal, token, ns.needle)
            print(removed)
            return 0
    except (PermissionError, ValueError, FileNotFoundError) as err:
        print(str(err), file=sys.stderr)
        return 2
    return 1


if __name__ == "__main__":
    sys.exit(main())
