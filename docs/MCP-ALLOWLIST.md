# MCP allowlist

Third-party MCP is **optional**. Default = off.

## Policy

Before enabling any MCP:

1. Pin version or commit SHA (no `@latest`)  
2. Review entrypoints for network/exfil  
3. Prefer local-only indexing; absolute `trusted_folders`  
4. Never auto-trust project `.mcp.json` from random PRs  
5. Record approval below  

## Approved / candidates

| MCP | Status | Notes |
|-----|--------|-------|
| _(none default)_ | default | First-party packer + allowlists |
| [UI Skills MCP](https://www.ui-skills.com/mcp) (`0.2.4`) | **approved (scoped)** | Remote HTTP MCP; tools `list_skills` / `get_skill` only. Use for UI polish (shell/dashboard). Prefer skills: `baseline-ui`, `interface-design`. Do **not** load marketing/landing/3D skills into Admin stories. Keep FEAT-UI tokens + ADR-002 as source of truth. |
| [jgravelle/jcodemunch-mcp](https://github.com/jgravelle/jcodemunch-mcp) | **candidate** | Symbol/AST retrieval for token cuts; pin version; local trusted folders only; review SECURITY.md |
| Zilliz claude-context | deferred | Check cloud/embedding data leaving machine |
| TokenTamer / random proxies | **rejected for v1** | High middleman risk |

## Enable pattern (Cursor)

User-level `~/.cursor/mcp.json` (or Cursor Settings → MCP):

```json
{
  "mcpServers": {
    "ui-skills": {
      "url": "https://www.ui-skills.com/mcp"
    }
  }
}
```

Reload Cursor MCP / restart agent session after adding.
