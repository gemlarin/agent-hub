---
name: help-getter
description: Hub help menu. Use when the user sends HELP by itself or invokes /help. Shows configuration, installed agents, installed skills, and memory settings.
disable-model-invocation: true
---

# help-getter

Help for agent-hub. Run this skill only when the prompt is `HELP` by itself, the user invokes `/help`, or they ask to use help-getter. A longer prompt that merely contains the word help is not this skill.

Read `Agents/Settings/CONFIG.md` when a menu item needs it. Do not dump `MEMORY.md`.

## Menu

Show this list and wait:

1. Display Configuration
2. List Agents
3. List Skills
4. Memory Information
5. Cancel

## Display Configuration

Read `Agents/Settings/CONFIG.md`. Show the file in one fenced code block. If the file is missing, say it is missing and show `Agents/Settings/CONFIG.example.md` in a fenced code block.

Then show the menu again.

## List Agents

Read `Agents/Subagents/README.md` (Using the agents) and the role lines in `Agents/Subagents/subagents.md`. List every installed specialist:

- Name
- Synopsis of what it does
- When it runs automatically

Include a specialist folder that exists under `Agents/Subagents/` even if the table is missing it. Then show the menu again.

## List Skills

Read `Agents/Skills/SKILLS.md`. List every installed skill:

- Skill name
- Which agent uses it
- Manual phrase for the next prompt
- Slash command

| Skill | Agent | Manual phrase | Slash |
|-------|--------|----------------|-------|
| memory-management | Memory Steward | Use the memory-management skill | `/memory-management` |
| git-merge | Git Coordinator | Use the git-merge skill | `/git-merge` |
| job-search | Job Finder | Use the Job Finder | `/job-search` |
| research | Research Scout | Use the research skill | `/research` |
| code-sweep | Code Sweeper | Use the code-sweep skill | `/code-sweep` |
| help-getter | main agent | HELP | `/help` |

Add any other `Agents/Skills/*/SKILL.md` the table misses. Then show the menu again.

## Memory Information

1. Read **MEMORY.md path** and **Memory max lines** from `Agents/Settings/CONFIG.md`. If that file is missing, also try **MEMORY.md path** in `Agents/Setup/hub-setup.local.md`.
2. The path is unset when it is empty, missing, or still `/absolute/path/to/MEMORY.md`.
3. When the path is unset, show this line and stop before the line-count:

`ERROR: Unset memory file path`

Ask whether to set up durable memory. Options: **YES** · **NO**.

- **YES:** Ask where the file should live (detected cloud file, `~/Documents/MEMORY.md`, or an absolute path outside the hub). Write **MEMORY.md path** in `Agents/Settings/CONFIG.md` and in `Agents/Setup/hub-setup.local.md`. Create the `MEMORY.md` stub if it is missing. Then continue with the counts below.
- **NO:** Show the help menu again.

4. When the path is set, show:

- The absolute path
- How many lines in that file have data (a line has data when it is not blank)
- **Memory max lines** from `CONFIG.md`

5. Ask whether to set up a new MEMORY file. Options: **YES** · **NO**.

- **NO:** Continue to the line-limit question below.
- **YES:** Ask for the path where the file should be stored. A directory means `MEMORY.md` inside it. The path must be absolute and outside the hub clone.
  - If that path cannot be created or written, say so and offer to help fix it. Do not change `CONFIG.md` until the file is in place.
  - If a `MEMORY.md` already exists at the current configured path, move that file to the new path. Do not create a second empty file.
  - If no memory file exists yet, create `MEMORY.md` at the new path.
  - If a file is already at the destination, do not overwrite it. Say so and ask for a different path.
  - Write **MEMORY.md path** in `Agents/Settings/CONFIG.md` and in `Agents/Setup/hub-setup.local.md`. Confirm the new path. Then continue to the line-limit question.

6. Ask whether to update the memory line limit. Options: **YES** · **NO**.

- **YES:** Ask how many lines the max should be. Write that positive integer to **Memory max lines** in `Agents/Settings/CONFIG.md`. Confirm the new value. Then show the help menu again.
- **NO:** Show the help menu again.

## Cancel

Tell the user: You have exited the help context.

Do not show the menu again.
