# Skills/

Load-on-demand procedures. Index: [`SKILLS.md`](./SKILLS.md).

These folders live under **`Agents/Skills/`** (hub policy). That is **not** the same as Cursor’s auto-discovered skill dirs (`.cursor/skills/`, `~/.cursor/skills/`).

## Activate a skill independently (users)

Cursor will not list these under `/` until they also exist in a discovered skill directory. To run **one** hub skill on purpose:

1. **Name it in Agent chat** (simplest):

   ```text
   Use the Job Finder.
   Use the job-search skill.
   Follow Agents/Skills/job-search/SKILL.md
   ```

   Same pattern for `memory-management`, `git-merge`, or `code-sweep` if you really want that procedure in this chat.

2. **@-attach the file:** in the chat input, `@` → `Agents/Skills/job-search/SKILL.md` (or another `SKILL.md`), then send your request. That forces the agent to read that skill.

3. **Cursor `/` menu** (optional): Cursor only discovers skills from `.cursor/skills/`, `.agents/skills/`, or `~/.cursor/skills/`. Copy or symlink a hub skill there if you want `/job-search` in the picker. Type `/`, choose the skill, **Enter** = this message only. **Option+Enter** (Mac) or **Alt+Enter** (Windows) = keep it on for the session (Custom Mode).

Skills with `disable-model-invocation: true` never auto-apply; they only run when you name them or invoke `/`. Hub skills without that flag may still load when your prompt matches the skill **description** (see [`SKILLS.md`](./SKILLS.md)).

Do **not** put a resume or job-result file in this repo. `git-merge` is for Git Coordinator; `memory-management` is for Memory Steward writes; `code-sweep` is for Code Sweeper.

## Design

```
Skills/
├── SKILLS.md                 # Index: when to load which skill
└── <skill-name>/
    ├── SKILL.md              # Frontmatter + instructions
    └── options.md            # User-facing ids the parent offers
```

Optional later: `reference.md`, `examples.md`, `scripts/` beside `SKILL.md`.

| Skill | Who must load it | Trigger |
|-------|------------------|---------|
| [`memory-management/`](./memory-management/) | Memory Steward (writes); parent auto-saves mid-session | Viable durable facts (auto); option menu on wrap-up or explicit save ([option list](./memory-management/options.md)) |
| [`git-merge/`](./git-merge/) | Git Coordinator | Merge, pull-that-merges, rebase, cherry-pick, conflicts ([option list](./git-merge/options.md)) |
| [`job-search/`](./job-search/) | Job Finder | Resume-matched job openings (only if the user asked) |
| [`research/`](./research/) | Research Scout | Brief + follow-ups + output formats ([option list](./research/options.md)) |
| [`code-sweep/`](./code-sweep/) | Code Sweeper | Topic-limited a11y/quality sweep ([option list](./code-sweep/options.md)) |

[`SKILLS.md`](./SKILLS.md) is the index. Orchestration paths live in [`../memory.md`](../memory.md) and [`../subagents.md`](../subagents.md), not duplicated as a second trigger matrix here.

## Contribute

1. New skill: folder + `SKILL.md` with YAML `name` and a **description that states when to use it**.
2. List it in [`SKILLS.md`](./SKILLS.md).
3. Point the owner (subagent or parent) at the skill from [`../subagents.md`](../subagents.md) or [`../memory.md`](../memory.md).
4. Keep capture/security rules in the skill; keep **file path** config in `hub-setup.local.md` / `memory.md`. User-facing ids live in that skill’s `options.md`.
5. Do not instruct the parent to run `git`/`gh` in this hub — that stays Git Coordinator (+ git-merge when needed).
