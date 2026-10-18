# Agent hub (canonical)

**Load policy on demand.** Use the table below; open linked files only when a row applies. Full subagent bodies live under `Subagents/` — read when [Subagents](./subagents.md) says to delegate.

App repos: keep a pointer `AGENTS.md` at the app root that points here (`../Agents/AGENTS.md` or `../../Agents/AGENTS.md`). See [README.md](../README.md#point-app-repos-at-the-hub).

| Module | Path | Read when |
|--------|------|-----------|
| Memory | [memory.md](./memory.md) | **Session start:** main agent reads Drive `MEMORY.md` only. **Writes:** Memory Steward only. |
| Subagents | [subagents.md](./subagents.md) | Any `git`/`gh`, deep research, code review, memory write, web lookup |
| Git Coordinator | [Subagents/git-coordinator.md](./Subagents/git-coordinator.md) | After subagents matrix says delegate git/gh |
| Skills index | [Skills/SKILLS.md](./Skills/SKILLS.md) | Before memory-management or git-merge work |
| Coding (core) | [coding-standards.md](./coding-standards.md) | Implementing or reviewing code (any stack) |
| Vue greenfield | [coding-standards-vue.md](./coding-standards-vue.md) | New Vue 3 + Vite apps or hub greenfield Vue work |
| Secrets & Git | [coding-standards § Secrets](./coding-standards.md#secrets--git) | Stage, commit, push, or open a PR |
| Comms | [personality-communication.md](./personality-communication.md) | Tone; **the user** = person directing the agent this session |
| Hub setup | [README.md](../README.md), [Setup/](./Setup/) ([hub-setup.md](./Setup/hub-setup.md), [bootstrap.sh](./Setup/scripts/bootstrap.sh)) | New machine, clone, `git pull` — run bootstrap once per machine |
| Context discipline | [context-discipline.md](./context-discipline.md) | Orchestrating git, memory, subagents, or large reads |
| Cursor integration | [Setup/scripts/install-cursor-integration.sh](./Setup/scripts/install-cursor-integration.sh) | **Cursor only** — bootstrap on first run; `--force` after editing `Subagents/` |
| Cursor User Rules | [Setup/cursor-user-rules.md](./Setup/cursor-user-rules.md) | **Cursor only** — paste if default git User Rules tell the parent to run git |

## Non‑negotiables (always)

1. **Memory:** No local `Projects/MEMORY.md`. Main agent does not delegate session-start memory load to Memory Steward.
2. **Secrets / PII:** Never commit, push, or put in PRs — use `.env` (gitignored) and `.env.example` placeholders. Details in Secrets & Git (link above).
3. **Git / GitHub (this hub repo):** Parent agent **does not** run `git` or `gh` here. Git Coordinator only; relay user choices; trust **Git Report**. Other git roots are not blocked by the Cursor hook — parent may run `git`/`gh` there, or pass `repo_path` to the coordinator. Ask **which repo** if unclear.
4. **Context:** One Drive memory read per session; trust subagent reports; details in [context discipline](./context-discipline.md).
