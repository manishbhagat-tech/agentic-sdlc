---
name: story-security
description: >-
  Run security-check.sh; compose security-and-hardening; update .agentic/security
  ledger. Optional ATTACK-CLASSES checklist.
---

# story-security

## Essentials first

Apply [`docs/WRAPPER-ESSENTIALS.md`](../../docs/WRAPPER-ESSENTIALS.md) before any composed skill.
Update product `.agentic/security/` ledger when present.

## Skills filter

1. Read `orchestrators.story-security.skills` from [`docs/WRAPPER-MAP.yaml`](../../docs/WRAPPER-MAP.yaml).
2. **Always** compose persona `addy-agents/security-auditor` (threat lens + Security Audit Report format).
3. Intersect story `skills:[]` for phase `security`; compose `addy/security-and-hardening` (and `addy/doubt-driven-development` when elevated and listed).

## Steps

1. Pack context for `<US-*|BUG-*>` (or reuse fresh pack).
2. Run [`scripts/security-check.sh`](../../scripts/security-check.sh) against the story diff / working tree. Non-zero on obvious secrets → outcome fail.
3. Adopt `addy-agents/security-auditor`; walk [`ATTACK-CLASSES.md`](./ATTACK-CLASSES.md) (+ optional Addy `references/security-checklist.md` via the persona wrapper).
4. Update `.agentic/security/` using [`templates/security/LEDGER.md`](../../templates/security/LEDGER.md) and findings conforming to [`harness/findings.schema.json`](../../harness/findings.schema.json). Map Critical/High into ledger — not chat-only.
5. **Critical/High open findings require `bug_id: BUG-*`** on the finding JSON and a matching `BUG-*` markdown story (author via feature-stories / bug template). CI gate `security_findings_bugs` enforces this. Sync the bug to GitHub Projects via `board-sync.sh` when board is enabled.
6. Apply [`docs/SECURITY-BASELINE.md`](../../docs/SECURITY-BASELINE.md) controls relevant to touched surfaces. Run scanners via [`scripts/security-check.sh`](../../scripts/security-check.sh) (gitleaks / npm audit when available).
7. Write `.agentic/runs/<id>-story-security.json` with `skills_declared` / `skills_invoked` (include persona id), scanner notes, `outcome`.
8. Emit:

```
HANDOFF: story-security → ui-review|story-review | outcome=<pass|fail> | ledger=<path|none> | notes=…
```

Prefer handoff to `ui-review` when web/mobile channels apply; else `story-review`.

## Refuse

- Dropping secret/vuln findings because upstream omitted them
- Leaving Critical/High open without `bug_id` / `BUG-*`
- Auto-merging `security: elevated`
- Committing secrets into packs or run logs
