# Agentic SDLC Protocol

Reusable, product-agnostic contract for story-driven agent development.

## Principles

1. **Story-only coding** — no implementation without `US-*` or `BUG-*` in `ready` / `in_progress`.
2. **Token-min** — run context packer before implement/fix/test/review/cleanup; stay under story budgets.
3. **Secure + lean** — no secrets, least privilege, authz; minimal diffs; no junk; security ledger when findings appear.
4. **Full-slice stories** — unless `channels` is narrowed: **API + Web UI + Mobile UI + tests + security/vuln review**.
5. **Design before code** — optional research pack → feature PRD → HLD → LLD → UI (if web/mobile) → stories with `skills:[]`.
6. **Cleanup before done** — `story-cleanup` required; only that story’s diff footprint.
7. **Markdown = source of truth** — boards (GitHub Projects / Jira) are mirrors.
8. **Humans merge** — especially `security: elevated`; no auto-merge.
9. **Wrappers only** — bots enter via `skills/` orchestrators/thin wrappers; never raw `vendor/`.

## Layout

| Layer | Role |
|-------|------|
| This kit (`agentic-sdlc`) | Skills, roles, hooks, packer, harness, board adapter, vendored pins |
| Docs repo (`DOCS_ROOT`) | Epics, features (PRD/HLD/LLD/UI), stories, bugs, ADRs |
| Code repos | Thin `AGENTS.md` + application code |

Set `DOCS_ROOT` in each code repo `AGENTS.md` (e.g. `../civil-erp-docs`).

## Branching

- Feature: `feat/US-ADMIN-001-short-slug`
- Bug: `fix/BUG-ADMIN-003-short-slug`
- One story/bug per PR; PR title/body must cite the id.
- Agent git via `scripts/git-safe.sh`.

## Skill loop

```
feature-research? → feature-prd → feature-hld → feature-lld → feature-ui? → feature-stories
  → story-implement (api→web→mobile) → story-test → story-security
  → ui-review? → story-review → story-cleanup → git-ops → done
```

Bugs: `BUG-*` (via feature-stories) → story-fix → test → security → … → done.

Legacy: `story-author` / `story-ready` are thin redirects — prefer feature-* skills.

### Story `skills:[]`

- Written at design time by `feature-stories`.
- Runtime loads **exactly** that list ∩ WRAPPER-MAP phase list (+ essentials).
- Stack skills gated by product `stacks:` + channels (`docs/WRAPPER-MAP.yaml`).

## Roles

See [ROLES.md](./ROLES.md) and [docs/GROK-ROLES.md](./docs/GROK-ROLES.md) (researcher, product, architect, designer, developer, qa, security, git, devops).

## Change handling

| Case | Action |
|------|--------|
| Code buggy, AC ok | `feedback` + `story-fix` |
| Small AC tweak | bump `revision`, re-pack, implement/fix |
| Scope change | supersede → new `US-*` |
| Unclear domain | `status: needs_human` |
| Late bug | new `BUG-*` linked to `US-*` |

## RACI

| Activity | Agent | Human |
|----------|-------|-------|
| Author PRD/stories | Assist | Own |
| HLD/LLD/UI docs | Assist | Own |
| Implement/test/cleanup in allow | Own | Spot-check |
| UAT / domain | — | Own |
| Elevated security merge | Checklist | Approve |
| Board prioritization | Sync | Own |
| Prod deploy | — | Own |

## Security levels

- `standard` — `story-security` + slim review checklist
- `elevated` — auth, money, RBAC, PII; human must approve merge

## Install

```bash
./scripts/install-to-workspace.sh /path/to/code-repo
./scripts/install-to-workspace.sh /path/to/code-repo --symlink   # live sync locally
```

## Further reading

- [docs/WRAPPER-ESSENTIALS.md](./docs/WRAPPER-ESSENTIALS.md)
- [docs/PRODUCT-CI.md](./docs/PRODUCT-CI.md)
- [docs/BOARD.md](./docs/BOARD.md)
- [docs/WRAPPER-MAP.yaml](./docs/WRAPPER-MAP.yaml)
- [docs/DESIGN-DOCS.md](./docs/DESIGN-DOCS.md)
- [docs/SECURITY-BASELINE.md](./docs/SECURITY-BASELINE.md)
- [docs/TOKEN-OPTIMIZATION.md](./docs/TOKEN-OPTIMIZATION.md)
- [docs/STANDARD-PRACTICES.md](./docs/STANDARD-PRACTICES.md)
- [docs/OSS-ENRICHMENT.md](./docs/OSS-ENRICHMENT.md)
- [docs/MCP-ALLOWLIST.md](./docs/MCP-ALLOWLIST.md)
