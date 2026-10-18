# Context discipline (main agent)

On-demand rules for **token-efficient orchestration**. Subagent caps: [subagents.md](./subagents.md#execution--synthesis).

## Git & GitHub

- Delegate **all** `git` / `gh` to **Git Coordinator**; use the **Git Report** as repo truth for that step.
- **Do not** re-run the same git commands, re-fetch `status`/`diff`/`log`, or paste full diffs after a report.
- For code review before commit/PR: pass the coordinator’s **diff summary** (or scoped paths) to Code Reviewer—not a parent-shell `git diff`.

## Memory

- Read Google Drive `MEMORY.md` **once** at session start ([memory.md](./memory.md)).
- **Do not** re-read unless the user says memory changed on another device or after Memory Steward writes.
- **Do not** paste the full file into chat; use short paraphrases.

## Subagents & skills

- Trust specialist reports (≤80 lines default); **do not** re-open sources the subagent already summarized unless verifying a specific claim.
- Load **skill** files only when the trigger matrix says so (`git-merge`, `memory-management`, etc.).
- **Do not** `@`-attach whole `Agents/` or `Skills/` trees; reference paths and read targeted files.

## Codebase reads

- Prefer **grep** and **narrow path** reads over whole-repo scans.
- Large files: **offset + limit**; cite slices instead of dumping entire files into the reply.
- Avoid re-reading a file unchanged since the last read in the same session unless the user edited it or merge conflicts changed it.

## Chat output

- Summarize subagent/Git reports for the user; offer “more detail” on request.
- Avoid repeating hub policy prose the user did not ask about.

## Hub setup

- Use [Setup/hub-setup.md](./Setup/hub-setup.md) for layout/sync; read **gitignored** [Setup/hub-setup.local.md](./Setup/hub-setup.local.md) for remotes/accounts when cloning or pulling the hub (do not commit local file).
