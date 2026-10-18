# Agent hub — setup & sync

Use this when you **first wire up** the hub on a machine or need a **refresher** after cloning. Day-to-day coding does not require opening this file.

---

## What you are setting up

| Piece | Location | Git |
|--------|-----------|-----|
| **Agent hub** (rules, subagents, skills) | `Projects/` folder root — `AGENTS.md`, `Agents/`, `Skills/` | One git repo (e.g. `agent-hub` remote) |
| **App repos** | Sibling folders under `Projects/` | Each has its own remote |
| **Memory** | Google Drive `Documents/MEMORY.md` | Never in hub git |
| **Your remotes/paths** | `Agents/hub-setup.local.md` | Gitignored |

**Wrong layout:** `git clone agent-hub` into `Projects/agent-hub/` when apps use pointer `AGENTS.md` with `../` — pointers break. The **Projects directory itself** is the hub git root.

---

## Before you start

- [ ] A folder that will be **hub root** (e.g. `~/Projects`) — may already contain app repos.
- [ ] Git installed; access to your **agent-hub** remote on GitHub (or fork).
- [ ] **Local config:** copy the example file (once per machine):

```bash
cd /path/to/Projects
cp Agents/hub-setup.local.example.md Agents/hub-setup.local.md
# Edit hub-setup.local.md: agent-hub URL, hub root path, GitHub user for apps.
```

- [ ] (Recommended) Google Drive desktop sync for `Documents/MEMORY.md` — see [memory.md](./memory.md).

---

## Scenario A — Hub git not initialized yet

Your `Projects` folder has apps but **no** hub `.git` yet (only `AGENTS.md` / `Agents/` from a copy or partial sync).

**1.** `cd` to hub root (same path you put in `hub-setup.local.md`).

**2.** Initialize and track **only** hub files (existing `.gitignore` ignores sibling app folders):

```bash
cd /path/to/Projects
git init
git remote add origin <your-agent-hub-url>   # from hub-setup.local.md
git fetch origin
git checkout -b main origin/main
```

**3.** Continue with [Cursor subagents](#cursor-subagents) below.

---

## Scenario B — Hub already a git clone

You already have `Projects` as a clone of agent-hub (or you completed Scenario A).

**Update hub files:**

```bash
cd /path/to/Projects
git pull
```

If you use git hooks (step below), `.cursor/agents/` refreshes automatically when `Agents/Subagents/` changes on pull.

---

## Scenario C — New machine, empty Projects folder

**1.** Create the folder and clone **into the folder root**, not into a subfolder:

```bash
mkdir -p ~/Projects && cd ~/Projects
git clone <your-agent-hub-url> .
```

**2.** Add `hub-setup.local.md` (copy from example and edit).

**3.** Clone or move app repos **as siblings** next to `AGENTS.md`.

**4.** In each app repo, ensure pointer stub `AGENTS.md` links to hub (`../AGENTS.md` or `../../AGENTS.md`).

**5.** Continue with [Cursor subagents](#cursor-subagents).

---

## Cursor subagents

Registers hub specialists (`git-coordinator`, `memory-steward`, etc.) for Cursor’s Task tool.

**One-time per clone** (from hub root):

```bash
cd /path/to/Projects
chmod +x Agents/scripts/sync-cursor-agents.sh .githooks/post-merge
./Agents/scripts/sync-cursor-agents.sh
git config core.hooksPath .githooks
```

Then **reload Cursor** (or restart) so custom agent names appear.

| What | Where |
|------|--------|
| Edit specs | `Agents/Subagents/*.md` |
| Manifest | `Agents/cursor-agents.json` |
| Generated output (commit with hub) | `.cursor/agents/<name>.md` |

**After you change a subagent spec:** run `./Agents/scripts/sync-cursor-agents.sh` and commit both the spec and `.cursor/agents/` (unless `post-merge` hook already ran on pull).

---

## Quick reference

| Task | Command |
|------|---------|
| Pull hub updates | `cd /path/to/Projects && git pull` |
| Regenerate Cursor agents | `./Agents/scripts/sync-cursor-agents.sh` |
| Hub remote / paths | `Agents/hub-setup.local.md` (not committed) |

---

## Troubleshooting

| Problem | Check |
|---------|--------|
| `git pull` wants to add app folders | Hub root should be `Projects` with sparse `.gitignore`; apps are not part of hub repo. |
| App can’t find `AGENTS.md` | Pointer path: one level up vs two (`../` vs `../../`) from app root to hub root. |
| Cursor doesn’t list `git-coordinator` | Run sync script; reload IDE; confirm `.cursor/agents/git-coordinator.md` exists. |
| Sync script fails | Try `/usr/bin/python3 Agents/scripts/sync_cursor_agents.py` from hub root. |
| Hook doesn’t run | `git config core.hooksPath .githooks` from hub root; hooks must be executable (`chmod +x`). |
