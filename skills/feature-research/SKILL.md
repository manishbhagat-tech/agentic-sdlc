---
name: feature-research
description: >-
  Topic in → cited research pack (ICP, competitors, trends, wedges, risks,
  recs). Hands off to product. No app code, PRDs, or stories.
---

# feature-research

## Essentials first

Apply [`docs/WRAPPER-ESSENTIALS.md`](../../docs/WRAPPER-ESSENTIALS.md) before any composed skill.
On conflict, essentials win; log override in the run log.

## Inputs

| Input | Required | Notes |
|-------|----------|-------|
| `topic` | yes | Research question / market / feature theme |
| `out_path` | yes | Markdown pack path (usually under `DOCS_ROOT`) |
| `product_context` | no | Existing product/ICP notes to constrain research, not replace it |

## Skills filter

1. Read `orchestrators.feature-research.skills` from [`docs/WRAPPER-MAP.yaml`](../../docs/WRAPPER-MAP.yaml).
2. If a feature/story frontmatter `skills:[]` is present, **intersect** with the map list for this phase (`design`). Load only the intersection.
3. Resolve each id to `skills/<ns>/<name>/SKILL.md` (thin wrappers only — never raw `vendor/`).

## Steps

1. Resolve inputs. If `out_path` is relative, write it under `DOCS_ROOT` from workspace `AGENTS.md`.
2. Research the topic. Pack sections (cited):
   - ICP
   - competitors
   - trends
   - fast-mover wedges
   - risks / unknowns
   - prioritized recs
3. Compose listed wrappers (when present) to ground sources and structure recs — **not** to write PRDs or stories:
   - `addy/source-driven-development`
   - `addy/planning-and-task-breakdown`
4. Write the cited markdown pack to `out_path`. Never invent stats; cite or mark unknown.
5. **Do not** edit application code, PRDs, or stories.
6. Write `.agentic/runs/<feat-id>-feature-research.json` with at least:
   - `story_id` (feature or topic id), `skill`: `feature-research`, `outcome`
   - `skills_declared`, `skills_invoked`
   - `pack_tokens_est`, `files_read`, `files_edited` when known
7. Emit handoff:

```
HANDOFF: feature-research → feature-prd | outcome=<pass|fail> | pack=<path> | notes=…
```

## Done when

- Cited pack exists at `out_path`
- HANDOFF to product (`feature-prd`) emitted

## Out of scope

- Application / source code
- PRDs, HLD/LLD/UI, US-*/BUG-* stories

## Refuse

- Writing app/source code, PRDs, or stories
- Inventing statistics or unsourced market claims
- Loading wrappers not in the filtered list
- Opening raw `vendor/` trees
