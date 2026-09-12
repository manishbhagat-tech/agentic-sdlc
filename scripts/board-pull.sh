#!/usr/bin/env bash
# board-pull.sh — optionally pull GitHub issue state into markdown status
set -euo pipefail
KIT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG="${BOARD_CONFIG:-$KIT_ROOT/board/github-projects.yaml}"
DOCS_ROOT="${DOCS_ROOT:-}"

python3 - "$CONFIG" "$DOCS_ROOT" <<'PY'
import re, sys, subprocess, pathlib

config_path, docs_root = sys.argv[1:3]
cfg = pathlib.Path(config_path).read_text(encoding="utf-8")
if not re.search(r"^enabled:\s*true\s*$", cfg, re.M):
    print("board-pull: enabled=false — skip")
    sys.exit(0)
if not re.search(r"status_from_board:\s*true", cfg):
    print("board-pull: status_from_board=false — skip")
    sys.exit(0)
repo_m = re.search(r"^repo:\s*(\S+)", cfg, re.M)
if not repo_m or not docs_root:
    print("ERROR: repo/DOCS_ROOT required", file=sys.stderr); sys.exit(1)
repo = repo_m.group(1)
docs = pathlib.Path(docs_root)

# Map GH state to our status (coarse)
gh_to_status = {"OPEN": None, "CLOSED": "done"}  # Projects columns need GraphQL; v1 uses issue state only

for f in docs.rglob("*.md"):
    text = f.read_text(encoding="utf-8", errors="replace")
    if not text.startswith("---"):
        continue
    parts = text.split("---", 2)
    fm = parts[1]
    eid_m = re.search(r'^external_id:\s*"?(\d+)"?', fm, re.M)
    id_m = re.search(r"^id:\s*((?:US|BUG)-[\w-]+)", fm, re.M)
    if not eid_m or not id_m:
        continue
    eid = eid_m.group(1)
    try:
        state = subprocess.check_output(
            ["gh", "issue", "view", eid, "-R", repo, "--json", "state", "-q", ".state"],
            text=True,
        ).strip()
    except subprocess.CalledProcessError:
        continue
    if state == "CLOSED":
        new_fm = re.sub(r"^status:\s*\w+", "status: done", fm, count=1, flags=re.M)
        f.write_text(f"---\n{new_fm}\n---\n{parts[2]}", encoding="utf-8")
        print(f"pulled {id_m.group(1)} → done")
print("board-pull done")
PY
