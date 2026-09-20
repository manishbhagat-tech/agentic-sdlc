#!/usr/bin/env bash
# check-run-logs.sh — optional: require run log for STORY_ID
set -euo pipefail

ROOT="${WORKSPACE_ROOT:-$(pwd)}"
if [[ "${AGENTIC_REQUIRE_RUN_LOG:-0}" != "1" ]]; then
  echo "OK run_log skipped (set AGENTIC_REQUIRE_RUN_LOG=1 to enforce)"
  exit 0
fi

STORY_ID="${STORY_ID:-}"
if [[ -z "$STORY_ID" ]]; then
  echo "FAIL run_log: STORY_ID required when AGENTIC_REQUIRE_RUN_LOG=1"
  exit 1
fi

RUNS="$ROOT/.agentic/runs"
if [[ ! -d "$RUNS" ]]; then
  echo "FAIL run_log: missing $RUNS"
  exit 1
fi

if compgen -G "$RUNS/${STORY_ID}-*.json" > /dev/null; then
  echo "OK run_log: found logs for $STORY_ID"
  exit 0
fi

echo "FAIL run_log: no $RUNS/${STORY_ID}-*.json"
exit 1
