# agent-hub

Shared **agent hub**: rules, subagents, and skills for the apps on your machine. Any AI app that can read [`Agents/AGENTS.md`](./Agents/AGENTS.md) can use it. **Cursor is optional.**

This file is for people. Agents read [`Agents/AGENTS.md`](./Agents/AGENTS.md). Extra setup detail: [`Agents/Setup/hub-setup.md`](./Agents/Setup/hub-setup.md).

---

## 1. Download

Start from the folder where your project files live, or where you want them to live. In the commands below, `code` is only an example. Use the name your root work directory already has (`Projects`, `dev`, `src`, or whatever it is called).

Forks: use your fork URL instead of `https://github.com/gemlarin/agent-hub.git`.

### Apps will sit next to the hub

This is the usual layout. The work folder becomes the hub git root, and `Agents/` sits beside your apps. Pointers in those apps use `../Agents/AGENTS.md` (or `../../Agents/AGENTS.md` if the app is one folder deeper).

**The folder is new or empty**

macOS, Linux, or Git Bash:

```bash
WORK=~/code   # change "code" to your work folder's real name
git clone https://github.com/gemlarin/agent-hub.git "$WORK"
```

Windows cmd (Git for Windows):

```bat
REM Change "code" to your work folder's real name
set WORK=%USERPROFILE%\code
git clone https://github.com/gemlarin/agent-hub.git %WORK%
```

PowerShell: `$WORK = "$env:USERPROFILE\code"  # change "code" to your work folder's real name`, then `git clone https://github.com/gemlarin/agent-hub.git $WORK`.

**The folder already has apps**

`git clone` will not write into a folder that already has files. From that folder:

```bash
cd "$WORK"
git init
git remote add origin https://github.com/gemlarin/agent-hub.git
git fetch origin
git checkout -t origin/main
```

The hub `.gitignore` leaves those app folders untracked. If `README.md` or `.gitignore` is already in that folder, fix the checkout conflict before you install.

### The hub is its own folder next to your apps

The work folder stays a normal directory. The clone lives inside it as `agent-hub/`. Pointers in sibling apps use `../agent-hub/Agents/AGENTS.md`.

```bash
git clone https://github.com/gemlarin/agent-hub.git "$WORK/agent-hub"
```

---

## 2. Install

Open the downloaded folder in the AI app you already use. You do not need Cursor. The app follows `Agents/AGENTS.md`. Cursor-only files (`.cursor/`, `.githooks/`) stay in this clone and are not required.

### Automatic

In that AI app, say **set up the hub**.

The installer detects your OS and asks:

- where to keep `MEMORY.md` (cloud storage or a file on this computer)
- your GitHub username
- which current project folders to link

Saying yes to a project writes or replaces that project's `AGENTS.md` so it points at this hub's `Agents/AGENTS.md`. You do not need [Point app repos at the hub](#point-app-repos-at-the-hub) for those folders. That section is only for project folders you add later. The installer does not commit.

### Manual

From the hub root (the folder that contains `Agents/`):

```bash
./Agents/Setup/scripts/setup.sh
```

Windows (Git for Windows): `Agents\Setup\scripts\setup.cmd`

The script asks the same questions and links the projects you pick. Folders you link here already point at the hub. Use [Point app repos at the hub](#point-app-repos-at-the-hub) only for project folders you add later.

To skip the script and do it yourself:

1. Copy [`Agents/Setup/hub-setup.local.example.md`](./Agents/Setup/hub-setup.local.example.md) to `Agents/Setup/hub-setup.local.md`. Set the hub path and the [memory path](#persistent-memory).
2. Add a pointer `AGENTS.md` in each app. Use the examples in [Point app repos at the hub](#point-app-repos-at-the-hub).
3. **Cursor only:** if that app's User Rules tell the agent to run git, paste [`Agents/Setup/cursor-user-rules.md`](./Agents/Setup/cursor-user-rules.md), then reload. Skip this step in every other AI app.

More detail: **[Agents/Setup/hub-setup.md](./Agents/Setup/hub-setup.md)**

---

## Point app repos at the hub

Skip this section if setup already linked your projects. Use it when you add another project folder later.

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

When your AI app has an **app** open, that pointer is how it loads hub **policy**. When it has this hub clone open, it should read `Agents/AGENTS.md` directly (there is no hub `AGENTS.md` at the clone root). Cursor is one app that can do this. Any other AI app that reads `AGENTS.md` can do the same.

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

Never commit `MEMORY.md`. Prefer a path **outside** this clone. Keep the file **short** (target ≤80 lines) so new chats stay cheap. Policy for agents: [`Agents/Memory/memory.md`](./Agents/Memory/memory.md). The main agent reads it once per session and auto-saves viable facts mid-session (you’ll see `Durable memory saved to MEMORY file`). Option ids appear when you ask to save or at wrap-up. Memory Steward writes only that file. Other specialists do not load it.

---

## Layout

| Path | Purpose |
|------|---------|
| [`Agents/AGENTS.md`](./Agents/AGENTS.md) | Entry point for agents (on-demand module table) |
| [`Agents/`](./Agents/) | Subagents, **[Rules/](./Agents/Rules/)**, memory, **[Setup/](./Agents/Setup/)**, **[Skills/](./Agents/Skills/)** — [how to contribute](./Agents/README.md) |
| [`.cursor/`](./.cursor/) | Cursor agents, rules, hooks — **hub workspace root only** — [how to contribute](./.cursor/README.md) |
| [`.githooks/`](./.githooks/) | Hub-repo git hooks (post-merge regen); not inherited by apps — [how to contribute](./.githooks/README.md) |
| App folders | Separate git repos. Siblings of `Agents/` when the work folder is the hub root; otherwise next to the `agent-hub/` clone |

**Memory:** path in gitignored `Agents/Setup/hub-setup.local.md` — [`Agents/Memory/memory.md`](./Agents/Memory/memory.md).

---

## Highlights

- **Git Coordinator** — [`Agents/Subagents/git-coordinator/git-coordinator.md`](./Agents/Subagents/git-coordinator/git-coordinator.md)
- **Job Finder** — [`Agents/Subagents/job-finder/job-finder.md`](./Agents/Subagents/job-finder/job-finder.md) (only if you ask for a job search)
- **Subagents** — [`Agents/Subagents/subagents.md`](./Agents/Subagents/subagents.md) · [using them](./Agents/Subagents/README.md#using-the-agents-users)
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
| [`Agents/Subagents/`](./Agents/Subagents/README.md) | Specialist specs ([how to use each agent](./Agents/Subagents/README.md#using-the-agents-users); [attach a skill](./Agents/Subagents/README.md#attach-a-skill-to-a-specialist)). Copy `user-config.example.md` to `user-config.md` in a specialist folder for machine-only overrides (gitignored). |
| [`Agents/Memory/`](./Agents/Memory/README.md) | Session contract for `MEMORY.md`. No local override file |
| [`Agents/Skills/`](./Agents/Skills/README.md) | Load-on-demand skills ([how to run one](./Agents/Skills/README.md#activate-a-skill-independently-users)). Copy `user-config.example.md` to `user-config.md` in a skill folder for machine-only overrides (gitignored). |
| [`Agents/Rules/`](./Agents/Rules/README.md) | Shared standards. Each rule folder has a contribute README. Copy `user-config.example.md` to `user-config.md` for machine-only overrides (gitignored). |
| [`Agents/Setup/`](./Agents/Setup/README.md) | Bootstrap and Cursor install |
| [`Agents/Setup/scripts/`](./Agents/Setup/scripts/README.md) | Setup scripts |
| [`.cursor/`](./.cursor/README.md) | Generated Cursor agents, rules, hooks |
| [`.githooks/`](./.githooks/README.md) | Hub-only git `post-merge` |

**Do not** put hub policy in app repos (pointer `AGENTS.md` only). **Do not** commit `MEMORY.md`, `Agents/Setup/hub-setup.local.md`, `Agents/Rules/**/user-config.md`, `Agents/Skills/**/user-config.md`, or `Agents/Subagents/**/user-config.md`. After editing `Agents/Subagents/`, regen Cursor agents ([Highlights](#highlights)). In **this** git root, parent agents must not run `git`/`gh` — Git Coordinator only.

## Forking

1. Fork on GitHub, then [download](#1-download) your fork into your work folder or as `agent-hub/` next to your apps.
2. [Install](#2-install) automatically (say **set up the hub**) or manually (`setup.sh` / `setup.cmd`, or the by-hand steps).
3. Add a pointer `AGENTS.md` only for project folders setup did not link. See [Point app repos at the hub](#point-app-repos-at-the-hub).

---

## License

Add a license if you publish publicly; otherwise treat as private team config.
