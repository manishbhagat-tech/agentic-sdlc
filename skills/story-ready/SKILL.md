---
name: story-ready
description: >-
  Legacy redirect. Prefer feature-stories DoR (PRD+HLD+LLD(+UI), skills:[]).
---

# story-ready

**Prefer `feature-stories`** for Definition of Ready. This skill is **legacy only**.

If you must use it: validate `id`, `status`→`ready`, `security`, budgets, `must_read`, `repos[].allow`, `tests[]`, and **`skills: []`** when present; BUG needs `story` + `repro`. Optionally dry-run packer. Do not edit application code.

```
HANDOFF: story-ready → story-implement|story-fix | outcome=legacy | notes=prefer feature-stories
```
