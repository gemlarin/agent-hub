# Code Sweeper

Shared spec: [`code-sweeper.md`](./code-sweeper.md). Cursor type: `code-sweeper`.

Orchestration: [`../subagents.md`](../subagents.md).

## Contribute

1. Edit [`code-sweeper.md`](./code-sweeper.md) for behavior every hub user should get.
2. Keep the trigger in [`../subagents.md`](../subagents.md). Do not copy that matrix here.
3. If the Cursor type or tools change, update [`../../Setup/cursor-agents.json`](../../Setup/cursor-agents.json) and regen `.cursor/agents/`.
4. Do not commit `user-config.md`.

## Local settings

Copy [`user-config.example.md`](./user-config.example.md) to `user-config.md`. That file stays on your machine. Additions extend this specialist. Overrides replace the matching part for you only.
