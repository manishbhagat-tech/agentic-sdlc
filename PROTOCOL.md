# Agentic SDLC Protocol

Reusable, product-agnostic contract for story-driven agent development.

## Principles

1. **Story-only coding** — no implementation without `US-*` or `BUG-*` in `ready` / `in_progress`.
2. **Token-min** — run context packer before implement/fix/test/review/cleanup; stay under story budgets.
3. **Secure + lean** — no secrets, least privilege, authz; minimal diffs; no junk.
4. **Cleanup before done** — `story-cleanup` required; only that story’s diff footprint.
5. **Markdown = source of truth** — boards (GitHub Projects / Jira) are mirrors.
6. **Humans merge** — especially `security: elevated`; no auto-merge.

## Layout

| Layer | Role |
|-------|------|
| This kit (`agentic-sdlc`) | Skills, hooks, packer, harness, board adapter |
| Docs repo (`DOCS_ROOT`) | Epics, features, stories, bugs, ADRs, program docs |
| Code repos | Thin `AGENTS.md` + application code |

Set `DOCS_ROOT` in each code repo `AGENTS.md` (e.g. `../civil-erp-docs`).

## Branching

- Feature: `feat/US-ADMIN-001-short-slug`
- Bug: `fix/BUG-ADMIN-003-short-slug`
- One story/bug per PR; PR title/body must cite the id.

## Skill loop

```
story-author → story-ready → story-implement → story-test → story-review → story-cleanup → done
```

Bugs: `BUG-*` → story-ready → story-fix → test → review → cleanup → done.

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
| Author stories | Assist | Own |
| Implement/test/cleanup in allow | Own | Spot-check |
| UAT / domain | — | Own |
| Elevated security merge | Checklist | Approve |
| Board prioritization | Sync | Own |
| Prod deploy | — | Own |

## Security levels

- `standard` — checklist in review
- `elevated` — auth, money, RBAC, PII; human must approve merge

## Install

```bash
./scripts/install-to-workspace.sh /path/to/code-repo
./scripts/install-to-workspace.sh /path/to/code-repo --symlink   # live sync locally
```

## Further reading

- [docs/TOKEN-OPTIMIZATION.md](./docs/TOKEN-OPTIMIZATION.md)
- [docs/STANDARD-PRACTICES.md](./docs/STANDARD-PRACTICES.md)
- [docs/MCP-ALLOWLIST.md](./docs/MCP-ALLOWLIST.md)
