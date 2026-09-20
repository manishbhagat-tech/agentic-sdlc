# OSS enrichment

We vendor **pinned** skill trees and enter only via thin wrappers under `skills/`. Ideas from other OSS become first-party packer/harness practices — not blind MCP.

## Vendor pins

| Vendor tree | Repo | Pin file |
|-------------|------|----------|
| addy-agent-skills | addyosmani/agent-skills | `vendor/addy-agent-skills/VERSION.json` |
| sivalabs-agent-skills | sivaprasadreddy/sivalabs-agent-skills | `vendor/sivalabs-agent-skills/VERSION.json` |
| vercel-agent-skills | vercel-labs/agent-skills | `vendor/vercel-agent-skills/VERSION.json` |
| nextjs-skills | vercel/next.js (skills/) | `vendor/nextjs-skills/VERSION.json` |
| ui-skills | ui-skills scoped export | `vendor/ui-skills/VERSION.json` |
| ecc-market-research | affaan-m/ECC (was everything-claude-code) | `vendor/ecc-market-research/VERSION.json` |
| pm-competitor-analysis | phuryn/pm-skills | `vendor/pm-competitor-analysis/VERSION.json` |

Stack notes (non-skill): `vendor/stacks/spring-boot`, `vendor/stacks/database`.

## Safety bar

1. MIT / compatible license; recorded in VERSION.json.
2. Reviewed SHA; re-review on bump (`scripts/vendor-sync-check.sh`).
3. **Pin only** — no live `git clone` at agent runtime; no `curl | bash` installers from vendor trees.
4. Agents never open raw `vendor/` except the single path named by the active thin wrapper.
5. WRAPPER-ESSENTIALS always win on conflict with upstream guidance.
6. WRAPPER-MAP must list every vendored skill ≥ once; `check-wrapper-coverage.sh` asserts 1:1 wrappers.
7. Story `skills:[]` + stack_gates limit what loads per run.

## Initial review notes

| Vendor | Verdict | Notes |
|--------|---------|-------|
| Addy agent-skills | accept | MIT; craft skills (TDD, review, hardening, ship). Host CLI dirs (`.claude`, …) stay in vendor — not entrypoints. Essentials override any “dump whole repo” advice. |
| SivaLabs | accept | MIT; Spring/Java primary for Grok Java work. Prefer over Amplicode as default Spring pack. |
| Vercel agent-skills | accept | React / RN / composition / deploy helpers; gate by `stacks:` + channels. |
| Next.js skills | accept | Sparse subset from `vercel/next.js` skills/; Next-only stories. |
| ui-skills | accept (scoped) | File-first stubs until MCP export; replace `vendor/ui-skills/*/SKILL.md` on bump via allowlisted export — see MCP-ALLOWLIST. Coverage still requires wrappers. |
| ECC market-research | accept (scoped) | MIT; pin only `.cursor/skills/market-research` (not the full ECC harness). Host `.agents/*.yaml` skipped. Wrapper `skills/ecc/market-research`. |
| phuryn competitor-analysis | accept (scoped) | MIT; pin only `pm-market-research/skills/competitor-analysis`. Wrapper `skills/pm/competitor-analysis`. |
| should-i-build | adapted first-party | Scorecard / BUILD·CONDITIONAL·PIVOT·STOP + claim statuses only. **Not vendored** — see catalog. |

## Sync process

1. Detect drift: `./scripts/vendor-sync-check.sh` (or a single vendor name).
2. Update vendor tree to the new commit — for **Addy**, include `skills/`, **`agents/`**, and `references/` (not only skills).
3. Refresh `VERSION.json` (sha, date, notes, re-review).
4. **Always** run `./scripts/vendor-refresh-wrappers.sh` (or `python3 scripts/generate-thin-wrappers.py`).
   This regenerates:
   - `skills/<ns>/<name>/` for every vendored `SKILL.md`
   - `skills/addy-agents/<name>/` for every `vendor/addy-agent-skills/agents/*.md`
5. Run `./scripts/check-wrapper-coverage.sh` (also invoked by refresh + harness).
   Coverage **fails** if a new Addy agent lacks a wrapper or a `WRAPPER-MAP.yaml` entry.
6. If a **new** agent appeared: add `personas: - addy-agents/<name>` on the right orchestrator(s) and `coverage_index`; update `roles/*/SKILLS.md` if needed.
7. If an agent was **removed**: delete orphan `skills/addy-agents/<name>/` and map/role references.
8. Run `./scripts/harness-check.sh`.
9. Note changes in CHANGELOG.

## Catalog — other OSS (ideas only)

| Source | Idea adopted here | Not adopted |
|--------|-------------------|-------------|
| Eval / golden harnesses | `harness/golden`, gates.yaml | Third-party LLM judge as required CI |
| Symbol / outline retrieval | packer `CODE_OUTLINES/` | Whole-repo embeddings MCP by default |
| Trace / run logs | `.agentic/runs/` + run-log schema | Shipping traces to third parties |
| Secret scanners | `security-check.sh` patterns | Replacing product SAST/DAST |
| Cloudflare / deep audit | optional doc only | Mandatory cloud dependency |
| Endokelp/Should-I-build | First-party `skills/should-i-build`: 7-pillar scorecard, verdicts BUILD / CONDITIONAL / PIVOT / STOP, claim statuses VERIFIED / PARTLY / FALSE / UNVERIFIABLE, `INSUFFICIENT_DATA`, never invent stats | Multi-agent Task/Wave machinery, `last30days`, `deep-research`, Claude-Code-only installers |

See [MCP-ALLOWLIST.md](./MCP-ALLOWLIST.md) for optional pinned MCP.
