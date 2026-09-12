#!/usr/bin/env bash
# board-push.sh — push ready/in_progress stories to GitHub Issues (Projects mirror)
# Requires: gh auth, board/github-projects.yaml with enabled: true
set -euo pipefail
KIT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG="${BOARD_CONFIG:-$KIT_ROOT/board/github-projects.yaml}"
DOCS_ROOT="${DOCS_ROOT:-}"

python3 - "$CONFIG" "$DOCS_ROOT" "$KIT_ROOT" <<'PY'
import os, re, sys, subprocess, pathlib

config_path, docs_root, kit = sys.argv[1:4]
cfg_text = pathlib.Path(config_path).read_text(encoding="utf-8")
enabled = re.search(r"^enabled:\s*true\s*$", cfg_text, re.M)
if not enabled:
    print("board-push: enabled=false — skip (configure board/github-projects.yaml)")
    sys.exit(0)

repo_m = re.search(r"^repo:\s*(\S+)", cfg_text, re.M)
if not repo_m:
    print("ERROR: repo missing in config", file=sys.stderr); sys.exit(1)
repo = repo_m.group(1)

if not docs_root:
    print("ERROR: set DOCS_ROOT", file=sys.stderr); sys.exit(1)
docs = pathlib.Path(docs_root)

def parse_fm(text):
    if not text.startswith("---"):
        return None
    fm = text.split("---", 2)[1]
    def g(k, default=None):
        m = re.search(rf"^{k}:\s*(.+)$", fm, re.M)
        return m.group(1).strip().strip('"').strip("'") if m else default
    return {
        "id": g("id"),
        "title": g("title", ""),
        "status": g("status"),
        "security": g("security", "standard"),
        "external_id": g("external_id"),
        "fm": fm,
        "body": text.split("---", 2)[-1].strip(),
    }

count = 0
for f in sorted(docs.rglob("*.md")):
    text = f.read_text(encoding="utf-8", errors="replace")
    meta = parse_fm(text)
    if not meta or not meta["id"]:
        continue
    if not re.match(r"^(US|BUG)-", meta["id"]):
        continue
    if meta["status"] not in ("ready", "in_progress", "in_review", "needs_human", "blocked"):
        continue
    if meta["external_id"] and meta["external_id"] not in ("null", "~"):
        print(f"skip {meta['id']} already external_id={meta['external_id']}")
        continue
    title = f"{meta['id']}: {meta['title'] or meta['id']}"
    labels = ["story"] if meta["id"].startswith("US-") else ["bug"]
    if meta["security"] == "elevated":
        labels.append("security:elevated")
    body = meta["body"][:60000]
    cmd = ["gh", "issue", "create", "-R", repo, "--title", title, "--body", body]
    for lab in labels:
        cmd += ["--label", lab]
    try:
        out = subprocess.check_output(cmd, text=True).strip()
        # URL .../issues/N
        m = re.search(r"/issues/(\d+)", out)
        if m:
            eid = m.group(1)
            new_fm = re.sub(r"^external_id:.*$", f"external_id: \"{eid}\"", meta["fm"], count=1, flags=re.M)
            if "external_id:" not in meta["fm"]:
                new_fm = meta["fm"].rstrip() + f"\nexternal_id: \"{eid}\"\n"
            f.write_text(f"---\n{new_fm}\n---\n{meta['body']}\n", encoding="utf-8")
            print(f"pushed {meta['id']} → #{eid}")
            count += 1
        else:
            print(f"pushed {meta['id']} → {out}")
            count += 1
    except subprocess.CalledProcessError as e:
        print(f"WARN: failed {meta['id']}: {e}", file=sys.stderr)

print(f"board-push done ({count})")
PY
