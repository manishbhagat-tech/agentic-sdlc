---
name: devops
description: >-
  CI/CD, Docker image build, Kubernetes staging deploy prep, and launch checklist.
  Compose Addy ci-cd + shipping; prod apply is human-only. Optional Vercel when stacks allow.
---

# devops

## Essentials first

Apply [`docs/WRAPPER-ESSENTIALS.md`](../../docs/WRAPPER-ESSENTIALS.md) before any composed skill.

**Hard rules**

- **No auto production deploy** — humans own prod (PROTOCOL RACI). Staging may auto after green CI.
- Never commit registry passwords, kubeconfigs, or cloud keys into git/packs/run logs.
- Prefer kit deploy templates under `templates/deploy/` and `templates/github/` — copy once into the **product** repo; do not build images from the agentic-sdlc repo for other apps.

## Skills filter

1. Read `orchestrators.devops.skills` from [`docs/WRAPPER-MAP.yaml`](../../docs/WRAPPER-MAP.yaml).
2. **Always** compose (procedure):
   - `addy/ci-cd-and-automation` — quality gates, pipeline shape, staging→prod, flags, rollback *patterns*
   - `addy/shipping-and-launch` — pre-launch checklist, health checks, monitoring, staged rollout
3. Compose when relevant: `addy/deprecation-and-migration`, gated `sivalabs/apply-renovate-prs`.
4. Compose `vercel/*` deploy wrappers **only** when product `stacks:` includes vercel/next **and** hosting is Vercel — not for Docker/K8s APIs.
5. Read stack notes: [`docs/stacks/kubernetes.md`](../../docs/stacks/kubernetes.md).

### What Addy does *not* provide

Upstream Addy has **no** Docker/Kubernetes/Helm skill. Use Addy for **delivery discipline**; use this orchestrator + product Docker/Helm files for **container mechanics**.

## Preconditions

- User names target repo(s) and environment (`local` | `staging` | `prod-prep`).
- For story-tied work, prefer a ready/in_progress `US-*` / `BUG-*` and pack context when touching app code.
- Cluster/registry credentials exist only in CI secrets / vault — never in the prompt.

## Steps

1. **Discover** existing `Dockerfile`, `.dockerignore`, `deploy/`, `helm/`, `k8s/`, `.github/workflows/*`.
2. If missing, **seed from kit templates** (copy into product repo — do not leave as the only copy in agentic-sdlc):
   - [`templates/deploy/`](../../templates/deploy/) — Dockerfile examples, `.dockerignore`
   - [`templates/github/docker-build.yml`](../../templates/github/docker-build.yml) — build & push image
   - [`templates/github/k8s-deploy-staging.yml`](../../templates/github/k8s-deploy-staging.yml) — staging apply
   - [`templates/k8s/`](../../templates/k8s/) — Deployment/Service examples
3. Compose `addy/ci-cd-and-automation`: lint→test→build→image→security audit; wire **agentic-gates** beside build (see [`docs/PRODUCT-CI.md`](../../docs/PRODUCT-CI.md)).
4. Compose `addy/shipping-and-launch`: health endpoint, rollback plan, monitoring window, feature flags where useful.
5. **Docker:** multi-stage build, non-root user, no secrets in layers, tag `git sha` (+ optional semver).
6. **Kubernetes:** manifests/Helm in the **app or infra repo**; staging pipeline applies; prod = `workflow_dispatch` + human approval.
7. Write `.agentic/runs/<id|adhoc>-devops.json` with `skills_declared` / `skills_invoked`.
8. Emit:

```
HANDOFF: devops → human|git-ops | outcome=<pass|fail> | env=<staging|prod-prep> | image=<tag|none> | notes=…
```

## Refuse

- `kubectl apply` / Helm upgrade to **production** without explicit human confirmation in-session
- Storing `kubeconfig` or registry tokens in the repo
- Using Vercel deploy skills as a stand-in for K8s API services
- Building product images from the agentic-sdlc git repo as a shared “builder service”
