# agent-hub

Shared **agent hub** for a `Projects/`-style workspace: rules, subagents, and skills. Works with **any** agent that reads [`AGENTS.md`](./AGENTS.md); **Cursor** integration is **optional** under [`Setup/`](./Setup/). App repos live as **siblings** of this folder and point here via a stub `AGENTS.md`.

The **Projects root `README.md` is yours** — this file is the hub’s. Agents read [`AGENTS.md`](./AGENTS.md) in this directory. Humans read this file and [`Setup/hub-setup.md`](./Setup/hub-setup.md) when installing or moving machines.

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

**Still manual:** Drive [`MEMORY.md`](./memory.md); pointer `AGENTS.md` in each app (below). **Cursor:** paste [`Setup/cursor-user-rules.md`](./Setup/cursor-user-rules.md) only if default git User Rules tell the parent to run `git`.

Full steps: **[Setup/hub-setup.md](./Setup/hub-setup.md)**

---

## Point app repos at the hub

Canonical policy is **[`Agents/AGENTS.md`](./AGENTS.md)** (this folder). Do **not** put hub policy in each app, and do **not** symlink this file.

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
| [`AGENTS.md`](./AGENTS.md) | Entry point for agents (on-demand module table) |
| [`./`](./) | Subagents, coding standards, memory, **[Setup/](./Setup/)**, **[Skills/](./Skills/)** |
| [`../.cursor/agents/`](../.cursor/agents/) | Cursor subagents (generated; optional) |
| App folders | Separate git repos under the Projects root |

**Memory:** Google Drive `Documents/MEMORY.md` only — [`memory.md`](./memory.md).

---

## Highlights

- **Git Coordinator** — [`Subagents/git-coordinator.md`](./Subagents/git-coordinator.md)
- **Subagents** — [`subagents.md`](./subagents.md)
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
