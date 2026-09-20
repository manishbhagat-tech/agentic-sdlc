# Attack classes (short checklist)

Use during `story-security`. Mark each as N/A, pass, or finding (ledger id).

| Class | Check |
|-------|--------|
| Secrets | No keys, tokens, passwords, `.env` in diff/logs/packs |
| Authn | Endpoints require auth unless explicitly public |
| Authz / tenant | Mutations scoped to company/tenant/role |
| Injection | Parameterized queries / safe binders; no shell/eval of user input |
| XSS / HTML | User content escaped or sanitized on web |
| CSRF / CORS | Mutating browser APIs protected; CORS least privilege |
| SSRF / URL fetch | Server-side fetches allowlisted |
| Deserialization | Untrusted payloads not unsafe-deserialized |
| File path | Uploads/downloads cannot escape allow roots |
| Dependency | `npm`/`mvn` audit noted; no new criticals in touched deps |
| Logging | No secrets/PII dumped; errors not swallowed silently |
| Config | Actuators/admin/debug not exposed publicly |

Findings → `.agentic/security/` per `templates/security/LEDGER.md` + findings schema.
