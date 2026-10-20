# Agents/ — canonical policy

This folder is what **any** agent follows. Cursor extras (`.cursor/`, `.githooks/`) live at the **clone root**, not here. Hub overview for humans: [`../README.md`](../README.md).

Agents enter through **[`AGENTS.md`](./AGENTS.md)** once per session, once more after a compaction summary that drops the table, and again when the user says **reload agents** or **recache agents** (on-demand table). They do not need this README.

## Design

| File / folder                | Role                                                                                                                            |
| ---------------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| [`AGENTS.md`](./AGENTS.md)   | Load table + non-negotiables                                                                                                    |
| [`Subagents/`](./Subagents/) | Specialists. The parent does not open the spec. The Task prompt tells the specialist to read its own file and `user-config.md`. |
| [`Skills/`](./Skills/)       | Procedural skills. Each skill folder has a gitignored `user-config.md` that extends `SKILL.md`                                  |
| [`Setup/`](./Setup/)         | Bootstrap, Cursor install, local config template                                                                                |
| [`Memory/`](./Memory/)       | Persistent `MEMORY.md` path and read/write split. No local override file                                                        |
| [`Settings/`](./Settings/)   | Gitignored `CONFIG.md`: test default, memory path, memory line cap                                                              |
| [`Rules/`](./Rules/)         | Standards, including interactive inputs. Each rule has its own folder, a contribute README, and a gitignored `user-config.md`   |

Policy is **markdown in git**. App repos get a **pointer** to `AGENTS.md`, not a copy. Skills and subagent bodies stay out of `AGENTS.md`. The parent does not open a specialist spec. The Task prompt tells the specialist to read its own spec and `user-config.md`.

## Contribute

1. Change the **smallest** file that owns the rule (do not paste the same policy into three places).
2. Keep [`AGENTS.md`](./AGENTS.md) as a **table of links**, not the full spec.
3. New specialist → [`Subagents/README.md`](./Subagents/README.md). New skill → [`Skills/README.md`](./Skills/README.md). New standard → [`Rules/README.md`](./Rules/README.md). New shared setting → [`Settings/README.md`](./Settings/README.md) and `CONFIG.example.md`. Setup/bootstrap → [`Setup/README.md`](./Setup/README.md).
4. Do not add a hub-root `AGENTS.md` (gitignored; apps and this clone must not duplicate policy there).
5. Never commit `MEMORY.md`, [`Settings/CONFIG.md`](./Settings/CONFIG.md), [`Setup/hub-setup.local.md`](./Setup/hub-setup.local.md), or any `Rules/**/user-config.md`, `Skills/**/user-config.md`, or `Subagents/**/user-config.md`.
6. Follow [`Rules/coding-standards`](./Rules/coding-standards/coding-standards.md) for code in apps; this folder is mostly docs.
