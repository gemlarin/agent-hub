# Interactive inputs

When the user must pick from a known set, call the host question control before any numbered list. A typed reply still counts: the number, the label, or the option id.

Open this file only for a hub menu whose options are not already in the skill, `options.md`, or git menu file for this task. A plain **Yes** / **No** does not open it.

**This machine:** After this file, read `user-config.md` in this folder when it exists. Additions extend the rule. Overrides replace the matching part on this machine only. Never commit that file. Copy [user-config.example.md](./user-config.example.md) to create it.

## Hosts

- **Cursor:** Call the structured question UI. One option per choice. Multi-select only when several ids may be chosen together. That list does not take keyboard focus. A typed number, label, or option id still counts.
- **Claude** (claude.ai and the desktop app): Call the interactive input at the bottom of the chat. Multiple choice for one answer. Multi-select for several. Ranking only when the user is ordering items.
- **Any other app** with a clickable choice control: call that control the same way.
- **Numbered list:** Use `1` … `n` only after the host control is absent or the call fails. Do not skip the call because the tool list looks incomplete. Accept the number or the label.

Free text stays typed: a path, a line count, a commit message, a custom merge plan, or a list of file paths. Do not force those into a fixed option list.

An option label capitalizes the first letter of the first word. Every other letter is lowercase: **Agent generated**, **Yes**, **No**. Ids in each `options.md` stay unchanged. A typed id, **YES**, **NO**, or an older label still counts.

**Cancel**, **Exit**, and **Return to previous menu** are the last item in that menu. Other items stay in their own order. When a menu also has **Abort merge**, that choice is just before the return or cancel item.

## Where to ask this way


| Ask                             | Choices                                                                                                            | How many                                        |
| ------------------------------- | ------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------- |
| Help menu                       | Agent behaviors, Change code settings, Display configuration, Enable edit, List agents, List skills, Memory information, Cancel | One. Alphabetical, then Cancel.                 |
| Help: Enable edit               | Enable, Disable, Cancel                                                                                            | One. Cancel last.                               |
| Hub edit while disabled         | Yes, No. Yes sets **Enable edit** to `true`, then the requested edit proceeds. No stops.                           | One                                             |
| Help: Agent behaviors           | Reload agents, Recache agents, Cancel                                                                              | One. Cancel last.                               |
| Help: Change code settings      | Change code test settings, Cancel                                                                                  | One                                             |
| Help: code test settings        | Unit, Browser, Both, None. The stored value stays `UNIT`, `BROWSER`, `BOTH`, or `NONE`.                            | One                                             |
| Memory: path unset              | Yes, No                                                                                                            | One                                             |
| Memory information              | Set up a new memory file, Update the memory line limit, Cancel                                                     | One. Cancel last.                               |
| `git auto push`                 | Yes, No, Preview                                                                                                   | One                                             |
| `git add`                       | Git add all. A typed `git add all` still counts. Named paths stay typed.                                           | One, plus text                                  |
| `git push` with unstaged files  | Yes, No. Add them before the commit. Named paths stay typed.                                                       | One, plus text                                  |
| Git verb without the word `git` | Yes, No                                                                                                            | One                                             |
| Commit message                  | Custom, Agent generated. The message text stays typed.                                                             | One                                             |
| Push needs a merge              | Yes, No                                                                                                            | One                                             |
| Merge: conflict menu            | Review in merge tool, Agent merge, Abort merge, Return to previous menu                                            | One                                             |
| Merge: after the merge tool     | Retry merge, Return to previous menu                                                                               | One                                             |
| Merge: unsure hunk              | Keep ours, Accept incoming, Keep both, Agent suggestion                                                            | One                                             |
| Merge: markers remain           | Yes, No                                                                                                            | One                                             |
| Memory save menu                | `mem-save`, `mem-skip`, `mem-prefs`, `mem-projects`, `mem-solutions`, `mem-blockers`, `mem-forget`, `mem-prune`    | One                                             |
| Code sweep start                | Topics to run, Run all                                                                                             | One. Before any topic list.                     |
| Code sweep topics               | `aria`, `live`, `a11y`, `bugs`, `typos`, `smell`, `types`, `async`, `secrets`, `ci`, `dod`                         | Several. Only after Topics to run.              |
| Research or jobs output         | `out-chat`, `out-md`, `out-xml`, `out-raw`                                                                         | One. After the run completes, before follow-up. |
| Follow-up on results            | Yes, No                                                                                                            | One. After that output is delivered.            |
| Research follow-up              | `compare`, `cite`, `verify`, `versions`, `extract`, `actions`, `explain`, `gaps`, `deepen`, `timeline`, `expand`   | One. Only after Yes.                            |
| Job follow-up                   | `refine`, `compare`, `employers`, `widen`                                                                          | One. Only after Yes.                            |
| Setup: test default             | Unit, Browser, Both, None. The stored value stays `UNIT`, `BROWSER`, `BOTH`, or `NONE`.                            | One                                             |
| Setup: memory file              | Use the detected file, Type a path, Skip                                                                           | One. The path is typed.                         |


Show the memory save menu only when the user asked to save or the session is ending. Mid-session saves stay automatic and silent.

The exact words for each id stay in that skill's `options.md`. This rule only decides how the choice is shown.