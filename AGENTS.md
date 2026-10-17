# Projects AGENTS.md (canonical)

# Master Agent Instructions

## Core Protocols

You must read and adhere to the following modular rule files:

- **Memory & context:** **Main agent only** reads Google Drive `Documents/MEMORY.md` at session start (path in [Memory rules](./Agents/memory.md)). **Memory Steward only** writes that file (via **memory-management** skill). Never a local `Projects/MEMORY.md`; do not delegate session-start reads to the steward.
- **Secrets & PII:** **Never** commit, push, or include in PRs any **secrets** (API keys, tokens, passwords, private keys, connection strings) or **PII** (government IDs, financial account numbers, full addresses, private phone numbers, health data). Use `.env` / local config for secrets (gitignored); use placeholders in `.env.example`. Details: [Secrets & Git](./Agents/coding-standards.md#secrets--git) in Coding Standards.
- **Coding Standards:** Refer to [Coding Standards](./Agents/coding-standards.md) for style guidelines.
- **Personality & Communications:** Refer to [Personality Communication](./Agents/personality-communication.md) for style guidelines.
- **Skills:** Refer to [Skills](./Skills/SKILLS.md) for skill guidelines (includes memory-management routing).
- **Subagents:** Refer to [Subagents](./Agents/subagents.md) for subagent guidelines (includes Memory Steward).

## Important File Paths

This file is the **hub** for agent rules. Individual app repos use a pointer `AGENTS.md` (relative `../AGENTS.md` or `../../AGENTS.md`) that points here at the **Projects folder root**—not inside a nested clone folder.

### Syncing the hub (Mac / PC)

Remote: [github.com/gemlarin/agent-hub](https://github.com/gemlarin/agent-hub)

- **Use your `Projects` directory as the Git root** for agent-hub so `AGENTS.md`, `Agents/`, and `Skills/` live next to your app folders.
- **Do not** `git clone` into `Projects/agent-hub/` if apps use pointer stubs; that breaks `../` / `../../` links.
- **First time on a machine** (folder already has app repos, no hub git yet):

```bash
cd /path/to/Projects
git init
git remote add origin https://github.com/gemlarin/agent-hub.git
git fetch origin
git checkout -b main origin/main
```

- **Updates:** from `Projects`, run `git pull` to refresh the hub files only (`.gitignore` keeps app repos out of this repo).
- **App repos** keep their own `origin` and remotes; only the hub uses the agent-hub remote.

---

## Important Accounts

- **GitHub** The repo for the primary GitHub account. All local repos use that account as origin: https://github.com/gemlarin/

---
