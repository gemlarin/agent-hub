# Skills

When a task matches a skill's description, load and follow its instructions. After `SKILL.md`, read `user-config.md` in that skill folder when it exists. Additions extend the skill. Overrides replace the matching part on this machine only. Never commit `user-config.md`.

## Available Workspace Skills

### 1. `memory-management` (`./memory-management/`)

- **Skill file:** [`./memory-management/SKILL.md`](./memory-management/SKILL.md)
- **User options:** [`options.md`](./memory-management/options.md) (`mem-save`, `mem-skip`, `mem-prefs`, `mem-projects`, `mem-solutions`, `mem-blockers`, `mem-forget`, `mem-prune`)
- **Orchestration (paths, triggers, steward):** [`memory.md`](../Memory/memory.md)
- **When to use:** Memory Steward **writes** (sanitize, dedupe, prune). Main agent **reads** once at session start, **auto-writes** viable facts mid-session, **offers option ids** only on explicit save or wrap-up, and passes a **slice** to other subagents—see `Agents/Memory/memory.md`.

### 2. `git-merge` (`./git-merge/`)

- **Skill file:** [`./git-merge/SKILL.md`](./git-merge/SKILL.md)
- **User options:** [`options.md`](./git-merge/options.md) (manage the merge, conflict menu, merge tool, unsure hunk, auto-fix)
- **Orchestration:** [Git Coordinator](../Subagents/git-coordinator/git-coordinator.md) in [`subagents.md`](../Subagents/subagents.md)
- **When to use:** Merge, pull-with-merge, rebase, cherry-pick, or a non-fast-forward push. Coordinator must load this skill before resolving or aborting. The conflicted files are listed first.

### 3. `job-search` (`./job-search/`)

- **Skill file:** [`./job-search/SKILL.md`](./job-search/SKILL.md)
- **Boards / output:** [`boards.md`](./job-search/boards.md) or gitignored `boards.local.md` ([example](./job-search/boards.local.example.md)), [`options.md`](./job-search/options.md), [`output.md`](./job-search/output.md)
- **When to use:** Loaded by **Job Finder** when the user asks for a job search (or names that subagent). Parent must not run this skill itself. Do not invent postings.

### 4. `research` (`./research/`)

- **Skill file:** [`./research/SKILL.md`](./research/SKILL.md)
- **User options:** [`options.md`](./research/options.md) (tasks + `out-chat` / `out-md` / `out-xml` / `out-raw`)
- **When to use:** Loaded by **Research Scout**. First pass is a brief; then the parent offers follow-up ids (`compare`, `cite`, `verify`, …). Not for job search or a one-line web lookup.

### 5. `code-sweep` (`./code-sweep/`)

- **Skill file:** [`./code-sweep/SKILL.md`](./code-sweep/SKILL.md)
- **User options:** [`options.md`](./code-sweep/options.md) (`aria`, `live`, `a11y`, `bugs`, `typos`, `smell`, `types`, `async`, `secrets`, `ci`, `dod`)
- **Orchestration:** [Code Sweeper](../Subagents/code-sweeper/code-sweeper.md) in [`subagents.md`](../Subagents/subagents.md)
- **When to use:** Loaded by **Code Sweeper** when the user asks for a code sweep (or names that subagent) or a `tasks.md` sweep item is due. Parent must not run a multi-topic sweep itself. Not Code Reviewer (git diffs).

### 6. `help-getter` (`./help-getter/`)

- **Skill file:** [`./help-getter/SKILL.md`](./help-getter/SKILL.md)
- **User options:** [`options.md`](./help-getter/options.md) (`Change code settings`, `Display configuration`, `List agents`, `List skills`, `Memory information`, `Cancel`)
- **When to use:** The prompt is `HELP` by itself, or the user invokes `/help`. The main agent runs it. Not a subagent.

---
