#!/usr/bin/env bash
# Link hub skills into .cursor/skills so Cursor's / menu can launch them.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
DEST="$ROOT/.cursor/skills"
SRC="$ROOT/Agents/Skills"

mkdir -p "$DEST"

link_skill() {
  local name="$1" folder="$2" linkpath target
  linkpath="$DEST/$name"
  target="../../Agents/Skills/$folder"
  if [[ ! -f "$SRC/$folder/SKILL.md" ]]; then
    echo "Missing skill: $SRC/$folder/SKILL.md" >&2
    exit 1
  fi
  rm -rf "$linkpath"
  ln -s "$target" "$linkpath"
  # macOS and Linux follow the symlink. Windows Git with core.symlinks=false
  # writes the target path as a text file, which Cursor cannot open.
  if [[ ! -d "$linkpath" ]]; then
    rm -rf "$linkpath"
    case "$(uname -s)" in
      MINGW* | MSYS* | CYGWIN*)
        cmd //c mklink /J "$(cygpath -w "$linkpath")" "$(cygpath -w "$SRC/$folder")"
        ;;
      *)
        echo "Skill link is not a directory: $linkpath" >&2
        exit 1
        ;;
    esac
  fi
  echo "Linked .cursor/skills/$name -> $target"
}

link_skill memory-management memory-management
link_skill git-merge git-merge
link_skill job-search job-search
link_skill research research
link_skill code-sweep code-sweep
link_skill help help-getter
