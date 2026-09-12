---
name: story-implement
description: >-
  Implement a ready US-* story with token-min pack, allowlist-only edits,
  secure and lean codegen across api + web + mobile unless channels say otherwise.
---

# story-implement

## Preconditions

- User provides `US-*` id
- Story `status` is `ready` or `in_progress`
- Not `needs_human` / `blocked` / `cancelled`
- Read `DOCS_ROOT/delivery/STORY-CONTRACT.md` for Civil ERP (full slice DoD)

## Steps

1. Run packer for `<US-id>`. Abort if pack fails.
2. Set story `status: in_progress`.
3. Default **channels** = `api`, `web`, `mobile` unless story overrides.
4. Implement in order: **API → Web → Mobile** within `repos[].allow`.
5. Web: FEAT-UI tokens/primitives only. Mobile: `theme/tokens.ts` only.
6. **Secure:** no secrets; validate inputs; authz/tenant scope; parameterized queries.
7. **Lean:** prefer edits; no dead code; diff maps to AC.
8. Write `.agentic/runs/<id>-implement.json`.
9. Hand off to `story-test` (all channel tests in frontmatter).

## Refuse

- No story id / vibe features
- Skipping web or mobile on a full-slice story without `channels` exception
- Paths outside allow / over budget
