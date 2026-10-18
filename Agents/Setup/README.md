# Agent hub — setup

Install, sync, and optional **Cursor** integration. Hub overview: [../../README.md](../../README.md). Policy lives under `Agents/`; `.cursor/` and `.githooks/` stay at the **hub git root** (they do not follow an app’s `AGENTS.md` pointer).

| File / folder | Purpose |
|---------------|---------|
| [hub-setup.md](./hub-setup.md) | Layout, bootstrap, Cursor regen, troubleshooting |
| [scripts/bootstrap.sh](./scripts/bootstrap.sh) / [bootstrap.cmd](./scripts/bootstrap.cmd) | First run / new machine (`.cmd` for Windows) |
| [hub-setup.local.example.md](./hub-setup.local.example.md) | Template → `hub-setup.local.md` (gitignored; remotes, paths, **MEMORY.md path**) |
| [cursor-user-rules.md](./cursor-user-rules.md) | Paste into Cursor **User Rules** only if default git User Rules tell the parent to run git |
| [cursor-agents.json](./cursor-agents.json) | Manifest for generating `.cursor/agents/` |
| [scripts/](./scripts/) | `detect-cursor-env.sh`, `install-cursor-integration.sh`, `sync-cursor-agents.sh`, `test-git-delegation-hook.py` |

**Quick command (hub root):** `./Agents/Setup/scripts/bootstrap.sh` (Windows: `Agents\Setup\scripts\bootstrap.cmd`)
