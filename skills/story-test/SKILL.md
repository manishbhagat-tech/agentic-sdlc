---
name: story-test
description: >-
  Run story/BUG declared tests with minimal context. On failure, read stack and
  one failing file slice only.
---

# story-test

## Steps

1. Pack context for id (or reuse fresh pack).
2. Run each `tests[].cmd` in the named repo working directory.
3. On failure: capture output; open only the failing test/source slice; suggest `story-fix` — do not broaden allow.
4. On success: write run log `*-test.json` with `tests_passed: true`.
5. Hand off to `story-review`.
