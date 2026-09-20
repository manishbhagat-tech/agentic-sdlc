---
name: story-review
description: >-
  Diff-only review: AC, lean, channels, code-review-and-quality. Slim security
  (defer deep work to story-security). Elevated requires human merge.
---

# story-review

## Essentials first

Apply [`docs/WRAPPER-ESSENTIALS.md`](../../docs/WRAPPER-ESSENTIALS.md) before any composed skill.

## Skills filter

1. Intersect story `skills:[]` with `orchestrators.story-review.skills` (phase `review`).
2. **Always** compose persona overlays from `orchestrators.story-review.personas`:
   - `addy-agents/code-reviewer` (five-dimension review + verdict template)
   - `addy-agents/web-performance-auditor` when `web` channel present (quick mode)
3. Compose procedure wrappers: `addy/code-review-and-quality` (and gated `performance-optimization`, `sivalabs/java-code-review`).

## Steps

1. Pack with `DIFF.md`. Prefer confirming `story-security` (and `ui-review` if web/mobile) already ran; if not, HANDOFF warn and keep slim checklist only.
2. Adopt `addy-agents/code-reviewer` persona; evaluate AC against the diff using its Critical/Required/Optional/Nit labels.
3. **Channels** (unless narrower): API + Web + Mobile touched or explicitly N/A.
4. **Slim security** (deep scan owned by `story-security`):
   - [ ] No secrets in diff
   - [ ] Mutating endpoints appear authorized / scoped
   - [ ] No string-built SQL in touched code
5. **Lean checklist**
   - [ ] No unused imports / dead code / commented blocks from this change
   - [ ] No speculative abstractions
   - [ ] Diff scoped to AC
6. Compose code-review procedure wrapper when listed; optional quick perf persona for web.
7. If `security: elevated`, require human merge — no auto-merge.
8. Write `.agentic/runs/<id>-story-review.json` with `skills_declared` / `skills_invoked` (include persona ids).
9. Emit:

```
HANDOFF: story-review → story-cleanup | outcome=<pass|fail> | elevated=<bool> | notes=…
```

## Refuse

- Replacing story-security with this slim checklist alone for elevated stories without human note
- Approving merge for elevated without human
