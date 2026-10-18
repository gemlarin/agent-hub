#!/usr/bin/env bash
# Thin wrapper so smoke tests and hooks.json can invoke the Python hook.
# Must exec the .py file (do not feed Python via a heredoc — that replaces stdin).
set -euo pipefail

PY="${PYTHON:-/usr/bin/python3}"
if ! command -v "$PY" >/dev/null 2>&1; then
  PY="$(command -v python3)"
fi

HERE="$(cd "$(dirname "$0")" && pwd)"
exec "$PY" "$HERE/git-delegation-hook.py" "$@"
