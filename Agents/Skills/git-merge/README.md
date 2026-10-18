# git-merge

**What:** Merge / rebase / cherry-pick / conflict protocol for the **Git Coordinator** only.

**Source:** [`SKILL.md`](./SKILL.md). User choices: [`options.md`](./options.md). **When:** [`../../subagents.md`](../../subagents.md) (Git Coordinator).

## Design

The parent never runs `git` in this hub. The coordinator loads this skill **before** any merge-class operation and before resolving conflicts. After `AWAIT_MERGE_APPROVAL`, the parent **offers option ids** (`approve`, `decline`, `ours`, `theirs`, `detail`, `revise`). Decline aborts.

## Contribute

- Edit [`SKILL.md`](./SKILL.md) for the conflict/approval/abort flow.
- Add or rename a user id in [`options.md`](./options.md) **and** the matching step in [`SKILL.md`](./SKILL.md).
- Keep `repo_path` mandatory and reports on the Git Report shape in [`../../Subagents/git-coordinator.md`](../../Subagents/git-coordinator.md).
- Do not add parent-shell git instructions here.
