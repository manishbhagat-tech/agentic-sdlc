# Product CI (agentic gates)

Wire product repos to [`harness/gates.yaml`](../harness/gates.yaml) — not only the kit harness.

## Install

```bash
./scripts/install-to-workspace.sh /path/to/code-repo
# copies scripts + optionally templates/github/agentic-gates.yml
cp agentic-sdlc/templates/github/agentic-gates.yml /path/to/code-repo/.github/workflows/
```

Set in code repo `AGENTS.md`:

```text
DOCS_ROOT: ../your-docs   # or docs/ if monorepo
AGENTIC_SDLC: ../agentic-sdlc
```

Repo variables (optional):

| Variable | Default | Meaning |
|----------|---------|---------|
| `DOCS_ROOT` | `docs` | Path to markdown stories in CI checkout |
| `AGENTIC_SECURITY_STRICT` | `0` | `1` = require gitleaks + fail npm audit high+ |
| `AGENTIC_REQUIRE_RUN_LOG` | `0` | `1` = require `.agentic/runs/<STORY>-*.json` |

## What `product-gates.sh` runs

Gates with `product_ci: true` in `harness/gates.yaml`:

1. **story frontmatter** — `skills:[]`, budget, repos, tests when ready/in_progress  
2. **pr_cite** — PR/commit cites `US-*` or `BUG-*`  
3. **security_check** — secret patterns + gitleaks + optional npm audit / semgrep  
4. **security_findings_bugs** — open Critical/High findings must set `bug_id: BUG-*`  
5. **run_log** — only if `AGENTIC_REQUIRE_RUN_LOG=1`  
6. **path-lock** — also run as a dedicated CI step  

Product **build/unit tests** and **Docker/K8s deploy** stay in your workflows. Kit seeds optional templates (`docker-build.yml`, `k8s-deploy-staging.yml`) — see [stacks/kubernetes.md](./stacks/kubernetes.md).

## Local

```bash
export DOCS_ROOT=../your-docs WORKSPACE_ROOT=.
export STORY_ID=US-ADMIN-001
export PR_TITLE="feat: US-ADMIN-001 login"
./scripts/agentic/product-gates.sh
```

## Kit vs product

| Check | Kit `harness-check.sh` | Product `product-gates.sh` |
|-------|------------------------|----------------------------|
| Wrapper coverage | yes | no |
| Golden packer | yes | no |
| PR story cite | no | yes |
| Story frontmatter | goldens only | your DOCS_ROOT |
| Security scanners | light | yes (+ gitleaks in template) |
| Findings → BUG | yes | yes |
