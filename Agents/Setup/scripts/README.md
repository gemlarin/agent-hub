# Setup scripts

Run from the **hub git root** (the folder that contains `Agents/AGENTS.md`). `bootstrap.sh` locates that root from this file’s path, so you can invoke it from any cwd.

## Design

| Script | Role |
|--------|------|
| [`setup.sh`](./setup.sh) / [`setup.cmd`](./setup.cmd) | Guided first run: detect OS, ask memory / GitHub / app pointers, then call bootstrap. `--plan` prints questions and changes nothing |
| [`bootstrap.sh`](./bootstrap.sh) / [`bootstrap.cmd`](./bootstrap.cmd) | Seed `hub-setup.local.md`, optional Cursor sync, local `core.hooksPath`, and (in a terminal) ask to link current project directories |
| [`install-cursor-integration.sh`](./install-cursor-integration.sh) | Detect Cursor, sync `.cursor/agents/`, chmod hooks (`--force` to run without Cursor) |
| [`sync-cursor-agents.sh`](./sync-cursor-agents.sh) | Wrapper → [`sync_cursor_agents.py`](./sync_cursor_agents.py) |
| [`sync_cursor_agents.py`](./sync_cursor_agents.py) | Generate `.cursor/agents/*.md` from `Agents/Subagents/` + [`../cursor-agents.json`](../cursor-agents.json) |
| [`detect-cursor-env.sh`](./detect-cursor-env.sh) | Is Cursor installed? |
| [`find-python.sh`](./find-python.sh) | Shared `python3` / `python` / `py -3` lookup |
| [`test-git-delegation-hook.sh`](./test-git-delegation-hook.sh) | Smoke-test the POSIX git-delegation hook (no Python) |
| [`test-git-delegation-hook.py`](./test-git-delegation-hook.py) | Same checks against the Windows Python fallback |

`setup.cmd` and `bootstrap.cmd` only find Git Bash and exec the matching `.sh`. Windows users without Git Bash cannot run the POSIX installer.

## Contribute

1. Keep scripts **idempotent** (safe to re-run). Do not overwrite an existing `hub-setup.local.md`.
2. Do not `git config` globally. Local `core.hooksPath` only, and only if unset (unless the user asked).
3. Missing Python must **warn**, not abort hub core (clone still has committed `.cursor/agents/`).
4. After behavior changes, update [`../hub-setup.md`](../hub-setup.md) and this README.
5. New Cursor agents: edit specs + [`../cursor-agents.json`](../cursor-agents.json), then `install-cursor-integration.sh --force` — do not hand-edit generated files as source.
