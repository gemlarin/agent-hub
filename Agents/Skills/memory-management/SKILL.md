---
name: memory-management
description: Captures, sanitizes, and maintains high-value cross-session state in persistent memory files (MEMORY.md) while strictly protecting sensitive data and discarding ephemeral noise.
tools: [read_file, write_file, edit_file]
---

# Skill: Memory & Cross-Session Persistence

Apply this skill when **writing** the configured `MEMORY.md` (Memory Steward). The **main agent** reads memory at session start without invoking the steward. Path comes from gitignored `Agents/Setup/hub-setup.local.md` — see [`memory.md`](../../memory.md). Never commit `MEMORY.md` to agent-hub or app repos. Evaluate new facts against the sections below before persisting.

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

### 3. Strict Security & Privacy Boundaries (Never Save)

You are **strictly prohibited** from writing the following types of sensitive information to any memory file, cache, or cross-session log:

- **Credentials & Secrets:** Passwords, API keys, private keys, SSH keys, bearer tokens, or database connection strings.
- **Personally Identifiable Information (PII):** Social Security Numbers (SSNs), tax IDs, banking/credit card numbers, home addresses, or private phone numbers.
- **Proprietary/Confidential Data:** Internal company trade secrets, proprietary unreleased code blocks containing embedded tokens, or client-restricted data.

> **Sanitization Rule:** If the user accidentally provides a secret or credential during a session, acknowledge the context without echoing the secret back, and actively ensure it is excluded from any memory write operations. Store only the _concept_ (e.g., _"Configured connection to Stripe API using environment variables"_).

### 4. Update & Maintenance Rules

- **Conciseness:** Keep entries brief, dense, and structured (bullet points over paragraphs).
- **Deduplication:** Before adding a new memory, check if it updates or contradicts an existing entry. Overwrite outdated information rather than appending duplicates.
- **Portability:** Ensure stored notes do not rely on local device states (avoid absolute paths like `/Users/name/Desktop/...` unless explicitly marked as device-specific).
- **File Target:** The absolute path in `Agents/Setup/hub-setup.local.md` (`MEMORY.md path`). Cloud-synced or local-only is fine. Main agent reads at session start; Memory Steward performs writes; both must follow this skill. Never commit the file.
