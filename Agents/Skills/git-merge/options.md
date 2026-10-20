# Git merge options

The parent calls the host question control first ([interactive inputs](../../Rules/interactive-inputs/interactive-inputs.md)). Number the list only if that control is absent or the call fails. A typed id still counts. **No default.** Do not resolve, commit, or abort until they pick.

List every conflicted path before the first conflict menu. Git Coordinator runs git. The parent only relays the id.

## Before a merge starts

When a push is not a fast-forward, or a merge is required and may conflict:

| Id | Label | Result |
|----|--------|--------|
| `yes` | Yes | Load this skill and start the merge. |
| `no` | No | Stop. Do not merge, pull, or force-push. |

## Conflict menu

Show this after the conflicted paths are listed. One choice. **Abort merge** and **Return to previous menu** stay at the end. **Return to previous menu** is last.

| Id | Label | Result |
|----|--------|--------|
| `mergetool` | Review in merge tool | Open the user's configured merge tool. If it cannot open, say so and show this menu again. |
| `agent-merge` | Agent merge | The agent resolves the conflicts. Unsure hunks stop for a choice. |
| `abort` | Abort merge | Abort the in-progress merge, rebase, or cherry-pick and restore the pre-merge state. |
| `back` | Return to previous menu | Leave this menu. Do not resolve. If a merge is already in progress, it stays in progress until they pick **Abort merge**. |

`decline` and `decline_merge_plan` mean **Abort merge**.

## After the merge tool

| Id | Label | Result |
|----|--------|--------|
| `retry` | Retry merge | Recheck the conflicted files, then finish the merge only if no conflict markers remain. |
| `back` | Return to previous menu | Show the conflict menu again. |

## Unsure hunk

The parent shows the conflicted code, then one choice.

| Id | Label | Result |
|----|--------|--------|
| `keep-ours` | Keep ours | Keep the current branch side. |
| `accept-incoming` | Accept incoming | Keep the incoming side. |
| `keep-both` | Keep both | Keep both sides, without conflict markers. Not offered for a binary file. |
| `agent-suggestion` | Agent suggestion | The agent picks a resolution, applies it, and says what it did. |

`ours` means **Keep ours**. `theirs` means **Accept incoming**.

## Markers still present

| Id | Label | Result |
|----|--------|--------|
| `yes` | Yes | Auto-fix the remaining conflicts, then recheck. |
| `no` | No | Do not merge. Show the conflict menu again. |

A typed path still means "show that file," then show the same menu again. A typed plan still means "use this plan," and the coordinator asks again if the plan is ambiguous.

Pick **one** per invocation. Protocol: [`SKILL.md`](./SKILL.md).
