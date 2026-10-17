# Skills

When a task matches a skill's description, load and follow its instructions.

## Available Workspace Skills

### 1. `memory-management` (`./memory-management/`)

- **When to use:** Updating `MEMORY.md`, capturing cross-session context, or enforcing secret/PII redaction rules.
- **Instruction Summary:** Filters ephemeral noise, redacts sensitive credentials (SSNs, API keys, passwords), and structures long-term project knowledge.

---

## Active Skill Routing: Memory Management

You have access to a persistent memory skill located at `./memory-management/SKILL.md`. You must load and apply its protocols during specific lifecycle events.

### 1. When to Trigger the Memory Skill

You must invoke the `memory-management` skill during these precise moments:

- **Session Initialization (Read Phase):** At the very beginning of a session or when starting work on a new task, check for and read the root `MEMORY.md` file to load user preferences, active project goals, and known blockers.
- **Milestone Completion (Write Phase):** When a major feature is completed, a complex bug is successfully resolved, or a hard-won configuration is finalized.
- **Preference Shift:** When the user explicitly states a new coding preference, tooling choice, or workflow constraint.
- **Session Wrap-Up / Exit:** Right before concluding a major working session or when the user prompts to save progress.

### 2. Execution Directives for Memory Updates

When executing a memory update using the skill:

1. **Filter & Sanitize:** Apply the strict security boundaries from `SKILL.md` to ensure zero API keys, passwords, or PII are written.
2. **Deduplicate:** Check existing contents in `MEMORY.md` and overwrite outdated facts rather than creating chronological clutter.
3. **Persist:** Write clean, concise updates directly to the root `MEMORY.md` file so other devices and future sessions can inherit the state.

---
