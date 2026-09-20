# Wrapper essentials (always first)

Apply these rules **before** any vendored skill body. On conflict with upstream steps, **essentials win** — skip the conflicting step, log an override in the run log, continue.

Bots enter only via `skills/` wrappers and orchestrators. Never open raw `vendor/` except:

- the single `SKILL.md` path named by the active thin skill wrapper, or
- the single `agents/*.md` (or named `references/*.md`) path named by an active `skills/addy-agents/*` persona wrapper.

Addy **personas** (`vendor/.../agents/`) are *who* + output format; **skills** are *how*. Orchestrators load `WRAPPER-MAP` `personas:` always for that phase (token-small), then intersect `skills:` with story `skills:[]`.

## Pack

1. Run `scripts/pack-story-context.sh <US-*|BUG-*>` (or the feature pack equivalent) before implement / fix / test / review / cleanup.
2. Abort if the pack exceeds story `budget.max_context_tokens` (fail-closed).
3. Prefer pack `CODE_OUTLINES/`, capped parents, and `DIFF.md` over full-tree reads.
4. Stay inside `repos[].allow`; path-lock violations are refusals.

## Channels

1. Default channels = `api`, `web`, `mobile` unless the story narrows `channels:`.
2. Skip UI / browser / RN vendor skills when the relevant channel is absent.
3. Implement order remains **API → Web → Mobile** within allowlists.
4. Do not invent work for a channel the story excluded.

## Ledger

1. Security work updates `.agentic/security/` ledger / findings (product layout) when present.
2. `security: elevated` requires human merge approval — no auto-merge.
3. Scanner / vuln notes belong in the run log and review handoff; do not drop them because upstream omitted them.
4. Secrets never enter git, packs, or run logs.

## Git-safe

Deny (even if upstream suggests them):

- `git push --force` / `--force-with-lease` to shared defaults
- Hard reset of published history, `git clean -fdx` without explicit human ask
- Deleting the repo, rewriting `main`/`master` history, or auto-prod deploy
- Committing `.env`, credentials, or private keys

Prefer story branches (`feat/US-*`, `fix/BUG-*`), one story per PR, PR cites the id. Humans merge elevated / production.

## Token-min

1. Progressive disclosure: load phase `personas:` (always) + wrappers intersecting story `skills:` (see [WRAPPER-MAP.yaml](./WRAPPER-MAP.yaml)).
2. Never dump the whole vendor tree, all agents, or all ~N skills into one turn. One persona file + mapped skills only.
3. Review = diff-only; implement = outline → slice → patch; test failure = stack + one file.
4. Record `pack_tokens_est`, `files_read`, `files_edited`, `skills_declared`, `skills_invoked` in `.agentic/runs/`.
5. See [TOKEN-OPTIMIZATION.md](./TOKEN-OPTIMIZATION.md).

## Story `skills:[]`

1. **Design-time SoT** — `feature-stories` / product writes the list on the US-* frontmatter.
2. Runtime loads **exactly** that list (plus always-on essentials), filtered by orchestrator **phase** in WRAPPER-MAP.
3. Every entry must resolve to an existing thin wrapper under `skills/<ns>/<name>/`.
4. Stack skills (`sivalabs/*`, `vercel/*`, `next/*`, `ui-skills/*`) only when channels + product `stacks:` justify them (e.g. no `react-native` without `mobile`).
5. Legacy stories missing `skills:` may infer from channels/allow with a **warn** to backfill; new stories require an explicit list.
6. Do not warm-load unused stack packs “for convenience.”

## Conflict + handoff

| Upstream asks | We do |
|---------------|--------|
| Read whole codebase | Pack + allowlist only |
| Force-push / auto-deploy | Skip; log override |
| Ignore authz / secrets | Keep secure-codegen + ledger |
| Load unrelated vendor trees | Refuse |

On completion, return pass/fail to the calling orchestrator with HANDOFF notes (what changed, tests, security, next skill).
