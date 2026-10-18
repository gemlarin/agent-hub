# agent-hub

Shared **agent hub**: rules, subagents, and skills. Clone this repo, then in each app add a stub `AGENTS.md` that points at [`Agents/AGENTS.md`](./Agents/AGENTS.md). Works with **any** agent that follows that file. **Cursor** integration is **optional** under [`Agents/Setup/`](./Agents/Setup/).

This file is the hub overview. Agents read [`Agents/AGENTS.md`](./Agents/AGENTS.md). Humans read this file and [`Agents/Setup/hub-setup.md`](./Agents/Setup/hub-setup.md) when installing or moving machines.

---

## Quick start

**Guided setup** (after this repo is on disk). One command detects macOS, Linux, WSL, or Windows, asks for the memory file, GitHub username, and which apps get a pointer, then finishes config:

```bash
./Agents/Setup/scripts/setup.sh
```

Windows (Git for Windows): `Agents\Setup\scripts\setup.cmd`

In Cursor, say **set up the hub**. The Hub Installer agent asks those questions in chat and runs the same command. It does not commit.

Pick a **work folder** first if you still need to clone: the directory that holds (or will hold) your app repos. The name does not matter (`~/Projects`, `~/code`, `~/dev`, `D:\work`, …). In the usual layout that folder **is** the hub git root, so `Agents/` sits next to the apps.

**macOS / Linux / Git Bash** — new or empty work folder:

```bash
WORK=~/code   # your work folder
git clone https://github.com/gemlarin/agent-hub.git "$WORK"
cd "$WORK"
./Agents/Setup/scripts/setup.sh
```

**Windows (cmd)** — Git for Windows required. New or empty work folder:

```bat
set WORK=%USERPROFILE%\code
git clone https://github.com/gemlarin/agent-hub.git %WORK%
cd /d %WORK%
Agents\Setup\scripts\setup.cmd
```

PowerShell: `$WORK = "$env:USERPROFILE\code"`, then `git clone https://github.com/gemlarin/agent-hub.git $WORK`.

**Work folder already has apps.** `git clone` refuses a non-empty directory. From that folder:

```bash
cd "$WORK"
git init
git remote add origin https://github.com/gemlarin/agent-hub.git
git fetch origin
git checkout -t origin/main
./Agents/Setup/scripts/setup.sh
```

The hub `.gitignore` ignores everything except hub files, so sibling app folders stay untracked. If `README.md` or `.gitignore` already exists in that folder, resolve the checkout conflict before setup.

**Hub as its own folder** (work folder stays a normal directory, not this git repo):

```bash
git clone https://github.com/gemlarin/agent-hub.git "$WORK/agent-hub"
cd "$WORK/agent-hub"
./Agents/Setup/scripts/setup.sh
```

Use that layout’s pointer (`../agent-hub/Agents/AGENTS.md`). Do **not** use `../Agents/AGENTS.md` unless `Agents/` is a direct child of the work folder. Forks: clone your fork URL instead of `gemlarin/agent-hub`.

`setup.sh` asks for the [memory path](#persistent-memory). Bootstrap then asks whether to link current project directories. Saying yes writes or replaces `AGENTS.md` in each selected project so it points at this hub's `Agents/AGENTS.md`. **Cursor:** paste [`Agents/Setup/cursor-user-rules.md`](./Agents/Setup/cursor-user-rules.md) only if default git User Rules tell the parent to run `git`. The installer cannot change Cursor settings for you.

Full steps: **[Agents/Setup/hub-setup.md](./Agents/Setup/hub-setup.md)**

---

## Point app repos at the hub

Canonical policy is **[`Agents/AGENTS.md`](./Agents/AGENTS.md)**. Do **not** copy hub policy into each app, and do **not** symlink this file.

At each **app repo root**, add `AGENTS.md` whose link is the relative path from that app to this clone. Examples:

**App next to this clone** (`~/code/my-app/` + `~/code/agent-hub/`):

```markdown
# AGENTS.md (pointer)

Agent rules for this repo are defined at the **agent hub**, not in this file.

**Read and follow:** [`../agent-hub/Agents/AGENTS.md`](../agent-hub/Agents/AGENTS.md).

That hub is the source of truth for agent rules. Apply it (and everything it references) before any task in this repo.
```

**App is a sibling of `Agents/`** (work folder is the hub root, app at `work/Portfolio/`):

```markdown
# AGENTS.md (pointer)

Agent rules for this repo are defined at the **agent hub**, not in this file.

**Read and follow:** [`../Agents/AGENTS.md`](../Agents/AGENTS.md).

That hub is the source of truth for agent rules. Apply it (and everything it references) before any task in this repo.
```

**App is one extra level down** (`work/Vue/Cairn/`):

```markdown
# AGENTS.md (pointer)

Agent rules for this repo are defined at the **agent hub**, not in this file.

**Read and follow:** [`../../Agents/AGENTS.md`](../../Agents/AGENTS.md).

That hub is the source of truth for agent rules. Apply it (and everything it references) before any task in this repo.
```

When Cursor’s workspace is the **app**, that pointer is how the agent loads hub **policy**. When the workspace is this hub clone, read `Agents/AGENTS.md` directly (there is no hub `AGENTS.md` at the clone root).

### What the pointer loads

The stub is the generic contract. It does **not** pull the hub’s `.cursor/` or `.githooks/` into the app.

| Follows the `AGENTS.md` pointer | Stays at this clone’s git / workspace root |
|---------------------------------|--------------------------------------------|
| Policy, skills, subagent specs under `Agents/` | [`.cursor/`](./.cursor/) — Task types, git-delegation rule and hooks |
| Nested `AGENTS.md` in the app | [`.githooks/`](./.githooks/) — hub-only git hooks (`core.hooksPath`) |

Do **not** move `.cursor/` or `.githooks/` into `Agents/`. Cursor only reads `.cursor/` from the **opened workspace root**. Git hooks only run in the repo that sets `core.hooksPath`. Opening an app therefore gets hub rules via the pointer, but not `git-coordinator` as a Cursor Task type unless that workspace has its own `.cursor/agents/` (or you open this hub). User-level `~/.cursor/` is the other way to share Cursor extras across apps.

---

## Persistent memory

Agents keep durable notes in **one** `MEMORY.md` file. Use **cloud storage** (Google Drive, iCloud, Dropbox, …) if you want the same file on every machine, or a **local file** if this computer is enough.

Configure the absolute path in gitignored [`Agents/Setup/hub-setup.local.md`](./Agents/Setup/hub-setup.local.md) (bootstrap copies the [example](./Agents/Setup/hub-setup.local.example.md)):

```markdown
## Persistent memory

- **MEMORY.md path:** `/absolute/path/to/MEMORY.md`
```

Examples:

| Kind | Path |
|------|------|
| Google Drive for Desktop (Mac) | `~/Library/CloudStorage/GoogleDrive-<account>/My Drive/Documents/MEMORY.md` |
| Google Drive for Desktop (Windows) | `~/Google Drive/My Drive/Documents/MEMORY.md` |
| Local only | `~/Documents/MEMORY.md` |

Never commit `MEMORY.md`. Prefer a path **outside** this clone. Keep the file **short** (target ≤80 lines) so new chats stay cheap. Policy for agents: [`Agents/memory.md`](./Agents/memory.md). The main agent reads it once per session and auto-saves viable facts mid-session (you’ll see `Durable memory saved to MEMORY file`). Option ids appear when you ask to save or at wrap-up. Memory Steward writes only that file. Other specialists do not load it.

---

## Layout

| Path | Purpose |
|------|---------|
| [`Agents/AGENTS.md`](./Agents/AGENTS.md) | Entry point for agents (on-demand module table) |
| [`Agents/`](./Agents/) | Subagents, coding standards, memory, **[Setup/](./Agents/Setup/)**, **[Skills/](./Agents/Skills/)** — [how to contribute](./Agents/README.md) |
| [`.cursor/`](./.cursor/) | Cursor agents, rules, hooks — **hub workspace root only** — [how to contribute](./.cursor/README.md) |
| [`.githooks/`](./.githooks/) | Hub-repo git hooks (post-merge regen); not inherited by apps — [how to contribute](./.githooks/README.md) |
| App folders | Separate git repos. Siblings of `Agents/` when the work folder is the hub root; otherwise next to the `agent-hub/` clone |

**Memory:** path in gitignored `Agents/Setup/hub-setup.local.md` — [`Agents/memory.md`](./Agents/memory.md).

---

## Highlights

- **Git Coordinator** — [`Agents/Subagents/git-coordinator.md`](./Agents/Subagents/git-coordinator.md)
- **Job Finder** — [`Agents/Subagents/job-finder.md`](./Agents/Subagents/job-finder.md) (only if you ask for a job search)
- **Subagents** — [`Agents/subagents.md`](./Agents/subagents.md) · [using them](./Agents/Subagents/README.md#using-the-agents-users)
- **Coding standards** — core + optional Vue split

After editing `Agents/Subagents/`:

```bash
./Agents/Setup/scripts/install-cursor-integration.sh --force
```

Windows: `Agents\Setup\scripts\setup.cmd` already ran sync on first install; regen with Git Bash (`./Agents/Setup/scripts/install-cursor-integration.sh --force`) or `py -3 Agents/Setup/scripts/sync_cursor_agents.py`.

---

## Contributing

This repo is **policy + Cursor glue**, not an application. Each folder has a README that covers design and how to change it:

| Level | README |
|-------|--------|
| Hub clone (this file) | Install, pointers, memory path |
| [`Agents/`](./Agents/README.md) | Canonical agent policy |
| [`Agents/Subagents/`](./Agents/Subagents/README.md) | Specialist specs ([how to use each agent](./Agents/Subagents/README.md#using-the-agents-users)) |
| [`Agents/Skills/`](./Agents/Skills/README.md) | Load-on-demand skills ([how to run one](./Agents/Skills/README.md#activate-a-skill-independently-users); [research options](./Agents/Skills/research/options.md)) |
| [`Agents/Setup/`](./Agents/Setup/README.md) | Bootstrap and Cursor install |
| [`Agents/Setup/scripts/`](./Agents/Setup/scripts/README.md) | Setup scripts |
| [`.cursor/`](./.cursor/README.md) | Generated Cursor agents, rules, hooks |
| [`.githooks/`](./.githooks/README.md) | Hub-only git `post-merge` |

**Do not** put hub policy in app repos (pointer `AGENTS.md` only). **Do not** commit `MEMORY.md` or `Agents/Setup/hub-setup.local.md`. After editing `Agents/Subagents/`, regen Cursor agents ([Highlights](#highlights)). In **this** git root, parent agents must not run `git`/`gh` — Git Coordinator only.

## Forking

1. Fork on GitHub; `git clone` your fork into your work folder (that folder becomes the hub root), or as `agent-hub/` next to your apps.
2. Run `setup.sh` or `setup.cmd` (detects the OS, asks the remaining questions, then runs bootstrap).
3. Pointer `AGENTS.md` in each app repo (see above).

---

## License

Add a license if you publish publicly; otherwise treat as private team config.
