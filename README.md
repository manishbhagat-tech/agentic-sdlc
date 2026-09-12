# agentic-sdlc

Reusable **token-min** agentic software delivery kit for Cursor:

- Story-only skills (author → ready → implement → fix → test → review → cleanup)
- Context packer + budgets (fail closed)
- First-party AI harness (gates, goldens, run logs, path-lock, cost report)
- Guardrail hooks/rules
- Board adapter (GitHub Projects now / Jira later)
- Secure + lean codegen protocol

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
| [PROTOCOL.md](./PROTOCOL.md) | Contract |
| [docs/TOKEN-OPTIMIZATION.md](./docs/TOKEN-OPTIMIZATION.md) | How we save tokens |
| [docs/STANDARD-PRACTICES.md](./docs/STANDARD-PRACTICES.md) | Engineering baseline |
| [docs/MCP-ALLOWLIST.md](./docs/MCP-ALLOWLIST.md) | Optional MCP (default off) |
| [CONTRIBUTING.md](./CONTRIBUTING.md) | Dev + sync |

## Harness (no LLM)

```bash
./scripts/harness-check.sh
```

## Enrichment stance

We adopt **ideas** from OSS (symbol retrieval, eval harnesses, trace replay) as first-party packer/harness practices. Third-party MCP is optional and must be pinned + allowlisted — see MCP-ALLOWLIST.

## License

MIT
