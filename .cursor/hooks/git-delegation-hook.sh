#!/bin/sh
# Cursor git-delegation hook (POSIX sh). Do not start Python.
# Python 3 is SIGKILL'd (~60s, exit 137) in this workspace; failClosed + Python
# made every hub `git` look hung. Marker must survive background Task postToolUse.
set -eu

HERE=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
HUB=$(CDPATH= cd -- "$HERE/../.." && pwd)
STATE="$HUB/.cursor/hooks/state"
MARKER_TMP="${TMPDIR:-/tmp}/cursor-agent-hub-git-delegation"
MAX_MARKER_AGE=14400

DENY_JSON='{"permission":"deny","user_message":"Git and gh are delegated to the git-coordinator subagent.","agent_message":"Do not run git or gh in the parent shell. Delegate to subagent_type git-coordinator and use the Git Report."}'

allow() { printf '%s\n' '{"permission":"allow"}'; }
deny() { printf '%s\n' "$DENY_JSON"; }

PAYLOAD=$(cat || true)

# Top-level string field. Respects \" inside the value so a quoted git -C path survives.
json_str() {
  key=$1
  printf '%s' "$PAYLOAD" | awk -v key="$key" '
    function skip_ws() {
      while (i <= n) {
        c = substr(s, i, 1)
        if (c != " " && c != "\t" && c != "\n" && c != "\r") break
        i++
      }
    }
    function parse_string(   out, ch) {
      out = ""
      if (substr(s, i, 1) != "\"") return ""
      i++
      while (i <= n) {
        ch = substr(s, i, 1)
        if (ch == "\\") {
          i++
          out = out substr(s, i, 1)
          i++
          continue
        }
        if (ch == "\"") { i++; return out }
        out = out ch
        i++
      }
      return out
    }
    function parse_object(level,   ch, k, val) {
      i++
      while (i <= n) {
        skip_ws()
        ch = substr(s, i, 1)
        if (ch == "}") { i++; return }
        if (ch == ",") { i++; continue }
        if (ch != "\"") { i++; continue }
        k = parse_string()
        skip_ws()
        if (substr(s, i, 1) == ":") i++
        skip_ws()
        ch = substr(s, i, 1)
        if (ch == "\"") {
          val = parse_string()
          if (level == 1 && k == key) { result = val; return }
        } else if (ch == "{") {
          parse_object(level + 1)
          if (result != "") return
        } else if (ch == "[") {
          depth = 1
          i++
          while (i <= n && depth > 0) {
            ch = substr(s, i, 1)
            if (ch == "\"") { parse_string(); continue }
            if (ch == "[") depth++
            if (ch == "]") depth--
            i++
          }
        } else {
          while (i <= n) {
            ch = substr(s, i, 1)
            if (ch == "," || ch == "}" || ch == "]") break
            i++
          }
        }
      }
    }
    {
      s = s $0
    }
    END {
      n = length(s)
      i = 1
      result = ""
      skip_ws()
      if (substr(s, i, 1) == "{") parse_object(1)
      printf "%s", result
    }
  '
}

# True only when this payload is a git-coordinator spawn, not merely text that mentions it.
is_git_coord() {
  printf '%s' "$PAYLOAD" | awk '
    function skip_ws() {
      while (i <= n) {
        c = substr(s, i, 1)
        if (c != " " && c != "\t" && c != "\n" && c != "\r") break
        i++
      }
    }
    function parse_string(   out, ch) {
      out = ""
      if (substr(s, i, 1) != "\"") return ""
      i++
      while (i <= n) {
        ch = substr(s, i, 1)
        if (ch == "\\") {
          i++
          out = out substr(s, i, 1)
          i++
          continue
        }
        if (ch == "\"") { i++; return out }
        out = out ch
        i++
      }
      return out
    }
    function skip_value(   ch, depth) {
      skip_ws()
      ch = substr(s, i, 1)
      if (ch == "\"") { parse_string(); return }
      if (ch == "{" || ch == "[") {
        depth = 1
        i++
        while (i <= n && depth > 0) {
          ch = substr(s, i, 1)
          if (ch == "\"") { parse_string(); continue }
          if (ch == "{" || ch == "[") depth++
          if (ch == "}" || ch == "]") depth--
          i++
        }
        return
      }
      while (i <= n) {
        ch = substr(s, i, 1)
        if (ch == "," || ch == "}" || ch == "]") break
        i++
      }
    }
    function parse_object(level,   ch, k, val, tool, ns, tname, st, input_st, input_args, input_ns, input_tn) {
      i++
      tool = ""
      ns = ""
      tname = ""
      st = ""
      input_st = ""
      input_args = ""
      input_ns = ""
      input_tn = ""
      while (i <= n) {
        skip_ws()
        ch = substr(s, i, 1)
        if (ch == "}") { i++; break }
        if (ch == ",") { i++; continue }
        if (ch != "\"") { i++; continue }
        k = parse_string()
        skip_ws()
        if (substr(s, i, 1) == ":") i++
        skip_ws()
        ch = substr(s, i, 1)
        if (ch == "\"") {
          val = parse_string()
          if (k == "tool_name") tool = val
          if (k == "toolName") tname = val
          if (k == "namespace") ns = val
          if (k == "subagent_type" || k == "subagentType") st = val
        } else if (ch == "{") {
          child_st = ""
          child_args = ""
          child_ns = ""
          child_tn = ""
          parse_object(level + 1)
          if (k == "tool_input") {
            input_st = child_st
            input_args = child_args
            input_ns = child_ns
            input_tn = child_tn
          }
          if (k == "arguments" || k == "args") child_args = child_st
        } else {
          skip_value()
        }
      }
      child_st = st
      child_ns = ns
      child_tn = tname != "" ? tname : tool
      if (level == 1) {
        if (st == "git-coordinator") found = 1
        if (tool == "Task" && input_st == "git-coordinator") found = 1
        if ((tool == "CallDynamicTool" || tool == "call_dynamic_tool") && input_ns == "cursor" && input_tn == "Task" && (input_args == "git-coordinator" || input_st == "git-coordinator")) found = 1
      }
    }
    { s = s $0 }
    END {
      n = length(s)
      i = 1
      found = 0
      child_st = ""
      child_args = ""
      skip_ws()
      if (substr(s, i, 1) == "{") parse_object(1)
      if (found) printf "yes"
    }
  ' | grep -q yes
}

EVENT=$(json_str hook_event_name || true)
CMD=$(json_str command || true)
CWD=$(json_str cwd || true)
[ -n "$CWD" ] || CWD=$HUB

marker_id() {
  id=$(json_str subagent_id || true)
  [ -n "$id" ] || id=$(json_str tool_use_id || true)
  [ -n "$id" ] || id=$(json_str conversation_id || true)
  [ -n "$id" ] || id=unknown
  printf '%s' "$id" | tr -c 'A-Za-z0-9._-' '-' | cut -c1-80
}

marker_mtime() {
  stat -f %m "$1" 2>/dev/null || stat -c %Y "$1" 2>/dev/null || date +%s
}

prune_markers() {
  now=$(date +%s)
  for d in "$STATE" "$MARKER_TMP"; do
    [ -d "$d" ] || continue
    for f in "$d"/coordinator.active "$d"/coordinator-*.active; do
      [ -f "$f" ] || continue
      mt=$(marker_mtime "$f")
      age=$((now - mt))
      if [ "$age" -gt "$MAX_MARKER_AGE" ]; then
        rm -f "$f"
      fi
    done
  done
}

activate() {
  mid=$(marker_id)
  if mkdir -p "$STATE" 2>/dev/null && [ -w "$STATE" ]; then
    printf '%s\n' "active" >"$STATE/coordinator-$mid.active"
    return 0
  fi
  mkdir -p "$MARKER_TMP" 2>/dev/null || return 0
  printf '%s\n' "active" >"$MARKER_TMP/coordinator-$mid.active"
}

deactivate() {
  mid=$(marker_id)
  rm -f "$STATE/coordinator-$mid.active" "$STATE/coordinator.active" 2>/dev/null || true
  rm -f "$MARKER_TMP/coordinator-$mid.active" "$MARKER_TMP/coordinator.active" 2>/dev/null || true
}

coordinator_active() {
  prune_markers
  for d in "$STATE" "$MARKER_TMP"; do
    [ -d "$d" ] || continue
    for f in "$d"/coordinator.active "$d"/coordinator-*.active; do
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
  # Last `git -C <path>`, including a quoted path that contains spaces.
  printf '%s' "$1" | awk '
    {
      s = $0
      n = length(s)
      i = 1
      last = ""
      while (i <= n) {
        if ((i == 1 || substr(s, i - 1, 1) ~ /[[:space:]]/) && substr(s, i, 2) == "-C" && (i + 2 > n || substr(s, i + 2, 1) ~ /[[:space:]]/)) {
          i += 2
          while (i <= n && substr(s, i, 1) ~ /[[:space:]]/) i++
          c = substr(s, i, 1)
          p = ""
          if (c == "\"" || c == "'\''") {
            q = c
            i++
            while (i <= n && substr(s, i, 1) != q) {
              p = p substr(s, i, 1)
              i++
            }
          } else {
            while (i <= n && substr(s, i, 1) !~ /[[:space:]]/) {
              p = p substr(s, i, 1)
              i++
            }
          }
          if (p != "") last = p
        }
        i++
      }
      if (last != "") print last
    }
  '
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
