# Settings/

One machine config that rules, skills, and subagents share. Agents read [`CONFIG.md`](./CONFIG.md). They do not invent these values.

| File | Role |
|------|------|
| [`CONFIG.example.md`](./CONFIG.example.md) | Template. Committed. Placeholders only. |
| `CONFIG.md` | This machine’s values. Gitignored. Setup copies the example and fills it. |

Do not commit `CONFIG.md`. It holds a local path.

`Agents/Setup/hub-setup.local.md` still stores the git remote, hub folder, and GitHub username. Setup also copies **MEMORY.md path** there so an older install keeps working. When both files have a path, agents use `CONFIG.md`.

## Fields

```markdown
## Code tests

- **Test default:** `NONE`

## Memory

- **MEMORY.md path:** `/absolute/path/to/MEMORY.md`
- **Memory max lines:** `80`
```

| Field | Allowed values | What it does |
|-------|----------------|--------------|
| **Test default** | `UNIT`, `BROWSER`, `BOTH`, `NONE` | What runs after a code or UI update. `UNIT` runs that project’s unit tests. `BROWSER` checks the visible change in the browser. `BOTH` runs both. `NONE` skips both and calls the change done. |
| **MEMORY.md path** | Absolute path outside this clone | The one durable `MEMORY.md`. Cloud storage or a local file. |
| **Memory max lines** | Positive integer | Line cap for that file. Memory Steward prunes less important bullets when a write would pass it. |

Setup asks for the test default and the line cap. The suggested line cap is 80.

## How to change a value

- **Test default:** prompt `CHANGE CODE SETTINGS`. The agent asks for `UNIT`, `BROWSER`, `BOTH`, or `NONE`, writes **Test default**, and confirms it. That prompt does not run tests.
- **One update only:** ask for a unit test or a browser test in the same change request. That overrides **Test default** for that request and leaves `CONFIG.md` unchanged.
- **Memory path or line cap:** prompt `HELP` or `/help`, then choose **Memory Information**. A new file path moves the existing `MEMORY.md` when one is already there. See [help-getter](../Skills/help-getter/README.md).
- **See every value:** `HELP` → **Display Configuration**. The agent shows `CONFIG.md` in a code block.

If `CONFIG.md` is missing, or **Test default** is not one of the four values, the agent skips tests and says the test default is unset. Copy the example to `CONFIG.md`, or run setup.

## Contribute

1. Add a field to [`CONFIG.example.md`](./CONFIG.example.md) and to the table above. Use the same `- **Label:** \`value\`` bullet so setup can update it.
2. Teach setup (`Agents/Setup/scripts/setup.sh`) to ask for the field and write it.
3. Point the rule, skill, or subagent that needs the value at `Agents/Settings/CONFIG.md`. Do not copy the value into those files.
