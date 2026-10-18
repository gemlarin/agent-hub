#!/bin/sh
# Unix launcher for smoke tests. Cursor hooks.json uses git-delegation-hook.cmd
# (polyglot) so Windows cmd and POSIX sh can both start the Python hook.
set -eu
HERE=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
# Keep python lookup in this file so .cursor/hooks stays self-contained.

python_is_ok() {
  "$1" -c "import sys; raise SystemExit(0 if sys.version_info >= (3, 8) else 1)" >/dev/null 2>&1
}

if [ -n "${PYTHON:-}" ] && { python_is_ok "$PYTHON"; } 2>/dev/null; then
  exec "$PYTHON" "$HERE/git-delegation-hook.py" "$@"
fi
if command -v python3 >/dev/null 2>&1 && { python_is_ok python3; } 2>/dev/null; then
  exec python3 "$HERE/git-delegation-hook.py" "$@"
fi
if command -v python >/dev/null 2>&1 && { python_is_ok python; } 2>/dev/null; then
  exec python "$HERE/git-delegation-hook.py" "$@"
fi
if command -v py >/dev/null 2>&1 && { py -3 -c "import sys; raise SystemExit(0 if sys.version_info >= (3, 8) else 1)"; } >/dev/null 2>&1; then
  exec py -3 "$HERE/git-delegation-hook.py" "$@"
fi
if [ -x /usr/bin/python3 ] && { python_is_ok /usr/bin/python3; } 2>/dev/null; then
  exec /usr/bin/python3 "$HERE/git-delegation-hook.py" "$@"
fi
echo "git-delegation-hook: Python 3.8+ not found. Set PYTHON or install Python 3." >&2
exit 1
