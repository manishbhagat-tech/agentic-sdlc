---
name: story-implement
description: >-
  Implement a ready US-* story with token-min pack, allowlist-only edits,
  secure and lean codegen. Refuse without story id.
---

# story-implement

## Preconditions

- User provides `US-*` id
- Story `status` is `ready` or `in_progress`
- Not `needs_human` / `blocked` / `cancelled`

## Steps

1. Run `$AGENTIC_SDLC/scripts/pack-story-context.sh <US-id>` (or installed copy). Abort if pack fails.
2. Set story `status: in_progress`.
3. Read **only** pack contents + allowlisted paths as needed (outline → slice → edit).
4. **Secure:** no secrets; validate inputs; authz/tenant scope on mutating APIs; parameterized queries.
5. **Lean:** prefer edits over new layers; no dead code, stubs, or speculative abstractions; diff maps to AC.
6. Stay inside `repos[].allow`.
7. Write `.agentic/runs/<id>-implement.json` run log (schema in harness).
8. Hand off to `story-test`.

## Refuse

- No story id / vibe feature requests
- Paths outside allow
- Over budget without story amend
