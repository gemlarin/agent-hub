# Coding Standards (core)

Shared rules for any stack. **Vue greenfield** (layout, Tailwind, Vue 3, new-app checklist): read [coding-standards-vue.md](../coding-standards-vue/coding-standards-vue.md) only when that applies.

**This machine:** After this file, read `user-config.md` in this folder when it exists. Additions extend the rule. Overrides replace the matching part on this machine only. Never commit that file. Copy [user-config.example.md](./user-config.example.md) to create it.

**Scope:** Do not rewrite existing apps (styles, READMEs, aliases, structure) unless the user asks.

**New apps:** Pointer `AGENTS.md` at the project root → relative path to this clone’s `Agents/AGENTS.md`. Do not symlink this file as `AGENTS.md`. See [README.md](../../../README.md#point-app-repos-at-the-hub).

## Tests after an update

Read **Test default** in [`Agents/Settings/CONFIG.md`](../../Settings/CONFIG.md). After a code or UI update, run that default: `UNIT`, `BROWSER`, `BOTH`, or `NONE`. A request that asks for a unit test or a browser test overrides the default for that request only. The user changes the stored default from `HELP` → **Change code settings** → **Change code test settings**. Offer **Unit**, **Browser**, **Both**, and **None** as an interactive choice. Write the matching token. ([interactive inputs](../interactive-inputs/interactive-inputs.md)).

## Spec-driven tasks

Light spec workflow for **new tasks** (features, refactors with a clear goal, interview drills, etc.). Skip for tiny one-liners the user already specified fully.

1. **Ask for specs** before coding: goal, in/out of scope, acceptance checks, constraints (stack, a11y, time box).
2. Write **`tasks.md`** at the **project root** (create/overwrite for that task — don’t scatter task lists).
3. Use a checkbox task list. Check items off as each is done.
4. **Always** include a **Code sweep** line that points at the topic ids (do not auto-run every topic).
5. Keep it short — outcomes, not a novel.

**`tasks.md` shape:**

```markdown
# Task: <short name>

## Spec

- Goal:
- In scope:
- Out of scope:
- Done when:

## Tasks

- [ ] …
- [ ] …
- [ ] Code sweep (offer topic ids — [code-sweep options](../../Skills/code-sweep/options.md); Code Sweeper runs them)
```

---

## Code sweep

When the user asks for a **code sweep** (or a `tasks.md` sweep item is due): **do not** run every topic at once, and **do not** sweep in the parent.

1. Offer topic **ids** from [`Skills/code-sweep/options.md`](../../Skills/code-sweep/options.md). Confirm **scope** (which app/paths) if unclear.
2. Wait for the user to name ids.
3. Delegate to **Code Sweeper** ([`subagents.md`](../../Subagents/subagents.md)) with those `topics` + `scope`. Trust the **Sweep Report**. Ask before applying suggested fixes (Change Control).

**Reminders:** If the user is deep in a build and hasn’t swept in a while (e.g. feature roughly done, about to call a task complete, or several sessions without a sweep), **once** gently remind: offer the topic ids. Don’t nag every turn.

---

## Change Control

- **Stay on request:** Only what the latest ask requires. No drive-by cleanups, renames, restyles, or extra files unless the user asks.
- **Never change out-of-scope code** (formatting, semicolons/quotes, unrelated files, “while I’m here” tidy-ups, comment rewrites, import reorder-only diffs) **unless the user explicitly asks.**
- Ask before behavior/API changes or refactors.
- In an already-approved file: typos, type fixes, and obvious bugs are OK without re-asking — still **do not** restyle the rest of the file.
- Ask before touching vendor config, `.env` / mocks, or DB seeds.
- Match existing patterns (including quote/semicolon style in that file); get approval before changing them.
- Never commit or push unless the user asks.
- Code sweeps: only approved topics; no surprise refactors under “while I was in there.”

---

## Secrets & Git

- **Never commit, push, or open a PR** that contains secrets or PII—no exceptions unless the user explicitly asks to revert a leak and rotate credentials.
- **Secrets:** API keys, bearer tokens, passwords, SSH/private keys, OAuth client secrets, webhook signing secrets, database URLs with credentials, `.env` / `.env.local` / `.env.production`, service account JSON, certificates with private keys.
- **PII:** SSNs/tax IDs, bank or card numbers, government ID numbers, full home addresses, private phone numbers, medical or health records, or other sensitive personal data that does not belong in a public or shared repo.
- Gitignore `.env` / `.env.*` (allow **`.env.example`** with fake placeholders only). Secrets live only in local env files or your secret manager—not in source, comments, tests, fixtures, screenshots, or sample data.
- Before any commit: scan staged files for env-like values and PII; if found, remove, rotate if already exposed, and use env vars or redacted samples instead.
- New projects: ship `.env.example` with `VITE_*` (or equivalent) placeholders.

---

## Definition of Done

1. No TS **errors** — `npm run typecheck` if present, else `npm run build`.
2. `npm run build` succeeds when relevant.
3. UI: prefer real controls over clickable `div`s; keyboard and focus behave sensibly (Vue specifics → [coding-standards-vue.md](../coding-standards-vue/coding-standards-vue.md#definition-of-done-vue-ui)).
4. When a **`tasks.md`** exists for the work: checklist items done (or explicitly deferred); **code sweep** offered via topic ids ([`Skills/code-sweep/options.md`](../../Skills/code-sweep/options.md)) before calling the task complete.

**Commands:** `npm run dev` · `npm run typecheck` · `npm run build` · `npm run preview`

---

## TypeScript

- Infer when obvious (`ref(false)`); explicit generics for complex/null refs.
- Explicit return types on functions, composables, and fetch helpers.
- Prefer `Pick` / `Omit` / `Partial` / `Readonly` over duplicate types.
- Use `?.` and `??`; guard API data instead of blind `as` casts.
- **No magic strings:** status values, event names, route names, API path segments, and similar literals live in typed constants or union types (`as const` / `type` files)—not scattered inline in components.

### Async & errors

- Prefer `async`/`await` over `.then()` / `.catch()` chains.
- Wrap awaits in `try`/`catch` (use `finally` for cleanup). Re-throw only when the caller should handle it.
- Never leave `catch` empty — log, set UI error state, or re-throw.

### Comments

- No comments that restate the code.
- Skip JSDoc `@param` / `@returns` when the signature is already typed.
- Comment the **why** (non-obvious logic, workarounds) — not the what.
- If it needs a long comment, refactor into a named helper instead.

---

## Testing & CI (new projects)

- Don’t force a test harness on every demo — ask before Vitest/Playwright.
- Prefer Vitest for composables/utils when tests are wanted.
- Default CI: install → typecheck → build on push/PR to `main`. No extra jobs unless asked.
