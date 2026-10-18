# Job board query patterns

Use `site:` (or equivalent) plus resume titles, skills, work mode, and location. Fetch the posting page for description + apply URL when the search snippet is thin.

| Board | Site / query |
|-------|----------------|
| LinkedIn | `site:linkedin.com/jobs` |
| BuiltIn | `site:builtin.com/job` |
| Indeed | `site:indeed.com/viewjob` OR `site:indeed.com/jobs` |
| Dice | `site:dice.com/job-detail` OR `site:dice.com/jobs` |
| The Ladders | `site:theladders.com` |
| Glassdoor | `site:glassdoor.com/Job` OR `site:glassdoor.com/job-listing` |
| ZipRecruiter | `site:ziprecruiter.com/c` OR `site:ziprecruiter.com/jobs` |
| Greenhouse | `site:boards.greenhouse.io` OR `site:job-boards.greenhouse.io` |

**Location modifiers**

- Remote: `remote` OR `"work from home"`
- Hybrid: `hybrid`
- In-office: `"<city>" "<state>"` and exclude obvious remote-only if the user required on-site

**Salary:** include `$<min>` or `"<min>000"` when it helps the index; still verify on the posting.

**Large employers (in-office extra):** search `"largest employers" "<city>" "<state>"` (or chamber / metro economic-development lists). Then `"<company>" (careers OR jobs) "<title keywords>"`.
