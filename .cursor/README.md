# .cursor/ — Cursor integration (this workspace)

Cursor loads this folder only when the **opened workspace root** is this hub clone. App repos that merely point at `Agents/AGENTS.md` do **not** inherit it. Design background: [root README — What the pointer loads](../README.md#what-the-pointer-loads).

## Design

| Path | Role | Source of truth |
|------|------|-----------------|
| [`agents/`](./agents/) | Task subagent types (`git-coordinator`, …) | **Generated** from [`../Agents/Subagents/`](../Agents/Subagents/) via [`../Agents/Setup/cursor-agents.json`](../Agents/Setup/cursor-agents.json) |
| [`rules/git-delegation.mdc`](./rules/git-delegation.mdc) | Always-on: parent must not run `git`/`gh` **in this hub** | Hand-edited |
| [`hooks.json`](./hooks.json) + [`hooks/`](./hooks/) | Shell/Task gating so git-coordinator owns hub git | Hand-edited scripts; `hooks/state/` is runtime (gitignored except `.gitkeep`) |

Do not move this tree under `Agents/`. Cursor does not scan nested `.cursor/` folders.

## Contribute

- **Subagent behavior:** edit `Agents/Subagents/*.md`, then from hub root:

  ```bash
  ./Agents/Setup/scripts/install-cursor-integration.sh --force
  ```

  Commit spec + generated `agents/*.md` together. See [`../Agents/Subagents/README.md`](../Agents/Subagents/README.md).

- **Rules / hooks:** edit the files here; keep hook commands as `.cursor/hooks/...` (they run from the project root). Smoke-test:

  ```bash
  python3 Agents/Setup/scripts/test-git-delegation-hook.py
  ```

- Do not commit `hooks/state/coordinator-*.active`.
- User Rules are **account-local** (`Agents/Setup/cursor-user-rules.md`) — not this folder.
