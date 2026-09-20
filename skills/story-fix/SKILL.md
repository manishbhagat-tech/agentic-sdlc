---
name: story-fix
description: >-
  Fix US-* / BUG-* with pack + debugging-and-error-recovery from story skills[].
  Secure + lean; hand off to story-test.
---

# story-fix

## Essentials first

Apply [`docs/WRAPPER-ESSENTIALS.md`](../../docs/WRAPPER-ESSENTIALS.md) before any composed skill.

## Skills filter

1. Intersect story `skills:[]` with `orchestrators.story-fix.skills` in WRAPPER-MAP (phase `fix`).
2. Compose `addy/debugging-and-error-recovery` when listed (expected for fix phase), plus `addy/context-engineering` and gated stack review skills.

## Preconditions

- Id is `US-*` or `BUG-*` with `ready`/`in_progress`
- BUG has `repro` and linked `story`

## Steps

1. Pack context for the id (include feedback/repro; linked US AC slice for BUG).
2. Read pack `SECURITY/` ledger/findings; prefer fixes that close related open findings without expanding scope.
3. Branch `fix/<id>-slug` if late bug; else stay on feature branch.
4. Compose filtered debugging / context wrappers; fix only allowlisted paths; add/adjust regression test when possible.
5. Secure + lean same as implement (reuse-first, no secrets, no ledger regression).
6. Write `.agentic/runs/<id>-story-fix.json` with `skills_declared` / `skills_invoked`.
7. Emit:

```
HANDOFF: story-fix → story-test | outcome=<pass|fail> | notes=…
```

## Refuse

- Broadening allow to “find the bug”
- Loading skills outside the filtered list
