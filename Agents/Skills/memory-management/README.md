# memory-management

**What:** Sanitization and update rules for cross-session `MEMORY.md`.

**Source:** [`SKILL.md`](./SKILL.md). Write ids: [`options.md`](./options.md). **Path and who reads vs writes:** [`../../Memory/memory.md`](../../Memory/memory.md).

## Design

The main agent **reads** the configured `MEMORY.md` at session start (once). Memory Steward **writes** using this skill and **keeps the file lean** (target ≤80 lines). Mid-session, viable facts are **auto-written in the background** (`mem-save` + `memory_path`); the parent prints `Durable memory saved to MEMORY file` when the report arrives. Option ids appear **only** on an explicit save request or session wrap-up. Other subagents **do not** read the file; the parent passes a task-relevant `related_memory` slice. The file path is **not** hardcoded here — it comes from gitignored `Agents/Setup/hub-setup.local.md`.

## Contribute

- Edit [`SKILL.md`](./SKILL.md) for capture / discard / never-save / lean-size rules.
- Add or rename a write id in [`options.md`](./options.md) **and** the matching step in [`SKILL.md`](./SKILL.md).
- Edit [`../../Memory/memory.md`](../../Memory/memory.md) and the steward spec if the read/write split or config file changes.
- Never tell anyone to commit `MEMORY.md` or `user-config.md`.

## Local settings

Copy [`user-config.example.md`](./user-config.example.md) to `user-config.md`. That file stays on your machine. Additions extend this skill. Overrides replace the matching part for you only.
