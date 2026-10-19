# Interactive inputs

When the user must pick from a known set, use the host's interactive input if it has one. A typed reply still counts: the number, the label, or the option id.

**This machine:** After this file, read `user-config.md` in this folder when it exists. Additions extend the rule. Overrides replace the matching part on this machine only. Never commit that file. Copy [user-config.example.md](./user-config.example.md) to create it.

## Hosts

- **Cursor:** structured question UI. One option per choice. Multi-select only when several ids may be chosen together.
- **Claude** (claude.ai and the desktop app): interactive inputs at the bottom of the chat. Multiple choice for one answer. Multi-select for several. Ranking only when the user is ordering items.
- **Any other app** with a clickable choice control: use that control the same way.
- **No such control:** number the choices `1` … `n`. Accept the number or the label.

Free text stays typed: a path, a line count, a commit message, a custom merge plan, or a list of file paths. Do not force those into a fixed option list.

An option label capitalizes the first letter of the first word. Every other letter is lowercase: **Agent generated**, **Yes**, **No**. Ids in each `options.md` stay unchanged. A typed id, **YES**, **NO**, or an older label still counts.

## Where to ask this way

| Ask | Choices | How many |
| --- | --- | --- |
| Help menu | Cancel, Change code settings, Display configuration, List agents, List skills, Memory information | One. Alphabetical. |
| Help: Change code settings | Change code test settings, Cancel | One |
| Help: code test settings | Unit, Browser, Both, None. The stored value stays `UNIT`, `BROWSER`, `BOTH`, or `NONE`. | One |
| Memory: set up, new file, or change the line cap | Yes, No | One |
| `git auto push` | Yes, No, Preview | One |
| `git add` | Git add all. A typed `git add all` still counts. Named paths stay typed. | One, plus text |
| `git push` with unstaged files | Yes, No. Add them before the commit. Named paths stay typed. | One, plus text |
| Git verb without the word `git` | Yes, No | One |
| Commit message | Custom, Agent generated. The message text stays typed. | One |
| Push needs a merge | Yes, No | One |
| Merge: conflict menu | Review in merge tool, Agent merge, Abort merge, Return to previous menu | One |
| Merge: after the merge tool | Retry merge, Return to previous menu | One |
| Merge: unsure hunk | Keep ours, Accept incoming, Keep both, Agent suggestion | One |
| Merge: markers remain | Yes, No | One |
| Memory save menu | `mem-save`, `mem-skip`, `mem-prefs`, `mem-projects`, `mem-solutions`, `mem-blockers`, `mem-forget`, `mem-prune` | One |
| Code sweep topics | `aria`, `live`, `a11y`, `bugs`, `typos`, `smell`, `types`, `async`, `secrets`, `ci`, `dod` | Several |
| Research follow-up | `compare`, `cite`, `verify`, `versions`, `extract`, `actions`, `explain`, `gaps`, `deepen`, `timeline`, `expand` | One |
| Save research or jobs | `out-chat`, `out-md`, `out-xml`, `out-raw` | One |
| Setup: test default | Unit, Browser, Both, None. The stored value stays `UNIT`, `BROWSER`, `BOTH`, or `NONE`. | One |
| Setup: memory file | Use the detected file, Type a path, Skip | One. The path is typed. |

Show the memory save menu only when the user asked to save or the session is ending. Mid-session saves stay automatic and silent.

The exact words for each id stay in that skill's `options.md`. This rule only decides how the choice is shown.
