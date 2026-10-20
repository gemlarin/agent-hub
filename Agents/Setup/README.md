# Agent hub — setup

Install, sync, and optional **Cursor** integration. Hub overview: [../../README.md](../../README.md). Policy lives under `Agents/`; `.cursor/` and `.githooks/` stay at the **hub git root** (they do not follow an app’s `AGENTS.md` pointer).

| File / folder | Purpose |
|---------------|---------|
| [hub-setup.md](./hub-setup.md) | Layout, bootstrap, Cursor regen, troubleshooting |
| [scripts/](./scripts/) | First-run and sync scripts — [how to contribute](./scripts/README.md) |
| [hub-setup.local.example.md](./hub-setup.local.example.md) | Template → `hub-setup.local.md` (gitignored; git remote, hub folder, GitHub username) |
| [../Settings/README.md](../Settings/README.md) | Global `CONFIG.md`. Setup writes the test default, memory path, and memory line cap here. |
| [cursor-user-rules.md](./cursor-user-rules.md) | Paste into Cursor **User Rules** only if default git User Rules tell the parent to run git |
| [cursor-agents.json](./cursor-agents.json) | Manifest for generating `.cursor/agents/` from `Agents/Subagents/` |

**Quick command (hub root):** `./Agents/Setup/scripts/setup.sh` (Windows: `Agents\Setup\scripts\setup.cmd`). That detects the OS, asks the remaining questions, and runs bootstrap. In Cursor: say **set up the hub**.

Setup asks where `MEMORY.md` lives, how many lines it may hold, and which checks to run after an update (`UNIT`, `BROWSER`, `BOTH`, or `NONE`). It writes those to `Agents/Settings/CONFIG.md`. Change the test default later from `HELP` → **Change code settings**. View or edit memory settings from `HELP` → **Memory information**. See [Settings](../Settings/README.md) and [help-getter](../Skills/help-getter/README.md).

## Design

This folder is **machine and Cursor wiring**, not agent policy. Policy stays in `Agents/*.md` and `Subagents/` / `Skills/`.

- **`hub-setup.md`** — what a human runs after clone.
- **`hub-setup.local.example.md`** — same field skeleton as gitignored `hub-setup.local.md` (placeholders only).
- **`cursor-agents.json`** — maps spec filenames → Cursor Task names.

## Still to do

- [x] Replace the Cursor User Rules already pasted on this account with [cursor-user-rules.md](./cursor-user-rules.md). The parent does not open `subagents.md` or `git-coordinator.md`. The Task prompt tells the specialist to read its own spec and `user-config.md`.

## Contribute

1. Keep the example’s **headings and keys** in lockstep with `hub-setup.local.md` (placeholders, not real paths or emails).
2. Bootstrap must not overwrite an existing `hub-setup.local.md`.
3. Manifest changes require a matching spec under `Agents/Subagents/` and a regen (`scripts/install-cursor-integration.sh --force`).
4. Document user-facing setup in [hub-setup.md](./hub-setup.md); document script internals in [scripts/README.md](./scripts/README.md).
