# Security deep audit (optional)

Kit baseline + `story-security` cover agent delivery. **Deep audit** is optional and human-triggered.

## When

- New public surface area
- Auth/money/PII (`security: elevated` programs)
- Pre-production milestones

## Options

1. **First-party** — expand ledger findings; run product SAST/DAST; dependency audits in CI.
2. **Cloudflare** (optional) — if the product already uses Cloudflare, consider WAF / security insights for internet-facing edges. Not required by this kit; no Cloudflare account is implied.
3. **External pen-test** — out of band; link report path in ledger Notes.

## Kit stance

- Do not block story Done solely on optional deep audit unless the product contract says so.
- Never paste full vuln dumps with secrets into run logs.
- Record “deep audit scheduled/done” as a ledger note when applicable.
