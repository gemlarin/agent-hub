# job-search

**What:** Resume-matched job search across public boards, ranked, saved to the Desktop.

**Source:** [`SKILL.md`](./SKILL.md). Boards: [`boards.md`](./boards.md) (defaults) or gitignored `boards.local.md` (yours; start from [`boards.local.example.md`](./boards.local.example.md)). Export ids: [`options.md`](./options.md). File shapes: [`output.md`](./output.md).

## Design

**Job Finder** loads this skill when the user asks for a job search. It collects resume + filters first, searches public pages only (no logins), ranks by resume fit, then offers the same export ids as research: `out-chat`, `out-md`, `out-xml`, `out-raw`.

The parent must not run this skill unless Job Finder is unavailable. Do not commit resumes or result files to the hub.

## Contribute

- Edit [`SKILL.md`](./SKILL.md) for the interview/search/rank/save flow.
- Edit [`boards.md`](./boards.md) to change the shared default boards. For a personal list, copy [`boards.local.example.md`](./boards.local.example.md) to `boards.local.md` (gitignored). Set **On** to `yes` or `no`, or add and delete rows. Do not hardcode board names in `SKILL.md`.
- Edit [`options.md`](./options.md) / [`output.md`](./output.md) for export ids and Desktop schemas. Keep ids aligned with [`../research/options.md`](../research/options.md).
- Keep the skill listed in [`../SKILLS.md`](../SKILLS.md).
- Do not commit `user-config.md`. Personal search steps go there. Personal boards stay in `boards.local.md`.

## Local settings

Copy [`user-config.example.md`](./user-config.example.md) to `user-config.md`. That file stays on your machine and extends this skill. Copy [`boards.local.example.md`](./boards.local.example.md) to `boards.local.md` when you want your own board table. Both files are gitignored.
