# Git delegation (parent menus)

Read this file only when the user message is a `git` or `gh` command. Do not open it on any other prompt.

**This machine:** After this file, read `user-config.md` in this folder when it exists. Additions extend the rule. Overrides replace the matching part on this machine only. Never commit that file. Copy [user-config.example.md](./user-config.example.md) to create it.

The parent does not run `git` or `gh` in this hub repo. Delegate to **git-coordinator**. Do not open `subagents.md` or `git-coordinator.md`. Cursor already loads the Git Coordinator procedure. The Task prompt does not tell Git Coordinator to read that file again. It tells Git Coordinator to read `user-config.md` in that folder when the file exists. After `reload agents` or `recache agents`, the next git Task tells Git Coordinator to read `Agents/Subagents/git-coordinator/git-coordinator.md` once. Later git Tasks skip that read until the next reload or recache.

- Offer each closed git choice as one interactive choice. The choices are in this file and, for a merge, in `Agents/Skills/git-merge/options.md`. Do not open the interactive-inputs catalog. A typed id still counts. Paths, a commit message, and a custom merge plan stay typed.
- Git commands start with **`git`** (`git add`, `git commit`, `git push`, `git auto push`). If the user says `add`, `commit`, `push`, or another git verb without `git`, offer **Yes** / **No**. **Yes** runs Git Coordinator for `git <keyword>`. **No** stops. Tell them to start with `git` next time. Do not run until they pick **Yes**.
- **`git auto push`:** offer **Yes**, **No**, **Preview**. The question is `about to add, commit and push all modified files to current repo. Are you sure?`
- **`git add`**, and **`git commit`** with nothing staged: list each file and a one-line summary, in this repo and in sibling apps. Offer **Git add all**. A typed `git add all` still counts. Named paths stay typed. A sentence that describes the work is not that approval.
- **`git push`:** if any file is unstaged, ask **Yes** / **No** to add those files before the commit. **Yes** stages them, then the message choice, then the commit. **No** leaves them unstaged. Named paths stay typed. Then check whether the push is a fast-forward. A non-fast-forward push asks **Yes** / **No** to manage the merge. **No** stops. **Yes** uses the git-merge skill. Do not force-push.
- **Commit message:** offer **Custom** and **Agent generated**. The message text stays typed.
- **Merge:** list every conflicted file, then offer the active menu in `Agents/Skills/git-merge/options.md`. **Abort merge** restores the pre-merge state.
- In **any other git repo** (sibling app, unrelated clone), the parent **may** run `git`/`gh`. The shell hook does not block those roots. The same push and merge choices apply. Do not stage unstaged files until they pick **Yes** or name the paths. Optional: use git-coordinator with `repo_path`.
