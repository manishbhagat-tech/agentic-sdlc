---
name: story-implement
description: >-
  Implement a ready US-* story with pack, LLD (+UI if web/mobile), story skills[]
  for implement phase, context-engineering + incremental-implementation, secure/reuse.
---

# story-implement

## Essentials first

Apply [`docs/WRAPPER-ESSENTIALS.md`](../../docs/WRAPPER-ESSENTIALS.md) before any composed skill.

## Skills filter

1. Read story frontmatter `skills:[]` — **required** for new stories; legacy may infer with warn.
2. Intersect with `orchestrators.story-implement.skills` in [`docs/WRAPPER-MAP.yaml`](../../docs/WRAPPER-MAP.yaml) (phase `implement`).
3. Apply `stack_gates` (sivalabs / vercel / next / ui-skills) against product `stacks:` + story `channels:`.
4. Load only the filtered thin wrappers. Prefer composing:
   - `addy/context-engineering`
   - `addy/incremental-implementation`
   - plus listed stack / elevated skills (`source-driven`, `doubt-driven` when gated)

## Preconditions

- User provides `US-*` id
- Story `status` is `ready` or `in_progress`
- Not `needs_human` / `blocked` / `cancelled`
- Feature **LLD** present under `DOCS_ROOT` (must_read or parents)
- Feature **UI.md** present when `channels` include `web` or `mobile`
- Read product `delivery/STORY-CONTRACT.md` when applicable

## Steps

1. Run packer for `<US-id>`. Abort if pack fails or over budget.
2. Read pack `SECURITY/` (baseline + open ledger findings when present); do not regress open findings; note new issues for `story-security`.
3. Set story `status: in_progress`.
4. Default **channels** = `api`, `web`, `mobile` unless story overrides.
5. **Reuse-first:** extend existing modules from LLD reuse map / HLD before adding new packages.
6. **Secure:** no secrets; validate inputs; authz/tenant scope; parameterized queries (see rules/secure-codegen).
7. Implement in order: **API → Web → Mobile** within `repos[].allow`.
8. Web: FEAT-UI / UI.md tokens only. Mobile: theme tokens only.
9. Write `.agentic/runs/<id>-story-implement.json` with `skills_declared`, `skills_invoked`, pack metrics.
9. Emit:

```
HANDOFF: story-implement → story-test | outcome=<pass|fail> | files_edited=<n> | notes=…
```

## Refuse

- No story id / vibe features
- Missing LLD (or UI when web/mobile)
- Paths outside allow / over budget
- Loading skills not in the filtered list
