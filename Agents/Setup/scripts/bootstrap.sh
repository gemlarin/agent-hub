#!/usr/bin/env bash
# First-run hub setup: seed local config, optional Cursor sync, local hooksPath.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
SCRIPTS="$ROOT/Agents/Setup/scripts"
EXAMPLE="$ROOT/Agents/Setup/hub-setup.local.example.md"
LOCAL="$ROOT/Agents/Setup/hub-setup.local.md"

SKIP_CURSOR=false
SET_HOOKS_PATH=true
NO_LINK=false
LINK_ALL=false
PRINT_PROJECTS=false
LINK_FILE="$(mktemp)"
trap 'rm -f "$LINK_FILE"' EXIT

usage() {
  cat <<'EOF'
Usage: bootstrap.sh [--skip-cursor] [--no-hooks-path] [--no-link | --link-all | --link PATH]

Run from any cwd. Resolves the hub root from this script's location.

  --skip-cursor      Do not run Cursor integration
  --no-hooks-path    Do not set local core.hooksPath
  --print-projects   List project directories and exit (no changes)
  --no-link          Do not ask and do not write app AGENTS.md files
  --link-all         Link every discovered project without asking
  --link PATH        Link this project directory (repeatable). Writes or replaces AGENTS.md

In a terminal, with none of the link flags, bootstrap asks whether to link current
project directories. Saying yes replaces each selected AGENTS.md with a pointer
to this hub's Agents/AGENTS.md.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skip-cursor) SKIP_CURSOR=true ;;
    --no-hooks-path) SET_HOOKS_PATH=false ;;
    --no-link) NO_LINK=true ;;
    --link-all) LINK_ALL=true ;;
    --print-projects) PRINT_PROJECTS=true ;;
    --link)
      if [[ -z "${2:-}" ]]; then
        echo "--link needs a directory." >&2
        exit 2
      fi
      printf '%s\n' "$2" >>"$LINK_FILE"
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

if [[ ! -f "$ROOT/Agents/AGENTS.md" || ! -d "$ROOT/Agents/Setup" ]]; then
  echo "Not an agent-hub root: $ROOT" >&2
  echo "Clone the hub so your work folder is the hub root (not <work>/agent-hub/) when apps use ../Agents/AGENTS.md." >&2
  exit 1
fi

if $NO_LINK && { $LINK_ALL || [[ -s "$LINK_FILE" ]]; }; then
  echo "Use either --no-link or --link / --link-all." >&2
  exit 2
fi

skip_dir_name() {
  case "$1" in
    Agents | .git | .cursor | .githooks | node_modules | dist | build | .next | coverage) return 0 ;;
  esac
  [[ "$1" == .* ]]
}

is_project_dir() {
  [[ -d "$1/.git" || -f "$1/.git" || -f "$1/AGENTS.md" ]]
}

project_search_root() {
  if [[ "$(basename "$ROOT")" == "agent-hub" ]]; then
    dirname "$ROOT"
  else
    printf '%s\n' "$ROOT"
  fi
}

discover_projects() {
  local search d child name cname
  search="$(project_search_root)"
  shopt -s nullglob
  for d in "$search"/*; do
    [[ -d "$d" ]] || continue
    name="$(basename "$d")"
    skip_dir_name "$name" && continue
    [[ "$(cd "$d" && pwd)" == "$ROOT" ]] && continue
    if is_project_dir "$d"; then
      printf '%s\n' "$(cd "$d" && pwd)"
      continue
    fi
    for child in "$d"/*; do
      [[ -d "$child" ]] || continue
      cname="$(basename "$child")"
      skip_dir_name "$cname" && continue
      if is_project_dir "$child"; then
        printf '%s\n' "$(cd "$child" && pwd)"
      fi
    done
  done
}

relpath_to() {
  local target="$1" base="$2" common rest result=""
  target="$(cd "$(dirname "$target")" && pwd)/$(basename "$target")"
  base="$(cd "$base" && pwd)"
  common="$base"
  while [[ "$target" != "$common" && "$target" != "$common"/* ]]; do
    [[ "$common" == "/" ]] && break
    common="$(dirname "$common")"
    result="../${result}"
  done
  if [[ "$target" == "$common" ]]; then
    printf '%s\n' "${result%/}"
    return
  fi
  rest="${target#"$common"/}"
  printf '%s%s\n' "$result" "$rest"
}

write_project_pointer() {
  local app="$1" rel dest tmp action
  if [[ ! -d "$app" ]]; then
    echo "Skip link: not a directory: $app" >&2
    return 1
  fi
  app="$(cd "$app" && pwd)"
  if [[ "$app" == "$ROOT" || "$app" == "$ROOT/Agents" ]]; then
    echo "Skip link: $app is part of the hub." >&2
    return 1
  fi
  rel="$(relpath_to "$ROOT/Agents/AGENTS.md" "$app")"
  dest="$app/AGENTS.md"
  tmp="$(mktemp)"
  cat >"$tmp" <<EOF
# AGENTS.md (pointer)

Agent rules for this repo are defined at the **agent hub**, not in this file.

**Read and follow:** [\`$rel\`]($rel).

That hub is the source of truth for agent rules. Follow its load table. Open a linked file only when that row matches the task.
EOF
  if [[ -f "$dest" ]] && cmp -s "$tmp" "$dest"; then
    echo "Already linked: $dest"
    rm -f "$tmp"
    return 0
  fi
  if [[ -f "$dest" ]]; then
    action="Updated"
  else
    action="Wrote"
  fi
  mv "$tmp" "$dest"
  echo "$action $dest → $rel"
}

link_listed_projects() {
  local app
  while IFS= read -r app; do
    [[ -z "$app" ]] && continue
    write_project_pointer "$app" || true
  done <"$1"
}

if $PRINT_PROJECTS; then
  discover_projects
  exit 0
fi

base="$(basename "$ROOT")"
if [[ "$base" == "agent-hub" ]]; then
  echo "Warning: hub root is named 'agent-hub'."
  echo "App pointer AGENTS.md files that use ../Agents/AGENTS.md expect the work folder itself to be the hub root."
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
  return 1
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
  sed_script+="s|/absolute/path/to/your-work-folder|$(sed_escape "$HOST_ROOT")|g;"
  sed_script+="s|/path/to/Projects|$(sed_escape "$HOST_ROOT")|g;"
  memory_path="$(detect_memory_path || true)"
  if [[ -n "$memory_path" ]]; then
    memory_path="$(host_path "$memory_path")"
    sed_script+="s|/absolute/path/to/MEMORY.md|$(sed_escape "$memory_path")|g;"
  fi
  sed -e "$sed_script" "$LOCAL" >"$tmp" && mv "$tmp" "$LOCAL"
  echo "Wrote $LOCAL (gitignored). Edit if origin, hub path, or MEMORY.md path look wrong."
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

choose_projects() {
  local found pick n=0 line choice token
  found="$(mktemp)"
  pick="$(mktemp)"
  discover_projects >"$found"
  if [[ ! -s "$found" ]]; then
    echo ""
    echo "No current project directories found next to the hub."
    rm -f "$found" "$pick"
    return 0
  fi
  echo ""
  echo "Current project directories:"
  while IFS= read -r line; do
    n=$((n + 1))
    printf '  %s) %s\n' "$n" "${line#"$ROOT"/}"
  done <"$found"
  echo "Link them to the agent hub? This writes or replaces AGENTS.md so it points at Agents/AGENTS.md."
  printf 'Link them? [y/N]: '
  read -r choice || true
  case "$choice" in
    y | Y | yes | YES) ;;
    *)
      echo "Not linking project directories."
      rm -f "$found" "$pick"
      return 0
      ;;
  esac
  printf 'Which? [all] (all, none, numbers like 1,3, or a path): '
  read -r choice || true
  choice="${choice:-all}"
  case "$choice" in
    all | ALL)
      link_listed_projects "$found"
      ;;
    none | n | N)
      echo "Not linking project directories."
      ;;
    *)
      old_ifs="$IFS"
      IFS=', '
      for token in $choice; do
        [[ -z "$token" ]] && continue
        if [[ "$token" == "all" || "$token" == "ALL" ]]; then
          cat "$found" >>"$pick"
        elif [[ "$token" =~ ^[0-9]+$ ]]; then
          sed -n "${token}p" "$found" >>"$pick"
        else
          printf '%s\n' "$token" >>"$pick"
        fi
      done
      IFS="$old_ifs"
      if [[ -s "$pick" ]]; then
        link_listed_projects "$pick"
      else
        echo "No matching project directories."
      fi
      ;;
  esac
  rm -f "$found" "$pick"
}

echo ""
if $NO_LINK; then
  echo "Project links skipped."
elif $LINK_ALL || [[ -s "$LINK_FILE" ]]; then
  combined="$(mktemp)"
  if $LINK_ALL; then
    discover_projects >>"$combined"
  fi
  if [[ -s "$LINK_FILE" ]]; then
    cat "$LINK_FILE" >>"$combined"
  fi
  link_listed_projects "$combined"
  rm -f "$combined"
elif [[ -t 0 && -t 1 ]]; then
  choose_projects
else
  echo "Project links skipped (non-interactive). Pass --link-all or --link PATH, or run bootstrap.sh in a terminal."
fi

echo ""
echo "Next (not automated):"
echo "  - Persistent memory: set MEMORY.md path in Agents/Setup/hub-setup.local.md (cloud or local) — Agents/Memory/memory.md"
if $NO_LINK; then
  echo "  - App repos: pointer AGENTS.md at the app root → ../Agents/AGENTS.md or ../../Agents/AGENTS.md"
fi
if $cursor_detected; then
  echo "  - Cursor User Rules: paste Agents/Setup/cursor-user-rules.md only if default git User Rules tell the parent to run git"
  echo "  - Reload Cursor (or start a new chat)"
fi
echo ""
echo "Later, after editing Agents/Subagents/: ./Agents/Setup/scripts/install-cursor-integration.sh --force"
echo "Details: Agents/Setup/hub-setup.md"
