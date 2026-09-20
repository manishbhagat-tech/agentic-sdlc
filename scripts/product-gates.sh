#!/usr/bin/env bash
# product-gates.sh — run product_ci gates from harness/gates.yaml
#
# Env:
#   DOCS_ROOT          docs repo (required for story/path gates)
#   STORY_ID           optional US-*|BUG-* to validate one story
#   PR_TITLE / PR_BODY optional (or GITHUB_EVENT_PATH in Actions)
#   AGENTIC_REQUIRE_RUN_LOG=1  fail if no .agentic/runs for STORY_ID
#   AGENTIC_SECURITY_STRICT=1  fail if gitleaks/npm audit unavailable when lockfiles present
#   WORKSPACE_ROOT     code repo root (default: pwd)
#   KIT_ROOT           kit root (default: sibling of scripts or .agentic/KIT_ROOT)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [[ -f "${WORKSPACE_ROOT:-}/.agentic/KIT_ROOT" ]]; then
  KIT_ROOT="$(cat "${WORKSPACE_ROOT:-$(pwd)}/.agentic/KIT_ROOT")"
elif [[ -f "$SCRIPT_DIR/../harness/gates.yaml" ]]; then
  KIT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
else
  KIT_ROOT="${KIT_ROOT:-}"
fi
WORKSPACE_ROOT="${WORKSPACE_ROOT:-$(pwd)}"
GATES="${KIT_ROOT}/harness/gates.yaml"

if [[ -z "${KIT_ROOT}" || ! -f "$GATES" ]]; then
  echo "ERROR: cannot find kit harness/gates.yaml (set KIT_ROOT)" >&2
  exit 2
fi

export KIT_ROOT WORKSPACE_ROOT
export DOCS_ROOT="${DOCS_ROOT:-}"
FAIL=0

echo "== product-gates (kit=$KIT_ROOT workspace=$WORKSPACE_ROOT) =="

run_gate() {
  local id="$1"
  local script="$2"
  local path="$SCRIPT_DIR/$script"
  if [[ ! -f "$path" && -f "$KIT_ROOT/scripts/$script" ]]; then
    path="$KIT_ROOT/scripts/$script"
  fi
  if [[ ! -f "$path" ]]; then
    echo "FAIL gate $id: missing script $script"
    FAIL=1
    return
  fi
  echo "---- gate: $id ($script) ----"
  if ! bash "$path"; then
    echo "FAIL gate $id"
    FAIL=1
  else
    echo "OK gate $id"
  fi
}

# Parse product_ci gates with a script field
while IFS=$'\t' read -r id script; do
  [[ -z "$id" || -z "$script" ]] && continue
  # Deduplicate scripts that serve multiple gate ids when appropriate
  case "$id" in
    story_ready|design_parents|tests)
      # validate-story-frontmatter runs once
      ;;
  esac
  run_gate "$id" "$script"
done < <(python3 - "$GATES" <<'PY'
import re, sys, pathlib
text = pathlib.Path(sys.argv[1]).read_text(encoding="utf-8")
# Split on "- id:" blocks
blocks = re.split(r"\n\s*-\s*id:\s*", text)
seen_scripts = set()
for b in blocks[1:]:
    id_m = re.match(r"(\w+)", b)
    if not id_m:
        continue
    gid = id_m.group(1)
    if not re.search(r"product_ci:\s*true", b):
        continue
    sm = re.search(r"script:\s*(\S+)", b)
    if not sm:
        continue
    script = sm.group(1)
    # Run validate-story-frontmatter only once even if multiple gates share it
    if script == "validate-story-frontmatter.sh":
        if script in seen_scripts:
            continue
        seen_scripts.add(script)
        print(f"story_frontmatter_bundle\t{script}")
        continue
    print(f"{gid}\t{script}")
PY
)

if [[ $FAIL -ne 0 ]]; then
  echo "PRODUCT-GATES FAIL"
  exit 1
fi
echo "PRODUCT-GATES OK"
exit 0
