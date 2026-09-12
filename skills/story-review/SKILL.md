---
name: story-review
description: >-
  Diff-only review against AC plus security and lean checklists. Block merge for
  elevated security until human approves.
---

# story-review

## Steps

1. Pack with `DIFF.md` (git diff for story branch / allowlisted paths).
2. Check every AC against the diff.
3. **Security checklist**
   - [ ] No secrets / credentials in code or logs
   - [ ] Mutating endpoints authorized + tenant/company scoped
   - [ ] Input validation; no string-built SQL
   - [ ] Least privilege (CORS, actuators, public routes)
   - [ ] Audit fields if AC requires
4. **Lean checklist**
   - [ ] No unused imports / dead code / commented blocks
   - [ ] No speculative abstractions
   - [ ] Diff scoped to AC (no drive-by refactors)
5. If `security: elevated`, mark `needs_human` for merge approval note in story.
6. Write run log `*-review.json`.
7. On pass → `story-cleanup`. On fail → `story-fix` or amend story.
