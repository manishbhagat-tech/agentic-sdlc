# Standard practices (agentic SDLC)

Baseline engineering practices this kit expects products to follow.

## Delivery

| Practice | Kit support |
|----------|-------------|
| Story-only changes | skills + rules + hooks |
| **Full slice (api+web+mobile)** | story contract / `channels` |
| Tests + security + vuln gate | story-test + story-review |
| Branch per story | `feat/US-*`, `fix/BUG-*` |
| One story per PR | PROTOCOL + CI cite gate |
| AC + DoD on every story | templates + `story-ready` |
| Definition of Ready | `story-ready` skill |
| Security elevated path | frontmatter + human merge |
| Lean / no junk | review + `story-cleanup` |
| Late bugs linked to stories | `BUG-*` template |
| Path conflict avoidance | `path-lock-check.sh` |
| Cost visibility | run logs + `cost-report.sh` |

## Code quality

- Prefer small diffs mapped to AC
- No secrets in git; env for credentials
- Tests declared on the story and run via `story-test`
- Authz and validation on mutating APIs

## Repo hygiene

- Keep product repos thin (`AGENTS.md` + install kit)
- Docs in a dedicated docs repo when multi-repo
- Board tools are mirrors; markdown is SoT
- Re-run `install-to-workspace.sh` after kit upgrades (or use `--symlink`)

## CI minimum

1. Story/BUG id on PRs  
2. Docs frontmatter validation  
3. Path-lock on docs  
4. Build + unit tests on code repos  
5. Kit `harness-check.sh` on this repo  

## What we deliberately skip (v1)

- Auto-merge  
- Auto-deploy agents  
- Blind third-party MCP  
- Replacing human UAT for domain/finance
