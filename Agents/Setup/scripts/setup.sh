#!/usr/bin/env bash
# Guided hub install. Detects the OS, asks only what it cannot infer, then runs bootstrap.
# A terminal prompts. A non-interactive caller (the Hub Installer agent) gets SETUP_NEED_INPUT
# until it re-runs with --apply and the answers.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
SCRIPTS="$ROOT/Agents/Setup/scripts"
LOCAL="$ROOT/Agents/Setup/hub-setup.local.md"

APPLY=false
PLAN=false
SKIP_CURSOR=false
NO_HOOKS=false
SKIP_MEMORY=false
SKIP_GITHUB=false
SKIP_APPS=false
LINK_ALL=false
MEMORY_PATH=""
GITHUB_USER=""
APPS=()

usage() {
  cat <<'EOF'
Usage: setup.sh [--plan] [--apply] [answers]

From the hub root (any cwd). Detects macOS, Linux, WSL, or Windows Git Bash.

  (no flags, terminal)  Ask, then install
  --plan                Print what is known and which questions remain; change nothing
  --apply               Install using flags below (for the Hub Installer agent; never prompts)
  --memory-path PATH    Absolute MEMORY.md path, or "local" for ~/Documents/MEMORY.md
  --skip-memory         Leave the memory path for later
  --github-user NAME    GitHub username for app-repo links in hub-setup.local.md
  --skip-github         Leave the GitHub username placeholder
  --app PATH            Project directory to link (repeatable). Replaces AGENTS.md with a hub pointer
  --link-all            Link every discovered project directory
  --skip-apps           Do not link project directories
  --skip-cursor         Pass through to bootstrap.sh
  --no-hooks-path       Pass through to bootstrap.sh

Exit 3 with SETUP_NEED_INPUT when --apply is missing answers. Does not commit.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --plan) PLAN=true ;;
    --apply) APPLY=true ;;
    --skip-cursor) SKIP_CURSOR=true ;;
    --no-hooks-path) NO_HOOKS=true ;;
    --skip-memory) SKIP_MEMORY=true ;;
    --skip-github) SKIP_GITHUB=true ;;
    --skip-apps) SKIP_APPS=true ;;
    --link-all) LINK_ALL=true ;;
    --memory-path)
      MEMORY_PATH="${2:-}"
      shift
      ;;
    --github-user)
      GITHUB_USER="${2:-}"
      shift
      ;;
    --app)
      APPS+=("${2:-}")
      shift
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

if $PLAN && $APPLY; then
  echo "Use either --plan or --apply." >&2
  exit 2
fi

if [[ ! -f "$ROOT/Agents/AGENTS.md" || ! -d "$ROOT/Agents/Setup" ]]; then
  echo "Not an agent-hub root: $ROOT" >&2
  echo "Clone the hub into your work folder first, then run this script." >&2
  exit 1
fi

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
  if [[ "$p" =~ ^/([a-zA-Z])/(.*)$ ]] && [[ "$(uname -s)" != Darwin ]] && [[ "$(uname -s)" != Linux ]]; then
    printf '%s:/%s\n' "$(printf '%s' "${BASH_REMATCH[1]}" | tr '[:lower:]' '[:upper:]')" "${BASH_REMATCH[2]}"
    return
  fi
  printf '%s\n' "$p"
}

detect_os() {
  local u
  u="$(uname -s 2>/dev/null || echo unknown)"
  case "$u" in
    Darwin) OS_ID=macos; OS_LABEL="macOS" ;;
    Linux)
      if grep -qi microsoft /proc/version 2>/dev/null; then
        OS_ID=wsl
        OS_LABEL="Linux (WSL)"
      else
        OS_ID=linux
        OS_LABEL="Linux"
      fi
      ;;
    MINGW* | MSYS* | CYGWIN*)
      OS_ID=windows
      OS_LABEL="Windows (Git Bash)"
      ;;
    *)
      OS_ID=unknown
      OS_LABEL="Unknown ($u)"
      ;;
  esac
}

detect_memory_path() {
  local f
  for f in "$HOME/Library/CloudStorage"/GoogleDrive-*/My\ Drive/Documents/MEMORY.md; do
    if [[ -f "$f" ]]; then
      printf '%s\n' "$f"
      return 0
    fi
  done
  if [[ -f "$HOME/Google Drive/My Drive/Documents/MEMORY.md" ]]; then
    printf '%s\n' "$HOME/Google Drive/My Drive/Documents/MEMORY.md"
    return 0
  fi
  if [[ -f "$HOME/Documents/MEMORY.md" ]]; then
    printf '%s\n' "$HOME/Documents/MEMORY.md"
    return 0
  fi
  return 1
}

field_value() {
  local file="$1" label="$2"
  [[ -f "$file" ]] || return 0
  awk -v label="$label" '
    index($0, "- **" label ":**") == 1 {
      s = $0
      sub(/^[^`]*`/, "", s)
      sub(/`.*/, "", s)
      print s
      exit
    }
  ' "$file"
}

set_bullet() {
  local file="$1" label="$2" value="$3" tmp
  tmp="$(mktemp)"
  awk -v label="$label" -v value="$value" '
    index($0, "- **" label ":**") == 1 {
      print "- **" label ":** `" value "`"
      next
    }
    { print }
  ' "$file" >"$tmp"
  mv "$tmp" "$file"
}

inside_hub() {
  local p="$1" host
  host="$(host_path "$ROOT")"
  case "$p" in
    "$ROOT" | "$ROOT"/* | "$host" | "$host"/*) return 0 ;;
  esac
  return 1
}

write_memory_file() {
  local path="$1"
  if [[ -e "$path" ]]; then
    return 0
  fi
  mkdir -p "$(dirname "$path")"
  cat >"$path" <<'EOF'
# MEMORY.md

> Private cross-session memory. Not committed to git.

## Preferences

- (none yet)

## Active projects

- (none yet)

## Solutions & conventions

- (none yet)

## Blockers

- (none)
EOF
  echo "Created $path"
}

detect_os
HOST_ROOT="$(host_path "$ROOT")"
DETECTED_MEMORY="$(detect_memory_path || true)"
ORIGIN=""
DETECTED_GITHUB=""
if git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  ORIGIN="$(git -C "$ROOT" remote get-url origin 2>/dev/null || true)"
  case "$ORIGIN" in
    *github.com[:/]*)
      DETECTED_GITHUB="$(printf '%s\n' "$ORIGIN" | sed -E 's#.*github\.com[:/]+([^/]+)/.*#\1#')"
      ;;
  esac
fi

CURSOR=no
if "$SCRIPTS/detect-cursor-env.sh" --quiet; then
  CURSOR=yes
fi

LAYOUT="work-folder-root"
if [[ "$(basename "$ROOT")" == "agent-hub" ]]; then
  LAYOUT="nested-agent-hub"
fi

INTERACTIVE=false
if [[ -t 0 && -t 1 ]] && ! $APPLY && ! $PLAN; then
  INTERACTIVE=true
fi

resolve_memory_token() {
  local raw="$1"
  if [[ "$raw" == "local" ]]; then
    printf '%s\n' "$(host_path "$HOME/Documents/MEMORY.md")"
    return
  fi
  printf '%s\n' "$(host_path "$raw")"
}

if $INTERACTIVE; then
  echo "OS: $OS_LABEL"
  echo "Hub root: $HOST_ROOT"
  echo "Layout: $LAYOUT"
  echo ""
  if [[ -n "$DETECTED_MEMORY" ]]; then
    echo "Found MEMORY.md: $(host_path "$DETECTED_MEMORY")"
  fi
  echo "Memory file:"
  echo "  1) Use the detected file, or ~/Documents/MEMORY.md if none was found"
  echo "  2) Type an absolute path"
  echo "  3) Skip for now"
  printf 'Choice [1]: '
  read -r mem_choice || true
  mem_choice="${mem_choice:-1}"
  case "$mem_choice" in
    1)
      if [[ -n "$DETECTED_MEMORY" ]]; then
        MEMORY_PATH="$(host_path "$DETECTED_MEMORY")"
      else
        MEMORY_PATH="$(host_path "$HOME/Documents/MEMORY.md")"
      fi
      ;;
    2)
      printf 'Absolute MEMORY.md path: '
      read -r MEMORY_PATH || true
      ;;
    3) SKIP_MEMORY=true ;;
    *)
      echo "Answer 1, 2, or 3." >&2
      exit 2
      ;;
  esac

  if [[ -n "$DETECTED_GITHUB" ]]; then
    printf 'GitHub username for app repos [%s] (- to skip): ' "$DETECTED_GITHUB"
  else
    printf 'GitHub username for app repos (- to skip): '
  fi
  read -r gh_reply || true
  if [[ "$gh_reply" == "-" ]]; then
    SKIP_GITHUB=true
  elif [[ -z "$gh_reply" && -n "$DETECTED_GITHUB" ]]; then
    GITHUB_USER="$DETECTED_GITHUB"
  elif [[ -n "$gh_reply" ]]; then
    GITHUB_USER="$gh_reply"
  else
    SKIP_GITHUB=true
  fi

  echo "Project directories are linked by bootstrap next (it lists folders that already look like apps)."
  APPLY=true
fi

if ! $APPLY; then
  PROJECT_LIST="$("$SCRIPTS/bootstrap.sh" --print-projects || true)"
  cat <<EOF
SETUP_NEED_INPUT
os=$OS_LABEL
os_id=$OS_ID
hub_root=$HOST_ROOT
layout=$LAYOUT
memory_detected=${DETECTED_MEMORY:-}
github_detected=${DETECTED_GITHUB:-}
cursor=$CURSOR

Ask the user, then re-run with --apply:
1. MEMORY.md path. Suggested: ${DETECTED_MEMORY:-$HOME/Documents/MEMORY.md} (or local). Flag: --memory-path PATH | --skip-memory
2. GitHub username for app repos. Suggested: ${DETECTED_GITHUB:-skip}. Flag: --github-user NAME | --skip-github
3. Link current project directories? Existing AGENTS.md files are replaced with a pointer to the hub.
${PROJECT_LIST:- (none found)}
Flag: --link-all | --app PATH (repeat) | --skip-apps
EOF
  exit 3
fi

if ! $SKIP_MEMORY && [[ -z "$MEMORY_PATH" && -n "$DETECTED_MEMORY" ]]; then
  MEMORY_PATH="$(host_path "$DETECTED_MEMORY")"
fi
if ! $SKIP_GITHUB && [[ -z "$GITHUB_USER" && -n "$DETECTED_GITHUB" ]]; then
  GITHUB_USER="$DETECTED_GITHUB"
fi

missing=()
if ! $SKIP_MEMORY && [[ -z "$MEMORY_PATH" ]]; then
  missing+=("memory")
fi
if ! $SKIP_GITHUB && [[ -z "$GITHUB_USER" ]]; then
  missing+=("github-user")
fi
if ! $INTERACTIVE && ! $SKIP_APPS && ! $LINK_ALL && [[ ${#APPS[@]} -eq 0 ]]; then
  missing+=("apps")
fi
if [[ ${#missing[@]} -gt 0 ]]; then
  echo "SETUP_NEED_INPUT missing: ${missing[*]}" >&2
  echo "Pass --memory-path or --skip-memory, --github-user or --skip-github, and --link-all or --app or --skip-apps." >&2
  exit 3
fi

if [[ -n "$MEMORY_PATH" ]]; then
  MEMORY_PATH="$(resolve_memory_token "$MEMORY_PATH")"
  case "$MEMORY_PATH" in
    /* | [A-Za-z]:/* | [A-Za-z]:\\*) ;;
    *)
      echo "MEMORY.md path must be absolute: $MEMORY_PATH" >&2
      exit 2
      ;;
  esac
  if inside_hub "$MEMORY_PATH"; then
    echo "MEMORY.md must live outside the hub clone." >&2
    exit 2
  fi
fi

if [[ -n "$GITHUB_USER" ]] && [[ ! "$GITHUB_USER" =~ ^[A-Za-z0-9-]+$ ]]; then
  echo "GitHub username must be letters, numbers, and hyphens." >&2
  exit 2
fi

boot_args=()
$SKIP_CURSOR && boot_args+=(--skip-cursor)
$NO_HOOKS && boot_args+=(--no-hooks-path)
if $SKIP_APPS; then
  boot_args+=(--no-link)
elif $LINK_ALL; then
  boot_args+=(--link-all)
elif [[ ${#APPS[@]} -gt 0 ]]; then
  for app in "${APPS[@]}"; do
    boot_args+=(--link "$app")
  done
fi
if [[ ${#boot_args[@]} -gt 0 ]]; then
  "$SCRIPTS/bootstrap.sh" "${boot_args[@]}"
else
  "$SCRIPTS/bootstrap.sh"
fi

if [[ ! -f "$LOCAL" ]]; then
  echo "bootstrap did not create $LOCAL" >&2
  exit 1
fi

if [[ -n "$MEMORY_PATH" ]]; then
  set_bullet "$LOCAL" "MEMORY.md path" "$MEMORY_PATH"
  write_memory_file "$MEMORY_PATH"
fi
if [[ -n "$GITHUB_USER" ]]; then
  tmp="$(mktemp)"
  awk -v user="$GITHUB_USER" '{ gsub(/<your-github-user>/, user); print }' "$LOCAL" >"$tmp"
  mv "$tmp" "$LOCAL"
  set_bullet "$LOCAL" "GitHub (apps)" "https://github.com/${GITHUB_USER}/"
fi

echo ""
echo "SETUP_OK"
echo "os=$OS_LABEL"
echo "hub_root=$HOST_ROOT"
echo "layout=$LAYOUT"
echo "local=$LOCAL"
if $SKIP_MEMORY; then
  echo "memory=skipped"
else
  echo "memory=$MEMORY_PATH"
fi
if $SKIP_GITHUB; then
  echo "github=skipped"
else
  echo "github=$GITHUB_USER"
fi
if $SKIP_APPS; then
  echo "apps=skipped"
elif $LINK_ALL; then
  echo "apps=link-all"
elif [[ ${#APPS[@]} -gt 0 ]]; then
  echo "apps=${APPS[*]}"
else
  echo "apps=asked-by-bootstrap"
fi
echo "cursor=$CURSOR"
if [[ "$CURSOR" == yes ]]; then
  echo "Still manual: if Cursor User Rules tell the parent to run git, paste Agents/Setup/cursor-user-rules.md, then reload Cursor."
fi
if [[ "$LAYOUT" == nested-agent-hub ]]; then
  echo "Layout note: app pointers must use the relative path to this clone's Agents/AGENTS.md, not ../Agents/AGENTS.md, unless Agents/ is a child of the work folder."
fi
