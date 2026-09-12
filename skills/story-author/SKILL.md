---
name: story-author
description: >-
  Author or amend Epic/Feature/Story/BUG markdown under DOCS_ROOT with tight
  allowlists, budgets, and security flags. Use when creating delivery work items.
---

# story-author

## Steps

1. Read `DOCS_ROOT` from workspace `AGENTS.md`.
2. Use templates from the agentic-sdlc kit (`templates/`).
3. Write **minimal** stories: clear AC, DoD, `must_read`, `repos[].allow`, `budget`, `tests`, `security`.
4. Prefer small `allow` globs; never entire modules.
5. Do **not** edit application code.
6. Leave `status: draft` until `story-ready` passes.
