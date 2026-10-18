# Agent hub — setup & sync

Use this when you **first wire up** the hub on a machine or need a **refresher** after cloning. Day-to-day coding does not require opening this file.

The hub is **not Cursor-only**. Any agent that can read `AGENTS.md` and `Agents/` can follow the same policy. **Cursor-specific** files (`.cursor/agents/`, hooks, User Rules) are optional—install them only when you use Cursor.

---

## What you are setting up

| Piece | Location | Git |
|--------|-----------|-----|
| **Agent hub** (rules, subagents, skills) | `Projects/` folder root — `AGENTS.md`, `Agents/`, `Skills/` | One git repo (e.g. `agent-hub` remote) |
| **App repos** | Sibling folders under `Projects/` | Each has its own remote |
| **Memory** | Google Drive `Documents/MEMORY.md` | Never in hub git |
| **Your remotes/paths** | `Agents/hub-setup.local.md` | Gitignored |
| **Cursor integration** (optional) | `.cursor/agents/`, `.cursor/hooks.json`, User Rules | `.cursor/` committed; User Rules are account-local |

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

**Check for Cursor (optional):**

```bash
./Agents/scripts/detect-cursor-env.sh
# or: ./Agents/scripts/detect-cursor-env.sh --json
```

If this fails, complete **Hub core** below and skip [Cursor integration](#cursor-integration-optional).

---

## Hub core (all environments)

### Scenario A — Hub git not initialized yet

Your `Projects` folder has apps but **no** hub `.git` yet.

```bash
cd /path/to/Projects
git init
git remote add origin <your-agent-hub-url>   # from hub-setup.local.md
git fetch origin
git checkout -b main origin/main
```

### Scenario B — Hub already a git clone

```bash
cd /path/to/Projects
git pull
```

Pulled commits already include `.cursor/agents/` for Cursor users; you only need a local regen when **you** edit `Agents/Subagents/` (see Cursor section).

### Scenario C — New machine, empty Projects folder

```bash
mkdir -p ~/Projects && cd ~/Projects
git clone <your-agent-hub-url> .
cp Agents/hub-setup.local.example.md Agents/hub-setup.local.md
# edit local file; clone app repos as siblings; pointer AGENTS.md in each app
```

### After hub core

- Point app repos at hub `AGENTS.md` (`../` or `../../`).
- Use [memory.md](./memory.md) for Drive `MEMORY.md`.
- **If you use Cursor:** continue with [Cursor integration](#cursor-integration-optional).

---

## Cursor integration (optional)

Only run this when [detect-cursor-env.sh](./scripts/detect-cursor-env.sh) succeeds, or when you know you use Cursor.

**One command** (recommended):

```bash
cd /path/to/Projects
chmod +x Agents/scripts/*.sh .githooks/post-merge .cursor/hooks/git-delegation-hook.sh 2>/dev/null || true
./Agents/scripts/install-cursor-integration.sh
```

If Cursor hooks are already enabled, run `chmod` in a normal terminal (outside Agent shell) if hook scripts report “permission denied”.

- **Without Cursor detected:** exits 0 and prints skip message (use `--force` to sync `.cursor/agents/` anyway).
- **With Cursor:** runs [sync-cursor-agents.sh](./scripts/sync-cursor-agents.sh), chmods hooks.

Then:

```bash
git config core.hooksPath .githooks   # optional: regen .cursor/agents after pull when Subagents/ change
```

Reload **Cursor**. Align **Settings → Rules** from [cursor-user-rules.md](./cursor-user-rules.md) (Cursor account only—not in this repo).

### What gets installed

| Item | Purpose |
|------|---------|
| `.cursor/agents/*.md` | Task subagent types (`git-coordinator`, …) |
| `.cursor/rules/git-delegation.mdc` | Parent must not run `git`/`gh` |
| `.cursor/hooks.json` + hook script | Optional shell block for `git`/`gh` when coordinator inactive |

**Canonical specs** stay in `Agents/Subagents/`; manifest: [cursor-agents.json](./cursor-agents.json).

**After you edit a subagent spec:** `./Agents/scripts/install-cursor-integration.sh` (or sync script with `--force`) and commit spec + `.cursor/agents/`.

### Git delegation hook

Hooks apply **only in Cursor** when the project loads `.cursor/hooks.json`. They block `git`/`gh` unless **git-coordinator** is active. See **Settings → Hooks** if commands are blocked unexpectedly.

---

## Quick reference

| Task | Command |
|------|---------|
| Pull hub updates | `cd /path/to/Projects && git pull` |
| Detect Cursor | `./Agents/scripts/detect-cursor-env.sh` |
| Cursor install / regen agents | `./Agents/scripts/install-cursor-integration.sh` |
| Force regen (no detect) | `./Agents/scripts/install-cursor-integration.sh --force` |
| Hub remote / paths | `Agents/hub-setup.local.md` |

---

## Troubleshooting

| Problem | Check |
|---------|--------|
| `git pull` wants to add app folders | Hub root = `Projects` with sparse `.gitignore`. |
| App can’t find `AGENTS.md` | Pointer `../` vs `../../` from app root. |
| Setup assumes Cursor but I use another IDE | Use **Hub core** only; ignore `.cursor/` and [cursor-user-rules.md](./cursor-user-rules.md). |
| Cursor doesn’t list `git-coordinator` | Run `install-cursor-integration.sh`; reload IDE. |
| Sync script fails | `/usr/bin/python3 Agents/scripts/sync_cursor_agents.py` |
| post-merge didn’t regen agents | `git config core.hooksPath .githooks`; Cursor detect may skip—use `--force` sync. |
