# Memory & Persistent Context

Cross-session continuity uses **one** `MEMORY.md` file. It is private—never commit it to agent-hub or app repos.

Put it in **cloud storage** (Google Drive, iCloud, Dropbox, …) so machines share it, or keep a **local-only** file on this computer.

## Configure the path

The Memory Steward and the main agent read the absolute path from gitignored [`Setup/hub-setup.local.md`](../Setup/hub-setup.local.md):

```markdown
## Persistent memory

- **MEMORY.md path:** `/absolute/path/to/MEMORY.md`
```

Bootstrap seeds that file from [`Setup/hub-setup.local.example.md`](../Setup/hub-setup.local.example.md). Edit the path on each machine. If the field is missing or still the placeholder, stop and ask the user to set it.

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
| **Main agent** | **Only** loader of session context. Read `hub-setup.local.md` for the path, then read that `MEMORY.md` **once** at **session start**. Apply context; do not re-read unless the user says the file changed or after Memory Steward writes. |
| **Memory Steward** | **Write only** to that same path. May read the file internally to merge, dedupe, and prune—never to bootstrap the parent or another specialist. |
| **Every other subagent** | **Do not** read `MEMORY.md` or `hub-setup.local.md` for memory. Use only `related_memory` bullets the parent put in the task prompt (may be empty). |

Do **not** invoke Memory Steward with `mode: read` to load session context (avoids double-read with the main agent).

## Keep it lean

`MEMORY.md` is loaded by every new main-agent session. Keep it short so it does not burn tokens.

- **Target:** ≤80 lines. **Hard cap:** 120 lines (~40 one-line bullets).
- One fact per bullet. No paragraphs, logs, diffs, or file dumps.
- Overwrite or drop stale bullets; do not append duplicates.
- Drop resolved blockers, finished one-off goals, and superseded preferences on every write.
- If a write would exceed the hard cap, prune lowest-value entries first (resolved blockers, then old project detail; keep current prefs and active goals).

## Auto-save vs option menu

### Viable fact (during the session)

As soon as the parent judges a fact meets the skill’s capture rules (standing preference, durable decision, hard-won workaround, open blocker, lasting goal)—and it is not already in memory—**auto-write**. Invoke Memory Steward **in the background** with `mode: write`, `option: mem-save`, **`memory_path`**, and the delta. Do **not** show option ids. Do **not** wait in the foreground (Drive `MEMORY.md` can stall this chat). Batch several facts from the same turn into one write.

When the Memory Report arrives with a real change, print exactly:

`Durable memory saved to MEMORY file`

### Option menu (only these times)

Show the proposed bullets and the ids in [`Skills/memory-management/options.md`](../Skills/memory-management/options.md) **only** when:

1. **Explicit save:** the user asked to remember / save / update memory.
2. **Session ending:** user input means they are done (e.g. “that’s all”, “we’re done”, “wrap up”, “thanks, I’m out”, “later”, “good night”, “stop for now”).

Do not write the wrap-up or explicit-save delta until they pick (or confirm). Skipping the session-end menu = `mem-skip`. After a successful user-chosen write, print the same `Durable memory saved to MEMORY file` line.

Never dump the full `MEMORY.md` into chat.

## Skill (content rules for writes)

When **writing** memory, the steward loads:

[`Skills/memory-management/SKILL.md`](../Skills/memory-management/SKILL.md)

Write ids the parent offers: [`Skills/memory-management/options.md`](../Skills/memory-management/options.md).

Main agent should follow the same capture/discard boundaries when deciding *what* to propose.

## Main agent responsibilities

1. **Session start:** Resolve the path from `hub-setup.local.md`, then read that `MEMORY.md` before planning work.
2. **During work:** Use memory as context; do not paste the full file into chat.
3. **Mid-session:** Auto-write viable durable facts in the **background** (`mem-save` + `memory_path`); print `Durable memory saved to MEMORY file` when the report arrives.
4. **Persistence:** Delegate **all writes** to Memory Steward (`mode: write`); never edit `MEMORY.md` during feature work.
5. **Subagents:** Pass **`related_memory`** — only the bullets that apply to **this** task. Never the full file. Never tell a specialist to open `MEMORY.md`.
6. **Menu:** Show option ids only on “remember” / “save session” / wrap-up. After a successful write, print the same save line.

## Passing memory to subagents

When invoking any specialist, include at most a short `related_memory` list (prefer ≤8 bullets) copied from session memory **if and only if** it affects that task (prefs for how to code/commit, the active project for this repo, a relevant workaround or blocker). Omit the field when nothing applies.

## What belongs in `MEMORY.md`

Follow the skill: preferences, project goals, durable solutions, open blockers—not secrets, PII, or ephemeral logs.
