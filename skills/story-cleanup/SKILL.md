---
name: story-cleanup
description: >-
  Remove junk introduced by this story's diff only, re-test, then allow status
  done. Required before marking US-* or BUG-* done.
---

# story-cleanup

## Steps

1. Pack using current git diff / run-log `files_edited` only.
2. Remove unused imports, dead methods, empty classes, leftover TODOs/stubs **introduced by this change**.
3. Do **not** clean unrelated module code.
4. Re-run story tests; revert cleanup hunks if tests fail.
5. Write run log with `cleanup_ran: true`.
6. Set `status: done`; append one line to feature `CHANGELOG.md` if present.
7. Human merges PR (required for elevated).
