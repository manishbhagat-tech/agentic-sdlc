# agentic-sdlc

Reusable **token-min** agentic software delivery kit for Cursor / Grok:

- Design orchestrators (PRD → HLD → LLD → UI → stories with `skills:[]`)
- Story loop (implement → test → security → ui-review → review → cleanup → git-ops)
- Thin wrappers over pinned OSS vendors (never raw `vendor/` entry)
- Context packer + budgets (fail closed); security ledger best-effort in packs
- Roles pack (`ROLES.md`) + alwaysApply rules + git-safe / shell denies
- First-party harness (gates, goldens, run logs, path-lock, wrapper coverage)
- Board adapter (GitHub Projects now / Jira later)

## Install into a product repo

```bash
git clone https://github.com/manishbhagat-tech/agentic-sdlc.git
./agentic-sdlc/scripts/install-to-workspace.sh /path/to/your-api

# Local machines — symlink so kit updates apply immediately:
./agentic-sdlc/scripts/install-to-workspace.sh /path/to/your-api --symlink
```

Set in product `AGENTS.md`:

```text
DOCS_ROOT: ../your-docs
AGENTIC_SDLC: ../agentic-sdlc
```

## Docs

| Doc | Purpose |
|-----|---------|
| [PROTOCOL.md](./PROTOCOL.md) | Contract + skill loop |
| [ROLES.md](./ROLES.md) | Grok/Cursor personas |
| [docs/WRAPPER-ESSENTIALS.md](./docs/WRAPPER-ESSENTIALS.md) | Always-first wrapper rules |
| [docs/DESIGN-DOCS.md](./docs/DESIGN-DOCS.md) | PRD/HLD/LLD/UI |
| [docs/SECURITY-BASELINE.md](./docs/SECURITY-BASELINE.md) | Security ledger baseline |
| [docs/stacks/kubernetes.md](./docs/stacks/kubernetes.md) | Docker/K8s templates + per-repo ownership |
| [docs/PRODUCT-CI.md](./docs/PRODUCT-CI.md) | Product gates ↔ gates.yaml |
| [docs/BOARD.md](./docs/BOARD.md) | GitHub Projects mirror for US-*/BUG-* |
| [docs/OSS-ENRICHMENT.md](./docs/OSS-ENRICHMENT.md) | Vendor pins + sync |
| [docs/TOKEN-OPTIMIZATION.md](./docs/TOKEN-OPTIMIZATION.md) | How we save tokens |
| [docs/STANDARD-PRACTICES.md](./docs/STANDARD-PRACTICES.md) | Engineering baseline |
| [docs/MCP-ALLOWLIST.md](./docs/MCP-ALLOWLIST.md) | Optional MCP (default off) |
| [CONTRIBUTING.md](./CONTRIBUTING.md) | Dev + sync |

## Harness (no LLM)

```bash
./scripts/check-wrapper-coverage.sh
./scripts/harness-check.sh
./scripts/product-gates.sh   # needs DOCS_ROOT; see docs/PRODUCT-CI.md
```

## Product CI + board

- Copy [`templates/github/agentic-gates.yml`](./templates/github/agentic-gates.yml) into each code repo (install does this once).
- Track `US-*` / `BUG-*` on a GitHub Project — see [docs/BOARD.md](./docs/BOARD.md). Markdown stays SoT.

## Enrichment stance

We adopt **ideas** from OSS as first-party packer/harness practices and pin skill vendors under `vendor/` with VERSION.json. Third-party MCP is optional and must be pinned + allowlisted — see MCP-ALLOWLIST.

## License

MIT
