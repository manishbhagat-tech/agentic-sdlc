# Standard practices (agentic SDLC)

Baseline engineering practices this kit expects products to follow.

## Delivery

| Practice | Kit support |
|----------|-------------|
| Story-only changes | skills + rules + hooks |
| Design docs before code | feature-research? → feature-prd/hld/lld/ui + DESIGN-DOCS |
| **Full slice (api+web+mobile)** | story contract / `channels` |
| Explicit skill loadout | story `skills:[]` ∩ WRAPPER-MAP |
| Tests + security + UI gate | story-test → story-security → ui-review → story-review |
| Branch per story | `feat/US-*`, `fix/BUG-*` + git-safe |
| One story per PR | PROTOCOL + CI cite gate |
| AC + DoD on every story | templates + feature-stories DoR |
| Definition of Ready | feature-stories (legacy story-ready) |
| Security elevated path | frontmatter + human merge + ledger |
| Lean / no junk | review + `story-cleanup` |
| Late bugs linked to stories | `BUG-*` template |
| Path conflict avoidance | `path-lock-check.sh` |
| Cost visibility | run logs + `cost-report.sh` |
| Roles | `ROLES.md` / `roles/*` |

## Code quality

- Prefer small diffs mapped to AC; reuse-first per LLD
- No secrets in git; env for credentials; `security-check.sh`
- Tests declared on the story and run via `story-test`
- Authz and validation on mutating APIs; scalable defaults (pagination, timeouts)

## Repo hygiene

- Keep product repos thin (`AGENTS.md` + install kit)
- Docs in a dedicated docs repo when multi-repo
- Board tools are mirrors; markdown is SoT
- Vendors pinned; wrappers only — see OSS-ENRICHMENT
- Re-run `install-to-workspace.sh` after kit upgrades (or use `--symlink`)

## CI minimum

1. Story/BUG id on PRs (`check-pr-story-id.sh` / product-gates)  
2. Docs frontmatter validation (`skills:[]` for ready stories)  
3. Path-lock on docs  
4. Build + unit tests on code repos  
5. Kit `check-wrapper-coverage.sh` + `harness-check.sh` on this repo  
6. Product `product-gates.sh` + gitleaks (see [PRODUCT-CI.md](./PRODUCT-CI.md))  
7. Critical/High findings → `bug_id` + GitHub Project mirror ([BOARD.md](./BOARD.md))  

## What we deliberately skip (v1)

- Auto-merge  
- Auto-deploy agents  
- Blind third-party MCP  
- Replacing human UAT for domain/finance  
- Mandatory Cloudflare / deep audit (optional — see SECURITY-DEEP-AUDIT)
