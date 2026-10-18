# Git merge options

Parent **shows this list** when Git Coordinator returns `AWAIT_MERGE_APPROVAL`. User replies with an **id** or the prompt. **No default** — do not resolve or abort until they pick.

| Id | Say this | Result |
|----|----------|--------|
| `approve` | “Approve” / “do that” | Execute the recommended plan exactly |
| `decline` | “Decline” / “abort” | Abort merge / rebase / cherry-pick; restore pre-state |
| `ours` | “Keep ours” | Resolve remaining (or named) paths with `--ours` |
| `theirs` | “Keep theirs” | Same with `--theirs` |
| `detail` | “Show me `<path>`” | Conflict hunks for that file only; then offer this list again |
| `revise` | “Instead, …” | Treat the rest of the message as the plan, then execute |

Aliases the coordinator already accepts: `approve_merge_plan` → `approve`, `decline_merge_plan` → `decline`. Naming a conflicted path without an id is the same as `detail`.

Pick **one** per invocation. Git Coordinator runs git; the parent only relays the id. Protocol: [`SKILL.md`](./SKILL.md).
