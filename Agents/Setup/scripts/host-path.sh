# Shared path helpers for setup.sh and bootstrap.sh. Source this file. Do not execute it.

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
