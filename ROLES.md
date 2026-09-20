# Roles (Grok / Cursor personas)

Product-agnostic role pack for agentic-sdlc. Each role points only at **orchestrators and thin wrappers** under `skills/` — never raw `vendor/`.

| Role | Owns | Primary orchestrators |
|------|------|------------------------|
| researcher | cited topic pack → product (ECC default; competitors / validate modes) | `feature-research` |
| product | PRD, stories, DoR | `feature-prd`, `feature-stories` |
| architect | HLD, LLD, ADRs | `feature-hld`, `feature-lld` |
| designer | UI.md, tokens SoT | `feature-ui`, `ui-review` |
| developer | implement / fix | `story-implement`, `story-fix` |
| qa | tests + review | `story-test`, `story-review` (+ `addy-agents/test-engineer`, `code-reviewer`) |
| security | ledger, baseline | `story-security` (+ `addy-agents/security-auditor`) |
| git | safe branches/PRs | `git-ops` |
| devops | CI/CD, Docker/K8s ship prep | `devops` (+ Addy ci-cd/shipping; templates in `templates/deploy`) |

Machine index: [`roles/roles.yaml`](./roles/roles.yaml). Per-role: `roles/<name>/PERSONA.md` + `SKILLS.md`.

See also [docs/GROK-ROLES.md](./docs/GROK-ROLES.md).
