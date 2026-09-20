#!/usr/bin/env bash
# board-sync.sh — push US-*/BUG-* markdown → GitHub Issues + optional Project items
# Markdown remains source of truth; Projects is the dashboard mirror.
#
# Requires: gh auth
# Env: DOCS_ROOT, BOARD_CONFIG (default board/github-projects.yaml)
set -euo pipefail

KIT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG="${BOARD_CONFIG:-$KIT_ROOT/board/github-projects.yaml}"
DOCS_ROOT="${DOCS_ROOT:-}"

if [[ -z "$DOCS_ROOT" || ! -d "$DOCS_ROOT" ]]; then
  echo "usage: DOCS_ROOT=/path/to/docs ./scripts/board-sync.sh" >&2
  exit 2
fi

# First: create/update issues (existing board-push)
"$KIT_ROOT/scripts/board-push.sh"

python3 - "$CONFIG" "$DOCS_ROOT" <<'PY'
"""Add issues to GitHub Project (v2) when project_number + owner set."""
import re, sys, subprocess, pathlib, json

config_path, docs_root = sys.argv[1:3]
cfg = pathlib.Path(config_path).read_text(encoding="utf-8")
if not re.search(r"^enabled:\s*true\s*$", cfg, re.M):
    print("board-sync: project attach skipped (enabled=false)")
    sys.exit(0)

repo_m = re.search(r"^repo:\s*(\S+)", cfg, re.M)
num_m = re.search(r"^project_number:\s*(\d+)", cfg, re.M)
owner_m = re.search(r"^project_owner:\s*(\S+)", cfg, re.M)
title_field = re.search(r"^status_field:\s*\"?([^\n\"]+)\"?", cfg, re.M)

if not repo_m or not num_m:
    print("board-sync: repo/project_number missing — issues only")
    sys.exit(0)

repo = repo_m.group(1)
project_number = num_m.group(1)
owner = owner_m.group(1) if owner_m else repo.split("/")[0]
status_field = title_field.group(1) if title_field else "Status"

# status_map
status_map = {}
in_map = False
for line in cfg.splitlines():
    if re.match(r"^status_map:\s*$", line):
        in_map = True
        continue
    if in_map:
        if re.match(r"^\S", line) and not line.startswith(" "):
            in_map = False
            continue
        m = re.match(r"^\s+(\w+):\s*(.+)$", line)
        if m:
            status_map[m.group(1)] = m.group(2).strip().strip('"')

docs = pathlib.Path(docs_root)
added = 0

def gh_json(args):
    out = subprocess.check_output(["gh", *args], text=True)
    return json.loads(out) if out.strip() else None

# Resolve project id
try:
    proj = gh_json([
        "project", "list", "--owner", owner, "--format", "json", "--limit", "50"
    ])
except subprocess.CalledProcessError as e:
    print(f"WARN: gh project list failed: {e}", file=sys.stderr)
    sys.exit(0)

projects = proj if isinstance(proj, list) else (proj or {}).get("projects") or []
# gh project list --format json structure varies; try number match
project_id = None
for p in projects if isinstance(projects, list) else []:
    if str(p.get("number")) == str(project_number):
        project_id = p.get("id")
        break

if not project_id:
    # fallback: gh project view
    try:
        view = subprocess.check_output(
            ["gh", "project", "view", project_number, "--owner", owner, "--format", "json"],
            text=True,
        )
        project_id = json.loads(view).get("id")
    except Exception as e:
        print(f"WARN: could not resolve project id: {e}", file=sys.stderr)
        sys.exit(0)

print(f"board-sync: project {owner}/{project_number} id={project_id}")

for f in sorted(docs.rglob("*.md")):
    text = f.read_text(encoding="utf-8", errors="replace")
    if not text.startswith("---"):
        continue
    fm = text.split("---", 2)[1]
    id_m = re.search(r"^id:\s*((?:US|BUG)-[\w-]+)", fm, re.M)
    eid_m = re.search(r'^external_id:\s*"?(\d+)"?', fm, re.M)
    st_m = re.search(r"^status:\s*(\w+)", fm, re.M)
    if not id_m or not eid_m:
        continue
    if st_m and st_m.group(1) in ("cancelled", "superseded", "draft"):
        continue
    issue = eid_m.group(1)
    # Add item (idempotent-ish — gh may error if already present)
    try:
        subprocess.check_call(
            [
                "gh", "project", "item-add", project_number,
                "--owner", owner,
                "--url", f"https://github.com/{repo}/issues/{issue}",
            ],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        print(f"project-add {id_m.group(1)} → #{issue}")
        added += 1
    except subprocess.CalledProcessError:
        print(f"project-skip {id_m.group(1)} (already on board or API limit)")

print(f"board-sync done (project adds attempted={added})")
print("Tip: set Project Status column manually or use Actions project automation;")
print("     markdown status remains SoT until status_from_board: true.")
PY
