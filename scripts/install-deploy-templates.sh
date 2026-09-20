#!/usr/bin/env bash
# install-deploy-templates.sh <code-repo-path> [jvm|node|both]
# Seeds Docker image build + K8s staging templates only (no full kit install).
# Never overwrites existing Dockerfile / workflows.
set -euo pipefail

TARGET="${1:-}"
FLAVOR="${2:-both}"
KIT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if [[ -z "$TARGET" || ! -d "$TARGET" ]]; then
  echo "usage: install-deploy-templates.sh <code-repo-path> [jvm|node|both]" >&2
  exit 2
fi
TARGET="$(cd "$TARGET" && pwd)"

# Refuse kit repo
if [[ "$TARGET" == "$KIT_ROOT" ]]; then
  echo "skip: refusing to install into agentic-sdlc itself ($TARGET)"
  exit 0
fi

mkdir -p "$TARGET/.github/workflows" "$TARGET/deploy/k8s"

seed() {
  local src="$1" dest="$2"
  if [[ -f "$dest" ]]; then
    echo "  keep $dest"
    return
  fi
  if [[ ! -f "$src" ]]; then
    echo "  miss $src"
    return
  fi
  cp -f "$src" "$dest"
  echo "  + $dest"
}

echo "== deploy templates → $TARGET (flavor=$FLAVOR) =="

seed "$KIT_ROOT/templates/github/docker-build.yml" "$TARGET/.github/workflows/docker-build.yml"
seed "$KIT_ROOT/templates/github/k8s-deploy-staging.yml" "$TARGET/.github/workflows/k8s-deploy-staging.yml"
seed "$KIT_ROOT/templates/github/k8s-deploy-prod.yml" "$TARGET/.github/workflows/k8s-deploy-prod.yml"

case "$FLAVOR" in
  jvm)
    seed "$KIT_ROOT/templates/deploy/Dockerfile.jvm.example" "$TARGET/Dockerfile.jvm.example"
    ;;
  node)
    seed "$KIT_ROOT/templates/deploy/Dockerfile.node.example" "$TARGET/Dockerfile.node.example"
    ;;
  both|*)
    seed "$KIT_ROOT/templates/deploy/Dockerfile.jvm.example" "$TARGET/Dockerfile.jvm.example"
    seed "$KIT_ROOT/templates/deploy/Dockerfile.node.example" "$TARGET/Dockerfile.node.example"
    ;;
esac

seed "$KIT_ROOT/templates/deploy/.dockerignore.example" "$TARGET/.dockerignore"
seed "$KIT_ROOT/templates/k8s/deployment.yaml.example" "$TARGET/deploy/k8s/deployment.yaml.example"
seed "$KIT_ROOT/templates/k8s/service.yaml.example" "$TARGET/deploy/k8s/service.yaml.example"

if [[ -f "$KIT_ROOT/templates/deploy/README.md" && ! -f "$TARGET/deploy/README.md" ]]; then
  cp -f "$KIT_ROOT/templates/deploy/README.md" "$TARGET/deploy/README.md"
  echo "  + $TARGET/deploy/README.md"
fi

echo "DONE $TARGET"
echo "Next: rename Dockerfile.*.example → Dockerfile, set vars IMAGE_NAME / REGISTRY / KUBE_CONFIG_*"
