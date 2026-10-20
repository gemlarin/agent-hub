---
name: help-getter
description: Hub help menu. Use when the user sends HELP by itself or invokes /help. Shows configuration, installed agents, installed skills, memory settings, and the code test default.
disable-model-invocation: true
---

# help-getter

Help for agent-hub. Run this skill only when the prompt is `HELP` by itself, the user invokes `/help`, or they ask to use help-getter. A longer prompt that merely contains the word help is not this skill.

Read `Agents/Settings/CONFIG.md` when a menu item needs it. Do not dump `MEMORY.md`.

## Menu

Offer this list as one host question control ([interactive inputs](../../Rules/interactive-inputs/interactive-inputs.md)). Keep the items in alphabetical order, then **Cancel** last. Call that control before any numbered list. Number only if the control is absent or the call fails. Wait either way:

1. Agent behaviors
2. Change code settings
3. Display configuration
4. List agents
5. List skills
6. Memory information
7. Cancel

## Agent behaviors

Offer **Reload agents**, **Recache agents**, and **Cancel** as one host question control. **Cancel** is last. Call that control before any numbered list. Number only if the control is absent or the call fails. Wait either way.

**Reload agents** and **Recache agents** do the same thing. Re-read the load table (`Agents/AGENTS.md`, or the file the app pointer names) and any hub behavior file already opened this session. Do not walk the whole `Agents/` tree. Do not open a specialist spec this session has not already opened. Tell the user those files were read again. Then show the main help menu.

Typing `reload agents` or `recache agents` outside this menu does that same read. It does not open help.

### Cancel

Show the main help menu again. Do not exit help.

## Change code settings

Offer this list as one host question control. Call that control before any numbered list. Number only if the control is absent or the call fails. Wait either way:

1. Change code test settings
2. Cancel

### Change code test settings

Offer **Unit**, **Browser**, **Both**, **None** as one host question control. Write the matching token `UNIT`, `BROWSER`, `BOTH`, or `NONE` to **Test default** in `Agents/Settings/CONFIG.md`. If that file is missing, copy `Agents/Settings/CONFIG.example.md` to `Agents/Settings/CONFIG.md`, then write the value. Confirm the new value. Do not run tests. Then show the main help menu again.

### Cancel

Show the main help menu again. Do not exit help.

## Display configuration

Read `Agents/Settings/CONFIG.md`. Show the file in one fenced code block. If the file is missing, say it is missing and show `Agents/Settings/CONFIG.example.md` in a fenced code block.

Then show the menu again.

## List agents

Read `Agents/Subagents/README.md` (Using the agents). Do not open `subagents.md` or a specialist spec. List every installed specialist:

- Name
- Synopsis of what it does
- When it runs automatically

Include a specialist folder that exists under `Agents/Subagents/` even if the table is missing it. Then show the menu again.

## List skills

Read `Agents/Skills/SKILLS.md`. Show every installed skill as an inline HTML table. Do not use a Markdown table. The chat styles these classes.

```html
<div class="vis-section-stack">
  <p class="vis-sr-only">Installed skills, which agent uses each, the phrase to type next, and the slash command.</p>
  <div class="vis-table-responsive">
    <table class="vis-table">
      <thead>
        <tr>
          <th>Skill</th>
          <th>Agent</th>
          <th>Manual phrase</th>
          <th>Slash</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td><code>memory-management</code></td>
          <td>Memory Steward</td>
          <td>Use the memory-management skill</td>
          <td><code>/memory-management</code></td>
        </tr>
      </tbody>
    </table>
  </div>
</div>
```

One row per skill. Put the skill name and the slash command in `<code>`. Add any other `Agents/Skills/*/SKILL.md` the rows miss.

| Skill | Agent | Manual phrase | Slash |
|-------|--------|----------------|-------|
| memory-management | Memory Steward | Use the memory-management skill | `/memory-management` |
| git-merge | Git Coordinator | Use the git-merge skill | `/git-merge` |
| job-search | Job Finder | Use the Job Finder | `/job-search` |
| research | Research Scout | Use the research skill | `/research` |
| code-sweep | Code Sweeper | Use the code-sweep skill | `/code-sweep` |
| help-getter | main agent | HELP | `/help` |

Then show the menu again.

## Memory information

1. Read **MEMORY.md path** and **Memory max lines** from `Agents/Settings/CONFIG.md`. If that file is missing, also try **MEMORY.md path** in `Agents/Setup/hub-setup.local.md`.
2. The path is unset when it is empty, missing, or still `/absolute/path/to/MEMORY.md`.
3. When the path is unset, show this line and stop before the line-count:

`ERROR: Unset memory file path`

Ask whether to set up durable memory with the host question control. Options: **Yes** · **No**.

- **Yes:** Ask where the file should live (detected cloud file, `~/Documents/MEMORY.md`, or an absolute path outside the hub). Write **MEMORY.md path** in `Agents/Settings/CONFIG.md` and in `Agents/Setup/hub-setup.local.md`. Create the `MEMORY.md` stub if it is missing. Then continue with the counts below.
- **No:** Show the help menu again.

4. When the path is set, show:

- The absolute path
- How many lines in that file have data (a line has data when it is not blank)
- **Memory max lines** from `CONFIG.md`

5. Offer this list as one host question control. **Cancel** is last:

1. Set up a new memory file
2. Update the memory line limit
3. Cancel

### Set up a new memory file

Ask for the path where the file should be stored. A directory means `MEMORY.md` inside it. The path must be absolute and outside the hub clone.

- If that path cannot be created or written, say so and offer to help fix it. Do not change `CONFIG.md` until the file is in place.
- If a `MEMORY.md` already exists at the current configured path, move that file to the new path. Do not create a second empty file.
- If no memory file exists yet, create `MEMORY.md` at the new path.
- If a file is already at the destination, do not overwrite it. Say so and ask for a different path.
- Write **MEMORY.md path** in `Agents/Settings/CONFIG.md` and in `Agents/Setup/hub-setup.local.md`. Confirm the new path. Then show the main help menu again.

### Update the memory line limit

Ask how many lines the max should be. Write that positive integer to **Memory max lines** in `Agents/Settings/CONFIG.md`. Confirm the new value. Then show the help menu again.

### Cancel

Show the main help menu again. Do not exit help.

## Cancel

Tell the user: You have exited the help context.

Do not show the menu again.
