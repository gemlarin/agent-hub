# Job search output options

After Job Finder returns ranked matches, the parent **offers delivery**. User replies with an **id** or the prompt. Default if they skip: **`out-chat`**.

| Id | Say this | Result |
|----|----------|--------|
| `out-chat` | “Just show it here” | Chat only |
| `out-md` | “Save as Markdown” | `~/Desktop/job-matches-YYYY-MM-DD.md` |
| `out-xml` | “Save as XML” | `.xml` — schema in [`output.md`](./output.md) |
| `out-raw` | “Save as plain text / raw” | `.txt` on Desktop |

Same ids as the [research skill](../research/options.md#output-options). File shapes: [`output.md`](./output.md). Job Finder writes the Desktop file (never the hub repo).
