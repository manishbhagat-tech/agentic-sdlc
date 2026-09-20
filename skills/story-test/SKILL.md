---
name: story-test
description: >-
  Run story tests with TDD wrapper; optional browser-testing if in skills[].
  Hand off to story-security.
---

# story-test

## Essentials first

Apply [`docs/WRAPPER-ESSENTIALS.md`](../../docs/WRAPPER-ESSENTIALS.md) before any composed skill.

## Skills filter

1. Intersect story `skills:[]` with `orchestrators.story-test.skills` (phase `test`).
2. **Always** compose persona `addy-agents/test-engineer`.
3. Compose `addy/test-driven-development` when listed.
4. Compose `addy/browser-testing-with-devtools` only when listed **and** web channel present.

## Steps

1. Pack context for id (or reuse fresh pack).
2. Adopt test-engineer persona; compose TDD / browser wrappers as filtered.
3. Run each `tests[].cmd` in the named repo working directory.
4. On failure: capture output; open only the failing test/source slice; suggest `story-fix` — do not broaden allow.
5. On success: write `.agentic/runs/<id>-story-test.json` with `tests_passed: true`, `skills_declared`, `skills_invoked`.
6. Emit:

```
HANDOFF: story-test → story-security | outcome=<pass|fail> | tests_passed=<bool> | notes=…
```

## Refuse

- Browser skill without web channel
- Expanding allow after a red test
