#!/usr/bin/env bash
# First-run hub setup: seed local config, optional Cursor sync, local hooksPath.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
SCRIPTS="$ROOT/Agents/Setup/scripts"
EXAMPLE="$ROOT/Agents/Setup/hub-setup.local.example.md"
LOCAL="$ROOT/Agents/Setup/hub-setup.local.md"

SKIP_CURSOR=false
SET_HOOKS_PATH=true

usage() {
  cat <<'EOF'
Usage: bootstrap.sh [--skip-cursor] [--no-hooks-path]

Run from any cwd. Resolves the hub root from this script's location.

  --skip-cursor     Do not run Cursor integration
  --no-hooks-path   Do not set local core.hooksPath
EOF
}

for arg in "$@"; do
  case "$arg" in
    --skip-cursor) SKIP_CURSOR=true ;;
    --no-hooks-path) SET_HOOKS_PATH=false ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ ! -f "$ROOT/Agents/AGENTS.md" || ! -d "$ROOT/Agents/Setup" ]]; then
  echo "Not an agent-hub root: $ROOT" >&2
  echo "Clone the hub into your Projects folder (not Projects/agent-hub/)." >&2
  exit 1
fi

base="$(basename "$ROOT")"
if [[ "$base" == "agent-hub" ]]; then
  echo "Warning: hub root is named 'agent-hub'."
  echo "App pointer AGENTS.md files that use ../Agents/AGENTS.md expect the Projects folder itself to be the hub."
  echo ""
fi

# Git/Cygwin: /c/Users/... → C:/Users/... for humans. Leave POSIX paths on macOS/Linux.
host_path() {
  local p="$1"
  if command -v cygpath >/dev/null 2>&1; then
    cygpath -m "$p"
    return
  fi
  if [[ "$p" =~ ^/cygdrive/([a-zA-Z])/(.*)$ ]]; then
    printf '%s:/%s\n' "$(printf '%s' "${BASH_REMATCH[1]}" | tr '[:lower:]' '[:upper:]')" "${BASH_REMATCH[2]}"
    return
  fi
  if [[ "$p" =~ ^/([a-zA-Z])/(.*)$ ]]; then
    printf '%s:/%s\n' "$(printf '%s' "${BASH_REMATCH[1]}" | tr '[:lower:]' '[:upper:]')" "${BASH_REMATCH[2]}"
    return
  fi
  printf '%s\n' "$p"
}

HOST_ROOT="$(host_path "$ROOT")"
echo "Hub root: $HOST_ROOT"

sed_escape() {
  printf '%s' "$1" | sed -e 's/[\\|&]/\\&/g'
}

origin=""
github_user=""
if git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  origin="$(git -C "$ROOT" remote get-url origin 2>/dev/null || true)"
  case "$origin" in
    *github.com[:/]*)
      github_user="$(printf '%s\n' "$origin" | sed -E 's#.*github\.com[:/]+([^/]+)/.*#\1#')"
      ;;
  esac
fi

if [[ ! -f "$LOCAL" ]]; then
  if [[ ! -f "$EXAMPLE" ]]; then
    echo "Missing template: $EXAMPLE" >&2
    exit 1
  fi
  cp "$EXAMPLE" "$LOCAL"
  tmp="$(mktemp)"
  sed_script=""
  if [[ -n "$origin" ]]; then
    sed_script+="s|https://github.com/<your-github-user>/agent-hub.git|$(sed_escape "$origin")|g;"
    sed_script+="s|https://github.com/gemlarin/agent-hub.git|$(sed_escape "$origin")|g;"
  fi
  if [[ -n "$github_user" ]]; then
    sed_script+="s|<your-github-user>|$(sed_escape "$github_user")|g;"
  fi
  sed_script+="s|/path/to/Projects|$(sed_escape "$HOST_ROOT")|g"
  sed -e "$sed_script" "$LOCAL" >"$tmp" && mv "$tmp" "$LOCAL"
  echo "Wrote $LOCAL (gitignored). Edit if origin or paths look wrong."
else
  echo "Keeping existing $LOCAL"
fi

chmod +x "$SCRIPTS"/*.sh "$SCRIPTS"/*.py 2>/dev/null || true

if $SKIP_CURSOR; then
  echo "Skipping Cursor integration."
  cursor_detected=false
else
  cursor_detected=false
  if "$SCRIPTS/detect-cursor-env.sh" --quiet; then
    cursor_detected=true
  fi
  if ! HUB_BOOTSTRAP=1 "$SCRIPTS/install-cursor-integration.sh"; then
    echo "Warning: Cursor integration failed (need Python 3.8+: python3, python, or py -3)."
    echo "Hub core is still set up; .cursor/agents/ from git remains in use."
  fi
fi

if $SET_HOOKS_PATH && [[ -d "$ROOT/.githooks" ]] && git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  current="$(git -C "$ROOT" config --local --get core.hooksPath 2>/dev/null || true)"
  if [[ -z "$current" ]]; then
    git -C "$ROOT" config --local core.hooksPath .githooks
    echo "Set local core.hooksPath=.githooks (regen .cursor/agents on pull when Subagents/ change)."
  elif [[ "$current" == ".githooks" ]]; then
    echo "core.hooksPath already .githooks"
  else
    echo "Leaving core.hooksPath=$current (not overwriting)."
  fi
fi

echo ""
echo "Next (not automated):"
echo "  - Google Drive: Documents/MEMORY.md — Agents/memory.md"
echo "  - App repos: pointer AGENTS.md at the app root → ../Agents/AGENTS.md or ../../Agents/AGENTS.md"
if $cursor_detected; then
  echo "  - Cursor User Rules: paste Agents/Setup/cursor-user-rules.md only if default git User Rules tell the parent to run git"
  echo "  - Reload Cursor (or start a new chat)"
fi
echo ""
echo "Later, after editing Agents/Subagents/: ./Agents/Setup/scripts/install-cursor-integration.sh --force"
echo "Details: Agents/Setup/hub-setup.md"
