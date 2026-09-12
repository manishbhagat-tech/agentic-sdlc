#!/usr/bin/env bash
# pack-story-context.sh <US-id|BUG-id>
# Builds a bounded context pack under .agentic/packs/<id>/
set -euo pipefail

ID="${1:-}"
if [[ -z "$ID" ]]; then
  echo "usage: pack-story-context.sh <US-*|BUG-*>" >&2
  exit 2
fi

ROOT="${WORKSPACE_ROOT:-$(pwd)}"
AGENTS="$ROOT/AGENTS.md"
DOCS_ROOT="${DOCS_ROOT:-}"

if [[ -z "$DOCS_ROOT" && -f "$AGENTS" ]]; then
  DOCS_ROOT=$(grep -E '^\s*DOCS_ROOT:' "$AGENTS" | head -1 | sed 's/.*DOCS_ROOT:[[:space:]]*//' | tr -d '`"'"'" || true)
fi
if [[ -z "$DOCS_ROOT" ]]; then
  DOCS_ROOT="$ROOT/../civil-erp-docs"
fi
# Resolve relative DOCS_ROOT
if [[ "$DOCS_ROOT" != /* ]]; then
  DOCS_ROOT="$(cd "$ROOT" && cd "$DOCS_ROOT" && pwd)"
fi

STORY_FILE=$(find "$DOCS_ROOT" -type f \( -name "${ID}.md" -o -name "*${ID}*.md" \) 2>/dev/null | head -1 || true)
if [[ -z "$STORY_FILE" ]]; then
  echo "ERROR: story/bug file for $ID not found under $DOCS_ROOT" >&2
  exit 1
fi

PACK_DIR="$ROOT/.agentic/packs/$ID"
rm -rf "$PACK_DIR"
mkdir -p "$PACK_DIR/PARENTS" "$PACK_DIR/CODE_OUTLINES"

cp "$STORY_FILE" "$PACK_DIR/STORY.md"

# Parse simple YAML-ish fields with python for reliability
python3 - "$STORY_FILE" "$PACK_DIR" "$DOCS_ROOT" "$ROOT" <<'PY'
import sys, re, json, os, pathlib

story_path, pack_dir, docs_root, workspace = sys.argv[1:5]
text = pathlib.Path(story_path).read_text(encoding="utf-8")
fm_match = re.match(r"^---\n(.*?)\n---\n", text, re.S)
if not fm_match:
    print("ERROR: missing YAML frontmatter", file=sys.stderr)
    sys.exit(1)
fm = fm_match.group(1)

def get_scalar(key, default=None):
    m = re.search(rf"^{re.escape(key)}:\s*(.+)$", fm, re.M)
    if not m:
        return default
    v = m.group(1).strip().strip('"').strip("'")
    if v in ("null", "~", ""):
        return default
    return v

def get_int(path_keys, default):
    # budget:\n  max_context_tokens: N
    if path_keys[0] == "budget":
        m = re.search(rf"^budget:\n(?:.*\n)*?\s+{path_keys[1]}:\s*(\d+)", fm, re.M)
        if m:
            return int(m.group(1))
    return default

max_tokens = get_int(["budget", "max_context_tokens"], 12000)
max_files = get_int(["budget", "max_files_read"], 12)
max_lines = get_int(["budget", "max_file_lines"], 200)
revision = get_scalar("revision", "1")
status = get_scalar("status", "draft")
security = get_scalar("security", "standard")

# must_read list
must_read = re.findall(r"^\s+-\s+(.+)$", fm.split("must_read:")[1].split("\nrepos:")[0] if "must_read:" in fm else "", re.M) if "must_read:" in fm else []
must_read = [m.strip().strip('"').strip("'") for m in must_read if m.strip() and not m.strip().startswith("#")]

# allow globs under repos
allow = re.findall(r'allow:\s*\[(.*?)\]', fm, re.S)
allow_paths = []
for block in allow:
    allow_paths += re.findall(r'"([^"]+)"', block)

parents_dir = pathlib.Path(pack_dir) / "PARENTS"
bytes_total = len(text.encode("utf-8"))
files_included = [story_path]

for rel in must_read:
    rel = rel.strip()
    p = pathlib.Path(docs_root) / rel
    if not p.is_file():
        print(f"WARN: must_read missing: {rel}", file=sys.stderr)
        continue
    raw = p.read_text(encoding="utf-8", errors="replace")
    # Cap parent files
    lines = raw.splitlines()
    if len(lines) > max_lines:
        raw = "\n".join(lines[:max_lines]) + f"\n\n… truncated at {max_lines} lines …\n"
    dest = parents_dir / rel.replace("/", "__")
    dest.write_text(raw, encoding="utf-8")
    bytes_total += len(raw.encode("utf-8"))
    files_included.append(str(p))

# Outlines: list matching allow files (names + first line only) — cheap
out_dir = pathlib.Path(pack_dir) / "CODE_OUTLINES"
outline_count = 0
ws = pathlib.Path(workspace)
# workspace may be api; allow paths relative to sibling or self
search_roots = [ws, ws.parent]
seen = set()
for glob_pat in allow_paths:
    for root in search_roots:
        for f in root.glob(glob_pat):
            if not f.is_file():
                continue
            key = str(f.resolve())
            if key in seen:
                continue
            seen.add(key)
            if outline_count >= max_files:
                break
            try:
                lines = f.read_text(encoding="utf-8", errors="replace").splitlines()
            except Exception:
                continue
            # outline: path + signatures-ish (lines with class/def/func/export)
            sigs = [ln for ln in lines if re.search(r"^\s*(public |private |protected |export |function |class |interface |def )", ln)][:40]
            body = f"# {f.relative_to(root) if str(f).startswith(str(root)) else f.name}\n" + "\n".join(sigs[:40])
            if len(body.splitlines()) > max_lines:
                body = "\n".join(body.splitlines()[:max_lines])
            (out_dir / f"{outline_count:02d}_{f.name}.md").write_text(body, encoding="utf-8")
            bytes_total += len(body.encode("utf-8"))
            files_included.append(str(f))
            outline_count += 1
        if outline_count >= max_files:
            break

# Optional DIFF
import subprocess
diff_path = pathlib.Path(pack_dir) / "DIFF.md"
try:
    diff = subprocess.check_output(["git", "diff", "--stat"], cwd=workspace, stderr=subprocess.DEVNULL, text=True)
    diff_full = subprocess.check_output(["git", "diff"], cwd=workspace, stderr=subprocess.DEVNULL, text=True)
    # cap diff
    # Cap tightly — diffs are for review skill; do not blow story budget
    if len(diff_full) > 20_000:
        diff_full = diff_full[:20_000] + "\n… truncated …\n"
    diff_path.write_text(f"```\n{diff}\n```\n\n```diff\n{diff_full}\n```\n", encoding="utf-8")
    # Count at most 4k bytes of diff toward budget
    bytes_total += min(4000, diff_path.stat().st_size)
except Exception:
    diff_path.write_text("(no git diff)\n", encoding="utf-8")

# Token estimate ~ chars/4
est_tokens = max(1, bytes_total // 4)
manifest = {
    "id": get_scalar("id"),
    "revision": revision,
    "status": status,
    "security": security,
    "story_file": story_path,
    "docs_root": docs_root,
    "bytes": bytes_total,
    "pack_tokens_est": est_tokens,
    "budget_max_context_tokens": max_tokens,
    "files_included": files_included,
    "outline_files": outline_count,
    "allow": allow_paths,
}
(pathlib.Path(pack_dir) / "MANIFEST.json").write_text(json.dumps(manifest, indent=2), encoding="utf-8")

if est_tokens > max_tokens:
    print(f"ERROR: pack_tokens_est={est_tokens} exceeds budget max_context_tokens={max_tokens}", file=sys.stderr)
    sys.exit(1)

print(f"OK packed {get_scalar('id')} → {pack_dir} (~{est_tokens} tokens, budget {max_tokens})")
PY
