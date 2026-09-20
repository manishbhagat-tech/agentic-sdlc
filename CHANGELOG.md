# Changelog

## 0.3.2 — 2026-09-20

- Deploy automation applied to product repos: real Dockerfiles, staging auto-deploy, prod `workflow_dispatch` + Environment approval
- `scripts/apply-deploy-automation.sh`; mobile → EAS workflow; pharma phase-0 placeholders
- Kit templates: docker-build, k8s-deploy-staging/prod aligned with product patterns

## 0.3.1 — 2026-09-20

- DevOps orchestrator `skills/devops/SKILL.md`: Docker/K8s + Addy ci-cd/shipping; no auto-prod
- Stack notes `docs/stacks/kubernetes.md`; templates under `templates/deploy`, `templates/k8s`, `templates/github/docker-build.yml` + `k8s-deploy-staging.yml`
- Install seeds Docker/K8s workflows and example manifests once (never overwrites)

## 0.3.0 — 2026-09-20

- Product CI: `product-gates.sh` wired to `harness/gates.yaml` (`product_ci` flags); template `templates/github/agentic-gates.yml`
- Gate scripts: validate-story-frontmatter, check-pr-story-id, check-run-logs, check-security-findings
- Security depth: gitleaks + npm audit hooks in security-check; Critical/High → required `bug_id`; ledger Bug column
- Board: `board-sync.sh` + BOARD.md — GitHub Projects dashboard mirror for US-*/BUG-*
- Docs: PRODUCT-CI.md, BOARD.md; goldens require `skills:[]`
- Install copies product workflow + board.yaml + new scripts; harness smoke-runs product-gates

## 0.2.0 — 2026-09-20

- Orchestrators: feature-prd/hld/lld/ui/stories, story-security, ui-review, git-ops; story-* updated for skills[] + HANDOFF
- story-author / story-ready → legacy redirects
- Templates: LLD, UI; HLD scalability/observability/ledger; story/bug skills[] + DoD
- Security baseline, ledger template, findings schema, security-check.sh, ATTACK-CLASSES
- Rules: secure-codegen, reuse-first, scalable-design, git-guardrails; expanded shell denies; git-safe.sh
- Roles pack (ROLES.md + roles/*) for Grok/Cursor
- Docs: OSS-ENRICHMENT, DESIGN-DOCS, GROK-ROLES, SECURITY-DEEP-AUDIT, stack stubs; PROTOCOL/README/STANDARD-PRACTICES
- Harness: new skills in run-log schema, gates, wrapper coverage in harness-check; packer includes security baseline/ledger
- Install: roles, security-check, git-safe, coverage script; vendor note

## 0.1.0 — 2026-09-13

- Initial kit: PROTOCOL, skills (author/ready/implement/fix/test/review/cleanup)
- Context packer, harness gates, path-lock, cost-report
- Board adapter (GitHub Projects + Jira example)
- Token optimization + standard practices docs
- Optional MCP allowlist (default off)
