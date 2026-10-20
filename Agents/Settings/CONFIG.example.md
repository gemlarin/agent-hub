# CONFIG

Machine settings for agent-hub. **Not committed.** Setup copies this file to `CONFIG.md` and fills the values.

Any rule, skill, or subagent reads `Agents/Settings/CONFIG.md`. Change the test default from `HELP` → Change code settings. Change hub editing from `HELP` → Enable edit. Change the memory line cap from `HELP` → Memory information.

## Code tests

- **Test default:** `NONE`

Allowed: `UNIT`, `BROWSER`, `BOTH`, `NONE`. This default runs after every update request. A single request can override it by asking for a unit test or a browser test in that prompt.

## Hub edits

- **Enable edit:** `false`

Allowed: `true`, `false`. `false` blocks every create, edit, and delete in this hub until the user turns it on.

## Memory

- **MEMORY.md path:** `/absolute/path/to/MEMORY.md`
- **Memory max lines:** `80`
