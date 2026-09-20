---
name: addy-agents-security-auditor
description: >-
  Thin persona wrapper for vendored Addy agent `security-auditor`. Apply WRAPPER-ESSENTIALS
  first; adopt perspective + output format from the vendor persona file.
---

# addy-agents/security-auditor

## Role

Persona overlay (**who** + output format). Procedure (**how**) stays in the paired
`skills/addy/*` skill listed by the calling orchestrator / WRAPPER-MAP.

## Preconditions

- Invoked via an orchestrator `personas:` entry (or listed in story `skills:`).
- Pack / diff context already loaded by the orchestrator when applicable.

## Steps

1. Read and apply [`docs/WRAPPER-ESSENTIALS.md`](../../../docs/WRAPPER-ESSENTIALS.md).
2. Read and adopt the vendored persona at:
   `vendor/addy-agent-skills/agents/security-auditor.md`
3. Use the persona's framework, severity labels, and output template.
4. Stay inside pack allowlists / story scope — do not expand beyond the orchestrator brief.
5. On conflict with WRAPPER-ESSENTIALS (secrets, budgets, channels, git-safe, ledger), **essentials win**; log override.

6. Optionally skim `vendor/addy-agent-skills/references/security-checklist.md` for gaps vs
   `skills/story-security/ATTACK-CLASSES.md` — do not dump the whole references tree.
7. Map Critical/High into `.agentic/security/` ledger / findings — not chat-only.

## Refuse

- Reading raw `vendor/` paths other than the persona file above (plus any reference named here).
- Auto-merging `security: elevated` or force-push / auto-prod.
