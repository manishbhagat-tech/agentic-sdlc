#!/usr/bin/env bash
# install-to-workspace.sh <path-to-code-repo> [--symlink]
set -euo pipefail

TARGET="${1:-}"
MODE="${2:-}"
KIT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
if [[ -z "$TARGET" || ! -d "$TARGET" ]]; then
  echo "usage: install-to-workspace.sh <code-repo-path> [--symlink]" >&2
  exit 2
fi
TARGET="$(cd "$TARGET" && pwd)"

mkdir -p "$TARGET/.cursor/skills" "$TARGET/.cursor/hooks" "$TARGET/.cursor/rules" "$TARGET/scripts/agentic"

link_or_copy_dir() {
  local src="$1" dest="$2"
  rm -rf "$dest"
  if [[ "$MODE" == "--symlink" ]]; then
    ln -s "$src" "$dest"
  else
    cp -R "$src" "$dest"
  fi
}

link_or_copy_file() {
  local src="$1" dest="$2"
  rm -f "$dest"
  if [[ "$MODE" == "--symlink" ]]; then
    ln -s "$src" "$dest"
  else
    cp -f "$src" "$dest"
  fi
}

for d in "$KIT_ROOT"/skills/*/; do
  name=$(basename "$d")
  link_or_copy_dir "${d%/}" "$TARGET/.cursor/skills/$name"
done

# Hooks: copy scripts (symlinks OK); hooks.json always file copy so Cursor resolves relative paths
mkdir -p "$TARGET/.cursor/hooks"
for f in "$KIT_ROOT"/hooks/*; do
  base=$(basename "$f")
  [[ "$base" == "hooks.json" ]] && continue
  link_or_copy_file "$f" "$TARGET/.cursor/hooks/$base"
done
if [[ -f "$KIT_ROOT/hooks/hooks.json" ]]; then
  cp -f "$KIT_ROOT/hooks/hooks.json" "$TARGET/.cursor/hooks.json"
fi

for f in "$KIT_ROOT"/rules/*; do
  [[ -f "$f" ]] || continue
  link_or_copy_file "$f" "$TARGET/.cursor/rules/$(basename "$f")"
done

for script in pack-story-context.sh harness-check.sh path-lock-check.sh cost-report.sh; do
  if [[ -f "$KIT_ROOT/scripts/$script" ]]; then
    link_or_copy_file "$KIT_ROOT/scripts/$script" "$TARGET/scripts/agentic/$script"
    chmod +x "$TARGET/scripts/agentic/$script" 2>/dev/null || true
  fi
done

mkdir -p "$TARGET/.agentic"
echo "$KIT_ROOT" > "$TARGET/.agentic/KIT_ROOT"
echo "$MODE" > "$TARGET/.agentic/INSTALL_MODE"
grep -q '.agentic/packs/' "$TARGET/.gitignore" 2>/dev/null || echo -e "\n.agentic/packs/\n.agentic/runs/\n" >> "$TARGET/.gitignore"

if [[ ! -f "$TARGET/AGENTS.md" ]]; then
  cat > "$TARGET/AGENTS.md" <<EOF
# Agent instructions

DOCS_ROOT: ../civil-erp-docs
AGENTIC_SDLC: ../../agentic-sdlc

## Rules

- Implement only from ready \`US-*\` / \`BUG-*\` stories.
- Run \`scripts/agentic/pack-story-context.sh <id>\` before implement/fix/review/cleanup.
- Branch: \`feat/US-…\` or \`fix/BUG-…\`.
- Secure + lean; cleanup before done.
- See kit docs: TOKEN-OPTIMIZATION.md, STANDARD-PRACTICES.md
EOF
fi

echo "Installed agentic-sdlc into $TARGET (mode=${MODE:-copy})"
if [[ "$MODE" != "--symlink" ]]; then
  echo "Tip: use --symlink on your machine so kit edits apply without re-install."
fi
