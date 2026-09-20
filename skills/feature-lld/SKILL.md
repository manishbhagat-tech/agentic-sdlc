---
name: feature-lld
description: >-
  Low-level design + reuse map for a feature; optional US-* slice; ARCHITECTURE.md
  pack pointer. Design docs only — no app code.
---

# feature-lld

## Essentials first

Apply [`docs/WRAPPER-ESSENTIALS.md`](../../docs/WRAPPER-ESSENTIALS.md) before any composed skill.

## Skills filter

1. Read `orchestrators.feature-lld.skills` from [`docs/WRAPPER-MAP.yaml`](../../docs/WRAPPER-MAP.yaml).
2. Intersect with feature/story `skills:[]` when present.
3. Load only listed thin wrappers.

## Steps

1. Require feature PRD + HLD under `DOCS_ROOT`.
2. Compose (when listed): `addy/api-and-interface-design`, `addy/source-driven-development`, `addy/documentation-and-adrs`, `addy/observability-and-instrumentation`, `addy/performance-optimization`.
3. Write/update **LLD** using [`templates/feature/LLD.md`](../../templates/feature/LLD.md):
   - Module/package boundaries, key types, sequence notes
   - **Reuse map** — existing modules/services to extend vs new
   - Optional **US-*** slice table (which stories cover which LLD sections)
4. If product has `ARCHITECTURE.md` (or similar), add/update a short pack pointer from LLD → that doc (path only; do not paste whole trees).
5. **Do not** edit application code.
6. Write `.agentic/runs/<feat-id>-feature-lld.json` with `skills_declared` / `skills_invoked`.
7. Emit:

```
HANDOFF: feature-lld → feature-ui|feature-stories | outcome=<pass|fail> | lld=<path> | notes=…
```

## Refuse

- Implementing code “to validate LLD”
- Loading stack skills without channel/stack gate
