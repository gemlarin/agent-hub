# research

**What:** Follow-up tasks on Research Scout findings (compare, cite, verify, matrix, extract, actions, and more).

**Source:** [`SKILL.md`](./SKILL.md). Tasks + output menu: [`options.md`](./options.md). File shapes: [`output.md`](./output.md).

## Design

**Research Scout** loads this skill. First invocation produces a Research Brief (`task: brief`). The parent then **offers follow-up tasks and output formats** (`out-chat`, `out-md`, `out-xml`, `out-raw`). Desktop saves are written by the parent, not the scout.

Scout stays read-only in the repo. This is not Web Researcher (one-shot lookup) and not Job Finder.

## Contribute

- Add or rename a follow-up or output id in [`options.md`](./options.md) **and** the matching format in [`SKILL.md`](./SKILL.md) / [`output.md`](./output.md).
- Keep the skill listed in [`../SKILLS.md`](../SKILLS.md).
- Do not teach the parent to re-read all sources when `cite` / `explain` is enough.
