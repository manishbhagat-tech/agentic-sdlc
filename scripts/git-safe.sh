#!/usr/bin/env bash
# git-safe.sh — allowlist wrapper for agent git operations.
# Usage: git-safe.sh <verb> [args...]
set -euo pipefail

VERB="${1:-}"
if [[ -z "$VERB" ]]; then
  echo "usage: git-safe.sh <status|diff|log|branch|checkout|switch|add|commit|pull|fetch|push|stash|rev-parse|show|remote> [args…]" >&2
  exit 2
fi
shift || true

ALLOWED_VERBS=(
  status diff log branch checkout switch add commit pull fetch push stash
  rev-parse show remote blame version
)

ok=0
for v in "${ALLOWED_VERBS[@]}"; do
  if [[ "$VERB" == "$v" ]]; then ok=1; break; fi
done
if [[ $ok -ne 1 ]]; then
  echo "DENIED: git verb '$VERB' not in git-safe allowlist" >&2
  exit 1
fi

ARGS=("$@")
JOINED="$VERB ${ARGS[*]-}"

deny_if() {
  local pat="$1" msg="$2"
  if printf '%s' "$JOINED" | grep -Eiq "$pat"; then
    echo "DENIED: $msg" >&2
    exit 1
  fi
}

# Global denies (also mirrored in hooks/deny-dangerous-shell.sh)
deny_if 'push[[:space:]]+.*(--force|--force-with-lease)|push[[:space:]]+-f([[:space:]]|$)' \
  "force push not allowed via git-safe"
# Block push when a ref arg is exactly main/master (not feat/*-main-*)
if [[ "$VERB" == "push" ]]; then
  for a in "${ARGS[@]-}"; do
    case "$a" in
      main|master|HEAD:main|HEAD:master|refs/heads/main|refs/heads/master)
        echo "DENIED: push to main/master blocked — use PR" >&2
        exit 1
        ;;
    esac
  done
fi

deny_if 'reset[[:space:]]+--hard' "hard reset denied"
deny_if 'clean[[:space:]]+.*-fdx|clean[[:space:]]+.*-ffdx' "git clean -fdx denied"
deny_if 'filter-branch|filter-repo' "history rewrite denied"
deny_if 'push[[:space:]]+.*:main|:master' "delete/push to main/master ref denied"
deny_if 'branch[[:space:]]+-[dD][[:space:]]+(main|master)' "deleting main/master denied"

if [[ "$VERB" == "add" ]]; then
  for a in "${ARGS[@]-}"; do
    case "$a" in
      .env|.env.*|*.pem|id_rsa*|credentials.json|*.p12)
        echo "DENIED: refusing to add sensitive path: $a" >&2
        exit 1
        ;;
    esac
  done
fi

exec git "$VERB" "${ARGS[@]}"
