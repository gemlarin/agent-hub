# agent-hub

Shared **agent hub** for a `Projects/`-style workspace: rules, subagents, and skills. Works with **any** agent that reads [`Agents/AGENTS.md`](./Agents/AGENTS.md); **Cursor** integration is **optional** under [`Agents/Setup/`](./Agents/Setup/). App repos live as **siblings** of `Agents/` and point here via a stub `AGENTS.md`.

This file is the hub overview. Agents read [`Agents/AGENTS.md`](./Agents/AGENTS.md). Humans read this file and [`Agents/Setup/hub-setup.md`](./Agents/Setup/hub-setup.md) when installing or moving machines.

---

## Quick start

**macOS / Linux / Git Bash**

```bash
git clone https://github.com/gemlarin/agent-hub.git ~/Projects
cd ~/Projects
./Agents/Setup/scripts/bootstrap.sh
```

**Windows (cmd or PowerShell)** — Git for Windows required:

```bat
git clone https://github.com/gemlarin/agent-hub.git %USERPROFILE%\Projects
cd %USERPROFILE%\Projects
Agents\Setup\scripts\bootstrap.cmd
```

Clone **into** `~/Projects` (or `%USERPROFILE%\Projects`), not `Projects/agent-hub/`. If `Projects` already exists, `cd` there and `git clone <url> .`.

**Still manual:** Drive [`MEMORY.md`](./Agents/memory.md); pointer `AGENTS.md` in each app (below). **Cursor:** paste [`Agents/Setup/cursor-user-rules.md`](./Agents/Setup/cursor-user-rules.md) only if default git User Rules tell the parent to run `git`.

Full steps: **[Agents/Setup/hub-setup.md](./Agents/Setup/hub-setup.md)**

---

## Point app repos at the hub

Canonical policy is **[`Agents/AGENTS.md`](./Agents/AGENTS.md)**. Do **not** put hub policy in each app, and do **not** symlink this file.

At each **app repo root**, add `AGENTS.md` that points here. Depth is from the app to the `Projects` folder:

**App is a sibling of `Agents/`** (`Projects/Portfolio/`):

```markdown
# AGENTS.md (pointer)

Agent rules for this repo are defined at the **Projects workspace hub**, not in this file.

**Read and follow:** [`../Agents/AGENTS.md`](../Agents/AGENTS.md).

That hub is the source of truth for agent rules. Apply it (and everything it references) before any task in this repo.
```

**App is one extra level down** (`Projects/Vue/Cairn/`):

```markdown
# AGENTS.md (pointer)

Agent rules for this repo are defined at the **Projects workspace hub**, not in this file.

**Read and follow:** [`../../Agents/AGENTS.md`](../../Agents/AGENTS.md).

That hub is the source of truth for agent rules. Apply it (and everything it references) before any task in this repo.
```

When Cursor’s workspace is the **app**, that pointer is how the agent loads hub rules. When the workspace is **Projects/** itself, read `Agents/AGENTS.md` directly (there is no hub `AGENTS.md` at the Projects root).

---

## Layout

| Path | Purpose |
|------|---------|
| [`Agents/AGENTS.md`](./Agents/AGENTS.md) | Entry point for agents (on-demand module table) |
| [`Agents/`](./Agents/) | Subagents, coding standards, memory, **[Setup/](./Agents/Setup/)**, **[Skills/](./Agents/Skills/)** |
| [`.cursor/agents/`](./.cursor/agents/) | Cursor subagents (generated; optional) |
| App folders | Separate git repos under the Projects root |

**Memory:** Google Drive `Documents/MEMORY.md` only — [`Agents/memory.md`](./Agents/memory.md).

---

## Highlights

- **Git Coordinator** — [`Agents/Subagents/git-coordinator.md`](./Agents/Subagents/git-coordinator.md)
- **Subagents** — [`Agents/subagents.md`](./Agents/subagents.md)
- **Coding standards** — core + optional Vue split

After editing `Agents/Subagents/`:

```bash
./Agents/Setup/scripts/install-cursor-integration.sh --force
```

Windows: `Agents\Setup\scripts\bootstrap.cmd` already ran sync on first install; regen with Git Bash (`./Agents/Setup/scripts/install-cursor-integration.sh --force`) or `py -3 Agents/Setup/scripts/sync_cursor_agents.py`.

---

## Forking

1. Fork on GitHub; `git clone` your fork into the Projects folder.
2. Run `bootstrap.sh` or `bootstrap.cmd` (seeds gitignored `hub-setup.local.md`).
3. Pointer `AGENTS.md` in each app repo (see above).

---

## License

Add a license if you publish publicly; otherwise treat as private team config.
