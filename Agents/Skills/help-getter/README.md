# help-getter

Help menu for agent-hub. The main agent runs it. It is not a subagent.

**Source:** [`SKILL.md`](./SKILL.md). Menu: [`options.md`](./options.md).

## Open it

Send a prompt that is only:

```text
HELP
```

or invoke `/help`.

`HELP` inside a longer sentence does not open the menu. In Cursor, `/help` appears after setup links this folder to `.cursor/skills/help`. If it is missing, run `Agents/Setup/scripts/sync-cursor-skills.sh` and reload Cursor.

## Menu

| Item | What you get |
|------|----------------|
| Display Configuration | `Agents/Settings/CONFIG.md` in a code block. If that file is missing, the example file is shown instead. |
| List Agents | Each installed agent, a one-line synopsis, and when it runs on its own. |
| List Skills | Each installed skill, which agent uses it, the phrase to type, and the `/` command. |
| Memory Information | Memory path, how many lines in that file have data, and **Memory max lines**. Can point the file at a new path or change the line cap. |
| Cancel | Leaves the menu. The agent says: You have exited the help context. |

After every item except Cancel, the menu is shown again.

## Memory Information

When **MEMORY.md path** is empty or still the placeholder, the agent shows:

`ERROR: Unset memory file path`

**YES** walks through where the file should live, writes the path into `CONFIG.md` and `hub-setup.local.md`, and creates the file if it is missing. **NO** returns to the help menu.

When the path is set, the agent asks whether to set up a new MEMORY file. **YES** asks for a path. An existing memory file is moved there. If none exists, a new `MEMORY.md` is created. If the path cannot be written, the agent says so and offers to help fix it. **NO** leaves the file where it is.

The agent then asks whether to change the line cap. **YES** asks how many lines and writes **Memory max lines** in `CONFIG.md`. **NO** returns to the help menu.

The test default is not changed here. Prompt `CHANGE CODE SETTINGS` for that. Details: [`../../Settings/README.md`](../../Settings/README.md).

## Contribute

- Keep this menu aligned with [`options.md`](./options.md) and [`SKILL.md`](./SKILL.md).
- Keep the skill listed in [`../SKILLS.md`](../SKILLS.md).
- Do not commit `user-config.md`.

## Local settings

Copy [`user-config.example.md`](./user-config.example.md) to `user-config.md`. That file stays on your machine.
