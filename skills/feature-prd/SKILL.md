---
name: feature-prd
description: >-
  Design-phase PRD under DOCS_ROOT. Composes interview-me / idea-refine /
  spec-driven-development. No application code.
---

# feature-prd

## Essentials first

Apply [`docs/WRAPPER-ESSENTIALS.md`](../../docs/WRAPPER-ESSENTIALS.md) before any composed skill.
On conflict, essentials win; log override in the run log.

## Skills filter

1. Read `orchestrators.feature-prd.skills` from [`docs/WRAPPER-MAP.yaml`](../../docs/WRAPPER-MAP.yaml).
2. If a feature/story frontmatter `skills:[]` is present, **intersect** with the map list for this phase (`design`). Load only the intersection.
3. Legacy docs missing `skills:` may use the full map list with a **warn** to backfill.
4. Resolve each id to `skills/<ns>/<name>/SKILL.md` (thin wrappers only — never raw `vendor/`).

## Steps

1. Resolve `DOCS_ROOT` from workspace `AGENTS.md`. Locate or create the feature folder.
2. Optionally run `addy/interview-me` for discovery when the list includes it.
3. Compose `addy/idea-refine` then `addy/spec-driven-development` (when listed) to sharpen problem, scope, and acceptance themes.
4. Write/update the feature **PRD** under `DOCS_ROOT` using [`templates/feature/PRD.md`](../../templates/feature/PRD.md).
5. **Do not** edit application code.
6. Write `.agentic/runs/<feat-id>-feature-prd.json` with at least:
   - `story_id` (feature id), `skill`: `feature-prd`, `outcome`
   - `skills_declared`, `skills_invoked`
   - `pack_tokens_est`, `files_read`, `files_edited` when known
7. Emit handoff:

```
HANDOFF: feature-prd → feature-hld | outcome=<pass|fail> | prd=<path> | notes=…
```

## Refuse

- Writing app/source code
- Loading wrappers not in the filtered list
- Opening raw `vendor/` trees
