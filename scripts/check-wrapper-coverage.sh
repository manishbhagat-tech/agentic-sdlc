#!/usr/bin/env bash
# Fails if any vendored skill or Addy agent lacks a thin wrapper under skills/.
set -euo pipefail

KIT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FAIL=0
MISSING=()
FOUND=0
AGENTS_FOUND=0

# ns|vendor_rel|nested (1 = under .../skills/, 0 = vendor dir itself)
VENDORS=(
  "addy|vendor/addy-agent-skills/skills|1"
  "sivalabs|vendor/sivalabs-agent-skills/skills|1"
  "vercel|vendor/vercel-agent-skills/skills|1"
  "next|vendor/nextjs-skills/skills|1"
  "ui-skills|vendor/ui-skills|0"
  "ecc|vendor/ecc-market-research|0"
  "pm|vendor/pm-competitor-analysis|0"
)

echo "== thin wrapper coverage (skills) =="

for entry in "${VENDORS[@]}"; do
  IFS='|' read -r ns rel _nested <<<"$entry"
  base="$KIT_ROOT/$rel"
  if [[ ! -d "$base" ]]; then
    echo "WARN: missing vendor path $rel (skip)"
    continue
  fi
  while IFS= read -r -d '' skill; do
    name="$(basename "$(dirname "$skill")")"
    wrapper="$KIT_ROOT/skills/$ns/$name/SKILL.md"
    FOUND=$((FOUND + 1))
    if [[ ! -f "$wrapper" ]]; then
      echo "MISSING: $ns/$name  (vendor: ${skill#$KIT_ROOT/})"
      MISSING+=("$ns/$name")
      FAIL=1
    else
      echo "OK $ns/$name"
    fi
  done < <(find "$base" -mindepth 2 -maxdepth 2 -type f -name SKILL.md -print0 | sort -z)
done

echo "== thin wrapper coverage (addy agents/) =="
AGENTS_DIR="$KIT_ROOT/vendor/addy-agent-skills/agents"
if [[ -d "$AGENTS_DIR" ]]; then
  while IFS= read -r -d '' agent; do
    name="$(basename "$agent" .md)"
    wrapper="$KIT_ROOT/skills/addy-agents/$name/SKILL.md"
    AGENTS_FOUND=$((AGENTS_FOUND + 1))
    if [[ ! -f "$wrapper" ]]; then
      echo "MISSING: addy-agents/$name  (vendor: ${agent#$KIT_ROOT/})"
      MISSING+=("addy-agents/$name")
      FAIL=1
    else
      # Ensure wrapper still points at this vendor file (stale after rename)
      if ! grep -q "vendor/addy-agent-skills/agents/${name}.md" "$wrapper"; then
        echo "STALE: addy-agents/$name does not reference agents/${name}.md"
        MISSING+=("addy-agents/$name (stale path)")
        FAIL=1
      else
        echo "OK addy-agents/$name"
      fi
    fi
  done < <(find "$AGENTS_DIR" -maxdepth 1 -type f -name '*.md' -print0 | sort -z)

  # Orphan wrappers (vendor agent removed) — warn, do not fail harness by default
  if [[ -d "$KIT_ROOT/skills/addy-agents" ]]; then
    while IFS= read -r -d '' wrap; do
      wname="$(basename "$(dirname "$wrap")")"
      if [[ ! -f "$AGENTS_DIR/${wname}.md" ]]; then
        echo "WARN: orphan wrapper skills/addy-agents/$wname (no vendor agents/${wname}.md) — remove or re-map"
      fi
    done < <(find "$KIT_ROOT/skills/addy-agents" -mindepth 2 -maxdepth 2 -type f -name SKILL.md -print0 | sort -z)
  fi
else
  echo "WARN: missing $AGENTS_DIR"
fi

# WRAPPER-MAP should mention each agent persona at least once (personas: or coverage_index)
MAP="$KIT_ROOT/docs/WRAPPER-MAP.yaml"
if [[ -f "$MAP" && -d "$AGENTS_DIR" ]]; then
  echo "== WRAPPER-MAP persona reachability =="
  while IFS= read -r -d '' agent; do
    name="$(basename "$agent" .md)"
    id="addy-agents/$name"
    if ! grep -qE "(^|[[:space:]-])${id}([[:space:]#]|$)" "$MAP"; then
      echo "MISSING MAP: $id not listed in WRAPPER-MAP.yaml (add personas: or coverage_index)"
      MISSING+=("$id (WRAPPER-MAP)")
      FAIL=1
    else
      echo "OK map $id"
    fi
  done < <(find "$AGENTS_DIR" -maxdepth 1 -type f -name '*.md' -print0 | sort -z)
fi

echo "== summary: checked $FOUND skills + $AGENTS_FOUND agents =="

if [[ $FAIL -ne 0 ]]; then
  echo "FAIL: ${#MISSING[@]} gap(s):"
  printf '  - %s\n' "${MISSING[@]}"
  echo "Run: python3 \"$KIT_ROOT/scripts/generate-thin-wrappers.py\""
  echo "Then wire new addy-agents/* into docs/WRAPPER-MAP.yaml personas: / coverage_index."
  exit 1
fi

echo "PASS: every vendored SKILL.md and agents/*.md has a thin wrapper (+ map entry)"
exit 0
