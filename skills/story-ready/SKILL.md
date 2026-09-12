---
name: story-ready
description: >-
  Definition-of-Ready gate: validate story/BUG frontmatter then set status ready.
  Use before any implement or fix.
---

# story-ready

## Required fields

- `id` matching `US-*` or `BUG-*`
- `status` → will set to `ready`
- `security` (`standard`|`elevated`)
- `budget.max_context_tokens`, `max_files_read`, `max_file_lines`
- `must_read` (non-empty for US; BUG may inherit linked story)
- `repos[].allow` non-empty
- `tests[].cmd` non-empty
- BUG: `story`, `repro`

## Steps

1. Locate file under `$DOCS_ROOT` by id.
2. Validate fields; refuse if missing.
3. Optionally run `pack-story-context.sh` dry-run; fail if over budget.
4. Set `status: ready`.
5. Do not edit application code.
