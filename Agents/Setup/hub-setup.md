# Agent hub — setup & sync

Use this when you **first wire up** the hub on a machine or need a **refresher** after cloning. Index: [Setup/README.md](./README.md).

The hub is **not Cursor-only**. Any agent that can read `AGENTS.md` and `Agents/` can follow the same policy. **Cursor-specific** steps are optional—install them only when you use Cursor.

---

## What you are setting up

| Piece | Location | Git |
|--------|-----------|-----|
| **Agent hub** (rules, subagents, skills) | `Projects/` folder root — `AGENTS.md`, `Agents/`, `Skills/` | One git repo (e.g. `agent-hub` remote) |
| **App repos** | Sibling folders under `Projects/` | Each has its own remote |
| **Memory** | Google Drive `Documents/MEMORY.md` | Never in hub git |
| **Your remotes/paths** | `Agents/Setup/hub-setup.local.md` | Gitignored |
| **Cursor integration** (optional) | `.cursor/agents/`, `.cursor/hooks.json`, User Rules | `.cursor/` committed; User Rules are account-local |

**Wrong layout:** `git clone agent-hub` into `Projects/agent-hub/` when apps use pointer `AGENTS.md` with `../` — pointers break. The **Projects directory itself** is the hub git root.

---

## Before you start

- [ ] A folder that will be **hub root** (e.g. `~/Projects`) — may already contain app repos.
- [ ] Git installed; access to your **agent-hub** remote on GitHub (or fork).
- [ ] **Local config:** copy the example file (once per machine):

```bash
cd /path/to/Projects
cp Agents/Setup/hub-setup.local.example.md Agents/Setup/hub-setup.local.md
# Edit hub-setup.local.md: agent-hub URL, hub root path, GitHub user for apps.
```

- [ ] (Recommended) Google Drive desktop sync for `Documents/MEMORY.md` — see [memory.md](../memory.md).

**Check for Cursor (optional):**

```bash
./Agents/Setup/scripts/detect-cursor-env.sh
# or: ./Agents/Setup/scripts/detect-cursor-env.sh --json
```

If this fails, complete **Hub core** below and skip [Cursor integration](#cursor-integration-optional).

---

## Hub core (all environments)

### Scenario A — Hub git not initialized yet

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

Pulled commits already include `.cursor/agents/` for Cursor users; regen locally only when **you** edit `Agents/Subagents/` (see Cursor section).

### Scenario C — New machine, empty Projects folder

```bash
mkdir -p ~/Projects && cd ~/Projects
git clone <your-agent-hub-url> .
cp Agents/Setup/hub-setup.local.example.md Agents/Setup/hub-setup.local.md
# edit local file; clone app repos as siblings; pointer AGENTS.md in each app
```

### After hub core

- Point app repos at hub `AGENTS.md` (`../` or `../../`).
- Use [memory.md](../memory.md) for Drive `MEMORY.md`.
- **If you use Cursor:** continue with [Cursor integration](#cursor-integration-optional).

---

## Cursor integration (optional)

Only when [detect-cursor-env.sh](./scripts/detect-cursor-env.sh) succeeds, or when you know you use Cursor.

**One command** (from hub root):

```bash
cd /path/to/Projects
chmod +x Agents/Setup/scripts/*.sh .githooks/post-merge .cursor/hooks/git-delegation-hook.sh .cursor/hooks/git-delegation-hook.cmd 2>/dev/null || true
./Agents/Setup/scripts/install-cursor-integration.sh
```

**Windows:** run the same from **Git Bash**, or skip chmod and run `python Agents/Setup/scripts/sync_cursor_agents.py` after Python 3 is on `PATH` (`python3`, `python`, or `py -3`). If hook scripts report “permission denied” on macOS, `chmod` from Terminal.app (not the agent shell).

- **Without Cursor detected:** exits 0 and skips (use `--force` to sync `.cursor/agents/` anyway).
- **With Cursor:** runs [sync-cursor-agents.sh](./scripts/sync-cursor-agents.sh), chmods hooks.

```bash
git config core.hooksPath .githooks   # optional: regen .cursor/agents when Subagents/ change on pull
```

Reload **Cursor**. Align **User Rules** from [cursor-user-rules.md](./cursor-user-rules.md).

### What gets installed

| Item | Purpose |
|------|---------|
| `.cursor/agents/*.md` | Task subagent types (`git-coordinator`, …) |
| `.cursor/rules/git-delegation.mdc` | Parent must not run `git`/`gh` |
| `.cursor/hooks.json` + hook script | Optional shell block for `git`/`gh` when coordinator inactive |

**Canonical specs:** `Agents/Subagents/`; manifest: [cursor-agents.json](./cursor-agents.json).

**After editing a subagent spec:** `./Agents/Setup/scripts/install-cursor-integration.sh` (or `--force`) and commit spec + `.cursor/agents/`.

### Git delegation hook

Hooks apply **only in Cursor** when `.cursor/hooks.json` loads. They block `git`/`gh` unless **git-coordinator** is active (marker file under `.cursor/hooks/state/`, set on `preToolUse` / `subagentStart` for a Task with `subagent_type: git-coordinator`). After editing hooks, Cursor reloads `hooks.json` automatically. See **Settings → Hooks** if commands are blocked unexpectedly.

The hook is **Python** (`.cursor/hooks/git-delegation-hook.py`). Cursor starts it through `.cursor/hooks/git-delegation-hook.cmd`, a polyglot so **Windows `cmd`** and **POSIX `sh`** both work. The launcher looks up `PYTHON`, then `python3`, `python`, or `py -3`. Do not feed Python via a bash heredoc — that replaces stdin and denies every `git` command. Markers live under `.cursor/hooks/state/` when writable, otherwise the process temp dir (`/tmp` or `%TEMP%`).

Requires **Python 3.8+** that actually runs (`python3`, `python`, `py -3`, or `/usr/bin/python3`). The launcher skips broken PATH stubs.

**Smoke test (full deny → allow → clear flow):**

```bash
python3 Agents/Setup/scripts/test-git-delegation-hook.py
# or: ./Agents/Setup/scripts/test-git-delegation-hook.sh
```

Expect `"permission":"deny"` with no marker, `"allow"` after a git-coordinator spawn, then deny again after stop. If a test **allows** `git status` with no marker, run `rm -f .cursor/hooks/state/coordinator-*.active`.

**Still blocked?** Confirm **Settings → Hooks** shows no errors. Parent agents may spawn coordinators via native `Task` or `CallDynamicTool` (`cursor` / `Task`); `preToolUse` matches both.

---

## Quick reference

| Task | Command |
|------|---------|
| Pull hub updates | `cd /path/to/Projects && git pull` |
| Detect Cursor | `./Agents/Setup/scripts/detect-cursor-env.sh` |
| Cursor install / regen | `./Agents/Setup/scripts/install-cursor-integration.sh` |
| Force regen | `./Agents/Setup/scripts/install-cursor-integration.sh --force` |
| Hub remote / paths | `Agents/Setup/hub-setup.local.md` |

---

## Troubleshooting

| Problem | Check |
|---------|--------|
| `git pull` wants to add app folders | Hub root = `Projects` with sparse `.gitignore`. |
| App can’t find `AGENTS.md` | Pointer `../` vs `../../` from app root. |
| Non-Cursor IDE | **Hub core** only; skip `.cursor/` and [cursor-user-rules.md](./cursor-user-rules.md). |
| Cursor missing `git-coordinator` | `install-cursor-integration.sh`; reload IDE. |
| Sync fails | `python3 Agents/Setup/scripts/sync_cursor_agents.py` (or `py -3` on Windows) |
| post-merge didn’t regen | `git config core.hooksPath .githooks`; use `--force` sync. |
| Hook test **allow** for `git status` | `rm -f .cursor/hooks/state/coordinator-*.active` |
| Hook “permission denied” | `chmod +x .cursor/hooks/git-delegation-hook.cmd` (Unix). On Windows, install Python 3 and confirm `py -3` or `python`. |
| Every `git` denied, even coordinator | Hook must read JSON on stdin. Re-run `./Agents/Setup/scripts/test-git-delegation-hook.sh`. |
