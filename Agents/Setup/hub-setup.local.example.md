# Agent hub — local overrides (private)

**Not committed to git.** `./Agents/Setup/scripts/bootstrap.sh` copies this file once per machine and fills origin, hub path, and `MEMORY.md path` when it can. To do it by hand:

```bash
# From hub root (your work folder):
cp Agents/Setup/hub-setup.local.example.md Agents/Setup/hub-setup.local.md
```

Edit the fields below. Same headings and keys as `hub-setup.local.md`.

---

## Hub git remote

- **origin:** `https://github.com/<your-github-user>/agent-hub.git`
- **Hub root on disk:** `/absolute/path/to/your-work-folder`

## Persistent memory

- **MEMORY.md path:** `/absolute/path/to/MEMORY.md`

## Accounts & defaults

- **GitHub (apps):** `https://github.com/<your-github-user>/`

## Notes

- (optional)
