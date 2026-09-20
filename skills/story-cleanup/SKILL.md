---
name: story-cleanup
description: >-
  Diff-scoped cleanup via code-simplification; re-test; then allow status done.
---

# story-cleanup

## Essentials first

Apply [`docs/WRAPPER-ESSENTIALS.md`](../../docs/WRAPPER-ESSENTIALS.md) before any composed skill.

## Skills filter

1. Intersect story `skills:[]` with `orchestrators.story-cleanup.skills` (phase `cleanup`).
2. Compose `addy/code-simplification` when listed.

## Steps

1. Pack using current git diff / run-log `files_edited` only.
2. Compose code-simplification; remove unused imports, dead methods, empty classes, leftover TODOs/stubs **introduced by this change**.
3. Do **not** clean unrelated module code.
4. Re-run story tests; revert cleanup hunks if tests fail.
5. Write `.agentic/runs/<id>-story-cleanup.json` with `cleanup_ran: true`, `skills_declared`, `skills_invoked`.
6. Set `status: done`; append one line to feature `CHANGELOG.md` if present.
7. Emit:

```
HANDOFF: story-cleanup → git-ops|human-merge | outcome=<pass|fail> | cleanup_ran=true | notes=…
```

Human merges PR (required for elevated).

## Refuse

- Repo-wide cleanup sprees
- Marking done when tests fail after cleanup
