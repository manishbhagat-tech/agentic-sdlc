# DevOps — skills

- **Orchestrator:** `skills/devops/SKILL.md`
- Stack notes: `docs/stacks/kubernetes.md`

## Addy (always for devops phase)

- `skills/addy/ci-cd-and-automation`
- `skills/addy/shipping-and-launch`
- `skills/addy/deprecation-and-migration` (when cutting over)

## Optional / gated

- `sivalabs/apply-renovate-prs` — dependency PRs
- `vercel/deploy-to-vercel`, `vercel/vercel-cli-with-tokens`, `vercel/vercel-optimize` — **only** if hosting is Vercel

## Templates to seed into product repos

- `templates/deploy/` — Dockerfile / `.dockerignore`
- `templates/github/docker-build.yml`, `k8s-deploy-staging.yml`
- `templates/k8s/` — Deployment / Service examples

Never open raw `vendor/`. No auto-prod deploy. No auto-merge of elevated stories.
