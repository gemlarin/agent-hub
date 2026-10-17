# Memory & Persistent Context

Cross-session continuity uses **one** file: **`MEMORY.md`** in **Google Drive** (`My Drive/Documents/MEMORY.md`). It is private—never commit it to agent-hub or app repos.

## Canonical path (read and write **only** here)

**Do not** read or write `MEMORY.md` under the Projects folder, app repos, or any other local path. **No symlinks, copies, or stubs** at the hub root—Google Drive is the only target so Mac and PC stay in sync.

Resolve the synced file on disk (Google Drive for Desktop):

| Machine | Typical absolute path |
|---------|------------------------|
| **Mac** | `~/Library/CloudStorage/GoogleDrive-<account>/My Drive/Documents/MEMORY.md` |
| **PC** | `~/Google Drive/My Drive/Documents/MEMORY.md` (or your Drive letter equivalent, e.g. `G:\My Drive\Documents\MEMORY.md`) |

If the path differs on a machine, locate `Documents/MEMORY.md` inside your synced **My Drive** folder and use that file only.

## Who reads vs writes

| Actor | Responsibility |
|--------|----------------|
| **Main agent** | **Read** Drive `MEMORY.md` once at **session start** (or when starting a new task in a fresh chat). Apply context; do not re-read unless the user says memory may have changed elsewhere. |
| **Memory Steward** | **Write only.** Invoked for persistence updates; may read the file internally to merge edits—never for session bootstrap. |

Do **not** invoke Memory Steward with `mode: read` to load session context (avoids double-read with the main agent).

## Skill (content rules for writes)

When **writing** memory, the steward loads:

[`Skills/memory-management/SKILL.md`](../Skills/memory-management/SKILL.md)

Main agent should follow the same capture/discard boundaries when deciding *what* to ask the steward to save.

## Main agent responsibilities

1. **Session start:** Read Google Drive `MEMORY.md` before planning work.
2. **During work:** Use memory as context; do not paste the full file into chat.
3. **Persistence:** Delegate **all writes** to Memory Steward (`mode: write`); never edit `MEMORY.md` during feature work.
4. **User triggers:** “Remember this”, “update memory”, “save session”, or wrap-up → Memory Steward with `mode: write` and a **memory delta** (bullets).

## What belongs in `MEMORY.md`

Follow the skill: preferences, project goals, durable solutions, open blockers—not secrets, PII, or ephemeral logs.
