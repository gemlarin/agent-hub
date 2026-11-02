"""Local loopback service. Stronger than a skill: the process holds the files."""

from __future__ import annotations

import json
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import urlparse

from .controller import MemoryController
from .paths import resolve_root_and_cap


def make_handler(ctl: MemoryController):
    class Handler(BaseHTTPRequestHandler):
        def log_message(self, fmt: str, *args) -> None:
            return

        def _auth(self) -> tuple[str, str]:
            principal = self.headers.get("X-Memory-Agent") or ""
            header = self.headers.get("Authorization") or ""
            token = header.split(" ", 1)[1].strip() if header.lower().startswith("bearer ") else ""
            return principal, token

        def _read_json(self) -> dict:
            length = int(self.headers.get("Content-Length") or "0")
            if length > 65536:
                raise ValueError("Payload too large")
            raw = self.rfile.read(length) if length else b"{}"
            return json.loads(raw.decode("utf-8") or "{}")

        def _send(self, code: int, body: dict | str) -> None:
            payload = body.encode("utf-8") if isinstance(body, str) else json.dumps(body).encode("utf-8")
            self.send_response(code)
            self.send_header("Content-Type", "application/json" if not isinstance(body, str) else "text/plain; charset=utf-8")
            self.send_header("Content-Length", str(len(payload)))
            self.end_headers()
            self.wfile.write(payload)

        def do_GET(self) -> None:
            path = urlparse(self.path).path
            principal, token = self._auth()
            try:
                if path == "/memory":
                    self._send(200, ctl.read_memory(principal, token))
                    return
                if path == "/proposals":
                    self._send(200, {"proposals": ctl.list_proposals(principal, token)})
                    return
            except PermissionError as err:
                self._send(403, {"error": str(err)})
                return
            self._send(404, {"error": "not found"})

        def do_POST(self) -> None:
            path = urlparse(self.path).path
            principal, token = self._auth()
            try:
                data = self._read_json()
                if path == "/propose":
                    pid = ctl.submit_proposal(principal, token, data)
                    self._send(200, {"proposal_id": pid})
                    return
                if path == "/approve":
                    ctl.approve_proposal(principal, token, data.get("proposal_id") or "")
                    self._send(200, {"ok": True})
                    return
                if path == "/reject":
                    ctl.reject_proposal(
                        principal,
                        token,
                        data.get("proposal_id") or "",
                        data.get("reason") or "rejected",
                    )
                    self._send(200, {"ok": True})
                    return
            except PermissionError as err:
                self._send(403, {"error": str(err)})
                return
            except (ValueError, FileNotFoundError, json.JSONDecodeError) as err:
                self._send(400, {"error": str(err)})
                return
            self._send(404, {"error": "not found"})

    return Handler


def serve(host: str = "127.0.0.1", port: int = 18791) -> None:
    root, cap = resolve_root_and_cap()
    ctl = MemoryController(root, cap)
    server = HTTPServer((host, port), make_handler(ctl))
    server.serve_forever()


if __name__ == "__main__":
    serve()
