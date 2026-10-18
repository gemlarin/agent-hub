# Your job boards (optional)

Copy this file to `boards.local.md` in the same folder:

```bash
cp Agents/Skills/job-search/boards.local.example.md Agents/Skills/job-search/boards.local.md
```

`boards.local.md` is gitignored. When it exists, Job Finder searches **only** these rows and ignores [`boards.md`](./boards.md).

- Add a row for a new board (name + a `site:` query).
- Delete a row to stop using that board.
- Set **On** to `no` to pause a board and keep the row.

| On | Board | Site / query |
|----|-------|----------------|
| yes | LinkedIn | `site:linkedin.com/jobs` |
| yes | BuiltIn | `site:builtin.com/job` |
| yes | Indeed | `site:indeed.com/viewjob` OR `site:indeed.com/jobs` |
| yes | Dice | `site:dice.com/job-detail` OR `site:dice.com/jobs` |
| yes | The Ladders | `site:theladders.com` |
| yes | Glassdoor | `site:glassdoor.com/Job` OR `site:glassdoor.com/job-listing` |
| yes | ZipRecruiter | `site:ziprecruiter.com/c` OR `site:ziprecruiter.com/jobs` |
| yes | Greenhouse | `site:boards.greenhouse.io` OR `site:job-boards.greenhouse.io` |
