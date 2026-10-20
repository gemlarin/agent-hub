# Job search output and follow-up

After Job Finder returns ranked matches, the parent uses this order. Call the host question control first. The choices are in this file. Do not open the interactive-inputs catalog. Number only if that control is absent or the call fails.

1. Offer `out-chat`, `out-md`, `out-xml`, `out-raw`. One choice. Wait. Skip it only when this run already named an output id.
2. Deliver that output. A file save reuses the matches already returned. Do not search again.
3. Offer **Yes** and **No**: follow-up work on these results? Wait.
4. **No:** stop.
5. **Yes:** offer one id from **Follow-up**. Wait.
6. Say the steps for that id, then do them.
7. When that follow-up finishes, go back to step 1.

If the host control fails and they do not answer the output question, use **`out-chat`**. A typed id or the phrase in **Say this** still counts.

## Output

| Id | Say this | Result |
|----|----------|--------|
| `out-chat` | “Just show it here” | Chat only |
| `out-md` | “Save as markdown” | `~/Desktop/job-matches-YYYY-MM-DD.md` |
| `out-xml` | “Save as xml” | `.xml` — schema in [`output.md`](./output.md) |
| `out-raw` | “Save as plain text / raw” | `.txt` on Desktop |

Same ids as the [research skill](../research/options.md#output-options). File shapes: [`output.md`](./output.md). Job Finder writes the Desktop file from the current matches (never the hub repo).

## Follow-up

Offer these only after **Yes**. One id. Say the steps, then do them.

| Id | Say this | Steps |
|----|----------|--------|
| `refine` | “Change the filters and search again” | Show the current count, salary, mode, and location. Ask which of those to change. Re-invoke Job Finder with the new filters and the same resume. |
| `compare` | “Compare these matches” | Use the matches already returned. Do not search again. Show title, employer, salary, mode, score, and one-line why. Ask which row to open, or return to the follow-up question. |
| `employers` | “Add local employers” | If the mode is not in-office, say so and show this list again. Confirm city and state. Re-invoke Job Finder with local employers on, and merge into the current list. |
| `widen` | “Return more matches” | Ask for a higher result count. Re-invoke Job Finder with that count and the same other filters. |
