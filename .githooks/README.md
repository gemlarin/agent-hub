# .githooks/ — hub git hooks

Git hooks for **this clone only**. Apps do not inherit them via an `AGENTS.md` pointer. Bootstrap sets **local** `core.hooksPath=.githooks` if it is unset.

## Design

| Hook | When | What |
|------|------|------|
| [`post-merge`](./post-merge) | After `git pull`/`merge` that updates `HEAD` | If `Agents/Subagents/` changed, runs `install-cursor-integration.sh` (no-op if Cursor is not detected) |

This is **not** the Cursor git-delegation hook (that lives in `.cursor/hooks/`).

## Contribute

1. Keep hooks POSIX `sh`, executable, and safe when Cursor/Python is missing.
2. Scope work to the hub root (`git rev-parse --show-toplevel`).
3. After changing hook behavior, mention it in [`../Agents/Setup/hub-setup.md`](../Agents/Setup/hub-setup.md).
4. Do not install User-level or app-repo hooks from here.
