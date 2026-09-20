# Board — GitHub Projects dashboard

**Yes — track stories and bugs on a GitHub Project.**  
Markdown under `DOCS_ROOT` remains the **source of truth**. Issues + Projects are the **mirror / dashboard**.

## Why

| Need | Board |
|------|--------|
| See all `US-*` / `BUG-*` by status | Project board columns |
| Elevated security work | Label `security:elevated` + filter view |
| Bugs from Critical/High findings | `BUG-*` issues linked via `bug_id` / `external_id` |
| Sprint planning without rewriting stories | Drag cards; do **not** enable `status_from_board` until options match |

## Setup

1. Create a GitHub **Project (v2)** under your org/user.  
2. Create Status options matching `board/github-projects.yaml` `status_map`.  
3. On the issues repo, create labels: `story`, `bug`, `security:elevated`.  
4. Copy config into the docs repo (or set `BOARD_CONFIG`):

```bash
cp board/github-projects.yaml /path/to/docs/.agentic/board.yaml
# edit: enabled: true, repo, project_owner, project_number
```

5. Sync:

```bash
export DOCS_ROOT=/path/to/docs
export BOARD_CONFIG=$DOCS_ROOT/.agentic/board.yaml
./scripts/board-sync.sh
```

`board-sync.sh` = `board-push.sh` (create issues + write `external_id`) + add items to the Project.

## Recommended Project views

1. **Stories** — filter `label:story`  
2. **Bugs** — filter `label:bug`  
3. **Elevated** — filter `label:security:elevated`  
4. **Board** — group by Status  

## Ledger → bug → board

When `story-security` opens a **Critical/High** finding:

1. Write `.agentic/security/findings/SEC-….json` with `bug_id: BUG-…`  
2. Author `BUG-*` markdown (template) linked to the finding / story  
3. `board-sync.sh` so the bug appears on the Project  

CI gate `security_findings_bugs` fails if open Critical/High lacks `bug_id`.

## Rules

- Do **not** treat the board as SoT while `status_from_board: false` (default).  
- Agents update markdown status; humans (or a later automation) mirror Project Status.  
- `board-pull.sh` only closes → `done` when `status_from_board: true` (coarse v1).  
