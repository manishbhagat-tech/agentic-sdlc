---
name: feature-stories
description: >-
  Replace story-author/ready for new work: create US-*/BUG-* with required
  skills:[] at design time; DoR validates PRD+HLD+LLD(+UI) and skills match channels.
---

# feature-stories

## Essentials first

Apply [`docs/WRAPPER-ESSENTIALS.md`](../../docs/WRAPPER-ESSENTIALS.md) before any composed skill.

## Skills filter

1. Read `orchestrators.feature-stories.skills` from [`docs/WRAPPER-MAP.yaml`](../../docs/WRAPPER-MAP.yaml).
2. Intersect with any parent feature `skills:[]` if present.
3. Compose `addy/planning-and-task-breakdown` and `addy/constraint-driven-development` when listed.

## Steps

1. Require feature **PRD + HLD + LLD** under `DOCS_ROOT`. Require **UI.md** when channels include `web` or `mobile`.
2. Create or amend `US-*` / `BUG-*` from [`templates/story/STORY.md`](../../templates/story/STORY.md) / [`templates/bug/BUG.md`](../../templates/bug/BUG.md).
3. **REQUIRE** frontmatter `skills: []` at design time — every entry must resolve to an existing thin wrapper under `skills/<ns>/<name>/`. Choose entries that match `channels:` and product `stacks:` (see WRAPPER-MAP `stack_gates`).
4. **Definition of Ready (DoR)** — refuse `ready` until:
   - [ ] PRD, HLD, LLD present (UI.md if web/mobile)
   - [ ] `skills:[]` non-empty and valid wrappers
   - [ ] Skills match channels (no RN without mobile; no ui-skills without web/mobile)
   - [ ] `budget`, `must_read`, `repos[].allow`, `tests[].cmd`, `security` set
   - BUG: `story`, `repro` present
5. Optionally dry-run `scripts/pack-story-context.sh <id>`; fail if over budget.
6. Set `status: ready` only when DoR passes; else leave `draft` and HANDOFF fail notes.
7. **Do not** edit application code.
8. Write `.agentic/runs/<id>-feature-stories.json` with `skills_declared` / `skills_invoked`.
9. Emit:

```
HANDOFF: feature-stories → story-implement|story-fix | outcome=<pass|fail> | id=<US-*|BUG-*> | notes=…
```

## Legacy

Prefer this skill over `story-author` / `story-ready`. Those remain thin redirects only.

## Refuse

- Ready without `skills:[]`
- Skills that fail channel/stack gates
- App code
