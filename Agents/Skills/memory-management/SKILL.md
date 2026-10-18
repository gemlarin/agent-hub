---
name: memory-management
description: Captures, sanitizes, and maintains a lean MEMORY.md. Auto-write viable facts mid-session; offer option ids only on explicit save or session wrap-up. Not for session-start reads (main agent) or for subagents loading the full file.
---

# Skill: Memory & Cross-Session Persistence

Apply this skill when **writing** the configured `MEMORY.md` (Memory Steward) and when the **parent** decides whether to prompt a save. The **main agent** reads memory at session start without invoking the steward. Path comes from gitignored `Agents/Setup/hub-setup.local.md` — see [`memory.md`](../../memory.md). Never commit `MEMORY.md` to agent-hub or app repos.

User-facing ids: [`options.md`](./options.md). Show that list **only** on an explicit save request or session wrap-up. Mid-session viable facts are **auto-written** (`mem-save`) without the menu. Memory Steward applies the id to the delta.

Subagents other than Memory Steward **must not** read `MEMORY.md`. The parent passes only task-relevant bullets as `related_memory`.

---

### 1. What to Capture (High-Value Signal)

Only save information that remains relevant across future sessions and different devices:

- **User Preferences & Constraints:** Explicit choices regarding coding style, tooling, formatting preferences, communication style, or hardware/OS setups.
- **Active Projects & Goals:** Current milestones, architectural decisions, and long-term objectives for ongoing work.
- **Hard-Won Solutions:** Unique troubleshooting resolutions, custom configurations, or project-specific workarounds that would take time to rediscover.
- **Unresolved Blockers:** Current roadblocks, pending design choices, or next steps left open at the end of a session.

### 2. What to Discard (Ephemeral Noise)

Do **not** save the following to long-term memory:

- Temporary conversation filler, pleasantries, or one-off brainstorming ideas that were rejected.
- Transient debugging logs, stack traces, or temporary file paths specific to a single session.
- Information the user can easily look up or that changes rapidly.
- Anything already represented by an existing bullet (update that bullet instead).

### 3. Strict Security & Privacy Boundaries (Never Save)

You are **strictly prohibited** from writing the following types of sensitive information to any memory file, cache, or cross-session log:

- **Credentials & Secrets:** Passwords, API keys, private keys, SSH keys, bearer tokens, or database connection strings.
- **Personally Identifiable Information (PII):** Social Security Numbers (SSNs), tax IDs, banking/credit card numbers, home addresses, or private phone numbers.
- **Proprietary/Confidential Data:** Internal company trade secrets, proprietary unreleased code blocks containing embedded tokens, or client-restricted data.

> **Sanitization Rule:** If the user accidentally provides a secret or credential during a session, acknowledge the context without echoing the secret back, and actively ensure it is excluded from any memory write operations. Store only the _concept_ (e.g., _"Configured connection to Stripe API using environment variables"_).

### 4. Update & Maintenance Rules (keep it lean)

- **Size:** Target **≤80 lines**; hard cap **120 lines**. One-line bullets only. If a write would exceed the cap, prune (resolved blockers first, then stale project detail; keep current prefs and active goals).
- **Deduplication:** Before adding, check if it updates or contradicts an existing entry. Overwrite rather than append.
- **Portability:** Do not rely on local device states (avoid absolute paths like `/Users/name/Desktop/...` unless marked device-specific).
- **File Target:** The absolute path in `Agents/Setup/hub-setup.local.md` (`MEMORY.md path`). Main agent reads at session start; Memory Steward performs writes. Never commit the file.
- **Option id:** Apply the id from [`options.md`](./options.md):
  - `mem-save` — infer the section from the delta.
  - `mem-prefs` / `mem-projects` / `mem-solutions` / `mem-blockers` — write only that stub heading.
  - `mem-forget` — delete the matching entry; do not add.
  - `mem-prune` — compact only (dedupe/drop stale); no new bullets.
  - `mem-skip` — do not write (parent should not invoke). Unknown id → `NEED_INPUT` with the option table.

### 5. Parent

- **Viable fact (mid-session):** When a new fact matches §1 and is not already stored, **auto-write** in the **background**: invoke Memory Steward with `mode: write`, `option: mem-save`, **`memory_path`**, and the delta. Do **not** show [`options.md`](./options.md). Do not wait in the foreground. When SUCCESS arrives, print exactly: `Durable memory saved to MEMORY file`
- **Session ending:** If user input means they are done (wrap-up, “that’s all”, “thanks I’m out”, “later”, “good night”, “stop for now”), **show** the option ids (and any remaining unsaved bullets). Do not auto-write the wrap-up. Skipping the menu = `mem-skip`.
- **Explicit save:** “Remember this” / “save to memory” / “save session” — show the same menu, or `mem-save` if they already confirmed.
- After **any** successful steward write (auto or user-chosen), print that same `Durable memory saved to MEMORY file` line when the report arrives. Do not dump the Memory Report or the full file into chat.
- Do not write `MEMORY.md` in the parent. When delegating **any** specialist, pass `related_memory` (task-relevant bullets only). Do not tell them to read `MEMORY.md`.
