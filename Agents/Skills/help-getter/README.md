# help-getter

Help menu for agent-hub. The main agent runs it. It is not a subagent.

**Source:** [`SKILL.md`](./SKILL.md). Menu: [`options.md`](./options.md).

## Open it

The menu is a clickable choice when the app supports one, and a numbered list otherwise. See [interactive inputs](../../Rules/interactive-inputs/interactive-inputs.md).

Send a prompt that is only:

```text
HELP
```

or invoke `/help`.

`HELP` inside a longer sentence does not open the menu. In Cursor, `/help` appears after setup links this folder to `.cursor/skills/help`. If it is missing, run `Agents/Setup/scripts/sync-cursor-skills.sh` and reload Cursor.

## Menu

| Item | What you get |
|------|----------------|
| Change code settings | A second choice. **Change code test settings** stores a new **Test default**. **Cancel** returns to this list. |
| Display configuration | `Agents/Settings/CONFIG.md` in a code block. If that file is missing, the example file is shown instead. |
| List agents | Each installed agent, a one-line synopsis, and when it runs on its own. |
| List skills | Each installed skill, which agent uses it, the phrase to type, and the `/` command. |
| Memory information | Memory path, how many lines in that file have data, and **Memory max lines**. Can point the file at a new path or change the line cap. |
| Cancel | Leaves help. The agent says: You have exited the help context. |

The other items stay alphabetical. **Cancel** is last. After every item except **Cancel**, the menu is shown again.

## Change code settings

| Item | What you get |
|------|----------------|
| Change code test settings | **Unit**, **Browser**, **Both**, or **None**. The agent writes the matching token to **Test default** in `CONFIG.md`, confirms it, and does not run tests. |
| Cancel | The main help list again. Help stays open. |

## Memory information

When **MEMORY.md path** is empty or still the placeholder, the agent shows:

`ERROR: Unset memory file path`

**Yes** walks through where the file should live, writes the path into `CONFIG.md` and `hub-setup.local.md`, and creates the file if it is missing. **No** returns to the help menu.

When the path is set, the agent shows the path, how many lines have data, and **Memory max lines**. Then it offers:

| Item | What you get |
|------|----------------|
| Set up a new memory file | Asks for a path. An existing memory file is moved there. If none exists, a new `MEMORY.md` is created. If the path cannot be written, the agent says so and offers to help fix it. |
| Update the memory line limit | Asks how many lines and writes **Memory max lines** in `CONFIG.md`. |
| Cancel | The main help list again. Help stays open. |

The test default is changed from **Change code settings** on this menu. Details: [`../../Settings/README.md`](../../Settings/README.md).

## Contribute

- Keep this menu aligned with [`options.md`](./options.md) and [`SKILL.md`](./SKILL.md).
- Keep the skill listed in [`../SKILLS.md`](../SKILLS.md).
- Do not commit `user-config.md`.

## Local settings

Copy [`user-config.example.md`](./user-config.example.md) to `user-config.md`. That file stays on your machine.
