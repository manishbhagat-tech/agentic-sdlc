---
name: story-review
description: >-
  Diff-only review against AC plus security, vulnerability, lean, and
  api/web/mobile channel completeness. Block elevated merges for humans.
---

# story-review

## Steps

1. Pack with `DIFF.md`.
2. Check every AC against the diff.
3. **Channels** (unless story `channels` is narrower): API + Web + Mobile touched or explicitly N/A in Notes.
4. **Security checklist**
   - [ ] No secrets / credentials in code or logs
   - [ ] Mutating endpoints authorized + tenant/company scoped
   - [ ] Input validation; no string-built SQL
   - [ ] Least privilege (CORS, actuators, public routes)
   - [ ] Audit fields if AC requires
5. **Vulnerability checklist**
   - [ ] No secrets files in diff
   - [ ] Dependency audit run or CI job noted (no new criticals in touched packages)
   - [ ] Dangerous APIs / eval / shell avoided
6. **Lean checklist**
   - [ ] No unused imports / dead code / commented blocks
   - [ ] No speculative abstractions
   - [ ] Diff scoped to AC
7. UI uses design tokens only (web CSS vars / mobile theme tokens).
8. If `security: elevated`, require human merge.
9. Write run log `*-review.json`.
10. On pass → `story-cleanup`.
