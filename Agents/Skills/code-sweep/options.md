# Code sweep topic options

When a code sweep is requested, a `tasks.md` sweep item is due, or a one-time wrap-up reminder fires, the parent asks **before** any sweep starts. Call the host question control first. The choices are in this file. Do not open the interactive-inputs catalog. Number only if that control is absent or the call fails.

First choice, one answer: **Topics to run** or **Run all**.

- **Topics to run:** then show the table below as a multi-select. Wait. Run only the ids they pick.
- **Run all:** run every id in the table. Do not ask them to pick ids again.

A typed id, **Topics to run**, or **Run all** still counts. Do not start the sweep before this choice.

| Id | Say this | Looks for |
|----|----------|-----------|
| `aria` | “Aria” | Roles, names, states; dynamic `aria-*` |
| `live` | “Live regions” | `aria-live` / status for loading, errors, success |
| `a11y` | “A11y basics” | Contrast/text size, `alt`, labels, focus order, keyboard, focus styles |
| `bugs` | “Bugs / edge cases” | Nulls, races, stale listeners, broken happy path |
| `typos` | “Typos” | UI copy, comments, README, in-scope commit messages |
| `smell` | “Code smell” | Duplication, god components, logic in templates, dead code |
| `types` | “Types” | `any`, weak casts, missing return types, magic strings |
| `async` | “Async / errors” | Empty catches, missing loading/error UI, no abort/cleanup |
| `secrets` | “Secrets / env” | Hardcoded secrets; `.env.example` in sync |
| `ci` | “Ci / scripts” | typecheck/test/build scripts still make sense |
| `dod` | “Definition of done” | typecheck/build; native controls over clickable `div`s |

**Topics to run** uses only the ids they named. **Run all** uses every id. Vue SFCs: also apply [`coding-standards-vue.md`](../../Rules/coding-standards-vue/coding-standards-vue.md) DoD when `a11y` or `dod` is on. Catalog owner: [`SKILL.md`](./SKILL.md).
