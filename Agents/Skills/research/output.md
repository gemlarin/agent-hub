# Research result file shapes

Desktop files are the **current task output** (brief, compare, cite, …) plus a source list. Do **not** save under the hub clone. Scout stays read-only in the repo; the **parent** writes the file when the user picks a save format.

Filename: `research-<task>-YYYY-MM-DD.<ext>` (append `-2` if it exists).

- macOS: `~/Desktop/`
- Windows: `%USERPROFILE%\Desktop\`

## Markdown (`.md`)

Use the task format from [`SKILL.md`](./SKILL.md). Start with:

```markdown
# Research — <task> — <topic> — YYYY-MM-DD

…
## Source Manifest
- path or URL — what it supported
```

## XML (`.xml`)

```xml
<research generated="YYYY-MM-DD" task="brief" topic="">
  <summary></summary>
  <body><![CDATA[
    (task-specific markdown or text)
  ]]></body>
  <sources>
    <source loc="" note=""/>
  </sources>
</research>
```

## Raw (`.txt`)

Plain text: same sections as the task, no markdown tables required (use labeled lines). End with `Sources:` and one path/URL per line.

## Chat only

Same content as the chosen task, in the chat. No file unless the user also asks to save.
