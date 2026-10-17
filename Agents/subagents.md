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

### Web Researcher (`./Subagents/web-researcher.md` or Direct Protocol)

**Role:** Performing targeted, high-precision web queries to find current documentation, release notes, error resolutions, or architectural patterns.

- **When to Trigger:**
  - **Current & Real-Time Data:** Looking up recent API deprecations, framework updates released after your training cutoff, or live status pages/issues.
  - **External Solution Discovery:** Searching for niche error codes, stack trace resolutions, or community-vetted best practices when local docs are insufficient.
  - **Ecosystem Benchmarking:** Comparing competing libraries, package version matrices, or architectural patterns across different tech stacks.

- **Source Quality & Credibility Rules:**
  - **Prioritize Official Sources:** Always prefer official vendor documentation (e.g., `docs.python.org`, `react.dev`), GitHub repositories/releases, and primary maintainer blogs over secondary content farms.
  - **Watch for Date Decay:** Filter out or cross-reference forum posts, Stack Overflow answers, or tutorials older than 2–3 years for fast-moving ecosystems (e.g., JavaScript/TypeScript tooling, cloud infrastructure).
  - **Cross-Verification:** For critical architectural or security-related queries, verify findings across at least two independent authoritative sources.

- **Output Compression (Anti-Noise):**
  - Discard SEO filler, marketing fluff, and repetitive tutorial introductions.
  - Extract only the core facts, code snippets, version requirements, or configuration options relevant to the user's specific context.

---

### General Delegation Protocol

- **Read-Only Scope:** Both subagents operate in a read-only capacity. They analyze and report; they never write or modify project files directly.
- **No Raw Log Dumping:** Never attempt to re-read raw logs, multi-hundred-line source code, or uncompressed search outputs that a subagent has already processed.
