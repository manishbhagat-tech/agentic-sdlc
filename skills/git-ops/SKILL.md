---
name: git-ops
description: >-
  Allowlist-only git via scripts/git-safe.sh. Composes addy/git-workflow filtered
  by deny list. No force-push to shared defaults, no destructive history rewrite.
---

# git-ops

## Essentials first

Apply [`docs/WRAPPER-ESSENTIALS.md`](../../docs/WRAPPER-ESSENTIALS.md) — especially **Git-safe**.
Prefer [`scripts/git-safe.sh`](../../scripts/git-safe.sh) for all agent git mutations.

## Skills filter

1. Read `orchestrators.git-ops.skills` from [`docs/WRAPPER-MAP.yaml`](../../docs/WRAPPER-MAP.yaml).
2. Intersect with story `skills:[]` when present (phase `git`).
3. Compose `addy/git-workflow-and-versioning` **after** deny-filter: skip any upstream step that suggests force-push, hard reset, `clean -fdx`, filter-branch, repo delete, or auto-prod deploy. Log overrides.

## Allowlist (via git-safe)

Typical allowed verbs: `status`, `diff`, `log`, `branch`, `checkout`/`switch` (story branches), `add` (non-secret paths), `commit`, `pull`/`fetch`, `push` (non-force, non-main/master force), `stash` (non-drop of others' work).

Denied (also enforced by hooks): force push to main/master, `reset --hard`, `clean -fdx`, `filter-branch`, `gh repo delete`, history rewrite of shared defaults.

## Steps

1. Confirm story/bug branch naming (`feat/US-*`, `fix/BUG-*`) when committing.
2. Run mutations only through `scripts/git-safe.sh <verb> …`.
3. Compose filtered git-workflow wrapper when listed.
4. PR must cite `US-*` / `BUG-*`. Humans merge elevated / production.
5. Write `.agentic/runs/<id>-git-ops.json` with `skills_declared` / `skills_invoked`.
6. Emit:

```
HANDOFF: git-ops → human-merge|done | outcome=<pass|fail> | branch=<name> | notes=…
```

## Refuse

- Force-push / hard-reset / clean -fdx / repo delete
- Committing `.env`, keys, or credentials
- Bypassing git-safe for “convenience”
