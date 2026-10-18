@goto :windows >nul 2>&1
#!/bin/sh
# Unix (macOS/Linux/Git Bash): Cursor runs this file via sh when the .cmd
# is not a native binary. Do not `set -e` before skipping the batch header.
HERE=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
exec /bin/sh "$HERE/git-delegation-hook.sh"

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
