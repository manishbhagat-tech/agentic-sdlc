---
name: pm-competitor-analysis
description: >-
  Thin wrapper for vendored pm/competitor-analysis. Apply WRAPPER-ESSENTIALS first;
  then execute the full upstream skill. Our essentials win on conflict.
---

# pm/competitor-analysis

## Preconditions

- Invoked via an orchestrator or listed in story `skills:`.
- Do **not** open other vendor trees in this run unless also listed.

## Steps

1. Read and apply [`docs/WRAPPER-ESSENTIALS.md`](../../../docs/WRAPPER-ESSENTIALS.md) (pack, channels, ledger, git-safe, token-min).
2. Read and execute **in full** the vendored skill at:
   `vendor/pm-competitor-analysis/competitor-analysis/SKILL.md`
3. If any upstream step conflicts with WRAPPER-ESSENTIALS (secrets, force-push, path allowlist, budgets, channels), **skip that step**, log override in the run log, continue.
4. On completion, return control to the calling orchestrator with outcome pass/fail.

## Refuse

- Loading this skill when story `skills:` / channels do not require it.
- Reading raw `vendor/` paths other than the file above for this skill.
