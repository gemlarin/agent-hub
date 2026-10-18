#!/usr/bin/env bash
# Detect whether Cursor IDE / agent is likely in use on this machine or shell.
# Exit 0 = Cursor likely; exit 1 = not detected (hub still works via AGENTS.md alone).
set -euo pipefail

QUIET=false
JSON=false
for arg in "$@"; do
  case "$arg" in
    --quiet) QUIET=true ;;
    --json) JSON=true ;;
  esac
done

reasons=()
found=false

if command -v cursor >/dev/null 2>&1; then
  found=true
  reasons+=("cursor CLI on PATH")
fi

case "$(uname -s 2>/dev/null || echo unknown)" in
  Darwin)
    if [[ -d "${HOME}/Library/Application Support/Cursor" ]]; then
      found=true
      reasons+=("Cursor application data (macOS)")
    fi
    ;;
  Linux)
    if [[ -d "${HOME}/.config/Cursor" ]]; then
      found=true
      reasons+=("Cursor config (Linux)")
    fi
    ;;
  MINGW*|MSYS*|CYGWIN*|Windows_NT*)
    if [[ -d "${APPDATA:-}/Cursor" ]] || [[ -d "${LOCALAPPDATA:-}/Programs/Cursor" ]]; then
      found=true
      reasons+=("Cursor application data (Windows)")
    fi
    ;;
esac

if [[ -n "${CURSOR_TRACE_ID:-}" ]] || [[ -n "${CURSOR_AGENT:-}" ]]; then
  found=true
  reasons+=("Cursor agent environment variable")
fi

if [[ "${TERM_PROGRAM:-}" == *Cursor* ]]; then
  found=true
  reasons+=("integrated terminal (TERM_PROGRAM)")
fi

if $JSON; then
  # shellcheck disable=SC1091
  . "$(cd "$(dirname "$0")" && pwd)/find-python.sh"
  find_python || exit 1
  REASONS_STR=$(printf '%s\n' "${reasons[@]}")
  CURSOR_JSON=$([ "$found" = true ] && echo true || echo false)
  export REASONS_STR
  if [ "${PY:-}" = py ]; then
    py -3 -c 'import json, os; r=[x for x in os.environ.get("REASONS_STR","").splitlines() if x.strip()]; print(json.dumps({"cursor": '"$CURSOR_JSON"', "reasons": r}))'
  else
    "$PY" -c 'import json, os; r=[x for x in os.environ.get("REASONS_STR","").splitlines() if x.strip()]; print(json.dumps({"cursor": '"$CURSOR_JSON"', "reasons": r}))'
  fi
fi

if $found; then
  if ! $QUIET; then
    echo "Cursor environment detected (${reasons[*]})."
  fi
  exit 0
fi

if ! $QUIET; then
  echo "Cursor not detected. Skip Cursor-only steps; use AGENTS.md and Agents/Subagents/ with your agent." >&2
fi
exit 1
