# Skills

When a task matches a skill's description, load and follow its instructions.

## Available Workspace Skills

### 1. `memory-management` (`./memory-management/`)

- **Skill file:** [`./memory-management/SKILL.md`](./memory-management/SKILL.md)
- **Orchestration (paths, triggers, steward):** [`Agents/memory.md`](../Agents/memory.md)
- **When to use:** Memory Steward **writes** (sanitization, dedupe). Main agent **reads** Drive `MEMORY.md` at session start—see `Agents/memory.md`.

### 2. `git-merge` (`./git-merge/`)

- **Skill file:** [`./git-merge/SKILL.md`](./git-merge/SKILL.md)
- **Orchestration:** [Git Coordinator](../Agents/Subagents/git-coordinator.md) in [`Agents/subagents.md`](../Agents/subagents.md)
- **When to use:** Merge, pull-with-merge, rebase, or cherry-pick conflicts. Coordinator must load this skill before resolving or aborting.

---
