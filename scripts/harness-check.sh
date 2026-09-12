#!/usr/bin/env bash
# harness-check.sh — static gates, no LLM
set -euo pipefail
KIT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ROOT="${WORKSPACE_ROOT:-$KIT_ROOT}"
FAIL=0

echo "== schema: run-log =="
python3 - <<'PY'
import json, pathlib, sys
p = pathlib.Path(sys.argv[1]) if False else None
PY
python3 -c "
import json, pathlib
schema = json.loads(pathlib.Path('$KIT_ROOT/harness/run-log.schema.json').read_text())
assert 'properties' in schema
print('run-log.schema.json OK')
"

echo "== gates.yaml present =="
test -f "$KIT_ROOT/harness/gates.yaml"

echo "== golden stories frontmatter =="
python3 <<PY
import re, pathlib, sys
kit = pathlib.Path("$KIT_ROOT")
required = ["id", "status", "security", "budget"]
fail = 0
for f in (kit / "harness" / "golden").glob("*.md"):
    text = f.read_text(encoding="utf-8")
    if not text.startswith("---"):
        print(f"FAIL {f.name}: no frontmatter"); fail = 1; continue
    fm = text.split("---", 2)[1]
    for k in required:
        if f"{k}:" not in fm:
            print(f"FAIL {f.name}: missing {k}"); fail = 1
    print(f"OK {f.name}")
sys.exit(fail)
PY

echo "== packer dry-run on golden (fixture docs) =="
FIX="$KIT_ROOT/harness/fixtures"
export DOCS_ROOT="$FIX/docs"
export WORKSPACE_ROOT="$FIX/mini-repo"
mkdir -p "$WORKSPACE_ROOT/.agentic"
# init git if needed for diff
if [[ ! -d "$WORKSPACE_ROOT/.git" ]]; then
  (cd "$WORKSPACE_ROOT" && git init -q && git add -A && git -c user.email=t@t -c user.name=t commit -qm init || true)
fi
if [[ -f "$FIX/docs/delivery/stories/US-GOLDEN-AUTH.md" ]]; then
  "$KIT_ROOT/scripts/pack-story-context.sh" US-GOLDEN-AUTH || FAIL=1
fi

echo "== path-lock-check =="
"$KIT_ROOT/scripts/path-lock-check.sh" "$FIX/docs" || true

if [[ $FAIL -ne 0 ]]; then
  echo "HARNESS FAIL"
  exit 1
fi
echo "HARNESS OK (harness-check passed)"
