# Job search output options

After Job Finder returns ranked matches, the parent **offers delivery** by calling the host question control first ([interactive inputs](../../Rules/interactive-inputs/interactive-inputs.md)). Number the list only if that control is absent or the call fails. User replies with an **id**, the prompt, or the number. Default if they skip: **`out-chat`**.

| Id | Say this | Result |
|----|----------|--------|
| `out-chat` | “Just show it here” | Chat only |
| `out-md` | “Save as markdown” | `~/Desktop/job-matches-YYYY-MM-DD.md` |
| `out-xml` | “Save as xml” | `.xml` — schema in [`output.md`](./output.md) |
| `out-raw` | “Save as plain text / raw” | `.txt` on Desktop |

Same ids as the [research skill](../research/options.md#output-options). File shapes: [`output.md`](./output.md). Job Finder writes the Desktop file (never the hub repo).
