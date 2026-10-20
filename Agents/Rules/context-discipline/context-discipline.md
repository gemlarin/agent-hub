# Context discipline (main agent)

On-demand rules for **token-efficient orchestration**. Specialist reports stay ≤80 lines unless the user asks for detail.

**This machine:** After this file, read `user-config.md` in this folder when it exists. Additions extend the rule. Overrides replace the matching part on this machine only. Never commit that file. Copy [user-config.example.md](./user-config.example.md) to create it.

## Git & GitHub

- Delegate **all** `git` / `gh` to **Git Coordinator**; use the **Git Report** as repo truth for that step.
- **Resume** the same coordinator agent id for `Yes` / `No` / `Preview`, add-before-commit **Yes** / **No**, **Custom** / **Agent generated**, and merge-menu ids. Do not cold-start a new Task per click. Offer each of those as one interactive choice.
- **Do not** re-run the same git commands, re-fetch `status`/`diff`/`log`, or paste full diffs after a report.
- For code review before commit/PR: pass the coordinator’s **diff summary** (or scoped paths) to Code Reviewer—not a parent-shell `git diff`.
- For a **code sweep**: offer [topic ids](../../Skills/code-sweep/options.md), then delegate to **Code Sweeper**. Do not grep the app in the parent.

## Memory

- Resolve **MEMORY.md path** and **Memory max lines** from `Settings/CONFIG.md`, then read that `MEMORY.md` **once** at session start ([memory.md](../../Memory/memory.md)). Pass both values on a memory write. The steward prunes to the configured line cap.
- **Do not** re-read unless the user says memory changed on another device or after Memory Steward writes.
- **Do not** paste the full file into chat; use short paraphrases.
- **Auto-write** viable durable facts mid-session in the **background** (`mem-save` + `memory_path`). Do not block this chat on Drive I/O. Print `Durable memory saved to MEMORY file` when SUCCESS arrives. Show [option ids](../../Skills/memory-management/options.md) only on explicit save or session wrap-up ([memory.md](../../Memory/memory.md#auto-save-vs-option-menu)).
- **Subagents** do not read `MEMORY.md`. Pass **`related_memory`** (task-relevant bullets only) in the specialist prompt.

## Stable prefix

The host can cache the opening of a prompt when that opening is the same on the next turn.

- Do not write session facts, memory bullets, or `user-config.md` into `AGENTS.md` or the always-on stubs.
- Read `user-config.md` after the shared file.
- A Task prompt is ordered: specialist name, spec path, `user-config.md` path, parameters, then `related_memory`, then the user request.

## Subagents & skills

- Parent does not open `Subagents/subagents.md` or a specialist spec, including when a User Rule lists those paths. The Task prompt names that path and tells the specialist to read it, then `user-config.md` in that folder.
- Trust specialist reports (≤80 lines default); **do not** re-open sources the subagent already summarized unless verifying a specific claim.
- Long I/O specialists (Job Finder, Research Scout, Code Sweeper, Web Researcher, Memory Steward) run in the **background**. Git Coordinator, Hub Installer, and a review that gates a commit stay in the **foreground**. Do not poll a background specialist; relay the report when it arrives.
- Load **skill** files only when the trigger matrix says so (`git-merge`, `memory-management`, etc.). After `SKILL.md`, read `user-config.md` in that folder when it exists. Additions extend the skill. Overrides replace the matching part on this machine only.
- **Do not** `@`-attach whole `Agents/` trees; reference paths and read targeted files.

## Codebase reads

- Read the load table once at session start (`Agents/AGENTS.md`, or the file the app pointer names). Do not open it again this session unless it was edited. If a compaction or conversation summary replaced earlier turns and the load-table rows are not in that summary, open it once more, then stop. This applies in Cursor and Claude. If the user says `reload agents` or `recache agents`, re-read that file and any hub behavior file already opened this session, then stop again.
- Prefer **grep** and **narrow path** reads over whole-repo scans.
- Large files: **offset + limit**; cite slices instead of dumping entire files into the reply.
- Avoid re-reading a file unchanged since the last read in the same session unless the user edited it or merge conflicts changed it.

## Chat output

- Summarize subagent/Git reports for the user; offer “more detail” on request.
- Avoid repeating hub policy prose the user did not ask about.

## Hub setup

- Humans: [README.md](../../../README.md). First run: [Setup/scripts/setup.sh](../../Setup/scripts/setup.sh) (Windows: `setup.cmd`), or say **set up the hub**. Layout/troubleshooting: [Setup/hub-setup.md](../../Setup/hub-setup.md). Read **gitignored** [Setup/hub-setup.local.md](../../Setup/hub-setup.local.md) for remotes/accounts (do not commit local file).
