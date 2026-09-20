---
name: should-i-build
description: >-
  First-party go/no-go scorecard: BUILD / CONDITIONAL / PIVOT / STOP with a
  7-pillar card and claim statuses. Use when feature-research mode is validate
  or the ask is go-no-go / should we build. Scorecard only — no multi-agent Task
  waves. Inspired by Endokelp/Should-I-build (not a vendor pin).
inspiration: https://github.com/Endokelp/Should-I-build
---

# should-i-build

Adapted **scorecard + verdict** only. Do **not** spawn Claude-Code Task waves, `last30days`, or `deep-research`. Work inline from the research pack and cited sources.

Inspiration (not vendored): [Endokelp/Should-I-build](https://github.com/Endokelp/Should-I-build). See [docs/OSS-ENRICHMENT.md](../../docs/OSS-ENRICHMENT.md).

## Essentials first

Apply [`docs/WRAPPER-ESSENTIALS.md`](../../docs/WRAPPER-ESSENTIALS.md) before scoring.
On conflict, essentials win; log override in the run log.

## Preconditions

- Invoked via `feature-research` (`mode: validate` or a go-no-go ask) or listed in story `skills:`.
- Prefer an existing cited pack (`out_path`) over a new market sweep.

## Evidence rules

1. Never invent statistics, TAM/SAM/SOM, share, or pricing.
2. Every important claim needs a source URL/doc, or status `UNVERIFIABLE` / `INSUFFICIENT_DATA`.
3. Separate **fact** / **inference** / **recommendation**.
4. Stale data: flag the date. Missing dimension: write `INSUFFICIENT_DATA` — do not estimate.

## Claim statuses

| Status | Meaning |
|--------|---------|
| `VERIFIED` | Independent source confirms the number or fact |
| `PARTLY` | Directionally supported; scope/date/definition is off |
| `FALSE` | Source contradicts the claim |
| `UNVERIFIABLE` | No checkable source |
| `INSUFFICIENT_DATA` | Search/pack returned nothing for this dimension |

## 7-pillar scorecard (0–5 each)

Score **evidence strength**, not optimism.

| Score | Meaning |
|-------|---------|
| 0 | No evidence / negative evidence / assumption only |
| 1–2 | Weak — partial data, mostly assumed |
| 3 | Moderate — some market/customer data + named assumptions |
| 4–5 | Strong — behavioral evidence, real spending, verified metrics |

1. **Problem Clarity** — pain urgent, specific, frequent?
2. **Target Customer** — named who / situation / budget authority?
3. **Demand Signal** — spending, workarounds, pre-orders (not compliments)?
4. **Differentiation** — a gap no existing tool fills well?
5. **Execution Feasibility** — realistic for this team? (no founder context → score 3)
6. **Distribution Readiness** — a plausible acquisition path?
7. **Monetization Viability** — unit economics / WTP evidenced?

**Kill condition:** if Demand Signal is 0 or 1 → verdict is **STOP**, regardless of total.

## Verdicts

| Total | Verdict | Meaning |
|-------|---------|---------|
| 30–35 | **BUILD** | Smallest version; evidence supports starting |
| 22–29 | **CONDITIONAL** | Named gap; close it before writing product/code |
| 15–21 | **PIVOT** | Pain may be real; approach, ICP, or pricing is wrong |
| < 15 | **STOP** | Demand/fundamentals failed. STOP is a successful outcome |

## Steps

1. Frame in ≤ 5 bullets: idea, target customer, problem, mechanic, why now (if known).
2. Pull contested claims (3–5) from the pack / topic. Mark each `VERIFIED` / `PARTLY` / `FALSE` / `UNVERIFIABLE` / `INSUFFICIENT_DATA`.
3. Score the seven pillars from cited evidence. Apply the kill condition.
4. Deliver the output contract. Return pass/fail to the calling orchestrator.

## Output contract

```
## Should I Build? — [Idea]

**Verdict: [BUILD / CONDITIONAL / PIVOT / STOP]** — [X]% confidence
(Confidence: 75–90% many VERIFIED + behavioral; 50–74% mixed PARTLY; 30–49% mostly UNVERIFIABLE. Cap 60% if claims were not checked.)

### Scorecard
| Pillar | /5 | Key evidence (source) |
| Problem Clarity | | |
| Target Customer | | |
| Demand Signal | | |
| Differentiation | | |
| Execution Feasibility | | |
| Distribution Readiness | | |
| Monetization Viability | | |
**Total: [XX]/35**

### Claim verification
| Claim | Status |
| [claim] | VERIFIED / PARTLY / FALSE / UNVERIFIABLE / INSUFFICIENT_DATA |

### Kill condition
Painkiller test: PASS / FAIL — one line

### Named gap / next experiment
One executable check targeting the weakest evidenced pillar.

### Evidence gaps
Unknowns marked INSUFFICIENT_DATA + fastest close.
```

## Refuse

- Inventing stats or unsourced market claims
- Spawning multi-agent Task / Wave machinery, `last30days`, or `deep-research`
- Writing app code, PRDs, or stories
- Opening raw `vendor/` trees
- Loading this skill when the orchestrator mode / story `skills:` do not require it
