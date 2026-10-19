# git-merge

**What:** Merge / rebase / cherry-pick / conflict protocol for the **Git Coordinator** only.

**Source:** [`SKILL.md`](./SKILL.md). User choices: [`options.md`](./options.md). **When:** [`../../Subagents/subagents.md`](../../Subagents/subagents.md) (Git Coordinator).

## Design

The parent never runs `git` in this hub. The coordinator loads this skill **before** any merge-class operation and before resolving conflicts. It lists every conflicted file first. The parent then offers the active menu in [`options.md`](./options.md): manage the merge, the conflict menu, the merge tool, an unsure hunk, or auto-fix. **Abort merge** restores the pre-merge state.

## Contribute

- Edit [`SKILL.md`](./SKILL.md) for the conflict/approval/abort flow.
- Add or rename a user id in [`options.md`](./options.md) **and** the matching step in [`SKILL.md`](./SKILL.md).
- Keep `repo_path` mandatory and reports on the Git Report shape in [`../../Subagents/git-coordinator/git-coordinator.md`](../../Subagents/git-coordinator/git-coordinator.md).
- Do not add parent-shell git instructions here.
- Do not commit `user-config.md`.

## Local settings

Copy [`user-config.example.md`](./user-config.example.md) to `user-config.md`. That file stays on your machine. Additions extend this skill. Overrides replace the matching part for you only.
