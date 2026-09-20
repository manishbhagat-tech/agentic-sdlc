#!/usr/bin/env bash
# check-pr-story-id.sh — PR title/body or commit message must cite US-* or BUG-*
set -euo pipefail

TITLE="${PR_TITLE:-}"
BODY="${PR_BODY:-}"

# GitHub Actions
if [[ -n "${GITHUB_EVENT_PATH:-}" && -f "${GITHUB_EVENT_PATH}" ]]; then
  eval "$(python3 - "$GITHUB_EVENT_PATH" <<'PY'
import json, sys, shlex
ev = json.load(open(sys.argv[1]))
pr = ev.get("pull_request") or {}
title = pr.get("title") or ""
body = pr.get("body") or ""
print(f"TITLE={shlex.quote(title)}")
print(f"BODY={shlex.quote(body)}")
PY
)"
fi

# Fallback: last commit subject
if [[ -z "$TITLE" ]]; then
  TITLE="$(git log -1 --pretty=%s 2>/dev/null || true)"
fi
if [[ -z "$BODY" ]]; then
  BODY="$(git log -1 --pretty=%b 2>/dev/null || true)"
fi

TEXT="${TITLE}"$'\n'"${BODY}"
# Allow kit-only PRs when AGENTIC_ALLOW_NO_STORY=1
if [[ "${AGENTIC_ALLOW_NO_STORY:-}" == "1" ]]; then
  echo "OK pr_cite skipped (AGENTIC_ALLOW_NO_STORY=1)"
  exit 0
fi

if echo "$TEXT" | grep -Eiq '(US|BUG)-[A-Z0-9][A-Z0-9_-]*'; then
  echo "OK pr_cite: story/bug id found in PR/commit text"
  exit 0
fi

echo "FAIL pr_cite: PR title/body (or commit) must cite US-* or BUG-*"
echo "  title: $TITLE"
exit 1
