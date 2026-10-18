# Result file shapes

Desktop files contain **openings only** (no resume text). Sorted best match first.

`output` is one of: `out-chat` (default), `out-md`, `out-xml`, `out-raw` — same ids as research. See [`options.md`](./options.md).

- macOS: `~/Desktop/`
- Windows: `%USERPROFILE%\Desktop\`

Filename: `job-matches-YYYY-MM-DD.md` / `.xml` / `.txt` (append `-2` if it exists).

## Chat only (`out-chat`)

Ranked list in the Job Report. No file.

## Markdown (`out-md`, `.md`)

```markdown
# Job matches — YYYY-MM-DD

Filters: N results · min salary · mode · location

## 1. <title> — <employer> (score)

- **Mode / location:**
- **Salary:**
- **Apply:** <url>
- **Source:**
- **Why:**

<short description>
```

## XML (`out-xml`, `.xml`)

```xml
<job-matches generated="YYYY-MM-DD" minSalary="" workMode="" location="" count="">
  <job rank="1" score="">
    <title></title>
    <employer></employer>
    <workMode></workMode>
    <location></location>
    <salary></salary>
    <source></source>
    <applyUrl></applyUrl>
    <why></why>
    <description></description>
  </job>
</job-matches>
```

## Raw (`out-raw`, `.txt`)

Numbered list, same fields as labels (`Title:`, `Employer:`, `Apply:`, …), blank line between jobs.

## Sources skipped

Append a short list of boards that failed or returned zero, with the reason (blocked, no public hits, timeout).
