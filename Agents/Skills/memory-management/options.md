# Memory write options

Show this list **only** when (1) the user asked to remember / save / update memory, or (2) the session looks finished. Call the host question control first. The choices are in this file. Do not open the interactive-inputs catalog. Number it only if that control is absent or the call fails. During the session, do **not** show these ids — auto-write viable facts with `mem-save` (see [`SKILL.md`](./SKILL.md) §5).

Show the **proposed bullets** with the ids. User replies with an **id** or the prompt.

| Id | Say this | Result |
|----|----------|--------|
| `mem-save` | “Remember this” / “save it” | Approve pending proposals |
| `mem-skip` | “Don’t save” | No controller call |
| `mem-prefs` | “Save as a preference” | Approve `preference` only |
| `mem-projects` | “Save as a project/goal” | Approve `decision` only |
| `mem-solutions` | “Save as a workaround/convention” | Approve `technical_context` only |
| `mem-blockers` | “Save as an open blocker” | Approve `blocker` only |
| `mem-forget` | “Forget …” / “remove that” | Controller `forget` |
| `mem-prune` | “Just clean it up” | No new approve; prune on commit |

Default if they already said “remember” / “save to memory” / “save session” and skip the menu: **`mem-save`**. Skipping the **session-end** menu = **`mem-skip`**.

After **any** successful write (auto or user-chosen), the parent prints exactly:

`Durable memory saved to MEMORY file`

Keep `MEMORY.md` within **Memory max lines** in `Agents/Settings/CONFIG.md`. The controller writes. Never commit `MEMORY.md`. Never dump the full file into chat. Capture rules: [`SKILL.md`](./SKILL.md).
