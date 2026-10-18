# agent-hub

Shared **agent hub** for a `Projects/`-style workspace: rules, subagents, and skills. Works with **any** agent that reads `AGENTS.md`; **Cursor** integration (`.cursor/agents/`, hooks) is **optional**. App repos live as **siblings** and point here via stub `AGENTS.md` (`../` or `../../`).

**Agents read:** [`AGENTS.md`](./AGENTS.md) (policy table and non-negotiables). **Humans read:** this file and [`Agents/hub-setup.md`](./Agents/hub-setup.md) when installing or moving machines.

---

## Quick start

```bash
# Empty folder: clone into the folder you use as Projects (not into Projects/agent-hub/)
git clone https://github.com/<you>/agent-hub.git ~/Projects
cd ~/Projects

# Or: existing Projects with apps — see hub-setup Scenario A
cp Agents/hub-setup.local.example.md Agents/hub-setup.local.md
# Edit hub-setup.local.md (remote URL, paths)

./Agents/scripts/detect-cursor-env.sh && \
  ./Agents/scripts/install-cursor-integration.sh
```

If you use **Cursor**, align **Settings → Rules** from [`Agents/cursor-user-rules.md`](./Agents/cursor-user-rules.md). Non-Cursor: skip that step.

Full steps (scenarios A/B/C, troubleshooting): **[Agents/hub-setup.md](./Agents/hub-setup.md)**

---

## Layout

| Path | Purpose |
|------|---------|
| [`AGENTS.md`](./AGENTS.md) | Entry point for agents (on-demand module table) |
| [`Agents/`](./Agents/) | Subagents, coding standards, memory rules, setup docs |
| [`Skills/`](./Skills/) | Skills (memory-management, git-merge, …) |
| [`.cursor/agents/`](./.cursor/agents/) | Cursor-registered subagents (generated from `Agents/Subagents/`) |
| App folders | Separate git repos; not part of agent-hub commits |

**Memory** is stored in **Google Drive** `Documents/MEMORY.md` only — never committed here. See [`Agents/memory.md`](./Agents/memory.md).

---

## Highlights

- **Git Coordinator** — only subagent runs `git` / `gh`; parent relays **Git Reports** ([`Agents/Subagents/git-coordinator.md`](./Agents/Subagents/git-coordinator.md)).
- **Hooks** — [`.cursor/hooks.json`](./.cursor/hooks.json) can block parent `git`/`gh` when the coordinator is not active.
- **Subagent matrix** — when to delegate research, review, memory writes, web lookup ([`Agents/subagents.md`](./Agents/subagents.md)).
- **Coding standards** — core + optional Vue greenfield split.

After editing specs under `Agents/Subagents/`, run:

```bash
./Agents/scripts/sync-cursor-agents.sh
```

---

## Forking

1. Fork this repo and set `origin` in `Agents/hub-setup.local.md`.
2. Copy `hub-setup.local.example.md` → `hub-setup.local.md` (gitignored).
3. Point your app repos at this hub with a relative `AGENTS.md` stub.

---

## License

Add a license file if you publish publicly; otherwise treat as private team config.
