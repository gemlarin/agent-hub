# Job boards

This is the **default** list. Job Finder searches every row whose **On** column is `yes`.

**Your list:** copy [`boards.local.example.md`](./boards.local.example.md) to `boards.local.md` in this folder. That file is gitignored. When it exists, Job Finder uses it **instead of** this file, so a hub update will not wipe your boards.

To change the defaults for everyone, edit the table below. To change them only on your machine, edit `boards.local.md`.

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

Add a row to include a board. Set **On** to `no` to skip it without deleting the row. **Site / query** is what gets combined with the resume titles, skills, work mode, and location.

**Location modifiers**

- Remote: `remote` OR `"work from home"`
- Hybrid: `hybrid`
- In-office: `"<city>" "<state>"` and exclude obvious remote-only if the user required on-site

**Salary:** include `$<min>` or `"<min>000"` when it helps the index; still verify on the posting.

**Large employers (in-office extra):** search `"largest employers" "<city>" "<state>"` (or chamber / metro economic-development lists). Then `"<company>" (careers OR jobs) "<title keywords>"`.
