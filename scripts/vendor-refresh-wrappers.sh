#!/usr/bin/env bash
# Post-vendor-bump refresh: regenerate skill + agent thin wrappers and verify coverage.
#
# Usage:
#   ./scripts/vendor-refresh-wrappers.sh
#   ./scripts/vendor-refresh-wrappers.sh addy-agent-skills
#
# Call this AFTER updating vendor/<name>/ tree + VERSION.json (see docs/OSS-ENRICHMENT.md).
# It does not fetch upstream itself — use vendor-sync-check.sh to detect drift, then
# copy/clone the new tree, then run this script.
set -euo pipefail

KIT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$KIT_ROOT"

FOCUS="${1:-}"

echo "== vendor-refresh-wrappers =="
if [[ -n "$FOCUS" ]]; then
  echo "focus: $FOCUS (wrappers still regenerated for all vendors)"
fi

echo "== regenerate thin wrappers (skills + addy agents/) =="
python3 "$KIT_ROOT/scripts/generate-thin-wrappers.py"

echo "== coverage check =="
"$KIT_ROOT/scripts/check-wrapper-coverage.sh"

if [[ -z "$FOCUS" || "$FOCUS" == "addy-agent-skills" || "$FOCUS" == "addy" ]]; then
  echo ""
  echo "== Addy agents roster (vendor vs wrappers) =="
  AGENTS_DIR="$KIT_ROOT/vendor/addy-agent-skills/agents"
  if [[ -d "$AGENTS_DIR" ]]; then
    echo "vendor agents:"
    ls -1 "$AGENTS_DIR"/*.md 2>/dev/null | xargs -n1 basename || true
    echo "wrappers:"
    ls -1d "$KIT_ROOT/skills/addy-agents"/*/ 2>/dev/null | xargs -n1 basename || true
  fi
  echo ""
  echo "If a NEW agent appeared: add it under the right orchestrator personas: in"
  echo "  docs/WRAPPER-MAP.yaml  (+ coverage_index) and roles/*/SKILLS.md as needed."
  echo "If an agent was REMOVED: drop orphan skills/addy-agents/<name>/ and map entries."
fi

echo ""
echo "Next: ./scripts/harness-check.sh && update CHANGELOG / OSS-ENRICHMENT pins."
echo "DONE vendor-refresh-wrappers"
