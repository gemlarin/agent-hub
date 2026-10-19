# Subagents

## Subagent Delegation & Orchestration Rules

You have access to specialized subagents in your workspace. To protect your context window, prevent hallucinations, and ensure high-quality outputs, offload tasks according to the following trigger matrix.

### How to Invoke Subagents

When delegating a task, provide the subagent with a complete, self-contained prompt:

1. State the exact subagent from the matrix (e.g. Git Coordinator, Memory Steward, Research Scout).
2. Pass explicit parameters (target file paths, scope, or expected output shape).
3. Specify the expected return format (e.g., "Return a Research Brief, ≤80 lines unless detail requested").
4. Pass **`related_memory`** only if durable memory applies to **this** task (prefer ≤8 bullets). Never the full `MEMORY.md`. Never tell the specialist to read that file (Memory Steward may read it only to apply a write).
5. Set **background vs foreground** from the table below (or the user’s “run that in the background” / `/multitask`). Do not wait or poll a background specialist; relay its report when it arrives.

### Background vs foreground

[Cursor: foreground blocks this chat until the specialist finishes; background returns immediately and the specialist works on its own](https://cursor.com/docs/subagents). This is **not** Cursor Cloud “background agents.”

| Specialist | Default | Why |
|------------|---------|-----|
| **Job Finder**, **Research Scout**, **Code Sweeper**, **Web Researcher** | **Background** | Long I/O (boards, docs, greps, web). User can keep chatting here. |
| **Git Coordinator** | **Foreground** | Relays `Yes` / `No` / `Preview`, `git add all`, `[custom]` / `[agent]`, and merge ids in this turn. |
| **Memory Steward** | **Background** | Cloud `MEMORY.md` can stall. Do not block this chat. Print `Durable memory saved to MEMORY file` when the report arrives. |
| **Code Reviewer** | **Foreground** when it gates a commit/PR; **background** if they asked for a review while doing other work | |
| **Hub Installer** | **Foreground** | Asks memory path, GitHub username, and app folders before it writes config. |

If they say **“in the background”**, **“don’t wait”**, or **`/multitask`**, use background even for a foreground-default specialist **unless** that would skip a required relay (commit/merge choices). Memory save line is printed when the steward report arrives — do not wait in the foreground for it.

### Execution & Synthesis

- Do not attempt to re-read raw logs or files that a subagent already processed. Trust the returned report.
- Verify the subagent's summary against project goals before taking direct action.
- **Report size:** Subagents return **≤80 lines** by default (summaries, capped lists, truncated diffs/snippets). Expand only when the user or parent asks for detail.
- **Parent relay:** Prefer the report summary in chat; pass full reports only when the user needs them.
- **Runtime:** Follow [context discipline](../Rules/context-discipline/context-discipline.md) (no duplicate git/memory reads, narrow file scope).

### Git Coordinator (`./git-coordinator/git-coordinator.md`)

- **Cursor:** Registered as `git-coordinator` in `.cursor/agents/` (run [`Setup/scripts/sync-cursor-agents.sh`](../Setup/scripts/sync-cursor-agents.sh) after spec changes).
- **When (hub repo):** Any **`git`** or **`gh`** on the agent-hub git root. Parent **never** runs those CLIs **in this hub**.
- **Resume:** After the first Git Coordinator Task in this chat, **resume that same agent id** for `Yes` / `No` / `Preview`, `git add all`, `[custom]` / `[agent]`, merge ids, and `commit_message`. Spawn a new coordinator only if the previous run **aborted**, **FAILED** with no id, or this is the first git ask in the chat. Cold-starting every relay is what makes GIT feel stuck.
- **Other repos:** Parent may run `git`/`gh` (shell hook does not block non-hub git roots). The add list still applies before a commit. Do not stage until **`git add all`** or named paths. A description of the work is not file approval. Use git-coordinator with **`repo_path`** when that flow is wanted.
- **Command word:** Git commands start with **`git`** (`git add`, `git commit`, `git push`, `git auto push`, and the other git verbs). If the user says `add`, `commit`, `push`, or another git verb without `git`, do **not** delegate yet. Ask if they want Git Coordinator, and suggest `git <keyword>` next time.
- **`git auto push`:** First ask, in these words: `about to add, commit and push all modified files to current repo. Are you sure?` Options: **Yes**, **No**, **Preview**. Preview lists the files. **No** stops. **Yes** drafts the message from the report and has the coordinator add, commit, and push the current branch. No `[custom]` / `[agent]` step.
- **`git add`:** List each changed file and a one-line summary. Offer **`git add all`** or let them name files.
- **`git commit`:** If nothing is staged, start **`git add`** first, in this repo and in sibling repos. Wait for **`git add all`** or named paths. A sentence that describes the work is not that approval. If something is staged, relay **`[custom]`** vs **`[agent]`** before a message is sent.
- **`git push`:** If the index is empty and files are modified, start **`git add`** and ask whether to commit before pushing. **`git add all`** or named paths stage those files, then the message choice, then commit and push. **No** pushes the current branch and does not commit. If files are already staged, skip add, commit those, then push.
- **Parent only:** Confirm **`repo_path`** with the user if unclear; relay choices and (if `[agent]` or auto-push **Yes**) a drafted commit message; surface the **Git Report**—do not re-run git or duplicate its output. On **`AWAIT_MERGE_APPROVAL`**, offer [git-merge option ids](../Skills/git-merge/options.md) unless already chosen.
- **Coordinator spec** (params, commit/merge flows, safety, report statuses): load the subagent file when delegating—not duplicated here.

---

### Research Scout (`./research-scout/research-scout.md`)

**Role:** Deep documentation research, codebase exploration, API investigations, and multi-source verification.

- **When to Trigger:**
  - **External Libraries & APIs:** Investigating third-party packages, new frameworks, or APIs spanning more than 3 files or requiring external web search.
  - **Version Compatibility:** Verifying breaking changes, version dependencies, or upgrade guides (e.g., checking `package.json` or `pyproject.toml` compatibility).
  - **Deep Discovery:** Searching through long historical design docs, architectural specs, or large log files.
- **Invocation Parameters:** Research objective, target dirs/URLs, version constraints, optional `task` from [research options](../Skills/research/options.md) (`brief` if omitted), optional `related_memory` (task-relevant bullets only). Scout loads the [research skill](../Skills/research/SKILL.md). Do not tell Scout to read `MEMORY.md`.
- **Handling Results:** Trust the brief. Then **offer follow-up tasks and output formats** ([`Skills/research/options.md`](../Skills/research/options.md)) unless the user already picked. Re-invoke with `task` / `output` + prior brief. Parent writes Desktop files for `out-md` / `out-xml` / `out-raw`. Do not re-read sources except for `deepen` / `verify` / `versions` / `timeline`.

---

### Code Reviewer (`./code-reviewer/code-reviewer.md`)

**Role:** Adversarial security auditing, edge-case analysis, and code quality verification for diffs and staged changes.

- **When to Trigger:**
  - **Complex Logic & Refactors:** Any new feature or refactor modifying core business logic across more than 2 files.
  - **Security-Sensitive Code:** Edits involving authentication, authorization, session management, token validation, or database access layers.
  - **Pre-Commit Verification:** When preparing a pull request or the user explicitly requests a code review (repo state/diff from **Git Coordinator**, not parent shell).
- **Do not trigger** for a topic-checkbox **code sweep** — that is Code Sweeper.
- **Invocation Parameters:** Specify target files, scope (e.g. diff summary from Git Report), any project-specific security concerns, and optional `related_memory` (task-relevant bullets only). Do not tell the reviewer to read `MEMORY.md`.
- **Handling Results:**
  - If the verdict is **REQUIRES CHANGES** or **CRITICAL BLOCKER**, you must address all flagged issues before finalizing your response.
  - If the verdict is **APPROVED**, proceed to complete the task.

---

### Code Sweeper (`./code-sweeper/code-sweeper.md`)

**Role:** Topic-limited accessibility and quality sweep using the [code-sweep](../Skills/code-sweep/SKILL.md) skill. Returns a **Sweep Report**. Read-only; does not apply fixes.

- **When to Trigger:**
  - The user asks for a code sweep or names Code Sweeper.
  - A `tasks.md` **Code sweep** item is due.
  - The one-time wrap-up reminder in [coding-standards.md](../Rules/coding-standards/coding-standards.md#code-sweep) (offer the topic menu first).
- **Do not trigger** for git-diff / security review (Code Reviewer), job search, or implementing the feature.
- **Invocation Parameters:** `scope` (app root / paths), `topics` from [code-sweep options](../Skills/code-sweep/options.md), optional `related_memory`. If topics are missing, **show the option ids** and wait — do not sweep all topics. Do not run the skill in the parent. Do not tell Code Sweeper to read `MEMORY.md`.
- **Handling Results:** Trust the Sweep Report. Relay findings by topic. **Ask before** applying suggested fixes (Change Control). Do not re-read the swept files unless verifying one finding.

---

### Memory Steward (`./memory-steward/memory-steward.md`)

**Role:** **Write only** to the `MEMORY.md` path in gitignored `Settings/CONFIG.md` (see [Memory rules](../Memory/memory.md)) using the [memory-management](../Skills/memory-management/SKILL.md) skill. Returns a **Memory Report**. Prunes the file to **Memory max lines**. Session context comes from the **main agent’s** session-start read—do not use this subagent to load memory at session start.

- **When to Trigger:**
  - **Viable fact (auto):** Parent judged a standing preference, durable decision, workaround, blocker, or lasting goal is worth storing. Invoke immediately with `option: mem-save` — **do not** show the option menu.
  - **Session ending / explicit save:** User input means they are done, or they said “remember” / “update memory” / “save session”. **Show** [memory option ids](../Skills/memory-management/options.md) first; invoke only after they pick (not on `mem-skip`).
- **Do not trigger** to bootstrap the session or to let another specialist read memory.
- **Invocation Parameters:** `mode: write`, **option** id (`mem-save` on autosave), **memory_path** (absolute, from this session’s `CONFIG.md` resolve), **memory_max_lines** (from that same file), **memory delta** (bullets; empty on `mem-prune`), optional one-paragraph session summary (not stored as-is). Parent must not ask the steward to change non-memory files. Launch **in the background**. Do not poll.
- **Handling Results:** Trust the Memory Report; do not re-read `MEMORY.md` unless the user says the file changed on another device or you need the new bullets for later `related_memory`. After SUCCESS with a real change, print exactly: `Durable memory saved to MEMORY file`

---

### Job Finder (`./job-finder/job-finder.md`)

**Role:** Resume-matched job search using the [job-search](../Skills/job-search/SKILL.md) skill. Returns a **Job Report**. Writes result files to the Desktop only when the user asks.

- **When to Trigger (only):**
  - The user asks for help finding jobs, openings, or a job search.
  - The user names Job Finder or a job board in that context (a default board, or one they added in `boards.local.md`).
- **Do not trigger** for coding, git, memory, code review, or general documentation/web lookup. Use Web Researcher / Research Scout for those.
- **Invocation Parameters:** Pass resume path/attachment and any filters already collected, plus optional `related_memory` (search prefs only). Job Finder returns `NEED_INPUT` for the rest; parent asks the user and re-invokes. Do not run the job-search skill in the parent. Do not tell Job Finder to read `MEMORY.md`. Launch **in the background** (see [Background vs foreground](#background-vs-foreground)).
- **Handling Results:** Trust the Job Report. Relay ranked matches and **output ids** (`out-chat`, `out-md`, `out-xml`, `out-raw`) unless already chosen. Re-invoke with `output` to save; do not re-run board searches.

---

### Hub Installer (`./hub-installer/hub-installer.md`)

**Role:** Finish first-run hub setup. Detects the OS and runs [`Setup/scripts/setup.sh`](../Setup/scripts/setup.sh). Returns a **Setup Report**.

- **When to Trigger:** The user asks to install, set up, or configure the agent hub, or names Hub Installer / `setup.sh`.
- **Do not trigger** for everyday coding, commits, job search, or a machine that is already configured unless they asked to re-run setup.
- **Invocation Parameters:** Any answers they already gave (memory path, GitHub username, app paths), plus optional `related_memory`. Do not tell Hub Installer to read `MEMORY.md`. It must not run `git`/`gh` itself — only `setup.sh`.
- **Handling Results:** If the report is **NEED_INPUT**, ask the user and re-invoke with the answers. Trust **SUCCESS**. Relay the memory path and anything still manual (Cursor User Rules paste).

---

### Web Researcher (`./web-researcher/web-researcher.md`)

**Role:** Targeted web search for current docs, release notes, errors, and patterns. Follow the protocol in that file (source quality, date decay, compressed output).

- **When to Trigger:** Post-cutoff framework/API facts, niche errors, or comparing libraries when local docs are not enough.
- **Invocation Parameters:** Precise query, stack/version constraints, desired output shape (answer + links + snippets), optional `related_memory` (task-relevant bullets only). Do not tell Web Researcher to read `MEMORY.md`.
- **Handling Results:** Use returned findings directly; do not re-run the same searches in the parent context.

---

### General Delegation Protocol

- **Trigger matrix:** When a section above matches, delegate—do not do that work in the parent.
- **Durable memory:** Specialists other than Memory Steward **do not** read `MEMORY.md`. Parent passes a task-relevant `related_memory` slice only ([memory.md](../Memory/memory.md#passing-memory-to-subagents)).
- **Read-Only default:** Research Scout, Code Reviewer, Code Sweeper, and Web Researcher do not edit the codebase. Reviewer uses coordinator diff text or `read_file`—not `git`. Sweeper greps named paths only.
- **Write exceptions:** Memory Steward → configured `MEMORY.md` only. Git Coordinator → `git`/`gh`; file edits only per [git-merge](../Skills/git-merge/SKILL.md) after user approves a merge plan. Job Finder → Desktop result files only (never the hub repo). Hub Installer → `hub-setup.local.md`, `Settings/CONFIG.md`, a `MEMORY.md` outside the clone, and pointer `AGENTS.md` files in app folders the user named. It runs `setup.sh` only (no direct `git`/`gh`).
- **No Raw Log Dumping:** Never attempt to re-read raw logs, multi-hundred-line source code, or uncompressed search outputs that a subagent has already processed.
- **Report cap:** Same **≤80 lines** default for every specialist (see Execution & Synthesis).
