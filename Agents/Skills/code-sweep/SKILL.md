---
name: code-sweep
description: Topic-limited accessibility and quality sweep of named paths. Use when the user asks for a code sweep, a tasks.md sweep item is due, or they name Code Sweeper. Not for git diffs (Code Reviewer), job search, or a full-repo rewrite.
---

# Skill: Code sweep

**Code Sweeper** loads this skill. Topic ids: [`options.md`](./options.md). The parent **must not** run a multi-topic sweep in the main chat.

Stay **read-only**. Do not edit files, run `git`/`gh`, or write `MEMORY.md`. Default report **≤80 lines**.

## 1. Inputs (stop until complete)

- **`scope`:** app root and/or file paths. If missing, `NEED_INPUT` — do not guess the whole workspace.
- **`topics`:** one or more ids from [`options.md`](./options.md). If missing, `NEED_INPUT` with that table. Never default to all topics.
- **`related_memory`:** optional bullets from the parent. Do not read `MEMORY.md`.

Skip any topic the user did not name.

## 2. How to sweep

Grep and narrow reads only. Cite `path:line`. Do not dump whole files.

| Id | Check |
|----|--------|
| `aria` | Interactive elements have roles/names/states; dynamic `aria-invalid`, `aria-expanded`, `aria-hidden` match UI state. |
| `live` | Loading, error, and success text is exposed (`aria-live`, `role="status"`, or equivalent). |
| `a11y` | Labels, `alt`, keyboard path, visible focus, contrast/text size. Prefer native controls over clickable `div`s. |
| `bugs` | Null/undefined paths, stale listeners, racey async, broken happy path. |
| `typos` | User-visible copy, comments, README in **scope** only. |
| `smell` | Duplication, god components, heavy template logic, dead code. |
| `types` | `any`, weak `as` casts, missing return types, magic strings that belong in unions/`as const`. |
| `async` | Empty `catch`, missing loading/error UI, no abort/`finally` cleanup. |
| `secrets` | Hardcoded keys/URLs with credentials; `.env` committed; `.env.example` missing or out of date. |
| `ci` | `package.json` scripts for typecheck/test/build still match the repo. Do not invent CI. |
| `dod` | Core [Definition of Done](../../coding-standards.md#definition-of-done). Vue in scope → also [Vue UI DoD](../../coding-standards-vue.md#definition-of-done-vue-ui). Optional: `npm run typecheck` then `build` in **scope** (never `git`). |

## 3. Report

Return a **Sweep Report** (shape in the Code Sweeper spec). Per finding: severity **CRITICAL | HIGH | MEDIUM | LOW**, path, one-line issue. Topics with nothing to report go under **Clean**.

List **Suggested fixes** as bullets. **Do not apply them.** Parent asks the user before any edit (Change Control).

## 4. Parent

1. Show [`options.md`](./options.md) (do not run every topic).
2. Confirm **`scope`** if more than one app could apply.
3. Invoke Code Sweeper with `topics` + `scope` + optional `related_memory`.
4. Trust the Sweep Report; do not re-read those files unless verifying one finding.
5. Ask before implementing suggested fixes.
