# Agent hub (canonical)

**Load policy on demand.** Use the table below; open linked files only when a row applies. Full subagent bodies live under `Agents/Subagents/` — read when [Subagents](./Agents/subagents.md) says to delegate.

| Module | Path | Read when |
|--------|------|-----------|
| Memory | [Agents/memory.md](./Agents/memory.md) | **Session start:** main agent reads Drive `MEMORY.md` only. **Writes:** Memory Steward only. |
| Subagents | [Agents/subagents.md](./Agents/subagents.md) | Any `git`/`gh`, deep research, code review, memory write, web lookup |
| Git Coordinator | [Agents/Subagents/git-coordinator.md](./Agents/Subagents/git-coordinator.md) | After subagents matrix says delegate git/gh |
| Skills index | [Skills/SKILLS.md](./Skills/SKILLS.md) | Before memory-management or git-merge work |
| Coding (core) | [Agents/coding-standards.md](./Agents/coding-standards.md) | Implementing or reviewing code (any stack) |
| Vue greenfield | [Agents/coding-standards-vue.md](./Agents/coding-standards-vue.md) | New Vue 3 + Vite apps or hub greenfield Vue work |
| Secrets & Git | [coding-standards § Secrets](./Agents/coding-standards.md#secrets--git) | Stage, commit, push, or open a PR |
| Comms | [Agents/personality-communication.md](./Agents/personality-communication.md) | Tone; **the user** = person directing the agent this session |
| Hub setup | [Agents/Setup/](./Agents/Setup/) ([hub-setup.md](./Agents/Setup/hub-setup.md), local [example](./Agents/Setup/hub-setup.local.example.md)) | New machine, clone, `git pull`, Cursor install |
| Context discipline | [Agents/context-discipline.md](./Agents/context-discipline.md) | Orchestrating git, memory, subagents, or large reads |
| Cursor integration | [Setup/scripts/install-cursor-integration.sh](./Agents/Setup/scripts/install-cursor-integration.sh) | **Cursor only** — after `detect-cursor-env.sh` succeeds |
| Cursor User Rules | [Agents/Setup/cursor-user-rules.md](./Agents/Setup/cursor-user-rules.md) | **Cursor only** — paste into Settings → Rules |

## Non‑negotiables (always)

1. **Memory:** No local `Projects/MEMORY.md`. Main agent does not delegate session-start memory load to Memory Steward.
2. **Secrets / PII:** Never commit, push, or put in PRs — use `.env` (gitignored) and `.env.example` placeholders. Details in Secrets & Git (link above).
3. **Git / GitHub:** Parent agent **does not** run `git` or `gh`. Git Coordinator only; relay user choices; trust **Git Report** — do not re-run the same commands. Ask **which repo** if `repo_path` is unclear.
4. **Context:** One Drive memory read per session; trust subagent reports; details in [context discipline](./Agents/context-discipline.md).
