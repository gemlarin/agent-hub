#!/bin/sh
# Cursor git-delegation hook (POSIX sh). Do not start Python.
# Python 3 is SIGKILL'd (~60s, exit 137) in this workspace; failClosed + Python
# made every hub `git` look hung. Marker must survive background Task postToolUse.
set -eu

HERE=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
HUB=$(CDPATH= cd -- "$HERE/../.." && pwd)
STATE="$HUB/.cursor/hooks/state"
TMPDIR="${TMPDIR:-/tmp}/cursor-agent-hub-git-delegation"

DENY_JSON='{"permission":"deny","user_message":"Git and gh are delegated to the git-coordinator subagent.","agent_message":"Do not run git or gh in the parent shell. Delegate to subagent_type git-coordinator and use the Git Report."}'

allow() { printf '%s\n' '{"permission":"allow"}'; }
deny() { printf '%s\n' "$DENY_JSON"; }

PAYLOAD=$(cat || true)

json_str() {
  key=$1
  printf '%s' "$PAYLOAD" | tr '\n' ' ' | sed -n "s/.*\"${key}\"[[:space:]]*:[[:space:]]*\"\\([^\"]*\\)\".*/\\1/p"
}

EVENT=$(json_str hook_event_name || true)
CMD=$(json_str command || true)
CWD=$(json_str cwd || true)
[ -n "$CWD" ] || CWD=$HUB

is_git_coord() {
  printf '%s' "$PAYLOAD" | grep -q 'git-coordinator'
}

activate() {
  if mkdir -p "$STATE" 2>/dev/null && [ -w "$STATE" ]; then
    printf '%s\n' "active" >"$STATE/coordinator.active"
    return 0
  fi
  mkdir -p "$TMPDIR" 2>/dev/null || return 0
  printf '%s\n' "active" >"$TMPDIR/coordinator.active"
}

deactivate() {
  rm -f "$STATE"/coordinator*.active "$STATE"/coordinator-*.active 2>/dev/null || true
  rm -f "$TMPDIR"/coordinator*.active "$TMPDIR"/coordinator-*.active 2>/dev/null || true
}

coordinator_active() {
  for d in "$STATE" "$TMPDIR"; do
    [ -d "$d" ] || continue
    for f in "$d"/coordinator.active "$d"/coordinator-*.active "$d"/coordinator*.active; do
      [ -f "$f" ] && return 0
    done
  done
  return 1
}

git_or_gh() {
  # Do not put extra chars inside [[:space:]] — that is an invalid class on BSD grep.
  printf '%s' "$1" | grep -Eqi '(^|[[:space:];&|'\''"/\\])(git|gh)(\.exe)?([[:space:]]|$)'
}

parse_git_c() {
  # Last `git -C <path>`. BSD sed has no \|; use awk.
  printf '%s' "$1" | awk '{
    for (i = 1; i < NF; i++) {
      if ($i == "-C") {
        p = $(i + 1)
        gsub(/^["'\'']|["'\'']$/, "", p)
        last = p
      }
    }
    if (last != "") print last
  }'
}

norm() {
  printf '%s' "$1" | sed 's|\\|/|g; s|/*$||'
}

find_git_root() {
  d=$1
  [ -n "$d" ] || d=$HUB
  if [ -f "$d" ]; then
    d=$(dirname "$d")
  fi
  while [ -n "$d" ] && [ "$d" != "/" ]; do
    if [ -e "$d/.git" ]; then
      printf '%s\n' "$d"
      return 0
    fi
    nd=$(dirname "$d")
    [ "$nd" = "$d" ] && break
    d=$nd
  done
  return 1
}

targets_hub() {
  cmd=$1
  cwd=$2
  hubn=$(norm "$HUB")
  cpath=$(parse_git_c "$cmd" || true)
  if [ -n "$cpath" ]; then
    [ "$(norm "$cpath")" = "$hubn" ] && return 0
    case "$cpath" in
      /*) start=$cpath ;;
      *) start="$cwd/$cpath" ;;
    esac
  else
    start=$cwd
    [ "$(norm "$start")" = "$hubn" ] && return 0
  fi
  root=$(find_git_root "$start" || true)
  if [ -n "$root" ]; then
    [ "$(norm "$root")" = "$hubn" ]
    return $?
  fi
  [ "$(norm "$start")" = "$hubn" ]
}

case "$EVENT" in
sessionStart)
  deactivate
  exit 0
  ;;
preToolUse | subagentStart)
  if is_git_coord; then
    activate
  fi
  allow
  exit 0
  ;;
postToolUse | postToolUseFailure)
  # Background Task fires postToolUse as soon as the specialist is spawned.
  # Clearing the marker here denied git while Git Coordinator was still running.
  exit 0
  ;;
subagentStop)
  if is_git_coord; then
    deactivate
  fi
  exit 0
  ;;
afterShellExecution)
  exit 0
  ;;
beforeShellExecution | "")
  if [ -z "$CMD" ]; then
    if [ -z "$EVENT" ]; then
      deny
    else
      allow
    fi
    exit 0
  fi
  if ! git_or_gh "$CMD"; then
    allow
    exit 0
  fi
  if ! targets_hub "$CMD" "$CWD"; then
    allow
    exit 0
  fi
  if coordinator_active; then
    allow
  else
    deny
  fi
  exit 0
  ;;
*)
  exit 0
  ;;
esac
