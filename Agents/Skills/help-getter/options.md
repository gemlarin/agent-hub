# Help menu

Show this list when help-getter is active. Call the host question control first. The choices are in this file. Do not open the interactive-inputs catalog. Number it only if that control is absent or the call fails. The user replies with the item name or its number.

| Item | Result |
|------|--------|
| Agent behaviors | A second choice: **Reload agents**, **Recache agents**, then **Cancel** |
| Change code settings | A second choice: **Change code test settings**, then **Cancel** |
| Display configuration | `CONFIG.md` in a code block |
| Enable edit | A second choice: **Enable**, **Disable**, then **Cancel** |
| List agents | Installed agents, what they do, when they run |
| List skills | Installed skills, which agent uses each, manual phrase, slash command |
| Memory information | Memory path, data-line count, max lines, then **Set up a new memory file**, **Update the memory line limit**, and **Cancel** |
| Cancel | Exit. Tell the user: You have exited the help context. |

**Agent behaviors** choices, in this order. **Cancel** is last:

| Item | Result |
|------|--------|
| Reload agents | Re-read the load table and any hub behavior file already opened this session. Do not walk the whole `Agents/` tree. Do not open a specialist spec this session has not already opened. The next git Task tells Git Coordinator to read its procedure once. Then show the main menu. |
| Recache agents | Same read as **Reload agents**. Then show the main menu. |
| Cancel | Show the main menu again. Do not exit help. |

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

**Enable edit** choices, in this order. **Cancel** is last. This menu may write the flag while editing is disabled.

| Item | Result |
|------|--------|
| Enable | Write `true` to **Enable edit** in `CONFIG.md`. Confirm hub editing is enabled. Then show the main menu. |
| Disable | Write `false` to **Enable edit** in `CONFIG.md`. Confirm hub editing is disabled. Then show the main menu. |
| Cancel | Show the main menu again. Do not exit help. Do not change the flag. |

Open the menu with `HELP` alone or `/help`.
