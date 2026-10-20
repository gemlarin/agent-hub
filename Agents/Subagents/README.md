# Subagents/

**Canonical specs** for hub specialists. Cursor Task types in [`.cursor/agents/`](../../.cursor/agents/) are **generated** from these files — do not treat the generated copies as source.

The parent does not open a specialist spec or [`subagents.md`](./subagents.md) to delegate. The Task prompt tells the specialist to read its own spec and `user-config.md`. Git Coordinator is the exception: Cursor already loaded that procedure, so the spec path is included only after `reload agents` or `recache agents`. [`subagents.md`](./subagents.md) is the contributor trigger matrix.

## Using the agents (users)

[Discover what Agent-hub can do for you.](https://gemlarin.github.io/blog/load-the-ai-rule-not-the-library)

You talk to the **main agent** in chat. It should spawn a specialist only when the trigger matches. You can also name the specialist yourself.

| Specialist          | Cursor type       | Say something like                                                                           | Do **not** expect it for                                                                                |
| ------------------- | ----------------- | -------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| **Git Coordinator** | `git-coordinator` | “Commit and push”, “open a PR” (in **this** hub repo)                                        | Coding, job search                                                                                      |
| **Memory Steward**  | `memory-steward`  | Mid-session autosave, “remember this”, wrap-up options                                       | Reading memory at session start (the main agent does that); other specialists must not open `MEMORY.md` |
| **Research Scout**  | `research-scout`  | “Dig through the docs/codebase for …” then pick a [follow-up](../Skills/research/options.md) | A quick web fact (use Web Researcher)                                                                   |
| **Code Reviewer**   | `code-reviewer`   | “Review this change”, “security pass on the diff”                                            | Writing the feature; topic code sweep                                                                   |
| **Code Sweeper**    | `code-sweeper`    | “Code sweep”, “sweep a11y/types”                                                             | Git-diff review (use Code Reviewer); writing the feature                                                |
| **Web Researcher**  | `web-researcher`  | “Look up the current API for …”                                                              | Job boards (use Job Finder)                                                                             |
| **Job Finder**      | `job-finder`      | “Help me find jobs”, “search Indeed”, “use Job Finder”                                       | Coding, git, docs, or a random web lookup                                                               |
| **Hub Installer**   | `hub-installer`   | “Set up the hub”, “run setup”                                                                | Everyday coding, commits, job search                                                                    |

**Job Finder only** runs if you ask for a job search or name it. The main agent must not start a job hunt on its own.

**How to request one directly**

- In chat: `Use the Job Finder` / `Use git-coordinator` (same idea for the others).
- Attach context with `@` (resume file for Job Finder, a diff for Code Reviewer).
- Cursor Task types come from `.cursor/agents/` after sync. Reload Cursor if a new specialist does not appear.

## Background specialists (users)

A **foreground** specialist holds this chat until it finishes. A **background** one starts and keeps working so you can send another request here. When it finishes, the main agent posts the report. Docs: [subagents (foreground vs background)](https://cursor.com/docs/subagents). Parallel extra requests: `/multitask` ([multi-agent](https://cursor.com/help/ai-features/multi-agent.md)). That is **not** Cursor Cloud “background agents.”

Say **“run that in the background”** if you want this chat free. Job Finder, Research Scout, Code Sweeper, and Web Researcher should already start that way. Git commits, hub setup questions, and durable-memory writes stay in the **foreground** so you can pick **Yes** / **No** / **Preview**, **Git add all**, add-before-commit **Yes** / **No**, or **Custom** / **Agent generated**, answer the installer, or see `Durable memory saved to MEMORY file`.

Stop or a new interrupting message can abort a running specialist — that is not the same as a failed search.

Skills (step-by-step procedures) are separate: [how to activate a skill](../Skills/README.md#activate-a-skill-independently-users). Job Finder **loads** [`../Skills/job-search/`](../Skills/job-search/). After matches, pick an output id, then decide on a follow-up. Research Scout **loads** [`../Skills/research/`](../Skills/research/). After a brief, pick an output id, then decide on a follow-up. Git Coordinator **loads** [`../Skills/git-merge/`](../Skills/git-merge/) and, on conflicts, the parent lists every conflicted file, then offers the active menu in [git-merge options](../Skills/git-merge/options.md). Memory Steward **loads** [`../Skills/memory-management/`](../Skills/memory-management/) and, before a write, the parent should offer [memory option ids](../Skills/memory-management/options.md). Code Sweeper **loads** [`../Skills/code-sweep/`](../Skills/code-sweep/) after you pick **Topics to run** or **Run all**.

## Git merge choices (users)

When a merge, rebase, cherry-pick, or non-fast-forward push hits conflicts, the agent lists every conflicted file first. Then pick from [`../Skills/git-merge/options.md`](../Skills/git-merge/options.md): Review in merge tool, Agent merge, Abort merge, or Return to previous menu.

## Memory write choices (users)

Mid-session, the main agent **auto-saves** viable facts in the background and prints `Durable memory saved to MEMORY file` when that finishes. You see option ids only when you ask to save, or when the session looks finished — [`../Skills/memory-management/options.md`](../Skills/memory-management/options.md): `mem-save`, `mem-skip`, `mem-prefs`, `mem-projects`, `mem-solutions`, `mem-blockers`, `mem-forget`, `mem-prune`. Specialists other than Memory Steward do not read `MEMORY.md`; the main agent passes only what that task needs.

## Code sweep topics (users)

When you want a sweep, pick **Topics to run** or **Run all** from [`../Skills/code-sweep/options.md`](../Skills/code-sweep/options.md). **Topics to run** then asks which of `aria`, `live`, `a11y`, `bugs`, `typos`, `smell`, `types`, `async`, `secrets`, `ci`, and `dod`. **Run all** uses every id. Name the app or paths. The specialist reports only; it does not edit until you ask.

## Job Finder export (users)

After matches, pick `out-chat`, `out-md`, `out-xml`, or `out-raw`. After that file or chat delivery, pick **Yes** or **No** for follow-up work. **Yes** offers `refine`, `compare`, `employers`, or `widen` — [`../Skills/job-search/options.md`](../Skills/job-search/options.md).

## Research follow-ups (users)

After Research Scout returns a brief, pick an **output** first, then decide on follow-up work — [`../Skills/research/options.md`](../Skills/research/options.md).

- Output: `out-chat`, `out-md`, `out-xml`, `out-raw` (Desktop file; not committed)
- After that delivery, **Yes** or **No**
- **Yes** tasks: `compare`, `cite`, `verify`, `versions`, `extract`, `actions`, `explain`, `gaps`, `deepen`, `timeline`, `expand`

The main agent says the steps for the task you pick, re-invokes Research Scout, and writes the file when you asked to save.

## Design

Each specialist is its own folder: the spec, a contribute README, and a gitignored `user-config.md`. The spec has YAML frontmatter (`name`, `description`, `tools`) plus the body the specialist follows. [`subagents.md`](./subagents.md) is the trigger matrix. It stays in this folder.

| Spec                                                         | Cursor `name` in [`../Setup/cursor-agents.json`](../Setup/cursor-agents.json) |
| ------------------------------------------------------------ | ----------------------------------------------------------------------------- |
| [`git-coordinator.md`](./git-coordinator/git-coordinator.md) | `git-coordinator`                                                             |
| [`memory-steward.md`](./memory-steward/memory-steward.md)    | `memory-steward`                                                              |
| [`code-reviewer.md`](./code-reviewer/code-reviewer.md)       | `code-reviewer`                                                               |
| [`web-researcher.md`](./web-researcher/web-researcher.md)    | `web-researcher`                                                              |
| [`research-scout.md`](./research-scout/research-scout.md)    | `research-scout`                                                              |
| [`code-sweeper.md`](./code-sweeper/code-sweeper.md)          | `code-sweeper`                                                                |
| [`job-finder.md`](./job-finder/job-finder.md)                | `job-finder`                                                                  |
| [`hub-installer.md`](./hub-installer/hub-installer.md)       | `hub-installer`                                                               |

Writable (`readonly: false`): Git Coordinator, Memory Steward, Job Finder (Desktop files only), Hub Installer (setup files and app pointers you named). The others are read-only (including Code Sweeper).

Reports default to **≤80 lines**. Parent agents relay user choices and **trust the report** — they must not re-run the specialist’s `git`/`gh` or re-read memory after a Memory Report.

## Local settings

Each specialist folder has `user-config.example.md`. Copy it to `user-config.md` in that same folder. The hub `.gitignore` ignores every `Agents/Subagents/**/user-config.md`.

When `user-config.md` exists, read it **after** the spec. **Additions** extend the specialist. **Overrides** replace the matching part on this machine only. A hub update does not touch `user-config.md`.

## Attach a skill to a specialist

A skill is the procedure. The specialist is who runs it. The parent does not run that procedure itself.

| Specialist      | Skill                                                                               |
| --------------- | ----------------------------------------------------------------------------------- |
| Git Coordinator | [`git-merge`](../Skills/git-merge/SKILL.md) for merge, rebase, and cherry-pick only |
| Memory Steward  | [`memory-management`](../Skills/memory-management/SKILL.md)                         |
| Research Scout  | [`research`](../Skills/research/SKILL.md)                                           |
| Code Sweeper    | [`code-sweep`](../Skills/code-sweep/SKILL.md)                                       |
| Job Finder      | [`job-search`](../Skills/job-search/SKILL.md)                                       |

Code Reviewer, Web Researcher, and Hub Installer have no skill. Their steps stay in the spec.

To attach a skill:

1. Put the procedure in `Agents/Skills/<skill>/SKILL.md`. List it in [`../Skills/SKILLS.md`](../Skills/SKILLS.md) with this specialist as the one who must load it.
2. In `Subagents/<name>/<name>.md`, add a **Required skill** section. Tell the specialist to load that `SKILL.md` before the work, then read `user-config.md` in the skill folder when it exists. Link `options.md` when the parent must offer ids. Do not paste the skill body into the spec.

   From a spec file, link the skill with a path relative to that file. Job Finder does it in [`job-finder.md`](./job-finder/job-finder.md):

   ```markdown
   ## Required skill

   Load and follow Agents/Skills/job-search/SKILL.md before searching.
   Then read Agents/Skills/job-search/user-config.md when that file exists.
   ```

3. In [`subagents.md`](./subagents.md), name that skill on the specialist's role line, and say the parent must not run it.
4. Regen `.cursor/agents/` so the generated specialist gets the same load instruction ([Contribute](#contribute)).

Two local files stay separate. `Subagents/<name>/user-config.md` extends the specialist. `Skills/<skill>/user-config.md` extends the procedure.

## Contribute

1. **Edit the spec in that specialist's folder**, not `.cursor/agents/*.md`.
2. Add or rename a specialist:
   - New folder `Subagents/<name>/<name>.md` with frontmatter `name` + `description`, plus `README.md` and `user-config.example.md`.
   - Register it in [`../Setup/cursor-agents.json`](../Setup/cursor-agents.json) (`name`, `source` path, `readonly`).
   - Add a trigger section in [`./subagents.md`](./subagents.md).
3. Regen Cursor copies from the hub root:

   ```bash
   ./Agents/Setup/scripts/install-cursor-integration.sh --force
   ```

   (`sync-cursor-agents.sh` / `sync_cursor_agents.py` is enough if you only need `.cursor/agents/`.)

4. Commit **spec + generated** `.cursor/agents/` together.
5. Do not put hub policy that belongs in `AGENTS.md` or a skill into a subagent body unless that specialist must follow it.
6. Do not commit `user-config.md`. Gitignore is already `Agents/Subagents/**/user-config.md`.
