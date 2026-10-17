# Skills

When a task matches a skill's description, load and follow its instructions.

## Available Workspace Skills

### 1. `memory-management` (`./memory-management/`)

- **When to use:** Reading or updating Google Drive `MEMORY.md`, cross-session context, or secret/PII redaction.
- **Who applies it:** **Memory Steward** for writes; main agent reads Google Drive `MEMORY.md` at session start (or steward `mode: read`). See [`Agents/memory.md`](../Agents/memory.md) for paths.
- **Instruction Summary:** Filters noise, redacts credentials/PII, structures long-term knowledge. **No local Projects `MEMORY.md`.**

---

## Active Skill Routing: Memory Management

Load [`./memory-management/SKILL.md`](./memory-management/SKILL.md) and [`Agents/memory.md`](../Agents/memory.md).

### 1. When to Trigger the Memory Skill

| Event | Actor | Action |
|-------|--------|--------|
| Session start / new agent | Main agent | Read **Google Drive** `Documents/MEMORY.md` **or** Memory Steward `mode: read` |
| User asks to remember something | Main agent → Memory Steward | `mode: write` + memory delta |
| Milestone, bug fix, preference change | Main agent → Memory Steward | `mode: write` + delta |
| Session wrap-up | Main agent → Memory Steward | `mode: read_then_write` if needed |

### 2. Execution Directives

1. **Google Drive only** for every read and write—never `Projects/MEMORY.md`.
2. **Delegate writes** to Memory Steward during unrelated tasks.
3. **Filter & sanitize** per `SKILL.md`.
4. **Deduplicate** against existing Drive `MEMORY.md` in the steward write path.

---
