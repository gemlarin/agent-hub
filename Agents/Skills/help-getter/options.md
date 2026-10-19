# Help menu

Show this list when help-getter is active. Offer it as an interactive choice when the host supports one ([interactive inputs](../../Rules/interactive-inputs/interactive-inputs.md)). Otherwise number it. The user replies with the item name or its number.

| Item | Result |
|------|--------|
| Change code settings | A second choice: **Change code test settings**, then **Cancel** |
| Display configuration | `CONFIG.md` in a code block |
| List agents | Installed agents, what they do, when they run |
| List skills | Installed skills, which agent uses each, manual phrase, slash command |
| Memory information | Memory path, data-line count, max lines, then **Set up a new memory file**, **Update the memory line limit**, and **Cancel** |
| Cancel | Exit. Tell the user: You have exited the help context. |

**Change code settings** choices, in this order:

| Item | Result |
|------|--------|
| Change code test settings | Ask **Unit**, **Browser**, **Both**, or **None**. Write the matching token to **Test default** in `CONFIG.md`. Confirm it. Do not run tests. Then show the main menu. |
| Cancel | Show the main menu again. Do not exit help. |

**Memory information** choices, after the path, data-line count, and max lines. **Cancel** is last:

| Item | Result |
|------|--------|
| Set up a new memory file | Ask for an absolute path outside the hub. A directory means `MEMORY.md` inside it. Move the current file, or create one if none exists. Do not overwrite a file already at the destination. Write **MEMORY.md path** in `CONFIG.md` and `hub-setup.local.md`. Confirm it. Then show the main menu. |
| Update the memory line limit | Ask how many lines. Write that positive integer to **Memory max lines** in `CONFIG.md`. Confirm it. Then show the main menu. |
| Cancel | Show the main menu again. Do not exit help. |

Open the menu with `HELP` alone or `/help`.
