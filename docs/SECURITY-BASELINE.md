# Security baseline (kit)

Product repos adopt this baseline; story-security and secure-codegen enforce it.

## Controls

1. **Secrets** — never in git, packs, run logs, or client bundles. Env / secret manager only.
2. **Authn / authz** — mutating APIs authenticated; tenant/company/role scoped.
3. **Injection** — parameterized queries / safe binders; no `eval` / shell of user input.
4. **Transport** — TLS in prod; no credentials in URLs.
5. **Dependencies** — run `npm audit` / `mvn dependency-check` (or CI equivalent); note results in review.
6. **Least privilege** — CORS, actuators, admin routes locked down.
7. **Logging** — structured; no passwords/JWTs/PII dumps; do not swallow errors silently.
8. **Elevated** — `security: elevated` stories require human merge after story-security + story-review.

## Ledger layout (product)

```text
.agentic/security/
  LEDGER.md          # open / closed summary
  findings/*.json    # one finding per file (see findings schema)
```

## Scripts

- `scripts/security-check.sh` — secret patterns on diff; warn if audit tools missing; exit non-zero on obvious secrets.
- Packer best-effort includes this baseline + open ledger findings.

## Deep audit

Optional Cloudflare / external deep audit: see [SECURITY-DEEP-AUDIT.md](./SECURITY-DEEP-AUDIT.md).
