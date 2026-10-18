# Context discipline (main agent)

On-demand rules for **token-efficient orchestration**. Subagent caps: [subagents.md](../../subagents.md#execution--synthesis).

**This machine:** After this file, read `user-config.md` in this folder when it exists. Additions extend the rule. Overrides replace the matching part on this machine only. Never commit that file. Copy [user-config.example.md](./user-config.example.md) to create it.

## Git & GitHub

- Delegate **all** `git` / `gh` to **Git Coordinator**; use the **Git Report** as repo truth for that step.
- **Resume** the same coordinator agent id for `[continue]` / `[more]` / `[custom]` / `[agent]` / merge ids. Do not cold-start a new Task per click.
- **Do not** re-run the same git commands, re-fetch `status`/`diff`/`log`, or paste full diffs after a report.
- For code review before commit/PR: pass the coordinator’s **diff summary** (or scoped paths) to Code Reviewer—not a parent-shell `git diff`.
- For a **code sweep**: offer [topic ids](../../Skills/code-sweep/options.md), then delegate to **Code Sweeper**. Do not grep the app in the parent.

## Memory

- Resolve the path from `Setup/hub-setup.local.md`, then read that `MEMORY.md` **once** at session start ([memory.md](../../memory.md)). Keep the file **lean** (target ≤80 lines) so that read stays cheap.
- **Do not** re-read unless the user says memory changed on another device or after Memory Steward writes.
- **Do not** paste the full file into chat; use short paraphrases.
- **Auto-write** viable durable facts mid-session in the **background** (`mem-save` + `memory_path`). Do not block this chat on Drive I/O. Print `Durable memory saved to MEMORY file` when SUCCESS arrives. Show [option ids](../../Skills/memory-management/options.md) only on explicit save or session wrap-up ([memory.md](../../memory.md#auto-save-vs-option-menu)).
- **Subagents** do not read `MEMORY.md`. Pass **`related_memory`** (task-relevant bullets only) in the specialist prompt.

## Subagents & skills

- Trust specialist reports (≤80 lines default); **do not** re-open sources the subagent already summarized unless verifying a specific claim.
- Long I/O specialists (Job Finder, Research Scout, Code Sweeper, Web Researcher, Memory Steward) run in the **background** by default ([subagents.md](../../subagents.md#background-vs-foreground)). Do not poll them; relay the report when it arrives.
- Load **skill** files only when the trigger matrix says so (`git-merge`, `memory-management`, etc.).
- **Do not** `@`-attach whole `Agents/` trees; reference paths and read targeted files.

## Codebase reads

- Prefer **grep** and **narrow path** reads over whole-repo scans.
- Large files: **offset + limit**; cite slices instead of dumping entire files into the reply.
- Avoid re-reading a file unchanged since the last read in the same session unless the user edited it or merge conflicts changed it.

## Chat output

- Summarize subagent/Git reports for the user; offer “more detail” on request.
- Avoid repeating hub policy prose the user did not ask about.

## Hub setup

- Humans: [README.md](../../../README.md). First run: [Setup/scripts/setup.sh](../../Setup/scripts/setup.sh) (Windows: `setup.cmd`), or say **set up the hub**. Layout/troubleshooting: [Setup/hub-setup.md](../../Setup/hub-setup.md). Read **gitignored** [Setup/hub-setup.local.md](../../Setup/hub-setup.local.md) for remotes/accounts (do not commit local file).
