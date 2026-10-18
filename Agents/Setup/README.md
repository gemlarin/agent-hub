# Agent hub — setup

Install, sync, and optional **Cursor** integration. Hub overview: [../../README.md](../../README.md). Policy lives under `Agents/`; `.cursor/` and `.githooks/` stay at the **hub git root** (they do not follow an app’s `AGENTS.md` pointer).

| File / folder | Purpose |
|---------------|---------|
| [hub-setup.md](./hub-setup.md) | Layout, bootstrap, Cursor regen, troubleshooting |
| [scripts/](./scripts/) | First-run and sync scripts — [how to contribute](./scripts/README.md) |
| [hub-setup.local.example.md](./hub-setup.local.example.md) | Template → `hub-setup.local.md` (gitignored; remotes, paths, **MEMORY.md path**) |
| [cursor-user-rules.md](./cursor-user-rules.md) | Paste into Cursor **User Rules** only if default git User Rules tell the parent to run git |
| [cursor-agents.json](./cursor-agents.json) | Manifest for generating `.cursor/agents/` from `Agents/Subagents/` |

**Quick command (hub root):** `./Agents/Setup/scripts/bootstrap.sh` (Windows: `Agents\Setup\scripts\bootstrap.cmd`)

## Design

This folder is **machine and Cursor wiring**, not agent policy. Policy stays in `Agents/*.md` and `Subagents/` / `Skills/`.

- **`hub-setup.md`** — what a human runs after clone.
- **`hub-setup.local.example.md`** — same field skeleton as gitignored `hub-setup.local.md` (placeholders only).
- **`cursor-agents.json`** — maps spec filenames → Cursor Task names.

## Contribute

1. Keep the example’s **headings and keys** in lockstep with `hub-setup.local.md` (placeholders, not real paths or emails).
2. Bootstrap must not overwrite an existing `hub-setup.local.md`.
3. Manifest changes require a matching spec under `Agents/Subagents/` and a regen (`scripts/install-cursor-integration.sh --force`).
4. Document user-facing setup in [hub-setup.md](./hub-setup.md); document script internals in [scripts/README.md](./scripts/README.md).
