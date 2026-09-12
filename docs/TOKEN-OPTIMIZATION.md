# Token optimization (first-party)

Practices inspired by symbol/AST retrieval tools (e.g. jCodeMunch-style “fetch symbols, not whole files”) and agent harnesses — implemented **inside this kit** without requiring third-party MCP by default.

## Hierarchy of savings

1. **Story allowlists** — only paths in `repos[].allow`
2. **must_read** — parent PRD/HLD only, line-capped
3. **Context packer** — outlines before bodies; budget fail-closed
4. **Skill discipline** — outline → slice → patch; review = diff-only
5. **Optional MCP** — pin+review before enable ([MCP-ALLOWLIST.md](./MCP-ALLOWLIST.md))

## Packer rules

| Artifact | Cap |
|----------|-----|
| Parent docs | `budget.max_file_lines` |
| Code outlines | signature-like lines only; `max_files_read` |
| DIFF.md | truncated; limited contribution to token estimate |
| Total pack | must be ≤ `max_context_tokens` or abort |

## Agent habits (enforce in skills)

- Never open pricing PDFs, sibling epics, or `node_modules` / `target`
- Prefer `CODE_OUTLINES/` from the pack over full-file reads
- On test failure: stack + one file slice, not the module
- Amend story budgets deliberately — do not “just raise and dump”

## Measuring burn

```bash
./scripts/cost-report.sh /path/to/code-repo/.agentic/runs
```

Run logs should include `pack_tokens_est`, `files_read`, `files_edited`.

## Optional next step (MCP)

If packs are still too large after tight allows:

1. Add a **pinned** local AST/symbol MCP to [MCP-ALLOWLIST.md](./MCP-ALLOWLIST.md)
2. Teach `story-implement` to prefer MCP symbol fetch over Read of whole files
3. Keep `trusted_folders` absolute and scoped to the product tree
