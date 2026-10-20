---
name: research
description: Follow-up tasks on Research Scout findings (compare, cite, verify, version matrix, extract APIs, actions, explain, gaps, deepen, timeline, expand). Use when running or continuing Research Scout work, not for job search or a one-shot web lookup.
---

# Skill: Research follow-ups

**This machine:** After this file, read `user-config.md` in this folder when it exists. Additions extend the skill. Overrides replace the matching part on this machine only. Never commit that file. Copy [user-config.example.md](./user-config.example.md) to create it.

**Research Scout** loads this skill. Catalog: [`options.md`](./options.md). File shapes: [`output.md`](./output.md).

Do not invent APIs or quotes. Stay **read-only** in the repo. Default **≤80 lines** unless `task` is `expand` or the parent asked for detail.

## First pass

If `task` is missing, run **`brief`** (existing Research Brief shape in the scout spec). Then stop. The **parent** offers **output** first, and follow-up work only after that output is delivered. Catalog: [`options.md`](./options.md).

## Later passes

1. Require `task` from the option **id** list. Unknown id → `NEED_INPUT` with the table from [`options.md`](./options.md).
2. Reuse the prior Research Brief the parent passed. Re-open sources only for `deepen`, `verify`, `versions`, or `timeline`.
3. Produce **only** the format for that task (below). Still include a short **Source Manifest** (paths/URLs).

## Task formats

- **`brief`** — Scout spec Research Brief.
- **`compare`** — Table: criterion | A | B | winner. Then 3–5 tradeoff bullets and a recommendation **if** sources support one.
- **`cite`** — Numbered cards: title, path/URL, date if known, one line on what it established.
- **`verify`** — Rows: claim | supported? | source | confidence. Unverified = `unsupported`, never guessed true.
- **`versions`** — Matrix: version/release × feature or breaking change. Mark unknown as `?`.
- **`extract`** — Name, signature, 3–10 line snippet copied from docs/code, behavior one-liner.
- **`actions`** — Numbered steps for **this repo** (verify against local files). No drive-by refactors.
- **`explain`** — 1 short problem, 1 short recommendation, 3 bullets a PM could read. No code unless asked.
- **`gaps`** — Unknowns, why they matter, suggested next source or `deepen` target.
- **`deepen`** — Mini-brief on the named slice only; new sources in the manifest.
- **`timeline`** — Dated bullets (oldest → newest). Skip undated speculation.
- **`expand`** — Same sections as `brief`, cap waived; still no fluff.

## Output

`output` is one of: `out-chat` (default), `out-md`, `out-xml`, `out-raw`. See [`options.md`](./options.md) and [`output.md`](./output.md).

- Scout returns the task body in chat (and XML/raw payload in the report if the parent asked for a file).
- **Parent** writes Desktop files. Scout never writes the hub or app repo.
- Confirm the saved path in chat.

## Parent

After a brief or a later task finishes, do these steps in order. Call the host question control first. Do not combine the steps into one question.

1. Offer `out-chat`, `out-md`, `out-xml`, `out-raw` unless this run already named an output id. Wait.
2. Deliver that output. For `out-md` / `out-xml` / `out-raw`, write `research-<task>-YYYY-MM-DD.<ext>` to the Desktop and do not commit it. Confirm the path.
3. Offer **Yes** and **No**: follow-up work on these results? Wait.
4. **No:** stop.
5. **Yes:** offer one follow-up id from [`options.md`](./options.md). Do not offer `brief`. Wait.
6. Say the steps for that id, in order, then re-invoke Research Scout with `task` and the previous result. Do not re-run the whole search for `cite` / `explain` / `extract` / `gaps` / `actions`.
7. When that task finishes, go back to step 1.
