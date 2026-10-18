@echo off
setlocal EnableExtensions
set "HERE=%~dp0"
set "SCRIPT=%HERE%bootstrap.sh"

if exist "%ProgramFiles%\Git\bin\bash.exe" (
  "%ProgramFiles%\Git\bin\bash.exe" "%SCRIPT%" %*
  exit /b %ERRORLEVEL%
)
if exist "%ProgramFiles(x86)%\Git\bin\bash.exe" (
  "%ProgramFiles(x86)%\Git\bin\bash.exe" "%SCRIPT%" %*
  exit /b %ERRORLEVEL%
)
if exist "%LOCALAPPDATA%\Programs\Git\bin\bash.exe" (
  "%LOCALAPPDATA%\Programs\Git\bin\bash.exe" "%SCRIPT%" %*
  exit /b %ERRORLEVEL%
)

echo Git Bash not found. Install Git for Windows, then run:
echo   Agents\Setup\scripts\bootstrap.cmd
echo or from Git Bash:
echo   ./Agents/Setup/scripts/bootstrap.sh
exit /b 1
