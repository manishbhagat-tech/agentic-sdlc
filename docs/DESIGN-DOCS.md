# Design docs

Feature design lives under product `DOCS_ROOT`, not in code repos.

## Order

```
feature-research? → feature-prd → feature-hld → feature-lld → feature-ui (if web/mobile) → feature-stories
```

## Artifacts

| Doc | Template | Owner role |
|-----|----------|------------|
| Research pack | cited md at `out_path` | researcher |
| PRD | `templates/feature/PRD.md` | product |
| HLD | `templates/feature/HLD.md` | architect |
| LLD | `templates/feature/LLD.md` | architect |
| UI | `templates/feature/UI.md` | designer |
| US-* / BUG-* | `templates/story/STORY.md`, `templates/bug/BUG.md` | product |

## Rules

- No application code in design skills.
- HLD includes Scalability, Observability, Ledger anti-patterns.
- LLD includes reuse map + optional US-* slice; pointer to product ARCHITECTURE.md.
- UI.md names token SoT paths; stories must not invent hex.
- Stories require `skills:[]` at design time; DoR checks PRD+HLD+LLD(+UI) and channel gates.

## Packs

`must_read` on stories should include the feature parents needed for implement/review. Packer stays fail-closed on budgets.
