#!/usr/bin/env bash
# path-lock-check.sh [docs_root]
# Fails if two in_progress stories have overlapping allow globs.
set -euo pipefail
DOCS="${1:-${DOCS_ROOT:-}}"
if [[ -z "$DOCS" || ! -d "$DOCS" ]]; then
  echo "WARN: path-lock-check: DOCS_ROOT missing — skip"
  exit 0
fi

python3 - "$DOCS" <<'PY'
import re, sys, pathlib
docs = pathlib.Path(sys.argv[1])
stories = []
for f in docs.rglob("*.md"):
    text = f.read_text(encoding="utf-8", errors="replace")
    if not text.startswith("---"):
        continue
    fm = text.split("---", 2)[1]
    sid = re.search(r"^id:\s*(US-|BUG-)[\w-]+", fm, re.M)
    status = re.search(r"^status:\s*(\w+)", fm, re.M)
    if not sid or not status:
        continue
    if status.group(1) != "in_progress":
        continue
    allows = []
    for block in re.findall(r"allow:\s*\[(.*?)\]", fm, re.S):
        allows += re.findall(r'"([^"]+)"', block)
    stories.append((sid.group(0).split(":",1)[1].strip(), allows, str(f)))

def overlap(a, b):
    # simplistic: identical or one prefix of other ignoring **
    def norm(g):
        return g.replace("**", "").rstrip("/")
    for x in a:
        for y in b:
            nx, ny = norm(x), norm(y)
            if nx == ny or nx.startswith(ny) or ny.startswith(nx):
                return True
    return False

fail = 0
for i in range(len(stories)):
    for j in range(i+1, len(stories)):
        if overlap(stories[i][1], stories[j][1]):
            print(f"LOCK: {stories[i][0]} overlaps {stories[j][0]}")
            fail = 1
if fail:
    sys.exit(1)
print(f"OK path-lock ({len(stories)} in_progress)")
PY
