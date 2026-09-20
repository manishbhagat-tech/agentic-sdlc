#!/usr/bin/env bash
# validate-story-frontmatter.sh — story_ready / design_parents / tests declaration
# Env: DOCS_ROOT (required), STORY_ID (optional — validate one; else all US-/BUG- under docs)
set -euo pipefail

DOCS="${DOCS_ROOT:-}"
if [[ -z "$DOCS" || ! -d "$DOCS" ]]; then
  echo "WARN: DOCS_ROOT unset — skip story frontmatter validation"
  exit 0
fi

STORY_ID="${STORY_ID:-}"
python3 - "$DOCS" "$STORY_ID" <<'PY'
import re, sys, pathlib

docs = pathlib.Path(sys.argv[1])
only = sys.argv[2].strip() if len(sys.argv) > 2 else ""
fail = 0
checked = 0

def parse(path: pathlib.Path):
    text = path.read_text(encoding="utf-8", errors="replace")
    if not text.startswith("---"):
        return None, text
    parts = text.split("---", 2)
    return parts[1], text

def scalar(fm, key, default=None):
    m = re.search(rf"^{re.escape(key)}:\s*(.+)$", fm, re.M)
    if not m:
        return default
    return m.group(1).strip().strip('"').strip("'")

def has_skills(fm):
    if re.search(r"^skills:\s*\[", fm, re.M):
        return True
    if re.search(r"^skills:\s*$", fm, re.M):
        # block form
        return bool(re.search(r"^skills:\s*\n(?:\s+-\s+.+\n)+", fm, re.M))
    return False

files = []
if only:
    for f in docs.rglob("*.md"):
        fm, _ = parse(f)
        if fm and scalar(fm, "id") == only:
            files.append(f)
            break
    if not files:
        print(f"FAIL: STORY_ID={only} not found under {docs}")
        sys.exit(1)
else:
    for f in sorted(docs.rglob("*.md")):
        fm, _ = parse(f)
        if not fm:
            continue
        sid = scalar(fm, "id")
        if sid and re.match(r"^(US|BUG)-", sid):
            files.append(f)

for f in files:
    fm, text = parse(f)
    sid = scalar(fm, "id")
    status = scalar(fm, "status", "")
    security = scalar(fm, "security", "standard")
    checked += 1
    errors = []

    if not status:
        errors.append("missing status")
    if "budget:" not in fm and "max_context_tokens" not in fm:
        errors.append("missing budget")

    # New / active stories require skills[]
    if status in ("ready", "in_progress", "in_review", "draft"):
        if not has_skills(fm):
            # Legacy goldens may omit — warn for draft/ready without skills if revision high? Fail for ready+
            if status in ("ready", "in_progress", "in_review"):
                errors.append("skills:[] required for ready/in_progress/in_review")

    if status in ("ready", "in_progress"):
        if "repos:" not in fm:
            errors.append("repos: required when ready/in_progress")
        if "tests:" not in fm:
            errors.append("tests: required when ready/in_progress")

    # Design parents via must_read hints (best-effort)
    channels = fm
    needs_ui = bool(re.search(r"channels:.*\b(web|mobile)\b", fm, re.S))
    must = re.findall(r'^\s*-\s*(delivery/[^\s]+)', fm, re.M)
    if status in ("ready", "in_progress") and must:
        for rel in must:
            p = docs / rel
            if not p.is_file():
                # also try without leading
                errors.append(f"must_read missing file: {rel}")

    if errors:
        fail = 1
        print(f"FAIL {sid} ({f.relative_to(docs)}): " + "; ".join(errors))
    else:
        print(f"OK {sid} status={status} security={security}")

print(f"checked {checked} stories")
sys.exit(fail)
PY
