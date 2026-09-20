---
name: feature-research
description: >-
  Topic in → cited research pack (ICP, competitors, trends, wedges, risks,
  recs). Default ECC market-research standards; optional competitor matrix and
  should-i-build verdict. Hands off to product. No app code, PRDs, or stories.
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
| `mode` | no | `default` · `competitors` · `validate` (see Modes) |

## Modes

| Mode | Also compose | When |
|------|----------------|------|
| `default` | `ecc/market-research` | Always — sources, fact vs inference vs recommendation, decision-oriented output |
| `competitors` | + `pm/competitor-analysis` | `mode: competitors` **or** the topic is competitive (landscape, alternatives, differentiation) |
| `validate` | + `should-i-build` | `mode: validate` **or** a go-no-go / should-we-build ask |

Addy wrappers still intersect story `skills:[]` when present.

## Skills filter

1. Read `orchestrators.feature-research.skills` from [`docs/WRAPPER-MAP.yaml`](../../docs/WRAPPER-MAP.yaml).
2. If a feature/story frontmatter `skills:[]` is present, **intersect** with the map list for this phase (`design`) for Addy wrappers. Load only the intersection.
3. Resolve namespaced ids to `skills/<ns>/<name>/SKILL.md`; first-party `should-i-build` to `skills/should-i-build/SKILL.md`. Thin wrappers / first-party only — never raw `vendor/`.
4. **Always** compose `ecc/market-research` on the default path (primary research standard).
5. Compose `pm/competitor-analysis` when mode is `competitors` or the topic is competitive.
6. Compose `should-i-build` when mode is `validate` or the ask is go-no-go.

## Steps

1. Resolve inputs. If `out_path` is relative, write it under `DOCS_ROOT` from workspace `AGENTS.md`.
2. Apply `ecc/market-research` standards while researching:
   - every important claim needs a source
   - prefer recent data; flag stale dates
   - include contrarian / downside cases
   - separate **fact**, **inference**, and **recommendation**
   - translate findings into a decision, not theater
3. Pack sections (cited):
   - ICP
   - competitors
   - trends
   - fast-mover wedges
   - risks / unknowns
   - prioritized recs
   - plus ECC default structure when useful: executive summary, key findings, implications, risks, recommendation, sources
4. If competitor mode: compose `pm/competitor-analysis` and include a **5-competitor matrix** (profiles, strengths/weaknesses, pricing, differentiation, positioning rec).
5. If validate / go-no-go: compose `should-i-build` (scorecard + BUILD / CONDITIONAL / PIVOT / STOP). Append the verdict block to the pack.
6. Compose listed Addy wrappers (when present) to ground sources and structure recs — **not** to write PRDs or stories:
   - `addy/source-driven-development`
   - `addy/planning-and-task-breakdown`
7. Write the cited markdown pack to `out_path`. Never invent stats; cite, mark unknown, or `INSUFFICIENT_DATA`.
8. **Do not** edit application code, PRDs, or stories.
9. Write `.agentic/runs/<feat-id>-feature-research.json` with at least:
   - `story_id` (feature or topic id), `skill`: `feature-research`, `outcome`
   - `skills_declared`, `skills_invoked`
   - `pack_tokens_est`, `files_read`, `files_edited` when known
10. Emit handoff:

```
HANDOFF: feature-research → feature-prd | outcome=<pass|fail> | pack=<path> | notes=…
```

## Done when

- Cited pack exists at `out_path` (ECC standards applied)
- Competitor matrix present when mode/topic required it
- Verdict present when validate / go-no-go required it
- HANDOFF to product (`feature-prd`) emitted

## Out of scope

- Application / source code
- PRDs, HLD/LLD/UI, US-*/BUG-* stories
- Endokelp multi-agent Task / Wave machinery

## Refuse

- Writing app/source code, PRDs, or stories
- Inventing statistics or unsourced market claims
- Loading wrappers not in the filtered list (except mode-required ECC / competitor / verdict skills above)
- Opening raw `vendor/` trees
