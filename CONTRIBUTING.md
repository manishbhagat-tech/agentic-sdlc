# Contributing

## Develop the kit

1. Edit skills/scripts under this repo  
2. Run `./scripts/harness-check.sh`  
3. Bump notes in `CHANGELOG.md`  
4. Open a PR; title may omit US-* (this repo is the kit itself)

## Sync into product repos

```bash
./scripts/install-to-workspace.sh /path/to/civil-erp-api
# or symlink mode (local machines):
./scripts/install-to-workspace.sh /path/to/civil-erp-api --symlink
```

## Security

Do not commit secrets. Do not add MCP servers without updating `docs/MCP-ALLOWLIST.md`.
