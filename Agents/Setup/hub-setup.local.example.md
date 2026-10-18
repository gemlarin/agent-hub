# Agent hub — local overrides (private)

**Not committed to git.** Copy this file once per machine:

```bash
# From hub root (your Projects folder):
cp Agents/Setup/hub-setup.local.example.md Agents/Setup/hub-setup.local.md
```

Edit `hub-setup.local.md` with your values. Agents may read it when setting up remotes or paths.

---

## Hub git remote

- **origin:** `https://github.com/<your-github-user>/agent-hub.git`
- **Hub root on disk:** `/path/to/Projects` (absolute path on this machine)

## Accounts & defaults

- **GitHub (apps):** Default org/user for application repo remotes — e.g. `https://github.com/<your-github-user>/`
- **Google Drive memory:** Optional label for which account syncs `My Drive/Documents/MEMORY.md` (not a password or token)

## Notes

- Machine name, SSH host aliases, or other device-only reminders.
