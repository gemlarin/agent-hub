# Subagents

## Subagent Delegation & Orchestration Rules

You have access to specialized subagents in your workspace. To protect your context window, prevent hallucinations, and ensure high-quality outputs, offload tasks according to the following trigger matrix.

### How to Invoke Subagents

When delegating a task, provide the subagent with a complete, self-contained prompt:

1. State the exact subagent from the matrix (e.g. Git Coordinator, Memory Steward, Research Scout).
2. Pass explicit parameters (target file paths, scope, or expected output shape).
3. Specify the expected return format (e.g., "Return a Research Brief, ≤80 lines unless detail requested").

### Execution & Synthesis

- Do not attempt to re-read raw logs or files that a subagent already processed. Trust the returned report.
- Verify the subagent's summary against project goals before taking direct action.
- **Report size:** Subagents return **≤80 lines** by default (summaries, capped lists, truncated diffs/snippets). Expand only when the user or parent asks for detail.
- **Parent relay:** Prefer the report summary in chat; pass full reports only when the user needs them.
- **Runtime:** Follow [context discipline](./context-discipline.md) (no duplicate git/memory reads, narrow file scope).

### Git Coordinator (`./Subagents/git-coordinator.md`)

- **Cursor:** Registered as `git-coordinator` in `.cursor/agents/` (run [`Setup/scripts/sync-cursor-agents.sh`](./Setup/scripts/sync-cursor-agents.sh) after spec changes).
- **When (hub repo):** Any **`git`** or **`gh`** on the agent-hub git root. Parent **never** runs those CLIs **in this hub**.
- **Other repos:** Parent may run `git`/`gh` (shell hook does not block non-hub git roots). Use git-coordinator only if the user wants the hub flow; still pass **`repo_path`**.
- **Parent only:** Confirm **`repo_path`** with the user if unclear; relay choices and (if `[agent]`) a drafted commit message; surface the **Git Report**—do not re-run git or duplicate its output.
- **Coordinator spec** (params, commit/merge flows, safety, report statuses): load the subagent file when delegating—not duplicated here.

---

### Research Scout (`./Subagents/deep-document-research.md`)

**Role:** Deep documentation research, codebase exploration, API investigations, and multi-source verification.

- **When to Trigger:**
  - **External Libraries & APIs:** Investigating third-party packages, new frameworks, or APIs spanning more than 3 files or requiring external web search.
  - **Version Compatibility:** Verifying breaking changes, version dependencies, or upgrade guides (e.g., checking `package.json` or `pyproject.toml` compatibility).
  - **Deep Discovery:** Searching through long historical design docs, architectural specs, or large log files.
- **Invocation Parameters:** Provide the research objective, target local directories/URLs, and any explicit version constraints.
- **Handling Results:** Trust the returned `Research Brief` and use its code snippets and API definitions directly without re-reading the source files.

---

### Code Reviewer (`./Subagents/code-reviewer.md`)

**Role:** Adversarial security auditing, edge-case analysis, and code quality verification for diffs and staged changes.

- **When to Trigger:**
  - **Complex Logic & Refactors:** Any new feature or refactor modifying core business logic across more than 2 files.
  - **Security-Sensitive Code:** Edits involving authentication, authorization, session management, token validation, or database access layers.
  - **Pre-Commit Verification:** When preparing a pull request or the user explicitly requests a code review (repo state/diff from **Git Coordinator**, not parent shell).
- **Invocation Parameters:** Specify target files, scope (e.g. diff summary from Git Report), and any project-specific security concerns.
- **Handling Results:**
  - If the verdict is **REQUIRES CHANGES** or **CRITICAL BLOCKER**, you must address all flagged issues before finalizing your response.
  - If the verdict is **APPROVED**, proceed to complete the task.

---

### Memory Steward (`./Subagents/memory-steward.md`)

**Role:** **Write only** to Google Drive `Documents/MEMORY.md` (see [Memory rules](./memory.md)) using the [memory-management](./Skills/memory-management/SKILL.md) skill. Returns a **Memory Report**. Session context comes from the **main agent’s** session-start read—do not use this subagent to load memory at session start.

- **When to Trigger:**
  - **Explicit save:** User says “remember”, “update memory”, “save progress”, or ends a working session (`mode: write`).
  - **Milestone / preference shift:** Major feature done, bug fixed, or new standing preference—parent passes a bullet **memory delta** (`mode: write`).
- **Invocation Parameters:** `mode: write`, **memory delta** (bullets), optional one-paragraph session summary. Parent must not ask the steward to change non-memory files.
- **Handling Results:** Trust the Memory Report; do not re-read `MEMORY.md` unless the user says Drive was edited on another device.

---

### Web Researcher (`./Subagents/web-researcher.md`)

**Role:** Targeted web search for current docs, release notes, errors, and patterns. Follow the protocol in that file (source quality, date decay, compressed output).

- **When to Trigger:** Post-cutoff framework/API facts, niche errors, or comparing libraries when local docs are not enough.
- **Invocation Parameters:** Precise query, stack/version constraints, desired output shape (answer + links + snippets).
- **Handling Results:** Use returned findings directly; do not re-run the same searches in the parent context.

---

### General Delegation Protocol

- **Trigger matrix:** When a section above matches, delegate—do not do that work in the parent.
- **Read-Only default:** Research Scout, Code Reviewer, and Web Researcher do not edit the codebase. Reviewer uses coordinator diff text or `read_file`—not `git`.
- **Write exceptions:** Memory Steward → Drive `MEMORY.md` only. Git Coordinator → `git`/`gh`; file edits only per [git-merge](./Skills/git-merge/SKILL.md) after user approves a merge plan.
- **No Raw Log Dumping:** Never attempt to re-read raw logs, multi-hundred-line source code, or uncompressed search outputs that a subagent has already processed.
- **Report cap:** Same **≤80 lines** default for every specialist (see Execution & Synthesis).
