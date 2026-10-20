# Research follow-up options

When a brief or a follow-up task finishes, the parent uses this order. Call the host question control first. The choices are in this file. Do not open the interactive-inputs catalog. Number only if that control is absent or the call fails.

1. Offer `out-chat`, `out-md`, `out-xml`, `out-raw`. One choice. Wait. Do not show follow-up ids in that question. Skip it only when this run already named an output id.
2. Deliver that output.
3. Offer **Yes** and **No**: follow-up work on these results? Wait.
4. **No:** stop.
5. **Yes:** offer one follow-up id from the table below. Do not offer `brief`. Wait.
6. Say the steps for that id, then re-invoke Research Scout with `task: <id>` and the prior result. Do not dump raw sources again unless the task is `deepen`, `verify`, `versions`, or `timeline`.
7. When that task finishes, go back to step 1.

| Id | Say this | Result |
|----|----------|--------|
| `brief` | “Research brief on …” / default first pass | Standard Research Brief (≤80 lines) |
| `compare` | “Compare a vs b from this research” | Decision table: winner per criterion, tradeoffs |
| `cite` | “Give me the sources / bibliography” | Annotated source cards (title, URL/path, what it proved) |
| `verify` | “Fact-check these claims” | Each claim → source → confidence (high/med/low) |
| `versions` | “Version compatibility matrix” | Table: versions × features / breaking changes |
| `extract` | “Extract apis and examples only” | Signatures + minimal snippets, no narrative |
| `actions` | “What should we do in this repo next?” | Ordered implementation / investigation steps |
| `explain` | “Brief a non-expert / stakeholder” | Short plain-language briefing, no API dump |
| `gaps` | “What’s still unknown?” | Open questions and where to look next |
| `deepen` | “Go deeper on [section or api]” | Second pass on that slice; new sources allowed |
| `timeline` | “How did this change over time?” | Chronology of API/docs/behavior |
| `expand` | “Full detail — don’t cap at 80 lines” | Long-form brief; still sourced |

Pick **one** task per invocation. A later turn can run another id (`cite` after `compare`).

Before the re-invoke, say these steps for the chosen id, then do them:

- `compare` — Name the two options. Build the criterion table from the brief. Recommend one only if the sources support it.
- `cite` — One card per source: title, location, date, what it established.
- `verify` — Each claim, supported or unsupported, with source and confidence.
- `versions` — Version matrix. Mark unknowns as `?`.
- `extract` — Names, signatures, and short snippets copied from the sources.
- `actions` — Numbered steps for this repo, checked against local files. Do not refactor.
- `explain` — One problem, one recommendation, three plain-language bullets.
- `gaps` — Unknowns, why they matter, and the next source.
- `deepen` — Name the slice, search that slice only, return a mini-brief.
- `timeline` — Dated events, oldest to newest. Skip undated guesses.
- `expand` — Same sections as the brief, without the 80-line cap.

## Output options

Offer these when the run completes, before any follow-up question. One choice. A typed id or the phrase in **Say this** still counts. If the host control fails and they do not answer, use **`out-chat`**.

| Id | Say this | Result |
|----|----------|--------|
| `out-chat` | “Just show it here” | Chat only |
| `out-md` | “Save as markdown” | `~/Desktop/research-<task>-YYYY-MM-DD.md` |
| `out-xml` | “Save as xml” | `.xml` — schema in [`output.md`](./output.md) |
| `out-raw` | “Save as plain text / raw” | `.txt` on Desktop |

They can combine: `cite` + `out-md`. File shapes: [`output.md`](./output.md). Parent writes the Desktop file (Scout does not edit the repo).
