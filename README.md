# agent-hub

Shared **agent hub**: rules, subagents, and skills. Clone this repo, then in each app add a stub `AGENTS.md` that points at [`Agents/AGENTS.md`](./Agents/AGENTS.md). Works with **any** agent that follows that file. **Cursor** integration is **optional** under [`Agents/Setup/`](./Agents/Setup/).

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

This clone treats the **Projects folder** as the hub git root (`Agents/` next to app folders). If `Projects` already exists, `cd` there and `git clone <url> .`. Do **not** nest a second `agent-hub/` folder when apps already use `../Agents/AGENTS.md`.

Clone **anywhere else** if you prefer; each app’s pointer must still be a relative path to **this clone’s** `Agents/AGENTS.md`.

**Still manual:** Drive [`MEMORY.md`](./Agents/memory.md); pointer `AGENTS.md` in each app (below). **Cursor:** paste [`Agents/Setup/cursor-user-rules.md`](./Agents/Setup/cursor-user-rules.md) only if default git User Rules tell the parent to run `git`.

Full steps: **[Agents/Setup/hub-setup.md](./Agents/Setup/hub-setup.md)**

---

## Point app repos at the hub

Canonical policy is **[`Agents/AGENTS.md`](./Agents/AGENTS.md)**. Do **not** copy hub policy into each app, and do **not** symlink this file.

At each **app repo root**, add `AGENTS.md` whose link is the relative path from that app to this clone. Examples:

**App next to this clone** (`~/code/my-app/` + `~/code/agent-hub/`):

```markdown
# AGENTS.md (pointer)

Agent rules for this repo are defined at the **agent hub**, not in this file.

**Read and follow:** [`../agent-hub/Agents/AGENTS.md`](../agent-hub/Agents/AGENTS.md).

That hub is the source of truth for agent rules. Apply it (and everything it references) before any task in this repo.
```

**App is a sibling of `Agents/`** (this repo cloned as `~/Projects`, app at `Projects/Portfolio/`):

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

When Cursor’s workspace is the **app**, that pointer is how the agent loads hub **policy**. When the workspace is this hub clone, read `Agents/AGENTS.md` directly (there is no hub `AGENTS.md` at the clone root).

### What the pointer loads

The stub is the generic contract. It does **not** pull the hub’s `.cursor/` or `.githooks/` into the app.

| Follows the `AGENTS.md` pointer | Stays at this clone’s git / workspace root |
|---------------------------------|--------------------------------------------|
| Policy, skills, subagent specs under `Agents/` | [`.cursor/`](./.cursor/) — Task types, git-delegation rule and hooks |
| Nested `AGENTS.md` in the app | [`.githooks/`](./.githooks/) — hub-only git hooks (`core.hooksPath`) |

Do **not** move `.cursor/` or `.githooks/` into `Agents/`. Cursor only reads `.cursor/` from the **opened workspace root**. Git hooks only run in the repo that sets `core.hooksPath`. Opening an app therefore gets hub rules via the pointer, but not `git-coordinator` as a Cursor Task type unless that workspace has its own `.cursor/agents/` (or you open this hub). User-level `~/.cursor/` is the other way to share Cursor extras across apps.

---

## Layout

| Path | Purpose |
|------|---------|
| [`Agents/AGENTS.md`](./Agents/AGENTS.md) | Entry point for agents (on-demand module table) |
| [`Agents/`](./Agents/) | Subagents, coding standards, memory, **[Setup/](./Agents/Setup/)**, **[Skills/](./Agents/Skills/)** |
| [`.cursor/`](./.cursor/) | Cursor agents, rules, hooks — **hub workspace root only** |
| [`.githooks/`](./.githooks/) | Hub-repo git hooks (post-merge regen); not inherited by apps |
| App folders | Separate git repos (siblings of `Agents/` in the Projects layout) |

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

1. Fork on GitHub; `git clone` your fork (into the Projects folder, or next to your apps).
2. Run `bootstrap.sh` or `bootstrap.cmd` (seeds gitignored `hub-setup.local.md`).
3. Pointer `AGENTS.md` in each app repo (see above).

---

## License

Add a license if you publish publicly; otherwise treat as private team config.
