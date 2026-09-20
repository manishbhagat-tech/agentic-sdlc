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

# Roles (personas) — optional but installed for Grok/Cursor
mkdir -p "$TARGET/.agentic"
if [[ -d "$KIT_ROOT/roles" ]]; then
  link_or_copy_dir "$KIT_ROOT/roles" "$TARGET/.agentic/roles"
  if [[ -f "$KIT_ROOT/ROLES.md" ]]; then
    link_or_copy_file "$KIT_ROOT/ROLES.md" "$TARGET/.agentic/ROLES.md"
  fi
fi

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

for script in pack-story-context.sh harness-check.sh path-lock-check.sh cost-report.sh security-check.sh git-safe.sh check-wrapper-coverage.sh vendor-sync-check.sh vendor-refresh-wrappers.sh generate-thin-wrappers.py product-gates.sh validate-story-frontmatter.sh check-pr-story-id.sh check-run-logs.sh check-security-findings.sh board-push.sh board-pull.sh board-sync.sh install-deploy-templates.sh; do
  if [[ -f "$KIT_ROOT/scripts/$script" ]]; then
    link_or_copy_file "$KIT_ROOT/scripts/$script" "$TARGET/scripts/agentic/$script"
    chmod +x "$TARGET/scripts/agentic/$script" 2>/dev/null || true
  fi
done

# Product CI workflow template (do not overwrite customized workflows)
mkdir -p "$TARGET/.github/workflows"
if [[ -f "$KIT_ROOT/templates/github/agentic-gates.yml" && ! -f "$TARGET/.github/workflows/agentic-gates.yml" ]]; then
  cp -f "$KIT_ROOT/templates/github/agentic-gates.yml" "$TARGET/.github/workflows/agentic-gates.yml"
  echo "Installed .github/workflows/agentic-gates.yml (edit DOCS_ROOT / vars)"
fi

# Docker / K8s workflow templates (seed once)
if [[ -f "$KIT_ROOT/templates/github/docker-build.yml" && ! -f "$TARGET/.github/workflows/docker-build.yml" ]]; then
  cp -f "$KIT_ROOT/templates/github/docker-build.yml" "$TARGET/.github/workflows/docker-build.yml"
  echo "Installed .github/workflows/docker-build.yml (set REGISTRY / IMAGE_NAME)"
fi
if [[ -f "$KIT_ROOT/templates/github/k8s-deploy-staging.yml" && ! -f "$TARGET/.github/workflows/k8s-deploy-staging.yml" ]]; then
  cp -f "$KIT_ROOT/templates/github/k8s-deploy-staging.yml" "$TARGET/.github/workflows/k8s-deploy-staging.yml"
  echo "Installed .github/workflows/k8s-deploy-staging.yml (staging only)"
fi
if [[ -f "$KIT_ROOT/templates/github/k8s-deploy-prod.yml" && ! -f "$TARGET/.github/workflows/k8s-deploy-prod.yml" ]]; then
  cp -f "$KIT_ROOT/templates/github/k8s-deploy-prod.yml" "$TARGET/.github/workflows/k8s-deploy-prod.yml"
  echo "Installed .github/workflows/k8s-deploy-prod.yml (manual + production env)"
fi

# Deploy file templates (seed once — product customizes)
mkdir -p "$TARGET/deploy/k8s"
if [[ ! -f "$TARGET/Dockerfile" && ! -f "$TARGET/Dockerfile.jvm" ]]; then
  if [[ -f "$KIT_ROOT/templates/deploy/Dockerfile.jvm.example" ]]; then
    cp -f "$KIT_ROOT/templates/deploy/Dockerfile.jvm.example" "$TARGET/Dockerfile.jvm.example"
    echo "Seeded Dockerfile.jvm.example — rename/customize to Dockerfile"
  fi
fi
if [[ ! -f "$TARGET/.dockerignore" && -f "$KIT_ROOT/templates/deploy/.dockerignore.example" ]]; then
  cp -f "$KIT_ROOT/templates/deploy/.dockerignore.example" "$TARGET/.dockerignore"
fi
if [[ ! -f "$TARGET/deploy/k8s/deployment.yaml" && -f "$KIT_ROOT/templates/k8s/deployment.yaml.example" ]]; then
  cp -f "$KIT_ROOT/templates/k8s/deployment.yaml.example" "$TARGET/deploy/k8s/deployment.yaml.example"
  cp -f "$KIT_ROOT/templates/k8s/service.yaml.example" "$TARGET/deploy/k8s/service.yaml.example"
  echo "Seeded deploy/k8s/*.example — customize before apply"
fi

mkdir -p "$TARGET/.agentic"
if [[ -f "$KIT_ROOT/board/github-projects.yaml" && ! -f "$TARGET/.agentic/board.yaml" ]]; then
  cp -f "$KIT_ROOT/board/github-projects.yaml" "$TARGET/.agentic/board.yaml"
fi
echo "$KIT_ROOT" > "$TARGET/.agentic/KIT_ROOT"
echo "$MODE" > "$TARGET/.agentic/INSTALL_MODE"
grep -q '.agentic/packs/' "$TARGET/.gitignore" 2>/dev/null || echo -e "\n.agentic/packs/\n.agentic/runs/\n.agentic/security/findings/\n" >> "$TARGET/.gitignore"

if [[ ! -f "$TARGET/AGENTS.md" ]]; then
  cat > "$TARGET/AGENTS.md" <<EOF
# Agent instructions

DOCS_ROOT: ../civil-erp-docs
AGENTIC_SDLC: ../../agentic-sdlc

## Rules

- Implement only from ready \`US-*\` / \`BUG-*\` stories with \`skills:[]\`.
- Design via feature-prd → hld → lld → ui → feature-stories.
- Run \`scripts/agentic/pack-story-context.sh <id>\` before implement/fix/review/cleanup.
- Git via \`scripts/agentic/git-safe.sh\`. Branch: \`feat/US-…\` or \`fix/BUG-…\`.
- Secure + lean; story-security + cleanup before done.
- Enter skills/ wrappers only — never raw vendor/.
- CI: \`scripts/agentic/product-gates.sh\` (see kit docs/PRODUCT-CI.md).
- Board: enable \`.agentic/board.yaml\` + \`board-sync.sh\` for GitHub Projects (docs/BOARD.md).
- See kit: PROTOCOL.md, ROLES.md, TOKEN-OPTIMIZATION.md, STANDARD-PRACTICES.md
EOF
fi

echo "Installed agentic-sdlc into $TARGET (mode=${MODE:-copy})"
echo "Note: vendor/ stays in the kit repo; agents use skills/ thin wrappers only."
if [[ "$MODE" != "--symlink" ]]; then
  echo "Tip: use --symlink on your machine so kit edits apply without re-install."
fi
