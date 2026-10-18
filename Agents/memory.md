# Memory & Persistent Context

Cross-session continuity uses **one** `MEMORY.md` file. It is private—never commit it to agent-hub or app repos.

Put it in **cloud storage** (Google Drive, iCloud, Dropbox, …) so machines share it, or keep a **local-only** file on this computer.

## Configure the path

The Memory Steward and the main agent read the absolute path from gitignored [`Setup/hub-setup.local.md`](./Setup/hub-setup.local.md):

```markdown
## Persistent memory

- **MEMORY.md path:** `/absolute/path/to/MEMORY.md`
```

Bootstrap seeds that file from [`Setup/hub-setup.local.example.md`](./Setup/hub-setup.local.example.md). Edit the path on each machine. If the field is missing or still the placeholder, stop and ask the user to set it.

Typical locations:

| Kind | Example |
|------|---------|
| Google Drive for Desktop (Mac) | `~/Library/CloudStorage/GoogleDrive-<account>/My Drive/Documents/MEMORY.md` |
| Google Drive for Desktop (Windows) | `~/Google Drive/My Drive/Documents/MEMORY.md` |
| Local only | `~/Documents/MEMORY.md` |

**Do not** commit `MEMORY.md`. Hub gitignore already drops a hub-root `/MEMORY.md`. Prefer a path **outside** the clone (cloud sync folder or `~/Documents`).

## Who reads vs writes

| Actor | Responsibility |
|--------|----------------|
| **Main agent** | Read `hub-setup.local.md` for the path, then read that `MEMORY.md` **once** at **session start**. Apply context; do not re-read unless the user says the file changed or after Memory Steward writes. |
| **Memory Steward** | **Write only** to that same configured path. May read the file internally to merge edits—never for session bootstrap. |

Do **not** invoke Memory Steward with `mode: read` to load session context (avoids double-read with the main agent).

## Skill (content rules for writes)

When **writing** memory, the steward loads:

[`Skills/memory-management/SKILL.md`](./Skills/memory-management/SKILL.md)

Main agent should follow the same capture/discard boundaries when deciding *what* to ask the steward to save.

## Main agent responsibilities

1. **Session start:** Resolve the path from `hub-setup.local.md`, then read that `MEMORY.md` before planning work.
2. **During work:** Use memory as context; do not paste the full file into chat.
3. **Persistence:** Delegate **all writes** to Memory Steward (`mode: write`); never edit `MEMORY.md` during feature work.
4. **User triggers:** “Remember this”, “update memory”, “save session”, or wrap-up → Memory Steward with `mode: write`, the configured **path**, and a **memory delta** (bullets).

## What belongs in `MEMORY.md`

Follow the skill: preferences, project goals, durable solutions, open blockers—not secrets, PII, or ephemeral logs.
