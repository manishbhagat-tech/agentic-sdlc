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
| _(none)_ | default | First-party packer + allowlists |
| [jgravelle/jcodemunch-mcp](https://github.com/jgravelle/jcodemunch-mcp) | **candidate** | Symbol/AST retrieval for token cuts; pin version; local trusted folders only; review SECURITY.md |
| Zilliz claude-context | deferred | Check cloud/embedding data leaving machine |
| TokenTamer / random proxies | **rejected for v1** | High middleman risk |

## Enable pattern (Cursor)

Document in product `AGENTS.md` only after allowlist row is `approved`:

```jsonc
// example — do not enable until pinned + reviewed
{
  "mcpServers": {
    "jcodemunch": {
      "command": "uvx",
      "args": ["jcodemunch-mcp@PINNED_VERSION"]
    }
  }
}
```

Then update `story-implement` skill: prefer symbol tools over full-file reads.
