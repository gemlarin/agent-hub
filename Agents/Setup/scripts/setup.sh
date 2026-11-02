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
MEMORY_CONTROLLER=""
MEMORY_PATH=""
MEMORY_MAX_LINES=""
KEEP_EXISTING=false
REPLACE_MEMORY=false
TEST_DEFAULT=""
GITHUB_USER=""
APPS=()
CONFIG="$ROOT/Agents/Settings/CONFIG.md"
CONFIG_EXAMPLE="$ROOT/Agents/Settings/CONFIG.example.md"

usage() {
  cat <<'EOF'
Usage: setup.sh [--plan] [--apply] [answers]

From the hub root (any cwd). Detects macOS, Linux, WSL, or Windows Git Bash.

  (no flags, terminal)  Ask, then install
  --plan                Print what is known and which questions remain; change nothing
  --apply               Install using flags below (for the Hub Installer agent; never prompts)
  --memory-path PATH    Override the OS local store, or "local" for that default
  --skip-memory         Leave durable memory for later
  --install-memory      Run the memory controller installer after setup
  --skip-memory-install Leave the controller for later (python3 Agents/Memory/installer/install_memory.py)
  --keep-existing       Reinstall: keep the memory file that is already there
  --replace-memory      Reinstall: create a new memory file (deletes current entries)
  --memory-max-lines N  Max lines stored in MEMORY.md before cleanup
  --test-default MODE   UNIT, BROWSER, BOTH, or NONE (checks after an update)
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
    --install-memory) MEMORY_CONTROLLER=install ;;
    --skip-memory-install) MEMORY_CONTROLLER=skip ;;
    --keep-existing) KEEP_EXISTING=true ;;
    --replace-memory) REPLACE_MEMORY=true ;;
    --skip-github) SKIP_GITHUB=true ;;
    --skip-apps) SKIP_APPS=true ;;
    --link-all) LINK_ALL=true ;;
    --memory-path)
      MEMORY_PATH="${2:-}"
      shift
      ;;
    --memory-max-lines)
      MEMORY_MAX_LINES="${2:-}"
      shift
      ;;
    --test-default)
      TEST_DEFAULT="${2:-}"
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

# shellcheck source=host-path.sh
. "$SCRIPTS/host-path.sh"

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
    printf '%s\n' "$(default_local_memory_path)"
    return
  fi
  printf '%s\n' "$(host_path "$raw")"
}

ask_existing_memory() {
  echo "A memory file already exists."
  echo "  1) Use the existing memory file"
  echo "  2) Create a new memory file (destructive)"
  printf 'Choice [1]: '
  read -r mem_existing || true
  mem_existing="${mem_existing:-1}"
  case "$mem_existing" in
    1 | yes | Yes | YES) KEEP_EXISTING=true ;;
    2) REPLACE_MEMORY=true ;;
    *)
      echo "Answer 1 or 2." >&2
      exit 2
      ;;
  esac
}

ask_memory_controller() {
  echo "Install durable memory on this machine now?"
  echo "  1) Yes — controller, permissions, and tokens"
  echo "  2) No — run Agents/Memory/installer/install_memory.py later"
  printf 'Choice [1]: '
  read -r mem_ctl || true
  mem_ctl="${mem_ctl:-1}"
  case "$mem_ctl" in
    1 | yes | Yes | YES) MEMORY_CONTROLLER=install ;;
    2 | no | No | NO) MEMORY_CONTROLLER=skip ;;
    *)
      echo "Answer 1 or 2." >&2
      exit 2
      ;;
  esac
}

if $INTERACTIVE; then
  echo "OS: $OS_LABEL"
  echo "Hub root: $HOST_ROOT"
  echo "Layout: $LAYOUT"
  echo ""
  MEMORY_PATH="$(default_local_memory_path)"
  echo "Memory file (local on this machine): $MEMORY_PATH"
  echo "Cloud storage is not a supported memory location."
  ask_memory_controller

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

  echo "After a code update, which checks should run?"
  echo "  1) UNIT"
  echo "  2) BROWSER"
  echo "  3) BOTH"
  echo "  4) NONE"
  printf 'Choice [4]: '
  read -r test_choice || true
  test_choice="${test_choice:-4}"
  case "$test_choice" in
    1 | UNIT | unit) TEST_DEFAULT=UNIT ;;
    2 | BROWSER | browser) TEST_DEFAULT=BROWSER ;;
    3 | BOTH | both) TEST_DEFAULT=BOTH ;;
    4 | NONE | none) TEST_DEFAULT=NONE ;;
    *)
      echo "Answer 1, 2, 3, or 4." >&2
      exit 2
      ;;
  esac

  printf 'Max lines stored in MEMORY.md before cleanup [80]: '
  read -r max_reply || true
  MEMORY_MAX_LINES="${max_reply:-80}"

  echo "Project directories are linked by bootstrap next (it lists folders that already look like apps)."
  echo "Change the test default later from HELP, then Change code settings."
  APPLY=true
fi

if ! $APPLY; then
  PROJECT_LIST="$("$SCRIPTS/bootstrap.sh" --print-projects || true)"
  MEMORY_EXISTING_HINT=""
  # shellcheck source=find-python.sh
  . "$SCRIPTS/find-python.sh"
  if find_python >/dev/null 2>&1; then
    existing_status=0
    if [ "$PY" = py ]; then
      py -3 "$ROOT/Agents/Memory/installer/install_memory.py" --check-existing >/dev/null 2>&1 || existing_status=$?
    else
      "$PY" "$ROOT/Agents/Memory/installer/install_memory.py" --check-existing >/dev/null 2>&1 || existing_status=$?
    fi
    if [[ "$existing_status" -eq 0 ]]; then
      MEMORY_EXISTING_HINT="6. A memory file already exists. Flag: --keep-existing (use it) or --replace-memory (destructive; deletes current entries)."
    fi
  fi
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
1. Install durable memory controller now? Memory file is the OS local store ($(default_local_memory_path)). Flag: --install-memory | --skip-memory-install | --skip-memory
2. GitHub username for app repos. Suggested: ${DETECTED_GITHUB:-skip}. Flag: --github-user NAME | --skip-github
3. Test default after an update: UNIT, BROWSER, BOTH, or NONE. Flag: --test-default MODE
4. Max lines stored in MEMORY.md before cleanup. Suggested: 80. Flag: --memory-max-lines N
5. Link current project directories? Existing AGENTS.md files are replaced with a pointer to the hub.
${PROJECT_LIST:- (none found)}
Flag: --link-all | --app PATH (repeat) | --skip-apps
${MEMORY_EXISTING_HINT}
EOF
  exit 3
fi

if ! $SKIP_MEMORY && [[ -z "$MEMORY_PATH" ]]; then
  MEMORY_PATH="$(default_local_memory_path)"
fi
if $SKIP_MEMORY; then
  MEMORY_CONTROLLER=skip
fi
if ! $SKIP_GITHUB && [[ -z "$GITHUB_USER" && -n "$DETECTED_GITHUB" ]]; then
  GITHUB_USER="$DETECTED_GITHUB"
fi

missing=()
if ! $SKIP_MEMORY && [[ -z "$MEMORY_PATH" ]]; then
  missing+=("memory")
fi
if ! $SKIP_MEMORY && [[ -z "$MEMORY_CONTROLLER" ]]; then
  missing+=("memory-install")
fi
if ! $SKIP_GITHUB && [[ -z "$GITHUB_USER" ]]; then
  missing+=("github-user")
fi
if [[ -z "$TEST_DEFAULT" ]]; then
  missing+=("test-default")
fi
if [[ -z "$MEMORY_MAX_LINES" ]]; then
  missing+=("memory-max-lines")
fi
if ! $INTERACTIVE && ! $SKIP_APPS && ! $LINK_ALL && [[ ${#APPS[@]} -eq 0 ]]; then
  missing+=("apps")
fi
if [[ ${#missing[@]} -gt 0 ]]; then
  echo "SETUP_NEED_INPUT missing: ${missing[*]}" >&2
  echo "Pass --install-memory or --skip-memory-install or --skip-memory, --github-user or --skip-github, --test-default, --memory-max-lines, and --link-all or --app or --skip-apps." >&2
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

case "$TEST_DEFAULT" in
  UNIT | BROWSER | BOTH | NONE) ;;
  *)
    echo "Test default must be UNIT, BROWSER, BOTH, or NONE." >&2
    exit 2
    ;;
esac
if [[ ! "$MEMORY_MAX_LINES" =~ ^[1-9][0-9]*$ ]]; then
  echo "Memory max lines must be a positive integer." >&2
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

if [[ ! -f "$CONFIG" ]]; then
  cp "$CONFIG_EXAMPLE" "$CONFIG"
fi
set_bullet "$CONFIG" "Test default" "$TEST_DEFAULT"
set_bullet "$CONFIG" "Memory max lines" "$MEMORY_MAX_LINES"
if ! grep -q '^- \*\*Enable edit:\*\*' "$CONFIG"; then
  tmp="$(mktemp)"
  awk '
    /^## Memory/ && !done {
      print "## Hub edits"
      print ""
      print "- **Enable edit:** `false`"
      print ""
      done = 1
    }
    { print }
  ' "$CONFIG" >"$tmp"
  mv "$tmp" "$CONFIG"
fi
if [[ -n "$MEMORY_PATH" ]]; then
  set_bullet "$CONFIG" "MEMORY.md path" "$MEMORY_PATH"
fi

run_memory_controller_install() {
  local src="" args
  # shellcheck source=find-python.sh
  . "$SCRIPTS/find-python.sh"
  if ! find_python; then
    echo "Python 3.8+ not found. Run Agents/Memory/installer/install_memory.py later."
    echo "memory_controller=skipped-no-python"
    return 0
  fi
  if [[ "$KEEP_EXISTING" == true && "$REPLACE_MEMORY" == true ]]; then
    echo "Use either --keep-existing or --replace-memory." >&2
    exit 2
  fi
  args=("$ROOT/Agents/Memory/installer/install_memory.py")
  if [[ -n "${DETECTED_MEMORY:-}" && -f "$DETECTED_MEMORY" ]]; then
    if [[ "$(host_path "$MEMORY_PATH")" != "$(host_path "$DETECTED_MEMORY")" ]]; then
      src="$DETECTED_MEMORY"
      args+=(--source "$src")
    fi
  fi
  existing_status=0
  if [ "$PY" = py ]; then
    py -3 "$ROOT/Agents/Memory/installer/install_memory.py" --check-existing >/dev/null 2>&1 || existing_status=$?
  else
    "$PY" "$ROOT/Agents/Memory/installer/install_memory.py" --check-existing >/dev/null 2>&1 || existing_status=$?
  fi
  if [[ "$existing_status" -eq 0 ]]; then
    if [[ "$KEEP_EXISTING" != true && "$REPLACE_MEMORY" != true ]]; then
      if [[ "${INTERACTIVE:-false}" == true ]]; then
        ask_existing_memory
      else
        echo "SETUP_NEED_INPUT missing: memory-existing" >&2
        echo "A memory file already exists. Pass --keep-existing or --replace-memory. --replace-memory deletes the current entries." >&2
        exit 3
      fi
    fi
  elif [[ "$existing_status" -ne 1 ]]; then
    exit "$existing_status"
  fi
  if [[ "$KEEP_EXISTING" == true ]]; then
    args+=(--keep-existing)
  fi
  if [[ "$REPLACE_MEMORY" == true ]]; then
    args+=(--replace-memory)
  fi
  if [[ "${INTERACTIVE:-false}" != true ]]; then
    args+=(--noninteractive)
  fi
  if [ "$PY" = py ]; then
    py -3 "${args[@]}"
  else
    "$PY" "${args[@]}"
  fi
  echo "memory_controller=installed"
}

if [[ -n "$MEMORY_PATH" && "$MEMORY_CONTROLLER" == install ]]; then
  run_memory_controller_install
elif [[ -n "$MEMORY_PATH" ]]; then
  echo "memory_controller=skipped"
  echo "Later: python3 Agents/Memory/installer/install_memory.py"
else
  echo "memory_controller=skipped"
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
echo "tests=$TEST_DEFAULT"
echo "memory_max_lines=$MEMORY_MAX_LINES"
echo "config=$CONFIG"
echo "Change the test default later from HELP, then Change code settings."
"$SCRIPTS/sync-cursor-skills.sh"
if [[ "$CURSOR" == yes ]]; then
  echo "Still manual: if Cursor User Rules tell the parent to run git, paste Agents/Setup/cursor-user-rules.md, then reload Cursor."
fi
if [[ "$LAYOUT" == nested-agent-hub ]]; then
  echo "Layout note: app pointers must use the relative path to this clone's Agents/AGENTS.md, not ../Agents/AGENTS.md, unless Agents/ is a child of the work folder."
fi
