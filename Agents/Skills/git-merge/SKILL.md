---
name: git-merge
description: Detect merge/rebase/cherry-pick conflicts, list conflicted files, and resolve only after the user picks a merge option. Abort restores the pre-merge state.
tools: [shell, read_file, write_file, edit_file]
---

# Skill: Git merge & conflict resolution

**This machine:** After this file, read `user-config.md` in this folder when it exists. Additions extend the skill. Overrides replace the matching part on this machine only. Never commit that file. Copy [user-config.example.md](./user-config.example.md) to create it.

Use this skill when the Git Coordinator handles **`git merge`**, **`git pull`** (merge or rebase), **`git rebase`**, or **`git cherry-pick`**, when a push is not a fast-forward, or when the repo is already conflicted from those operations.

User-facing ids: [`options.md`](./options.md). The **main agent** relays those ids. The **coordinator** runs all git commands and reads conflicted files.

A conflict marker is a line that begins with `<<<<<<<`, `=======`, or `>>>>>>>`.

---

## 1. Before starting a merge-class operation

1. Confirm `repo_path` and record **pre-state**: `git status -sb`, current branch, `HEAD` hash, and whether a merge, rebase, or cherry-pick is already in progress.
2. If the user did not name a target, and this is not a push that needs the upstream branch, return **`NEED_INPUT`**. Do not merge.
3. Do not force-push. A non-fast-forward push is a merge question, not a force-push.
4. When a push needs a merge, preview conflicts without changing the worktree when `git merge-tree` can do that. Return **`Git Report: AWAIT_MERGE_MANAGE`**. The parent asks **Yes** / **No**: should the agent manage the merge? Include every path the preview says will conflict. If no preview is available, say a merge is required and conflicts are possible.
5. **No:** stop. Do not pull, merge, or push.
6. **Yes:** run the merge (`git pull` or `git merge` of the upstream branch, unless they named another target). A clean fast-forward or a clean merge commit is **SUCCESS**. Then continue the push that started this, if one is still requested.

---

## 2. Detect conflicts

When git exits non-zero or status shows unmerged paths:

1. `git diff --name-only --diff-filter=U` and `git status --porcelain`.
2. Build the full conflicted file list. Never truncate it.
3. For each file, note ours vs theirs and whether the file is text, binary, a lockfile, a migration, or generated.

Return **`Git Report: AWAIT_MERGE_APPROVAL`** with `menu: conflict`. Put the file list in the report before any resolution. Do not edit files yet.

The parent shows that list, then the conflict menu from [`options.md`](./options.md).

---

## 3. Review in merge tool

On **`mergetool`**:

1. Read the user's merge tool with `git config --get merge.tool`. If it is unset, or launching it fails, say the merge tool cannot be opened. Stay on `menu: conflict`. Do not pretend it opened.
2. If it opens, wait for the user to finish. Then return `menu: mergetool`.

On **`retry`**:

1. Recheck every conflicted path and the index (`git ls-files -u`) for conflict markers and unmerged entries.
2. If the user already completed the merge, recheck those files anyway. Markers mean it is not complete.
3. If the tree is clean of markers and unmerged entries, stage the resolved paths and complete the merge, rebase, or cherry-pick if git has not already completed it. Return **SUCCESS**. If a push is still requested, continue that push.
4. If any marker or unmerged entry remains, do not commit and do not continue. Name the files. Return `menu: autofix`.

On **`back`** from this submenu, return `menu: conflict`.

---

## 4. Agent merge

On **`agent-merge`**, the agent may edit the conflicted files.

Resolve a hunk without asking when the outcome is clear: both sides match, one side deleted an untouched file, or a lockfile should be regenerated. Say what was done. For a lockfile, prefer regenerating it and say so.

When a hunk is not clear, stop. Return `menu: hunk` with that file path and the conflicted code. The parent offers **Keep ours**, **Accept incoming**, **Keep both**, and **Agent suggestion**.

- **Keep ours** / **Accept incoming:** take that side and remove the markers.
- **Keep both:** keep both text sides, in a working order, with the markers removed. Do not offer this for a binary file. Offer **Keep ours**, **Accept incoming**, then **Abort merge** last.
- **Agent suggestion:** choose a resolution, apply it, and say what changed.

Then continue with the next unsure hunk. After the last file, run the same marker check as **Retry merge**. Complete the merge only when that check is clean.

---

## 5. Auto-fix remaining markers

On **Yes** from `menu: autofix`, resolve only the files that still have markers or unmerged entries, using **Agent merge**. Recheck. If markers remain, do not commit. Name the files and return `menu: conflict`.

On **No**, do not commit. Return `menu: conflict`.

---

## 6. Abort

On **`abort`**, **`decline`**, or **`decline_merge_plan`**:

| State | Command |
|--------|---------|
| Merge | `git merge --abort` |
| Rebase | `git rebase --abort` |
| Cherry-pick | `git cherry-pick --abort` |

Confirm `git status -sb` has no unmerged paths and matches the recorded pre-state. Return **`Git Report: MERGE_ABORTED`**. Do not leave conflict markers in the tree.

**`back`** on the conflict menu does not abort. The merge stays in progress until **Abort merge**.

---

## 7. Safety

- Do not commit, continue a rebase, or push while any conflict marker or unmerged index entry remains.
- No force-push to `main` or `master` to finish a merge.
- Do not delete branches unless the user approved that in this thread.
- Do not edit files until the user picks **Review in merge tool**, **Agent merge**, **Retry merge**, **Yes** on auto-fix, or a hunk choice.

## 8. Parent

Relay the id for the active menu. Do not run `git` in the parent on this hub. Re-invoke the same Git Coordinator with `user_choice` set to that id.
