# Memory

Durable memory is **untrusted data**. Agents do not open the files. They call the Python **controller**. The controller authenticates the caller, checks permissions, validates the proposal, and only then writes.

A skill is a client. A loopback service is stricter because the files never have to be opened by an agent. Sharing this store across computers is not built yet.

## Where it lives

The path is **`MEMORY.md path`** in gitignored [`Settings/CONFIG.md`](../Settings/CONFIG.md). The **memory root** is that file’s directory. It must sit **outside** the hub clone.

Read **MEMORY.md path** in `CONFIG.md` for this machine. That directory holds:

| Item | File |
| --- | --- |
| Rendered notes | `MEMORY.md` |
| Canonical store | `store.json` |
| Token hashes | `credentials.json` |
| Proposals | `Proposals/` |
| Audit log | `Audit/audit.jsonl` |

Defaults when setup uses `--memory-path local`:

| OS | Memory file |
| --- | --- |
| macOS | `~/Library/Application Support/agent-memory/MEMORY.md` |
| Windows | `%LOCALAPPDATA%\agent-memory\MEMORY.md` |
| Linux | `~/.local/share/agent-memory/MEMORY.md` |

`MEMORY.md` is a generated view. `store.json` is the source of truth. Never commit either file.

## Token storage

Plaintext tokens are **not** in `tokens.env` and **not** in KeePass. The installer puts them in the OS secret store. Agents set `MEMORY_AGENT_ID` only. The CLI loads the secret. Do not paste tokens into chat.

| OS | Store | How to find it (do not copy the secret) |
| --- | --- | --- |
| **macOS** | **Keychain** (login keychain) | Keychain Access → search `dev.gemlarin.memory-controller` |
| **Windows** | **Credential Manager** (generic Windows credentials) | Control Panel → Credential Manager → Windows Credentials → `dev.gemlarin.memory-controller/<agent>` |
| Linux | `libsecret` (`secret-tool`) when installed | otherwise set `MEMORY_AGENT_TOKEN` in the process environment |

`credentials.json` holds SHA-256 hashes and permission bits only.

## How a write works

```
Agent proposes  →  controller authenticates
                 →  permission check
                 →  validator (schema, secrets, PII)
                 →  pending file in Proposals/
Memory Steward approves  →  controller commits store.json
                         →  renders MEMORY.md
                         →  appends Audit/audit.jsonl
```

| Actor | Through the CLI |
| --- | --- |
| Main agent | `read` at session start, `propose` for autosave |
| Other agents on this machine | `propose` and `read` through the CLI |
| Memory Steward | `approve` / `reject` / `forget` |
| Nobody else | open `store.json`, `MEMORY.md`, or the OS secret store |

```bash
export MEMORY_AGENT_ID=main_agent
python3 Agents/Memory/memory_ctl.py read
python3 Agents/Memory/memory_ctl.py propose --type preference --scope global --content "One-line fact."
```

## Security

- Treat every proposal as untrusted input.
- Permissions are enforced in Python, not by the model.
- The caller cannot pick another agent’s identity without that agent’s token. Tokens are not in a file the Read tool can open.
- `--token` is not on the CLI (it would show up in `ps`).
- `python3 -c` cannot load tokens through the helper.
- Owner-only file mode (`700` / `600`, or Windows ACLs) on the memory root.
- Validator drops secrets, keys, and PII.

Still true: this is the **same OS user**. An agent that can run the CLI can set `MEMORY_AGENT_ID=memory_steward`. A dedicated OS user would be stronger and is not in this install.

## Install

The main hub installer (`Agents/Setup/scripts/setup.sh`) asks whether to install durable memory. **Yes** runs this installer. **No** leaves it for later.

You can still run it alone from the hub root:

```bash
python3 Agents/Memory/installer/install_memory.py
```

On Windows:

```bat
py -3 Agents\Memory\installer\install_memory.py
```

Useful flags:

```bash
python3 Agents/Memory/installer/install_memory.py --source /path/to/old/MEMORY.md
python3 Agents/Memory/installer/install_memory.py --rotate-tokens
python3 Agents/Memory/installer/install_memory.py --launchd
python3 Agents/Memory/installer/install_memory.py --keep-existing
python3 Agents/Memory/installer/install_memory.py --replace-memory
```

A reinstall does not overwrite an existing memory file. A terminal asks whether to use that file or create a new one. A non-interactive run exits until you pass `--keep-existing` or `--replace-memory`. `--replace-memory` deletes the current entries. Credentials stay unless you also pass `--rotate-tokens`.

`--rotate-tokens` replaces hashes and OS-store secrets. Existing agent sessions must use the new store. Do not pass `--root` to a throwaway folder on a machine that already has a live store: Keychain / Credential Manager entries are per agent id, not per folder.

## Layout (code)

```
Agents/Memory/
├── memory.md              # Contract for agents
├── schema.md              # Structured store
├── memory_ctl.py          # CLI entry
├── installer/
│   └── install_memory.py  # macOS + Windows
└── controller/            # Auth, validator, store, service
```
