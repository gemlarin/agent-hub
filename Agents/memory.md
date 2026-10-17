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

## Skill (how to read / write)

Content rules (capture vs discard, redaction, deduplication):

[`Skills/memory-management/SKILL.md`](../Skills/memory-management/SKILL.md)

Load that skill whenever you touch `MEMORY.md`.

## Main agent responsibilities

1. **Session start / new task:** Read **Google Drive** `MEMORY.md` (absolute path above) **or** invoke **Memory Steward** with `mode: read` before planning work.
2. **During work:** Use memory as context; do not duplicate long memory contents into chat.
3. **Memory reads and writes:** Never use a local Projects `MEMORY.md`. Delegate all writes to **Memory Steward**; do not edit memory inline during feature work.
4. **User triggers:** “Remember this”, “update memory”, “save session”, or wrap-up → Memory Steward with `mode: write` and a memory delta.

## What belongs in `MEMORY.md`

Follow the skill: preferences, project goals, durable solutions, open blockers—not secrets, PII, or ephemeral logs.
