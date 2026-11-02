# Memory & Persistent Context

Cross-session continuity uses a **structured store** behind the memory controller. `MEMORY.md` is a rendered view. Never commit the store, tokens, or `CONFIG.md`.

## Configure the path

The controller and installer read the path and the line cap from gitignored [`Settings/CONFIG.md`](../Settings/CONFIG.md):

```markdown
## Memory

- **MEMORY.md path:** `/absolute/path/to/MEMORY.md`
- **Memory max lines:** `80`
```

The memory **root** is the directory that contains that file. Run [`installer/install_memory.py`](./installer/install_memory.py) after the path is set. It writes permissions, credentials, `store.json`, `Proposals/`, and `Audit/`.

## Who may do what

Permissions are in `credentials.json` (token hashes). The CLI loads the matching token from the OS secret store. Agents set `MEMORY_AGENT_ID` only. They do not read Keychain, Credential Manager, or a token file.

| Actor | Through the controller |
| --- | --- |
| **Main agent** | `read` at session start. `propose` for autosave. Never open the files with the Read/Write tools. |
| **Memory Steward** | `approve` / `commit` / `forget`. Never write `MEMORY.md` or `store.json` itself. |
| **Every other subagent** | `propose` and `read` through the controller. Do not open the files. |

```bash
export MEMORY_AGENT_ID=main_agent
python3 Agents/Memory/memory_ctl.py read
python3 Agents/Memory/memory_ctl.py propose --type preference --scope global --content "One-line fact."
```

Steward then `pending` and `approve <id>`.

## Keep it lean

- **Cap:** **Memory max lines** in `CONFIG.md`. The controller prunes on commit.
- One fact per entry. No paragraphs, logs, diffs, or file dumps.
- Types: `fact`, `preference`, `decision`, `technical_context`, `blocker`.

## Auto-save vs option menu

### Viable fact (during the session)

Parent proposes via the controller (`main_agent` token), then invokes Memory Steward to approve. Do **not** show option ids. Do **not** `Write` the memory file.

When the Memory Report arrives with a real change, print exactly:

`Durable memory saved to MEMORY file`

### Option menu (only these times)

Show the proposed bullets and the ids in [`Skills/memory-management/options.md`](../Skills/memory-management/options.md) **only** when the user asked to save or the session is ending.

Never dump the full store into chat.

## Main agent responsibilities

1. **Session start:** Resolve the path from `CONFIG.md`, then `memory_ctl.py read` once.
2. **During work:** Use that snapshot. Do not paste the file into chat.
3. **Mid-session:** Propose durable facts; steward approves.
4. **Subagents:** Pass **`related_memory`** only.
5. **Menu:** Option ids only on save / wrap-up.
