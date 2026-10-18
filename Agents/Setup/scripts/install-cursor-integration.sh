#!/usr/bin/env bash
# Optional: sync .cursor/agents, chmod hooks. Safe to run; no-op if Cursor not detected unless --force.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
SCRIPTS="$ROOT/Agents/Setup/scripts"
FORCE=false

for arg in "$@"; do
  case "$arg" in
    --force) FORCE=true ;;
    -h | --help)
      echo "Usage: install-cursor-integration.sh [--force]"
      echo "  --force  Run sync even if Cursor is not detected"
      exit 0
      ;;
  esac
done

if ! $FORCE && ! "$SCRIPTS/detect-cursor-env.sh" --quiet; then
  echo "Skipping Cursor integration (not detected)."
  echo "Hub works without Cursor: Agents/AGENTS.md, Agents/Subagents/subagents.md, Agents/Skills/."
  echo "To install anyway: $0 --force"
  echo "Details: Agents/Setup/hub-setup.md#cursor-integration-optional"
  exit 0
fi

echo "Installing Cursor integration from hub root: $ROOT"
cd "$ROOT"

chmod +x "$SCRIPTS/sync-cursor-agents.sh" "$SCRIPTS/detect-cursor-env.sh" 2>/dev/null || true
if ! "$SCRIPTS/sync-cursor-agents.sh"; then
  echo "Warning: could not sync .cursor/agents (need Python 3.8+: python3, python, or py -3)."
  echo ".cursor/agents/ from this clone is still used."
fi

if [[ -f "$ROOT/.githooks/post-merge" ]]; then
  chmod +x "$ROOT/.githooks/post-merge"
fi
for f in \
  "$ROOT/.cursor/hooks/git-delegation-hook.sh" \
  "$ROOT/.cursor/hooks/git-delegation-hook.cmd" \
  "$ROOT/.cursor/hooks/git-delegation-hook.py" \
  "$ROOT/Agents/Setup/scripts/test-git-delegation-hook.sh" \
  "$ROOT/Agents/Setup/scripts/test-git-delegation-hook.py" \
  "$ROOT/Agents/Setup/scripts/find-python.sh"; do
  if [[ -f "$f" ]]; then
    chmod +x "$f" 2>/dev/null || true
  fi
done

if [[ ! -f "$ROOT/.cursor/hooks.json" ]]; then
  echo "Note: .cursor/hooks.json missing in this clone — pull latest hub or see Agents/Setup/hub-setup.md"
fi

if [[ "${HUB_BOOTSTRAP:-}" != 1 ]]; then
  echo ""
  echo "Recommended (Cursor only):"
  echo "  Prefer bootstrap.sh (or bootstrap.cmd on Windows) on a new machine (sets hooksPath)."
  echo "  Or: git config core.hooksPath .githooks   # from hub root"
  echo "  User Rules: Agents/Setup/cursor-user-rules.md — only if default git User Rules tell the parent to run git"
  echo "  Reload Cursor after first install."
fi
