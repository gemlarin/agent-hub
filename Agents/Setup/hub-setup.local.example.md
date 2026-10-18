# Agent hub — local overrides (private)

**Not committed to git.** `./Agents/Setup/scripts/bootstrap.sh` copies this file once per machine and fills origin + hub path when it can. To do it by hand:

```bash
# From hub root (your Projects folder):
cp Agents/Setup/hub-setup.local.example.md Agents/Setup/hub-setup.local.md
```

Edit `hub-setup.local.md` with your values. Agents may read it when setting up remotes or paths.

---

## Hub git remote

- **origin:** `https://github.com/gemlarin/agent-hub.git`
- **Hub root on disk:** `/path/to/Projects` (absolute path on this machine)

## Accounts & defaults

- **GitHub (apps):** Default org/user for application repo remotes — e.g. `https://github.com/gemlarin/`
- **Google Drive memory:** Optional label for which account syncs `My Drive/Documents/MEMORY.md` (not a password or token)

## Notes

- Machine name, SSH host aliases, or other device-only reminders.
