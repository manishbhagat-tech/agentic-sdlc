# Harness

Local gates and measurement — no third-party SaaS required.

- `budgets.defaults.yaml` — global caps
- `gates.yaml` — must-pass checks
- `run-log.schema.json` — agent run log shape
- `golden/` — kit self-test stories
- `fixtures/` — tiny docs + repo for packer CI

```bash
../scripts/harness-check.sh
```
