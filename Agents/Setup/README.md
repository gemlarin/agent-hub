# Agent hub — setup

Install, sync, and optional **Cursor** integration. Policy and subagents live elsewhere under `Agents/`.

| File / folder | Purpose |
|---------------|---------|
| [hub-setup.md](./hub-setup.md) | Hub git layout, scenarios A/B/C, Cursor optional, troubleshooting |
| [hub-setup.local.example.md](./hub-setup.local.example.md) | Template → copy to `hub-setup.local.md` (gitignored) |
| [cursor-user-rules.md](./cursor-user-rules.md) | Paste into Cursor **User Rules** (account settings) |
| [cursor-agents.json](./cursor-agents.json) | Manifest for generating `.cursor/agents/` |
| [scripts/](./scripts/) | `detect-cursor-env.sh`, `install-cursor-integration.sh`, `sync-cursor-agents.sh` |

**Quick command (hub root):** `./Agents/Setup/scripts/install-cursor-integration.sh`
