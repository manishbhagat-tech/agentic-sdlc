# Kubernetes + Docker stack notes

First-party conventions for products that ship with **Docker images** and **Kubernetes**.  
Addy (`ci-cd-and-automation`, `shipping-and-launch`) supplies **pipeline/launch discipline** only — not Dockerfile/Helm content.

## What lives where

| Location | Owns |
|----------|------|
| **agentic-sdlc** | Templates + devops orchestrator + this doc |
| **Each product repo** | Real `Dockerfile`, workflows, Helm/manifests, registry project |
| **Infra / platform repo** (optional) | Cluster, ingress, shared base images, sealed-secrets |

**Do not** run image builds for app A from the agentic-sdlc repository. Install/copy templates **once** into each app repo (or monorepo service folder).

```text
agentic-sdlc/templates/deploy/*     →  your-api/Dockerfile  (customize)
agentic-sdlc/templates/github/*     →  your-api/.github/workflows/
agentic-sdlc/templates/k8s/*        →  your-api/deploy/k8s/  or helm chart
```

`install-to-workspace.sh` can seed these if missing (never overwrite customized files).

## Recommended layout (per service repo)

```text
your-api/
├── Dockerfile
├── .dockerignore
├── deploy/k8s/          # or charts/
│   ├── deployment.yaml
│   └── service.yaml
├── .github/workflows/
│   ├── agentic-gates.yml
│   ├── docker-build.yml
│   └── k8s-deploy-staging.yml
└── AGENTS.md            # stacks: [spring, kubernetes]  (example)
```

## Pipeline shape (compatible with kit)

```text
PR  → agentic-gates + unit tests + docker build (no push, or push :pr-<n>)
main → docker-build push :sha → k8s-deploy-staging
prod → workflow_dispatch + environment approval (human)
```

Align with Addy: staging auto after green CI; production manual; rollback plan before ship; health check after apply.

## Image rules

1. Multi-stage builds; final image non-root.  
2. Tag with git SHA; optionally also semver on release.  
3. No secrets in `ARG`/`ENV` that bake credentials into layers.  
4. Scan in CI when available (`trivy` / registry scan) — product CI owns the scanner install.  
5. Base images: pin digests when possible; org-wide bases live in **infra**, not agentic-sdlc.

## Kubernetes rules

1. Resource requests/limits required.  
2. Probes: liveness + readiness on a real `/health` (or Actuator).  
3. No plaintext secrets in manifests — use Sealed Secrets / External Secrets / CI-injected secrets.  
4. One Deployment per service; ingress/TLS via platform standards.  
5. Prod apply only with human-approved workflow.

## AGENTS.md stacks example

```text
stacks: [spring, kubernetes]
```

Gate Vercel wrappers off when stacks are kubernetes-only.

## Related

- Orchestrator: [`skills/devops/SKILL.md`](../../skills/devops/SKILL.md)
- Addy wrappers: `skills/addy/ci-cd-and-automation`, `skills/addy/shipping-and-launch`
- Product gates: [`PRODUCT-CI.md`](./PRODUCT-CI.md)
- Board: [`BOARD.md`](./BOARD.md)
