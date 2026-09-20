#!/usr/bin/env bash
# Deny dangerous shell commands for agent sessions.
set -euo pipefail
input=$(cat || true)
# Cursor passes JSON on stdin; extract command if present
cmd=$(printf '%s' "$input" | python3 -c "import sys,json,re
raw=sys.stdin.read()
try:
  d=json.loads(raw)
  print(d.get('command') or d.get('tool_input',{}).get('command') or '')
except Exception:
  print(raw)
" 2>/dev/null || true)

deny_patterns=(
  'git[[:space:]]+push[[:space:]]+.*--force'
  'git[[:space:]]+push[[:space:]]+.*--force-with-lease'
  'git[[:space:]]+push[[:space:]]+-f([[:space:]]|$)'
  'git[[:space:]]+push[[:space:]]+.*[[:space:]](main|master)([[:space:]]|$)'
  'git[[:space:]]+reset[[:space:]]+--hard'
  'git[[:space:]]+clean[[:space:]]+.*-fdx'
  'git[[:space:]]+clean[[:space:]]+.*-ffdx'
  'git[[:space:]]+filter-branch'
  'git[[:space:]]+filter-repo'
  'git[[:space:]]+push[[:space:]]+.*:main'
  'git[[:space:]]+push[[:space:]]+.*:master'
  'gh[[:space:]]+repo[[:space:]]+delete'
  'gh[[:space:]]+repo[[:space:]]+edit[[:space:]]+.*--visibility[[:space:]]+public'
  'rm[[:space:]]+-rf[[:space:]]+/'
  'rm[[:space:]]+-rf[[:space:]]+~'
  'mkfs\.'
  'dd[[:space:]]+if='
  'chmod[[:space:]]+-R[[:space:]]+777[[:space:]]+/'
)

for pat in "${deny_patterns[@]}"; do
  if printf '%s' "$cmd" | grep -Eqi "$pat"; then
    echo "{\"permission\":\"deny\",\"userMessage\":\"Blocked dangerous command by agentic-sdlc guardrail.\"}"
    exit 0
  fi
done

echo "{\"permission\":\"allow\"}"
