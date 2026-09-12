---
name: story-fix
description: >-
  Fix bugs for US-* (mid-flight feedback) or BUG-* (late defects) with minimal
  context pack. Use instead of freeform fix prompts.
---

# story-fix

## Preconditions

- Id is `US-*` or `BUG-*` with `ready`/`in_progress`
- BUG has `repro` and linked `story`

## Steps

1. Pack context for the id (include feedback/repro; linked US AC slice for BUG).
2. Branch `fix/<id>-slug` if late bug; else stay on feature branch.
3. Fix only allowlisted paths; add/adjust regression test when possible.
4. Secure + lean same as implement.
5. Write run log `*-fix.json`.
6. Hand off to `story-test`.
