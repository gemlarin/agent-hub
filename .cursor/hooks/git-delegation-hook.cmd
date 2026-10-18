@goto :windows >nul 2>&1
#!/bin/sh
# Unix (macOS/Linux/Git Bash): Cursor runs this file via sh when the .cmd
# is not a native binary. Do not `set -e` before skipping the batch header.
HERE=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
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

:windows
@echo off
setlocal EnableExtensions
set "HERE=%~dp0"
set "SCRIPT=%HERE%git-delegation-hook.py"

if defined PYTHON (
  "%PYTHON%" "%SCRIPT%" %*
  exit /b %ERRORLEVEL%
)

REM Prefer the Windows py launcher, then python3/python on PATH.
where py >nul 2>&1 && (
  py -3 "%SCRIPT%" %*
  exit /b %ERRORLEVEL%
)

where python3 >nul 2>&1 && (
  python3 "%SCRIPT%" %*
  exit /b %ERRORLEVEL%
)

where python >nul 2>&1 && (
  python "%SCRIPT%" %*
  exit /b %ERRORLEVEL%
)

echo git-delegation-hook: Python 3 not found. Install Python 3 and add it to PATH, or set PYTHON. 1>&2
exit /b 1
