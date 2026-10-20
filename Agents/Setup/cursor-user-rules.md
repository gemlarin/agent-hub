# Cursor User Rules — align with agent hub

**Cursor only.** Skip this file if you do not use Cursor, or if your User Rules do **not** tell the parent to run `git`/`gh` (clone already ships `.cursor/rules/git-delegation.mdc`). Paste the blocks below **only when** Cursor’s default `<committing-changes-with-git>` / `<creating-pull-requests>` rules would make the parent run git in this hub.

**User Rules** are account-level (not in this repo). **Where to edit (macOS):**

1. **⌘⇧J** → **Rules** tab → **User Rules** → add or edit text, or  
2. Sidebar **Customize** → **Rules** → **User Rules**

Not under **⌘,** (editor settings) and not **General → Rules for AI** (old UI). **New Cursor Rule** in the palette creates **project** rules (`.cursor/rules/`), not User Rules.

First-run: `./Agents/Setup/scripts/setup.sh` (or `bootstrap.sh` when nothing is left to ask). This paste is the leftover Cursor step the installer cannot do.

Replace or merge the blocks below so they match **AGENTS.md** and **git-coordinator**. Project rules: `.cursor/rules/git-delegation.mdc` in the hub.

---

## 1. Replace `<committing-changes-with-git>`

Copy everything inside the tag into your User Rules (replace the old block).

```xml
<committing-changes-with-git>
Only create commits when requested by the user. If unclear, ask first.

## Git delegation (required **in the agent-hub repo only**)

You are the **parent agent**.

- **Agent-hub git root** (folder with hub `Agents/AGENTS.md` / `.cursor/hooks/`): do **not** run `git` or `gh`. Delegate to **git-coordinator** (`subagent_type: git-coordinator`). Pass **`repo_path`**. Relay `Yes` / `No` / `Preview`, add-before-commit **Yes** / **No**, **Custom** / **Agent generated**, and merge-menu ids as one interactive choice each. **Resume** the same coordinator agent id for those relays (do not spawn a new Task unless the last run aborted). Trust the **Git Report**; do not re-run those commands.
- Git commands start with **`git`**. If the user says `add`, `commit`, `push`, or another git verb without `git`, offer **Yes** / **No**. **Yes** runs Git Coordinator for `git <keyword>`. **No** stops. Tell them to start with `git` next time. Do not run until they pick **Yes**.
- **Any other git repo** (sibling app, unrelated clone, no hub hooks): you **may** run `git`/`gh` in the parent shell. Do not treat User Rules as a global git ban. The same push and merge choices apply. Do not stage unstaged files until they pick **Yes** or name the paths. Optional: use git-coordinator with `repo_path`.
- Do not open `subagents.md` or `git-coordinator.md` in the parent. The Task prompt tells git-coordinator to read `Agents/Subagents/git-coordinator/git-coordinator.md` and `user-config.md` in that folder.

## When the user asks to commit

The command is **`git commit`**, **`git add`**, **`git push`**, or **`git auto push`**.

1. **`git auto push`:** offer **Yes**, **No**, **Preview** as one interactive choice. The question is `about to add, commit and push all modified files to current repo. Are you sure?` Preview lists the files. **Yes** drafts the message from the Git Report and has the coordinator add, commit, and push the current branch.
2. **`git add`:** list each changed file and a one-line summary. Offer **Git add all** as one interactive choice. A typed `git add all` still counts. Named paths stay typed.
3. **`git commit`:** if nothing is staged, start **`git add`** in every repo, including sibling apps. List each file and a one-line summary. Wait for **Git add all** or named paths. A sentence that describes the work is not that approval. If something is staged, offer **Custom** and **Agent generated** as one interactive choice. The message text stays typed. If they pick **Agent generated**, draft the message from the coordinator’s diff summary and send it on the next invocation as `commit_message`.
4. **`git push`:** if any file is unstaged, offer **Yes** / **No**: add those files before the commit? **Yes** stages them, then the message choice, then the commit. **No** leaves them unstaged. Named paths stay typed. A non-fast-forward push offers **Yes** / **No** to manage the merge. **No** stops. **Yes** uses the git-merge skill. Do not force-push.
5. **Merge:** list every conflicted file, then offer the active menu in `Agents/Skills/git-merge/options.md`. **Abort merge** restores the pre-merge state.
6. Invoke **git-coordinator** with `repo_path` and `user_authorized: true`. Do **not** run `git status`, `git diff`, or `git log` yourself.

## Safety (coordinator enforces; parent must not bypass)

- NEVER update the git config
- NEVER run destructive/irreversible git commands (e.g. push --force, hard reset) unless the user explicitly requests them
- NEVER skip hooks (`--no-verify`, `--no-gpg-sign`, etc.) unless the user explicitly requests them
- NEVER force push to `main`/`master`; warn if the user requests force push
- Avoid `git commit --amend` only when ALL apply: user requested amend; HEAD commit was yours this conversation; commit not pushed
- If commit **failed** or was **rejected by a hook**, never amend—fix and create a **new** commit
- If already pushed, never amend unless the user explicitly requests it (needs force push)
- NEVER commit unless the user explicitly asks
- Do not commit secrets (`.env`, credentials, keys); coordinator should BLOCK—do not bypass
- Commit messages: coordinator uses a proper multi-line message (HEREDOC-style via `-m` / `-F` as appropriate)

Do not push unless the user explicitly asks.
</committing-changes-with-git>
```

---

## 2. Replace `<creating-pull-requests>`

```xml
<creating-pull-requests>
Use **git-coordinator** for `git` and `gh` **in the agent-hub repo**. The parent does **not** run those CLIs **there**. For other git roots, the parent may run `git`/`gh` (the project hook does not block them).

When the user asks to create a pull request:

1. Confirm **`repo_path`** with the user if unclear.
2. Invoke **git-coordinator** to gather repo state (branch, tracking, commits vs base, diff summary)—do **not** run `git status`, `git diff`, or `git log` yourself.
3. Draft the PR title and body from the **Git Report** and user intent.
4. **Resume** git-coordinator (same agent id) with `user_authorized: true` to **push** (if needed) and **`gh pr create`** (pass title/body via the coordinator prompt / `gh_args`).
5. Return the PR URL from the **Git Report**.

Never update the git config. Do not push unless the user asked (or it is required to open the PR they requested).

For other GitHub tasks (issues, checks, releases), delegate **`gh`** to **git-coordinator** the same way.
</creating-pull-requests>
```

---

## 3. Optional: short global reminder

Add anywhere in User Rules if commits still run git in the parent:

```markdown
When the workspace uses the agent hub (`Agents/AGENTS.md`), git/gh policy in hub and User Rules overrides any impulse to run git in the parent thread.
```

---

## 4. Unchanged rules

Keep your other User Rules (communication, code principles, name/preferences) as they are unless you want them in the hub too.

---

## Checklist

- [ ] Needed only if default git User Rules tell the parent to run git
- [ ] Replaced `<committing-changes-with-git>` in **⌘⇧J → Rules → User Rules** (or Customize → Rules)
- [ ] Replaced `<creating-pull-requests>` in the same place
- [ ] Reloaded Cursor or started a new chat
- [ ] Test: “commit hub changes” → parent should call **git-coordinator**, not `git status` in parent shell
