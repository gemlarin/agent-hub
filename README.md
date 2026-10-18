# agent-hub

Shared **agent hub** for a `Projects/`-style workspace: rules, subagents, and skills. Works with **any** agent that reads `AGENTS.md`; **Cursor** integration is **optional** under [`Agents/Setup/`](./Agents/Setup/). App repos live as **siblings** and point here via stub `AGENTS.md` (`../` or `../../`).

**Agents read:** [`AGENTS.md`](./AGENTS.md). **Humans read:** this file and [`Agents/Setup/hub-setup.md`](./Agents/Setup/hub-setup.md) when installing or moving machines.

---

## Quick start

```bash
git clone https://github.com/<you>/agent-hub.git ~/Projects
cd ~/Projects

cp Agents/Setup/hub-setup.local.example.md Agents/Setup/hub-setup.local.md
# Edit hub-setup.local.md (remote URL, paths)

./Agents/Setup/scripts/detect-cursor-env.sh && \
  ./Agents/Setup/scripts/install-cursor-integration.sh
```

**Cursor only:** paste User Rules from [`Agents/Setup/cursor-user-rules.md`](./Agents/Setup/cursor-user-rules.md).

Full steps: **[Agents/Setup/hub-setup.md](./Agents/Setup/hub-setup.md)**

---

## Layout

| Path | Purpose |
|------|---------|
| [`AGENTS.md`](./AGENTS.md) | Entry point for agents (on-demand module table) |
| [`Agents/`](./Agents/) | Subagents, coding standards, memory, **[Setup/](./Agents/Setup/)** |
| [`Skills/`](./Skills/) | Skills (memory-management, git-merge, …) |
| [`.cursor/agents/`](./.cursor/agents/) | Cursor subagents (generated; optional) |
| App folders | Separate git repos |

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

---

## Forking

1. Set `origin` in `Agents/Setup/hub-setup.local.md`.
2. Copy `hub-setup.local.example.md` → `hub-setup.local.md` (gitignored).
3. Pointer `AGENTS.md` in each app repo.

---

## License

Add a license if you publish publicly; otherwise treat as private team config.
