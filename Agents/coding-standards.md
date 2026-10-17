# Coding Standards

**Scope:** Greenfield stack rules apply to **new projects only**. Do not rewrite existing apps (styles, READMEs, aliases, structure) unless D asks. Vue rules → Vue apps. React apps → local patterns + shared sections (comms, secrets, change control, DoD).

**New apps:** Add a pointer `AGENTS.md` at the project root that links to the hub (`../AGENTS.md` or `../../AGENTS.md` at the Projects folder). Do not symlink this coding-standards file as `AGENTS.md`.

## Spec-driven tasks

Light spec workflow for **new tasks** (features, refactors with a clear goal, interview drills, etc.). Skip for tiny one-liners D already specified fully.

1. **Ask for specs** before coding: goal, in/out of scope, acceptance checks, constraints (stack, a11y, time box).
2. Write **`tasks.md`** at the **project root** (create/overwrite for that task — don’t scatter task lists).
3. Use a checkbox task list. Check items off as each is done.
4. **Always** include a **Code sweep** line that points at the sweep prompt (do not auto-run every topic).
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
- [ ] Code sweep (prompt D for topics — see AGENTS.md)
```

---

## Code sweep

When D asks for a **code sweep** (or a `tasks.md` sweep item is due): **do not** run every topic at once.

1. Post a **checkbox menu by topic** (markdown `- [ ]`).
2. Wait for D to check / name the topics to run.
3. Sweep **only** the approved topics; report findings per topic; ask before large fixes if Change Control applies.

**Prompt template** (copy into chat):

```markdown
Code sweep — check what to run:

### Accessibility

- [ ] ARIA — roles, names, states; dynamic attrs (`aria-invalid`, `aria-expanded`, etc.)
- [ ] Live regions — `aria-live` / status for loading, errors, success
- [ ] A11y basics — text sizing/contrast, `alt`, labels, focus order, keyboard, focus styles

### Quality

- [ ] Bugs / edge cases — nulls, races, stale listeners, broken happy path
- [ ] Typos — UI copy, comments, README, commit messages in scope
- [ ] Code smell — duplication, god components, logic in templates, dead code
- [ ] Types — `any`, weak casts, missing return types, magic strings
- [ ] Async / errors — empty catches, missing loading/error UI, no abort/cleanup

### Ship-readiness (optional)

- [ ] Secrets / env — no hardcoded secrets; `.env.example` in sync
- [ ] CI / scripts — typecheck/test/build still make sense
- [ ] DoD — typecheck/build; native controls over clickable `div`s
```

**Reminders:** If D is deep in a build and hasn’t swept in a while (e.g. feature roughly done, about to call a task complete, or several sessions without a sweep), **once** gently remind: offer the checkbox menu. Don’t nag every turn.

---

## Change Control

- **Stay on request:** Only what the latest ask requires. No drive-by cleanups, renames, restyles, or extra files unless D asks.
- **Never change out-of-scope code** (formatting, semicolons/quotes, unrelated files, “while I’m here” tidy-ups, comment rewrites, import reorder-only diffs) **unless D explicitly asks.**
- Ask before behavior/API changes or refactors.
- In an already-approved file: typos, type fixes, and obvious bugs are OK without re-asking — still **do not** restyle the rest of the file.
- Ask before touching vendor config, `.env` / mocks, or DB seeds.
- Match existing patterns (including quote/semicolon style in that file); get approval before changing them.
- Never commit or push unless D asks.
- Code sweeps: only approved topics; no surprise refactors under “while I was in there.”

---

## Secrets & Git

- **Never commit, push, or open a PR** that contains secrets or PII—no exceptions unless D explicitly asks to revert a leak and rotate credentials.
- **Secrets:** API keys, bearer tokens, passwords, SSH/private keys, OAuth client secrets, webhook signing secrets, database URLs with credentials, `.env` / `.env.local` / `.env.production`, service account JSON, certificates with private keys.
- **PII:** SSNs/tax IDs, bank or card numbers, government ID numbers, full home addresses, private phone numbers, medical or health records, or other sensitive personal data that does not belong in a public or shared repo.
- Gitignore `.env` / `.env.*` (allow **`.env.example`** with fake placeholders only). Secrets live only in local env files or your secret manager—not in source, comments, tests, fixtures, screenshots, or sample data.
- Before any commit: scan staged files for env-like values and PII; if found, remove, rotate if already exposed, and use env vars or redacted samples instead.
- New projects: ship `.env.example` with `VITE_*` (or equivalent) placeholders.

---

## New Project Layout

| Path                       | Purpose                |
| -------------------------- | ---------------------- |
| `src/components/`          | UI only                |
| `src/composables/`         | `use*` reactive logic  |
| `src/types/`               | Types / unions         |
| `src/stores/`              | Pinia — only if needed |
| `src/utils/` or `src/lib/` | Plain helpers          |
| `src/assets/`              | Imported assets        |

---

## Stack (new projects)

- TypeScript, strict null checks; prefer type files.
- **Tailwind v4** + `@tailwindcss/vite`. No vanilla/inline CSS unless a third-party lib needs it (ask first).
- Existing / a11y–API drills: match the repo (scoped CSS OK).
- Components = display; logic in composables.
- Native HTML + Tailwind first — ask before UI kits (Headless, Radix, Vuetify, etc.).
- Vue Router only when there is more than one real route.
- Ask before adding npm deps.
- Prefer `const` over `let`.
- API URLs from `import.meta.env.VITE_*` — never hardcode; never use `process.env` in Vite client code.
- New projects: configure `@` → `/src` in **vite.config + tsconfig**. Do not invent `@/` mid-edit in repos that lack it.

**Theme tokens:** Define in `@theme` / Tailwind config. Utilities OK if they map to tokens. **No raw hex in SFCs.**

```css
@theme {
  --color-background: #f7f7f7;
  --color-foreground: #1a1a1a;
  --color-border: #d4d4d4;
  --color-success: #15803d;
}
```

Use `bg-background`, `text-foreground`, `border-border`, `text-success`.

**Tailwind:** No dynamic class string concat; avoid arbitrary values when scale classes work; extract a child component instead of `@apply` dumps.

---

## Definition of Done

1. No TS **errors** — `npm run typecheck` if present, else `npm run build`.
2. `npm run build` succeeds when relevant.
3. Vue UI: real controls over clickable `div`s; keyboard works; ARIA only when native isn’t enough; keep focus styles.
4. When a **`tasks.md`** exists for the work: checklist items done (or explicitly deferred); **code sweep** offered via topic checkboxes before calling the task complete.

**Commands:** `npm run dev` · `npm run typecheck` · `npm run build` · `npm run preview`

---

## Vue 3

- Always `<script setup lang="ts">`. No Options API unless maintaining legacy.
- Pinia only when global state is needed (not Vuex; don’t add Pinia just to comply). Use `storeToRefs()` when destructuring store state.
- `defineProps` / `defineEmits` type macros; prefer `defineModel`. Reactive prop destructure OK.
- Prefer `update:prop` / `defineModel` for two-way data; custom events for domain actions (`submit`, `select`).
- `ref()` by default; `reactive()` only for deep objects you won’t replace.
- DOM/template refs: `ref<HTMLInputElement | null>(null)` matching the template `ref` name.
- Component order: props/emits → state → computed → methods.

### Never

- `any` — use `unknown` or an interface.
- `v-html` unless D asks.
- Heavy logic in templates — use `computed()`.
- Mutating props — emit or `defineModel`.

### Composables

- Name `useX.ts` in `composables/` (or `@/composables` when `@` exists).
- Vue reactivity/lifecycle → composable; pure transforms → `utils`/`lib` (no `use` prefix).
- Clean up listeners/intervals/watchers (and in-flight fetches) with `onUnmounted` / `onScopeDispose`.
- Return an **object** of refs/methods — never an array.

**Fetch shape:** `{ data, error, loading, execute }` (+ computed filters as needed). Don’t invent a new loading pattern per file.

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

---

## New Project Checklist

1. Pointer `AGENTS.md` to the hub `AGENTS.md` at the Projects root (`../` or `../../`)
2. `.gitignore` for env + `.env.example`
3. `@` alias in vite + tsconfig
4. Layout folders above; Pinia only if needed
5. Vue 3 + TS + Vite + Tailwind v4 + starter tokens
6. Short README: what it does, install, env, `dev` / `typecheck` / `build`
7. Optional CI as above
8. Stay on request; ask before deps, UI kits, test runners, vendor/env/seeds
