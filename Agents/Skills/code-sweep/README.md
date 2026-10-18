# code-sweep

**What:** Topic-limited accessibility and quality sweep of named paths (ARIA, a11y, bugs, types, DoD, …).

**Source:** [`SKILL.md`](./SKILL.md). Topic menu: [`options.md`](./options.md). **When:** [`../../Subagents/subagents.md`](../../Subagents/subagents.md) (Code Sweeper).

## Design

**Code Sweeper** loads this skill. The parent offers topic ids, then delegates. Sweeper is **read-only** and reports only the topics the user named. It is not Code Reviewer (git-diff / security) and not a drive-by rewrite.

Change Control still applies: findings are suggestions until the user asks to fix.

## Contribute

- Add or rename a topic id in [`options.md`](./options.md) **and** the matching row in [`SKILL.md`](./SKILL.md). Keep the menu aligned with the Code sweep section in [`../../Rules/coding-standards/coding-standards.md`](../../Rules/coding-standards/coding-standards.md).
- Keep the skill listed in [`../SKILLS.md`](../SKILLS.md).
- Do not teach the parent to grep the whole app when a Sweep Report exists.
- Do not commit `user-config.md`.

## Local settings

Copy [`user-config.example.md`](./user-config.example.md) to `user-config.md`. That file stays on your machine. Additions extend this skill. Overrides replace the matching part for you only.
