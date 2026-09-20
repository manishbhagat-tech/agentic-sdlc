---
name: story-author
description: >-
  Legacy redirect. Prefer feature-prd / feature-stories for new delivery docs.
---

# story-author

**Prefer `feature-prd` then `feature-stories`.** This skill is **legacy only**.

If you must use it: author Epic/Feature/Story/BUG markdown under `DOCS_ROOT` with templates, tight allowlists, budgets, and `skills: []` on new US-*/BUG-*. Do not edit application code. Leave `status: draft` until DoR (`feature-stories` or legacy `story-ready`) passes.

```
HANDOFF: story-author → feature-stories|story-ready | outcome=legacy | notes=prefer feature-prd/feature-stories
```
