# Grok roles

How to run agentic-sdlc with named personas (Grok or Cursor Agent).

## Setup

1. Install kit (`scripts/install-to-workspace.sh`) so skills/rules/hooks land in the code repo.
2. Point the agent at [`ROLES.md`](../ROLES.md) and `roles/<role>/PERSONA.md` + `SKILLS.md`.
3. Machine map: [`roles/roles.yaml`](../roles/roles.yaml).

## Rules for every role

- Apply `docs/WRAPPER-ESSENTIALS.md` first.
- Enter only via orchestrators / thin wrappers — **never** raw `vendor/`.
- Phase `personas:` (Addy agent overlays under `skills/addy-agents/`) load always for that orchestrator; procedure `skills:` still intersect story `skills:[]`.
- Respect story `skills:[]` intersected with WRAPPER-MAP phase.
- Emit run logs under `.agentic/runs/` with `skills_declared` / `skills_invoked`.
- End with a `HANDOFF:` line naming the next skill.

## Addy agent personas (vendored)

| Persona wrapper | Orchestrator | Purpose |
|-----------------|--------------|---------|
| `addy-agents/code-reviewer` | `story-review` | Five-dimension review + verdict template |
| `addy-agents/security-auditor` | `story-security` | Threat lens + audit report → ledger |
| `addy-agents/test-engineer` | `story-test` | Test strategy / prove-it |
| `addy-agents/web-performance-auditor` | `ui-review`, `story-review` (web) | CWV anti-patterns; quick mode default |

Personas are **who**; `skills/addy/*` are **how**. Both go through wrappers.

## Suggested loops

| Goal | Roles in order |
|------|----------------|
| New feature | researcher → product → architect → designer → product (stories) → developer → qa → security → designer (ui-review) → devops/review → developer (cleanup) → git |
| Bug | product (BUG) → developer (fix) → qa → security → … |
| Ship / image / K8s staging | devops (`skills/devops`) after review; prod = human |

## Deploy / hosting

- **Docker + Kubernetes** (default for APIs): [`docs/stacks/kubernetes.md`](./stacks/kubernetes.md), orchestrator `skills/devops/SKILL.md`.
- Addy `ci-cd-and-automation` + `shipping-and-launch` = delivery discipline; kit templates = Dockerfile/GH Actions/K8s examples seeded into **each product repo**.
- Vercel wrappers only when the app is actually on Vercel.

## Anti-patterns

- Loading all vendor skills “just in case”
- Product writing Java/TS in PRD phase
- Security skipped because review has a slim checklist
