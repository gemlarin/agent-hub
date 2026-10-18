# Agent hub — setup & sync

Use this when you **first wire up** the hub on a machine or need a **refresher** after cloning. Overview: [README.md](../../README.md). This folder: [Setup/README.md](./README.md).

The hub is **not Cursor-only**. Any agent that can read `Agents/AGENTS.md` can follow the same policy. **Cursor-specific** steps are optional. Apps consume the hub through a **pointer** `AGENTS.md` — they do not inherit this clone’s `.cursor/` or `.githooks/`.

---

## What you are setting up

| Piece | Location | Git |
|--------|-----------|-----|
| **Agent hub** (rules, subagents, skills) | `Agents/` — `AGENTS.md`, `Skills/`, `Setup/` | This clone (work folder is the hub root, or a standalone `agent-hub` folder) |
| **App repos** | Separate folders; each has a pointer to `Agents/AGENTS.md` | Each has its own remote |
| **Memory** | Path in `hub-setup.local.md` (Drive-synced or local `MEMORY.md`) | Never commit `MEMORY.md` |
| **Your remotes/paths** | `Agents/Setup/hub-setup.local.md` | Gitignored; seeded by bootstrap |
| **Cursor integration** (optional) | **Hub git root** `.cursor/` (not under `Agents/`) | `.cursor/` committed; User Rules are account-local |
| **Hub git hooks** | **Hub git root** `.githooks/` (`core.hooksPath`) | Hub repo only |

**Usual layout:** your **work folder** (any path or name) is the hub git root; `Agents/` sits next to app folders. Cloning into `<work>/agent-hub/` breaks pointers that use `../Agents/AGENTS.md`.

**Other layout:** clone this repo as its own folder anywhere. Each app’s pointer is the relative path to **this clone’s** `Agents/AGENTS.md` (see [README — Point app repos](../../README.md#point-app-repos-at-the-hub)).

**Do not nest `.cursor/` or `.githooks/` under `Agents/`.** Cursor only loads `.cursor/` from the opened workspace root. Git hooks only run where `core.hooksPath` is set. Details: [README — What the pointer loads](../../README.md#what-the-pointer-loads).

---

## First run

You need: Git, access to this repo (or your fork), and a **work folder** that will be the hub root. The folder name is yours (`~/code`, `~/dev`, `D:\work`, …). It may already contain app repos.

**Recommended:** after the clone is on disk, run the guided installer. It detects the OS and asks for the memory file, GitHub username, and app folders:

```bash
./Agents/Setup/scripts/setup.sh
```

Windows: `Agents\Setup\scripts\setup.cmd`. In Cursor, say **set up the hub** (Hub Installer). `bootstrap.sh` is what that command calls. In a terminal it also asks whether to link current project directories, then writes or replaces each selected `AGENTS.md` with a pointer to `Agents/AGENTS.md`. Use `--no-link` to skip that, or `--link-all` / `--link PATH` when there is no prompt.

```bash
# macOS / Linux / Git Bash — new or empty work folder
WORK=~/code
git clone https://github.com/gemlarin/agent-hub.git "$WORK"
cd "$WORK"
./Agents/Setup/scripts/setup.sh
```

```bat
REM Windows cmd (Git for Windows) — new or empty work folder
set WORK=%USERPROFILE%\code
git clone https://github.com/gemlarin/agent-hub.git %WORK%
cd /d %WORK%
Agents\Setup\scripts\setup.cmd
```

Work folder already has apps (`git clone` refuses a non-empty directory): `cd` there, `git init`, `git remote add origin <url>`, `git fetch origin`, `git checkout -t origin/main`, then `setup.sh`. Full variants, including a nested `agent-hub/` folder: [README — Quick start](../../README.md#quick-start).

Already a clone: `cd` to the hub root, `git pull`, then `setup.sh` / `setup.cmd` **once per machine**.

`bootstrap` seeds `hub-setup.local.md` if missing (origin, hub path, and `MEMORY.md path` when it finds Drive `Documents/MEMORY.md`; Windows Git Bash paths are stored as `C:/...`), runs [install-cursor-integration.sh](./scripts/install-cursor-integration.sh) when Cursor is detected, and sets local `core.hooksPath=.githooks` if unset. Missing Python does **not** abort hub core — you get a warning and `.cursor/agents/` from git.

### After bootstrap (not automated)

- Point app repos at hub [`Agents/AGENTS.md`](../AGENTS.md) with a relative path from the app (this layout: `../Agents/AGENTS.md` or `../../Agents/AGENTS.md`). See [README.md](../../README.md#point-app-repos-at-the-hub).
- Set **MEMORY.md path** in [hub-setup.local.md](./hub-setup.local.md) (cloud or local). See [memory.md](../memory.md) and [README — Persistent memory](../../README.md#persistent-memory).
- **Cursor:** paste [cursor-user-rules.md](./cursor-user-rules.md) **only if** default git User Rules tell the parent to run `git`. Then reload Cursor.

---

## Cursor integration (optional)

`.cursor/agents/` is already in git. Regen only after **you** edit `Agents/Subagents/`:

```bash
./Agents/Setup/scripts/install-cursor-integration.sh --force
```

- **Without Cursor detected:** install exits 0 and skips (use `--force` to sync `.cursor/agents/` anyway).
- **With Cursor:** runs [sync-cursor-agents.sh](./scripts/sync-cursor-agents.sh), chmods hooks.

If hook scripts report “permission denied” on macOS, `chmod` from Terminal.app (not the agent shell). Python 3 on `PATH` (`python3`, `python`, or `py -3`) is required for sync on Windows.

### What gets installed

| Item | Purpose |
|------|---------|
| `.cursor/agents/*.md` | Task subagent types (`git-coordinator`, …) |
| `.cursor/rules/git-delegation.mdc` | Parent must not run `git`/`gh` **in this hub** |
| `.cursor/hooks.json` + hook script | Optional shell block for `git`/`gh` when coordinator inactive |

**Canonical specs:** `Agents/Subagents/`; manifest: [cursor-agents.json](./cursor-agents.json). Commit spec + `.cursor/agents/` after regen.

These files stay at the **hub workspace root**. An app that only points at `Agents/AGENTS.md` does not get Task types, the git-delegation rule, or these hooks. To use them in an app workspace: copy/sync `.cursor/agents/` into that app, install user-level `~/.cursor/` extras, or open this hub as the workspace.

### Git delegation hook

Hooks apply **only in Cursor** when this hub’s `.cursor/hooks.json` is loaded (workspace = this clone). They block `git`/`gh` **only for the agent-hub git root**, unless **git-coordinator** is active. `git -C <other-repo>` and a shell `cwd` in another git root are **allowed**.

**Other repos — nothing extra.** The pointer does not install hooks into apps. Setup does **not** install User-level hooks. If User Rules still say “never run git,” update them from [cursor-user-rules.md](./cursor-user-rules.md).

The hot path is **POSIX sh** (`.cursor/hooks/git-delegation-hook.sh`), started through `.cursor/hooks/git-delegation-hook.cmd`. Do **not** run Python for `beforeShellExecution` on Unix — Python 3 is SIGKILL'd in this workspace and `failClosed` made every `git` look hung. Windows still uses the Python file. `failClosed` is **false** so a dead hook cannot freeze git. Markers clear on **`subagentStop`** only (not `postToolUse`), or background Git Coordinator loses its allow marker at spawn.

**Smoke test:**

```bash
sh Agents/Setup/scripts/test-git-delegation-hook.sh
# Windows (Python fallback): py -3 Agents/Setup/scripts/test-git-delegation-hook.py
```

Expect `"permission":"deny"` with no marker, `"allow"` after a git-coordinator spawn, then deny again after stop. If a test **allows** `git status` with no marker, run `rm -f .cursor/hooks/state/coordinator-*.active`.

---

## Quick reference

| Task | Command |
|------|---------|
| First run / new machine | `./Agents/Setup/scripts/setup.sh` (Windows: `setup.cmd`) |
| Pull hub updates | `cd /path/to/your-work-folder && git pull` |
| Detect Cursor | `./Agents/Setup/scripts/detect-cursor-env.sh` |
| Cursor regen | `./Agents/Setup/scripts/install-cursor-integration.sh --force` |
| Hub remote / paths | `Agents/Setup/hub-setup.local.md` |

---

## Troubleshooting

| Problem | Check |
|---------|--------|
| `git pull` wants to add app folders | Work folder is the hub root; sparse `.gitignore` should ignore sibling apps. |
| App can’t find `AGENTS.md` | Pointer must be the relative path from the **app root** to this clone’s `Agents/AGENTS.md`. |
| Memory path unset / placeholder | Edit **MEMORY.md path** in `Agents/Setup/hub-setup.local.md`. Cloud-synced or local file; never commit it. |
| Cloned into `<work>/agent-hub/` | For the work-folder-as-root layout: move or reclone so the **work folder** is the hub root. Or keep the standalone clone and fix app pointers. |
| Non-Cursor IDE | Skip Cursor User Rules; hub still works via the `AGENTS.md` pointer. |
| Cursor missing `git-coordinator` in the **hub** | `install-cursor-integration.sh --force`; reload IDE. |
| Cursor missing `git-coordinator` in an **app** | Expected: the pointer does not load hub `.cursor/`. Open the hub, sync agents into the app, or use `~/.cursor/agents/`. |
| Sync fails | `python3 Agents/Setup/scripts/sync_cursor_agents.py` (or `py -3` on Windows) |
| post-merge didn’t regen | `bootstrap.sh` (or `git config core.hooksPath .githooks`); `--force` sync. |
| Hook test **allow** for `git status` | `rm -f .cursor/hooks/state/coordinator-*.active` |
| Hook “permission denied” | `chmod +x .cursor/hooks/git-delegation-hook.cmd` (Unix). On Windows, install Python 3. |
| Every `git` denied, even coordinator | Hook must read JSON on stdin. Re-run `./Agents/Setup/scripts/test-git-delegation-hook.sh`. |
| Git Coordinator slow / git hung | Unix hook must be **sh** (not Python). Markers clear on **subagentStop** only. Preflight is one `status -sb` + `--stat` chain. Resume the same agent id. |
