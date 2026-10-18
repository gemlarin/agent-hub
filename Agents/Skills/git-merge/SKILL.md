---
name: git-merge
description: Detect merge/rebase/cherry-pick conflicts, summarize conflicted paths, recommend resolutions, and execute only after user approval via the main agent. Abort and restore pre-merge state on decline.
tools: [shell, read_file, write_file, edit_file]
---

# Skill: Git merge & conflict resolution

Use this skill when the Git Coordinator handles **`git merge`**, **`git pull`** (merge or rebase), **`git rebase`**, or **`git cherry-pick`**, or when the repo is already in a conflicted state from those operations.

User-facing ids: [`options.md`](./options.md). The **main agent** relays those ids. The **coordinator** runs all git commands and reads conflicted files.

---

## 1. Before starting a merge-class operation

1. Confirm `repo_path` and record **pre-state**: `git status -sb`, current branch, `HEAD` hash, and whether a merge/rebase/cherry-pick is already in progress.
2. If the user did not name branches/targets, return **`NEED_INPUT`** via Git Report; do not merge.
3. Run the requested operation (e.g. `git pull`, `git merge <branch>`). If **fast-forward** with no conflict, report **SUCCESS** and skip conflict sections.

---

## 2. Detect conflicts

When git exits non-zero or status shows unmerged paths:

1. `git status --porcelain` and `git diff --name-only --diff-filter=U`.
2. Build the **conflicted file list** (unique paths, sorted).
3. For each file (or a representative subset if >15 files), read conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`) and note:
   - **Sides:** ours vs theirs (branch names from `git log` / merge message if available).
   - **Nature:** e.g. both modified same lines, deleted vs modified, binary, rename.

---

## 3. Present plan (stop — do not resolve yet)

Return **`Git Report: AWAIT_MERGE_APPROVAL`** to the parent with:

### Conflicted files

- Bulleted list of every path in conflict.

### Conflict summary

- Per file (or grouped): 1–3 sentences on what disagrees (no full-file paste unless small).

### Recommendation

- Concrete resolution per file or group: keep ours, keep theirs, manual merge strategy, or edit instructions.
- Call out risky files (lockfiles, migrations, generated code, CI config).
- State any follow-up commands (`git add`, `git rebase --continue`, `git commit` for merge commit).

### User choices (parent must relay)

Offer the ids in [`options.md`](./options.md). Map aliases `approve_merge_plan` → `approve`, `decline_merge_plan` → `decline`.

Do **not** edit conflicted files or `git add` until `approve`, `ours`, `theirs`, or `revise`.

---

## 4. On `approve` / `ours` / `theirs` / `revise`

1. Apply resolutions:
   - **`approve`** — the recommendation exactly.
   - **`ours` / `theirs`** — `git checkout --ours/--theirs` on remaining conflicted paths, or only the paths the user named.
   - **`revise`** — the user’s alternate plan (treat the rest of their message as the plan). If it is still ambiguous, `NEED_INPUT`.
2. `git add` resolved paths; verify `git diff --check` and no remaining `<<<<<<<`.
3. Continue the operation:
   - **Merge:** complete merge commit if needed.
   - **Rebase:** `git rebase --continue` (repeat skill from §2 if new conflicts).
   - **Cherry-pick:** `git cherry-pick --continue`.
4. Return **`Git Report: SUCCESS`** with final status, commit hash(es), and brief summary.

On **`detail`:** return hunks for the named path only; stay **`AWAIT_MERGE_APPROVAL`** and offer [`options.md`](./options.md) again. Do not resolve.

If the choice is missing or unknown, return **`NEED_INPUT`** with the option table instead of guessing.

---

## 5. On `decline`

Run the correct abort for the in-progress operation:

| State | Command |
|--------|---------|
| Merge | `git merge --abort` |
| Rebase | `git rebase --abort` |
| Cherry-pick | `git cherry-pick --abort` |

If unsure, prefer abort that matches `git status` (e.g. “rebase in progress”). Then confirm:

- `git status -sb` is clean or matches **pre-state** intent (no unmerged paths).
- Return **`Git Report: MERGE_ABORTED`** with what was aborted and current branch/HEAD.

Do not leave conflict markers in the working tree after abort.

---

## 6. Pull with merge

Treat **`git pull`** that stops with conflicts the same as **merge**: summarize, recommend, await approval, or abort on decline (`git merge --abort` when pull used merge; use **git-merge** rebase abort rules if `pull --rebase`).

---

## 7. Safety

- No force-push to `main`/`master` as part of “finishing” a merge.
- Do not delete branches unless the user approved in this thread.
- Lockfile conflicts: recommend regenerating from the preferred package manager when in doubt, and say so in the recommendation.

## 8. Parent

- After `AWAIT_MERGE_APPROVAL`, list the **ids** from [`options.md`](./options.md) unless the user already picked.
- Re-invoke Git Coordinator with `user_choice` set to that id. Do not run `git` in the parent on this hub.
