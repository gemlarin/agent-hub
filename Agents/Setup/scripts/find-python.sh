# POSIX helper: set PY to a working Python 3.8+ executable. Source from other scripts.
# Honors $PYTHON. Skips broken PATH entries (e.g. dead /usr/local/bin/python3).

python_is_ok() {
  # Must actually start and be 3.8+ (Path.unlink(missing_ok=True)).
  # Outer 2>/dev/null hides "Killed: 9" from dead PATH stubs.
  { "$1" -c "import sys; raise SystemExit(0 if sys.version_info >= (3, 8) else 1)"; } >/dev/null 2>&1
}

find_python() {
  PY=
  PY_ARGS=
  if [ -n "${PYTHON:-}" ] && python_is_ok "$PYTHON"; then
    PY=$PYTHON
    return 0
  fi
  if command -v python3 >/dev/null 2>&1 && python_is_ok python3; then
    PY=python3
    return 0
  fi
  if command -v python >/dev/null 2>&1 && python_is_ok python; then
    PY=python
    return 0
  fi
  if command -v py >/dev/null 2>&1; then
    if py -3 -c "import sys; raise SystemExit(0 if sys.version_info >= (3, 8) else 1)" >/dev/null 2>&1; then
      PY=py
      PY_ARGS=-3
      return 0
    fi
  fi
  if [ -x /usr/bin/python3 ] && python_is_ok /usr/bin/python3; then
    PY=/usr/bin/python3
    return 0
  fi
  echo "Python 3.8+ not found (tried \$PYTHON, python3, python, py -3, /usr/bin/python3)." >&2
  return 1
}

exec_python() {
  find_python || return 1
  if [ "$PY" = py ]; then
    exec py -3 "$@"
  fi
  exec "$PY" "$@"
}
