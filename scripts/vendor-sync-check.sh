#!/usr/bin/env bash
# Compare vendor/*/VERSION.json commit_sha to upstream remote (or print how to diff).
# Usage: vendor-sync-check.sh [vendor-dir-name ...]
#   with no args, checks every vendor/*/VERSION.json
set -euo pipefail

KIT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VENDOR_ROOT="$KIT_ROOT/vendor"

usage() {
  echo "usage: vendor-sync-check.sh [addy-agent-skills|sivalabs-agent-skills|...]" >&2
  exit 2
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
fi

names=("$@")
if [[ ${#names[@]} -eq 0 ]]; then
  while IFS= read -r -d '' vj; do
    names+=("$(basename "$(dirname "$vj")")")
  done < <(find "$VENDOR_ROOT" -mindepth 2 -maxdepth 2 -name VERSION.json -print0 | sort -z)
fi

if [[ ${#names[@]} -eq 0 ]]; then
  echo "No vendor/*/VERSION.json found under $VENDOR_ROOT" >&2
  exit 1
fi

TMPDIR="${TMPDIR:-/tmp}"
WORKDIR="$(mktemp -d "$TMPDIR/vendor-sync-XXXXXX")"
cleanup() { rm -rf "$WORKDIR"; }
trap cleanup EXIT

check_one() {
  local name="$1"
  local dir="$VENDOR_ROOT/$name"
  local ver="$dir/VERSION.json"

  echo ""
  echo "======== $name ========"

  if [[ ! -f "$ver" ]]; then
    echo "ERROR: missing $ver"
    return 1
  fi

  local repo url pinned tag
  repo="$(python3 -c "import json,sys; d=json.load(open(sys.argv[1])); print(d.get('repo',''))" "$ver")"
  url="$(python3 -c "import json,sys; d=json.load(open(sys.argv[1])); print(d.get('url',''))" "$ver")"
  pinned="$(python3 -c "import json,sys; d=json.load(open(sys.argv[1])); print(d.get('commit_sha',''))" "$ver")"
  tag="$(python3 -c "import json,sys; d=json.load(open(sys.argv[1])); print(d.get('tag') or '')" "$ver")"

  echo "repo:        $repo"
  echo "url:         $url"
  echo "pinned_sha:  $pinned"
  [[ -n "$tag" ]] && echo "tag:         $tag"

  # Non-git / manual pins (e.g. ui-skills MCP export)
  if [[ ! "$pinned" =~ ^[0-9a-f]{7,40}$ ]]; then
    echo "status:      manual pin (not a git SHA)"
    echo "how to diff: refresh vendor files intentionally, then update VERSION.json + docs/OSS-ENRICHMENT.md"
    echo "             compare locally: diff -ru <old-export> \"$dir\""
    return 0
  fi

  # Derive clone URL (strip /tree/... paths from GitHub blob URLs)
  local clone_url="$url"
  if [[ "$clone_url" =~ ^https://github.com/([^/]+)/([^/]+) ]]; then
    clone_url="https://github.com/${BASH_REMATCH[1]}/${BASH_REMATCH[2]%.git}.git"
  elif [[ "$clone_url" != *.git && "$clone_url" == https://github.com/* ]]; then
    clone_url="${clone_url}.git"
  fi

  if ! command -v git >/dev/null 2>&1; then
    echo "status:      git not available"
    echo "how to diff:"
    echo "  git ls-remote \"$clone_url\" HEAD"
    echo "  # then: git diff ${pinned}..<remote-sha> -- skills agents references"
    return 0
  fi

  # Prefer network compare; fall back to printable instructions
  local remote_sha=""
  local ref="HEAD"
  [[ -n "$tag" && "$tag" != "null" ]] && ref="refs/tags/$tag"

  if remote_sha="$(git ls-remote "$clone_url" "$ref" 2>/dev/null | awk '{print $1; exit}')"; then
    :
  fi
  if [[ -z "$remote_sha" ]]; then
    remote_sha="$(git ls-remote "$clone_url" HEAD 2>/dev/null | awk '{print $1; exit}' || true)"
  fi

  if [[ -z "$remote_sha" ]]; then
    echo "status:      could not reach remote (offline or auth)"
    echo "how to diff:"
    echo "  git ls-remote \"$clone_url\" HEAD"
    echo "  git fetch \"$clone_url\" \"$pinned\" && git fetch \"$clone_url\" HEAD"
    echo "  git diff ${pinned}..<upstream-sha> -- ."
    echo "  # Or shallow clone:"
    echo "  git clone --filter=blob:none --sparse \"$clone_url\" /tmp/${name}-upstream"
    return 0
  fi

  echo "remote_sha:  $remote_sha"

  # Exact or prefix match (short vs full SHA)
  if [[ "$pinned" == "$remote_sha" || "$remote_sha" == "$pinned"* || "$pinned" == "$remote_sha"* ]]; then
    echo "status:      UP TO DATE (pinned matches remote $ref)"
    return 0
  fi

  echo "status:      BEHIND or DIVERGED (pinned ≠ remote)"
  echo "how to bump:"
  echo "  1. Refresh vendor/$name to $remote_sha (skills/ + agents/ + references/ for Addy)"
  echo "  2. Update vendor/$name/VERSION.json (commit_sha, date, notes)"
  echo "  3. Run: ./scripts/vendor-refresh-wrappers.sh $name"
  echo "     (regenerates skills/* and skills/addy-agents/* thin wrappers)"
  echo "  4. Wire any NEW agents into docs/WRAPPER-MAP.yaml personas: / coverage_index"
  echo "  5. ./scripts/harness-check.sh && CHANGELOG"
  echo "how to diff:"
  echo "  git clone --filter=blob:none \"$clone_url\" \"$WORKDIR/$name\""
  echo "  git -C \"$WORKDIR/$name\" diff ${pinned}..${remote_sha} --stat -- skills agents references"
  # Best-effort live diffstat when network works
  if git clone --quiet --filter=blob:none --single-branch "$clone_url" "$WORKDIR/$name" 2>/dev/null; then
    git -C "$WORKDIR/$name" fetch --quiet origin "$pinned" 2>/dev/null || true
    if git -C "$WORKDIR/$name" cat-file -e "${pinned}^{commit}" 2>/dev/null; then
      echo "--- diffstat (pinned..remote) ---"
      git -C "$WORKDIR/$name" diff "${pinned}..${remote_sha}" --stat || true
    else
      echo "(pinned commit not fetchable in shallow clone; use full fetch for diffstat)"
    fi
  fi
  return 0
}

rc=0
for n in "${names[@]}"; do
  check_one "$n" || rc=1
done
exit "$rc"
