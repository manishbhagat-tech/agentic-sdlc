---
name: ui-review
description: >-
  UI review composing frontend-ui + ui-skills (+ gated vercel). Fail on design
  token violations.
---

# ui-review

## Essentials first

Apply [`docs/WRAPPER-ESSENTIALS.md`](../../docs/WRAPPER-ESSENTIALS.md) before any composed skill.
Skip entirely when channels exclude `web` and `mobile` — HANDOFF pass with `skipped=channels`.

## Skills filter

1. Read `orchestrators.ui-review.skills` from [`docs/WRAPPER-MAP.yaml`](../../docs/WRAPPER-MAP.yaml).
2. Intersect with story `skills:[]` for phase `ui-review`.
3. When `web` channel present, **always** compose persona `addy-agents/web-performance-auditor` (quick mode).
4. Load only filtered thin wrappers for procedure.

## Steps

1. Pack with `DIFF.md`; prefer feature `UI.md` + token SoT from must_read/parents.
2. Compose when listed: `addy/frontend-ui-engineering`, `ui-skills/baseline-ui`, `ui-skills/interface-design`, gated vercel design/react skills.
3. Run web-performance persona in quick mode when web applies (no fabricated metrics).
4. **Fail** on token violations: hardcoded colors/spacing/type that bypass product tokens / CSS variables / theme modules named in UI.md or FEAT-UI.
5. Check web and/or mobile surfaces touched (or N/A noted).
6. Write `.agentic/runs/<id>-ui-review.json` with `skills_declared` / `skills_invoked`.
7. Emit:

```
HANDOFF: ui-review → story-review | outcome=<pass|fail> | token_violations=<n> | notes=…
```

## Refuse

- Passing with known token bypasses
- Loading RN skills without mobile channel
