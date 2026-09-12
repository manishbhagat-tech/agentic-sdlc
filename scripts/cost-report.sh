#!/usr/bin/env bash
# cost-report.sh [runs_dir]
set -euo pipefail
RUNS="${1:-.agentic/runs}"
OUT="${2:-.agentic/cost-report.md}"
mkdir -p "$(dirname "$OUT")"
python3 - "$RUNS" "$OUT" <<'PY'
import json, sys, pathlib
runs = pathlib.Path(sys.argv[1])
out = pathlib.Path(sys.argv[2])
rows = []
if runs.is_dir():
    for f in sorted(runs.glob("*.json")):
        try:
            d = json.loads(f.read_text())
            rows.append(d)
        except Exception:
            pass
lines = ["# Agent cost ledger", "", "| Story | Skill | Est. tokens | Files edited | Outcome |", "|-------|-------|-------------|--------------|---------|"]
total = 0
for d in rows:
    t = int(d.get("pack_tokens_est") or 0)
    total += t
    lines.append(f"| {d.get('story_id','')} | {d.get('skill','')} | {t} | {d.get('files_edited','')} | {d.get('outcome','')} |")
lines += ["", f"**Total est. pack tokens (logged):** {total}", ""]
out.write_text("\n".join(lines), encoding="utf-8")
print(f"Wrote {out} ({len(rows)} runs)")
PY
