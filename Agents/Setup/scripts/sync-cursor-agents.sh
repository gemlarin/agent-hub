#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
PY="${PYTHON:-/usr/bin/python3}"
if ! command -v "$PY" >/dev/null 2>&1; then
  PY="$(command -v python3)"
fi
exec "$PY" "$ROOT/Agents/Setup/scripts/sync_cursor_agents.py"
