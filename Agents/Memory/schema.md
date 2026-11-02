# Memory schema

Canonical memory is a JSON document, not a free-form notes file. `memory.md` is a rendered view the controller writes after a successful commit.

## Store (`store.json`)

```json
{
  "version": 1,
  "entries": [
    {
      "id": "uuid",
      "type": "preference",
      "scope": "global",
      "source": "research_scout",
      "content": "One-line durable fact.",
      "created": "2026-11-02T15:00:00+00:00",
      "approved_by": "memory_steward",
      "proposal_id": "uuid"
    }
  ]
}
```

## Proposal fields

| Field | Allowed |
| --- | --- |
| `type` | `fact`, `preference`, `decision`, `technical_context` |
| `scope` | `global`, `project`, `agent` |
| `source` | Submitting agent id |
| `content` | One line. No secrets, keys, or PII. |

## Files (all owner-only after install)

| File | Role |
| --- | --- |
| `store.json` | Canonical structured memory |
| `MEMORY.md` | Rendered view for humans |
| `Proposals/*.json` | Untrusted submissions |
| `Audit/audit.jsonl` | Append-only events |
| `credentials.json` | Token hashes and permissions |
| OS secret store | Plaintext tokens (Keychain / Credential Manager). Never a file. |
