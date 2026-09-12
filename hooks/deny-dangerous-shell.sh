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
  'git[[:space:]]+push[[:space:]]+-f'
  'git[[:space:]]+reset[[:space:]]+--hard'
  'rm[[:space:]]+-rf[[:space:]]+/'
  'rm[[:space:]]+-rf[[:space:]]+~'
  'mkfs\.'
  'dd[[:space:]]+if='
)

for pat in "${deny_patterns[@]}"; do
  if printf '%s' "$cmd" | grep -Eqi "$pat"; then
    echo "{\"permission\":\"deny\",\"userMessage\":\"Blocked dangerous command by agentic-sdlc guardrail.\"}"
    exit 0
  fi
done

echo "{\"permission\":\"allow\"}"
