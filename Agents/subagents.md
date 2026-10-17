# Subagents

## Subagent Delegation & Orchestration Rules

You have access to specialized subagents in your workspace. To protect your context window, prevent hallucinations, and ensure high-quality outputs, offload tasks according to the following trigger matrix.

### How to Invoke Subagents

When delegating a task, provide the subagent with a complete, self-contained prompt:

1. State the exact subagent name (`Research Scout Subagent`).
2. Pass explicit parameters (target file paths, scope, or expected output shape).
3. Specify the expected return format (e.g., "Return a Research Brief").

### Execution & Synthesis

- Do not attempt to re-read raw logs or files that a subagent already processed. Trust the returned report.
- Verify the subagent's summary against project goals before taking direct action.

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
  - **Pre-Commit Verification:** When preparing a pull request, checking a `git diff`, or when the user explicitly requests a code review.
- **Invocation Parameters:** Specify target files, scope (e.g., `git diff HEAD~1`), and any project-specific security concerns.
- **Handling Results:**
  - If the verdict is **REQUIRES CHANGES** or **CRITICAL BLOCKER**, you must address all flagged issues before finalizing your response.
  - If the verdict is **APPROVED**, proceed to complete the task.

---

### Memory Steward (`./Subagents/memory-steward.md`)

**Role:** Read and update **only** Google Drive `Documents/MEMORY.md` (see [Memory rules](./memory.md)) using the [memory-management](../Skills/memory-management/SKILL.md) skill. Returns a **Memory Brief** (read) or **Memory Report** (write). Never use a hub-local `MEMORY.md`.

- **When to Trigger:**
  - **Session start:** Parent needs cross-session context before planning (`mode: read`).
  - **Explicit save:** User says “remember”, “update memory”, “save progress”, or ends a working session (`mode: write` or `read_then_write`).
  - **Milestone / preference shift:** Major feature done, bug fixed, or new standing preference—parent passes a bullet **memory delta** (`mode: write`).
- **Invocation Parameters:** `mode`, optional **memory delta** (bullets), optional one-paragraph session summary. Parent must not ask the steward to change non-memory files.
- **Handling Results:** Use the Memory Brief as ground truth for preferences and goals; apply Memory Report changes without re-reading the full `MEMORY.md` unless verifying a conflict.

---

### Web Researcher (`./Subagents/web-researcher.md`)

**Role:** Targeted web search for current docs, release notes, errors, and patterns. Follow the protocol in that file (source quality, date decay, compressed output).

- **When to Trigger:** Post-cutoff framework/API facts, niche errors, or comparing libraries when local docs are not enough.
- **Invocation Parameters:** Precise query, stack/version constraints, desired output shape (answer + links + snippets).
- **Handling Results:** Use returned findings directly; do not re-run the same searches in the parent context.

---

### General Delegation Protocol

- **Read-Only Default:** Research Scout, Code Reviewer, and Web Researcher are read-only on the codebase.
- **Memory Steward Exception:** May write **only** Google Drive `Documents/MEMORY.md`, per the memory-management skill.
- **No Raw Log Dumping:** Never attempt to re-read raw logs, multi-hundred-line source code, or uncompressed search outputs that a subagent has already processed.
