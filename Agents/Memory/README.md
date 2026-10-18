# Memory

Session contract for durable memory. Loaded from [`../AGENTS.md`](../AGENTS.md) at session start.

Shared file: [`memory.md`](./memory.md).

## What lives here

Who reads `MEMORY.md`, who writes it, and how the main agent passes a slice to other specialists.

The file path is in gitignored [`../Setup/hub-setup.local.md`](../Setup/hub-setup.local.md). Write steps are in [`../Skills/memory-management/`](../Skills/memory-management/). When to call Memory Steward is in [`../Subagents/subagents.md`](../Subagents/subagents.md).

## Contribute

1. Edit [`memory.md`](./memory.md) for a change every hub user should get.
2. Personal capture rules belong in the memory-management skill's `user-config.md`, not in this folder.
3. Do not add a `user-config.md` here. Overriding who may read `MEMORY.md` would break the rest of the hub.
