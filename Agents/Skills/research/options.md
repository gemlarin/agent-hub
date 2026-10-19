# Research follow-up options

Parent **shows this list** after a Research Brief (or when the user asks what they can do with the findings). Offer it as an interactive choice when the host supports one ([interactive inputs](../../Rules/interactive-inputs/interactive-inputs.md)). Otherwise number it. User replies with the **id**, the **prompt**, or the number. Parent re-invokes Research Scout with `task: <id>` and the prior brief (do not dump raw sources again unless the task is `deepen` or `verify`).

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

Pick **one** task per invocation unless the user names two that compose (`cite` after `compare` is fine as a second turn).

## Output options

After **any** task (including the first `brief`), the parent **offers delivery** the same way (interactive choice, or a numbered list). User replies with an **id**, the prompt, or the number. Default if they skip: **`out-chat`**.

| Id | Say this | Result |
|----|----------|--------|
| `out-chat` | “Just show it here” | Chat only |
| `out-md` | “Save as markdown” | `~/Desktop/research-<task>-YYYY-MM-DD.md` |
| `out-xml` | “Save as xml” | `.xml` — schema in [`output.md`](./output.md) |
| `out-raw` | “Save as plain text / raw” | `.txt` on Desktop |

They can combine: `cite` + `out-md`. File shapes: [`output.md`](./output.md). Parent writes the Desktop file (Scout does not edit the repo).
