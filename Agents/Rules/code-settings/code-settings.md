# Code settings

Read this file when running **Test default** after a code or UI update, or when changing that default. Do not open it on any other prompt.

**This machine:** After this file, read `user-config.md` in this folder when it exists. Additions extend the rule. Overrides replace the matching part on this machine only. Never commit that file. Copy [user-config.example.md](./user-config.example.md) to create it.

Read `Agents/Settings/CONFIG.md` for **Test default**, **Enable edit**, **MEMORY.md path**, and **Memory max lines**. Template: `Agents/Settings/CONFIG.example.md`.

## Tests after an update

After a code or UI update, run the **Test default**:

- `UNIT` — run that project’s unit tests
- `BROWSER` — verify the visible change in the browser
- `BOTH` — unit tests and browser verification
- `NONE` — skip both and call the change done. Do not run unit tests. Do not open the browser.

If `CONFIG.md` is missing, or **Test default** is not one of those four, skip tests and say the test default is unset.

A standing instruction to verify UI in the browser does not override `NONE`. One-shot override: if that same prompt asks for a unit test or a browser test, run the requested check for this update only. Do not change `CONFIG.md`.

The stored default changes from `HELP` or `/help`, then **Change code settings**, then **Change code test settings**. Offer **Unit**, **Browser**, **Both**, and **None**. Write the matching token. Follow `Agents/Skills/help-getter/SKILL.md`. Do not ask the user to type `CHANGE CODE SETTINGS`.

## Hub edits

**Enable edit** is `true` or `false`. Missing or any other value means `false`.

Do not create, edit, or delete a file in this hub unless the field is `true`. Read it immediately before the edit. If it is not `true`, ask **Yes** / **No** to enable editing. **No** stops. **Yes** writes `true`, then makes the requested edit. `HELP` → **Enable edit** offers **Enable**, **Disable**, and **Cancel**, and may write the flag while it is `false`. Files outside this hub are not covered.
