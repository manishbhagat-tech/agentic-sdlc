# Deploy templates (Docker / Kubernetes)
#
# agentic-sdlc keeps **examples only**. Each product repo copies and owns the real files.
# See docs/stacks/kubernetes.md and skills/devops/SKILL.md.

| Template | Copy to product as |
|----------|-------------------|
| `Dockerfile.jvm.example` | `Dockerfile` (Spring/Java) |
| `Dockerfile.node.example` | `Dockerfile` (Next.js standalone) |
| `.dockerignore.example` | `.dockerignore` |
| `../github/docker-build.yml` | `.github/workflows/docker-build.yml` |
| `../github/k8s-deploy-staging.yml` | `.github/workflows/k8s-deploy-staging.yml` |
| `../github/k8s-deploy-prod.yml` | `.github/workflows/k8s-deploy-prod.yml` |
| `../k8s/*.example` | `deploy/k8s/*.yaml` |
