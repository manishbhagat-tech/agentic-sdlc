#!/usr/bin/env bash
# check-security-findings.sh — Critical/High open findings must have bug_id (BUG-*)
set -euo pipefail

ROOT="${WORKSPACE_ROOT:-$(pwd)}"
FIND_DIRS=(
  "$ROOT/.agentic/security/findings"
)
if [[ -n "${DOCS_ROOT:-}" ]]; then
  FIND_DIRS+=("${DOCS_ROOT}/.agentic/security/findings")
fi

KIT_ROOT="${KIT_ROOT:-}"
SCHEMA=""
if [[ -n "$KIT_ROOT" && -f "$KIT_ROOT/harness/findings.schema.json" ]]; then
  SCHEMA="$KIT_ROOT/harness/findings.schema.json"
fi

FAIL=0
FOUND=0

python3 - "$SCHEMA" "${FIND_DIRS[@]}" <<'PY'
import json, sys, pathlib, re

schema_path = sys.argv[1]
dirs = [pathlib.Path(p) for p in sys.argv[2:] if p]
fail = 0
found = 0

for d in dirs:
    if not d.is_dir():
        continue
    for f in sorted(d.glob("*.json")):
        found += 1
        try:
            data = json.loads(f.read_text(encoding="utf-8"))
        except Exception as e:
            print(f"FAIL {f}: invalid JSON ({e})")
            fail = 1
            continue
        for req in ("id", "class", "severity", "summary", "status"):
            if req not in data:
                print(f"FAIL {f.name}: missing {req}")
                fail = 1
        sev = (data.get("severity") or "").lower()
        status = (data.get("status") or "").lower()
        if status == "open" and sev in ("critical", "high"):
            bug = data.get("bug_id") or ""
            if not re.match(r"^BUG-", str(bug)):
                print(f"FAIL {f.name}: open {sev} finding requires bug_id (BUG-*)")
                fail = 1
            else:
                print(f"OK {f.name}: {sev} → {bug}")
        else:
            print(f"OK {f.name}: {data.get('id')} {sev}/{status}")

if found == 0:
    print("OK security_findings: no findings JSON (nothing to enforce)")
sys.exit(fail)
PY
