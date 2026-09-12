#!/usr/bin/env bash
# Soft-check: if prompt looks like implementation without US-/BUG- id, warn via deny optional.
# Fail-open for non-implement prompts.
set -euo pipefail
input=$(cat || true)
python3 - <<'PY' "$input"
import json, re, sys
raw = sys.argv[1] if len(sys.argv) > 1 else sys.stdin.read()
try:
    d = json.loads(raw)
except Exception:
    d = {"prompt": raw}
prompt = (d.get("prompt") or d.get("input") or "") if isinstance(d, dict) else str(d)
lower = prompt.lower()
impl_hints = ("implement", "add feature", "build the", "write code", "create endpoint", "fix the bug", "code this")
looks_impl = any(h in lower for h in impl_hints)
has_id = bool(re.search(r"\b(US|BUG)-[A-Z0-9]+-\d+\b", prompt, re.I))
# Also allow explicit skill names
if looks_impl and not has_id and "story-author" not in lower and "draft story" not in lower:
    print(json.dumps({
        "continue": True,
        "userMessage": "Reminder: agentic-sdlc requires a US-* or BUG-* id for implementation. Create/amend a story first."
    }))
else:
    print(json.dumps({"continue": True}))
PY
