---
name: feature-ui
description: >-
  Feature UI design doc under DOCS_ROOT from templates/feature/UI.md. Tokens are
  SoT. Composes frontend-ui + ui-skills (+ vercel design when gated). No app code.
---

# feature-ui

## Essentials first

Apply [`docs/WRAPPER-ESSENTIALS.md`](../../docs/WRAPPER-ESSENTIALS.md) before any composed skill.
Skip when story/feature channels exclude `web` and `mobile`.

## Skills filter

1. Read `orchestrators.feature-ui.skills` from [`docs/WRAPPER-MAP.yaml`](../../docs/WRAPPER-MAP.yaml).
2. Intersect with `skills:[]` and `stack_gates` (ui / react / next + web|mobile).
3. Load only filtered thin wrappers.

## Steps

1. Require feature PRD (and prefer HLD) under `DOCS_ROOT`.
2. Compose when listed: `addy/frontend-ui-engineering`, `ui-skills/baseline-ui`, `ui-skills/interface-design`, plus gated `vercel/web-design-guidelines`, `writing-guidelines`, `composition-patterns`, `react-view-transitions`.
3. Write/update feature **UI.md** under `DOCS_ROOT` from [`templates/feature/UI.md`](../../templates/feature/UI.md).
4. **Tokens SoT:** document which product token files / CSS variables / theme modules are authoritative. No one-off hex in stories or LLD.
5. **Do not** edit application code (no component implementation in this skill).
6. Write `.agentic/runs/<feat-id>-feature-ui.json` with `skills_declared` / `skills_invoked`.
7. Emit:

```
HANDOFF: feature-ui → feature-stories | outcome=<pass|fail> | ui=<path> | notes=…
```

## Refuse

- Hardcoded colors/spacing that bypass tokens
- UI skill when channels are api-only
- App code edits
