# Cursor User Rules — align with agent hub

**Cursor only.** If you do not use Cursor, skip this file; follow **AGENTS.md** and **Agents/Subagents/** with your agent.

**User Rules** live in **Cursor → Settings → Rules** (account-level), not in this repo. Run `./Agents/scripts/detect-cursor-env.sh` before setup if unsure.

Replace or merge the blocks below so they match **AGENTS.md** and **git-coordinator**. Project rules: `.cursor/rules/git-delegation.mdc` in the hub.

---

## 1. Replace `<committing-changes-with-git>`

Copy everything inside the tag into your User Rules (replace the old block).

```xml
<committing-changes-with-git>
Only create commits when requested by the user. If unclear, ask first.

## Git delegation (required)

You are the **parent agent**. Do **not** run `git` or `gh` in your shell.

- Delegate **all** git/gh to the **git-coordinator** subagent (`subagent_type: git-coordinator`).
- Pass **`repo_path`** (git root). Ask the user which repo when unclear (hub `Projects/` vs an app folder).
- Relay user choices: `[more]`, `[continue]`, `[custom]`, `[agent]`, merge approve/decline.
- Trust the **Git Report**; do **not** re-run the same commands or duplicate `status` / `diff` / `log` in the parent.
- Hub details: `AGENTS.md`, `Agents/subagents.md`, `Agents/Subagents/git-coordinator.md`.

## When the user asks to commit

1. Invoke **git-coordinator** with `operation: commit`, `user_authorized: true`, and `repo_path`.
2. Follow the coordinator workflow (staged-file confirm, then `[custom]` vs `[agent]` message).
3. If the user picks **`[agent]`**, draft the commit message from the coordinator’s diff summary and send it on the next invocation as `commit_message`.
4. Do **not** run `git status`, `git diff`, or `git log` yourself for that commit.

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
Use **git-coordinator** for **all** `git` and `gh` work. The parent agent does **not** run `git` or `gh` in the shell.

When the user asks to create a pull request:

1. Confirm **`repo_path`** with the user if unclear.
2. Invoke **git-coordinator** to gather repo state (branch, tracking, commits vs base, diff summary)—do **not** run `git status`, `git diff`, or `git log` yourself.
3. Draft the PR title and body from the **Git Report** and user intent.
4. Invoke **git-coordinator** again with `user_authorized: true` to **push** (if needed) and **`gh pr create`** (pass title/body via the coordinator prompt / `gh_args`).
5. Return the PR URL from the **Git Report**.

Never update the git config. Do not push unless the user asked (or it is required to open the PR they requested).

For other GitHub tasks (issues, checks, releases), delegate **`gh`** to **git-coordinator** the same way.
</creating-pull-requests>
```

---

## 3. Optional: short global reminder

Add anywhere in User Rules if commits still run git in the parent:

```markdown
When the workspace uses the agent hub (`AGENTS.md` at Projects root), git/gh policy in hub and User Rules overrides any impulse to run git in the parent thread.
```

---

## 4. Unchanged rules

Keep your other User Rules (communication, code principles, name/preferences) as they are unless you want them in the hub too.

---

## Checklist

- [ ] Replaced `<committing-changes-with-git>` in Cursor Settings → Rules
- [ ] Replaced `<creating-pull-requests>` in Cursor Settings → Rules
- [ ] Reloaded Cursor or started a new chat
- [ ] Test: “commit hub changes” → parent should call **git-coordinator**, not `git status` in parent shell
