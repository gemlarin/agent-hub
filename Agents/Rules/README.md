# Rules/

Shared standards the agent loads from [`../AGENTS.md`](../AGENTS.md). Each rule is its own folder.

| Rule | Shared file |
|------|-------------|
| Coding (any stack) | [`coding-standards/coding-standards.md`](./coding-standards/coding-standards.md) |
| Vue greenfield | [`coding-standards-vue/coding-standards-vue.md`](./coding-standards-vue/coding-standards-vue.md) |
| Tone | [`personality-communication/personality-communication.md`](./personality-communication/personality-communication.md) |
| Interactive inputs | [`interactive-inputs/interactive-inputs.md`](./interactive-inputs/interactive-inputs.md) |
| Context use | [`context-discipline/context-discipline.md`](./context-discipline/context-discipline.md) |
| Git menus | [`git-delegation/git-delegation.md`](./git-delegation/git-delegation.md) |
| Code settings | [`code-settings/code-settings.md`](./code-settings/code-settings.md) |

Memory, skills, subagents, and setup stay outside this folder.

## Local settings

Each folder has `user-config.example.md`. Copy it to `user-config.md` in that same folder. The hub `.gitignore` ignores every `Agents/Rules/**/user-config.md`.

When `user-config.md` exists, read it **after** the shared rule. **Additions** extend the rule. **Overrides** replace the matching part on this machine only. A hub update does not touch `user-config.md`.

## Still to do

- [x] Shrink the always-on rules to a stub. `.cursor/rules/*.mdc` keeps the trigger. Git menus and test-default meanings open only when that task starts.
- [x] Keep the stable prefix cacheable. Do not write memory, `user-config.md`, or the user message into `AGENTS.md` or the always-on stubs. In a Task prompt, those come after the spec path.

## Contribute

1. Edit the shared `.md` in the rule folder. Do not put personal preferences there.
2. Update that folder's README if the way to change the rule changed.
3. If you add a rule, add a folder here, a row in [`../AGENTS.md`](../AGENTS.md), and a `user-config.example.md`. Gitignore is already `Agents/Rules/**/user-config.md`.
