---
name: feature-hld
description: >-
  Feature HLD under DOCS_ROOT: API/interfaces, ADRs, observability, performance,
  ledger anti-patterns. No application code.
---

# feature-hld

## Essentials first

Apply [`docs/WRAPPER-ESSENTIALS.md`](../../docs/WRAPPER-ESSENTIALS.md) before any composed skill.
On conflict, essentials win; log override in the run log.

## Skills filter

1. Read `orchestrators.feature-hld.skills` from [`docs/WRAPPER-MAP.yaml`](../../docs/WRAPPER-MAP.yaml).
2. Intersect with feature/story `skills:[]` when present (phase `design`).
3. Load only wrappers in the filtered set via `skills/<ns>/<name>/`.

## Steps

1. Require an existing feature PRD under `DOCS_ROOT` (or abort with HANDOFF fail).
2. Compose (when listed):
   - `addy/api-and-interface-design`
   - `addy/documentation-and-adrs`
   - `addy/observability-and-instrumentation`
   - `addy/performance-optimization`
3. Write/update feature **HLD** using [`templates/feature/HLD.md`](../../templates/feature/HLD.md) — include Scalability, Observability, and Ledger / anti-patterns sections.
4. Call out security ledger anti-patterns (secrets in config, missing authz, string SQL, silent swallow) and point to [`docs/SECURITY-BASELINE.md`](../../docs/SECURITY-BASELINE.md) when present.
5. **Do not** edit application code.
6. Write `.agentic/runs/<feat-id>-feature-hld.json` with `skills_declared` / `skills_invoked`.
7. Emit:

```
HANDOFF: feature-hld → feature-lld|feature-ui | outcome=<pass|fail> | hld=<path> | notes=…
```

## Refuse

- App code changes
- Skipping PRD when required by product contract
- Unfiltered vendor dumps
