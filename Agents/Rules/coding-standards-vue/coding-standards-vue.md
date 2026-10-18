# Coding Standards — Vue greenfield

**Read when:** new Vue 3 + Vite projects, or Vue-specific structure/stack work in this hub.

**Always apply first:** [coding-standards.md](../coding-standards/coding-standards.md) (change control, secrets, spec/tasks, code sweep, TypeScript, testing).

**This machine:** After this file, read `user-config.md` in this folder when it exists. Additions extend the rule. Overrides replace the matching part on this machine only. Never commit that file. Copy [user-config.example.md](./user-config.example.md) to create it.

**Scope:** Rules below apply to **new Vue projects only**. Do not rewrite existing apps unless the user asks. React and other stacks → local patterns + core standards only.

**New apps:** Pointer `AGENTS.md` at project root → relative path to this clone’s `Agents/AGENTS.md`. Do not symlink this file as `AGENTS.md`. See [README.md](../../../README.md#point-app-repos-at-the-hub).

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

## Definition of Done (Vue UI)

In addition to [core DoD](../coding-standards/coding-standards.md#definition-of-done):

- Real controls over clickable `div`s; keyboard works; ARIA only when native isn’t enough; keep focus styles.

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
- `v-html` unless the user asks.
- Heavy logic in templates — use `computed()`.
- Mutating props — emit or `defineModel`.

### Composables

- Name `useX.ts` in `composables/` (or `@/composables` when `@` exists).
- Vue reactivity/lifecycle → composable; pure transforms → `utils`/`lib` (no `use` prefix).
- Clean up listeners/intervals/watchers (and in-flight fetches) with `onUnmounted` / `onScopeDispose`.
- Return an **object** of refs/methods — never an array.

**Fetch shape:** `{ data, error, loading, execute }` (+ computed filters as needed). Don’t invent a new loading pattern per file.

---

## New Project Checklist

1. Pointer `AGENTS.md` to hub `Agents/AGENTS.md` (`../Agents/AGENTS.md` or `../../Agents/AGENTS.md`)
2. `.gitignore` for env + `.env.example`
3. `@` alias in vite + tsconfig
4. Layout folders above; Pinia only if needed
5. Vue 3 + TS + Vite + Tailwind v4 + starter tokens
6. Short README: what it does, install, env, `dev` / `typecheck` / `build`
7. Optional CI as in core [Testing & CI](../coding-standards/coding-standards.md#testing--ci-new-projects)
8. Stay on request; ask before deps, UI kits, test runners, vendor/env/seeds
