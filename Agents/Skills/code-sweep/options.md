# Code sweep topic options

Parent **shows this list** when the user asks for a code sweep, a `tasks.md` sweep item is due, or a one-time wrap-up reminder. User replies with **ids** (one or more). Do **not** run every topic.

| Id | Say this | Looks for |
|----|----------|-----------|
| `aria` | “ARIA” | Roles, names, states; dynamic `aria-*` |
| `live` | “Live regions” | `aria-live` / status for loading, errors, success |
| `a11y` | “A11y basics” | Contrast/text size, `alt`, labels, focus order, keyboard, focus styles |
| `bugs` | “Bugs / edge cases” | Nulls, races, stale listeners, broken happy path |
| `typos` | “Typos” | UI copy, comments, README, in-scope commit messages |
| `smell` | “Code smell” | Duplication, god components, logic in templates, dead code |
| `types` | “Types” | `any`, weak casts, missing return types, magic strings |
| `async` | “Async / errors” | Empty catches, missing loading/error UI, no abort/cleanup |
| `secrets` | “Secrets / env” | Hardcoded secrets; `.env.example` in sync |
| `ci` | “CI / scripts” | typecheck/test/build scripts still make sense |
| `dod` | “Definition of Done” | typecheck/build; native controls over clickable `div`s |

Pick **only** the topics they named. Vue SFCs: also apply [`coding-standards-vue.md`](../../coding-standards-vue.md) DoD when `a11y` or `dod` is on. Catalog owner: [`SKILL.md`](./SKILL.md).
