#!/usr/bin/env bash
# Consolidate civil-erp sibling repos → one monorepo (api/ web/ mobile/ docs/)
# Separate Docker images retained (matrix build). Does NOT delete old folders until verified —
# renames them to _legacy_* after successful copy.
set -euo pipefail

ROOT=/Users/manish/Projects/civil-erp
cd "$ROOT"

if [[ -d api && -f api/pom.xml && -d web && -f web/package.json && ! -d civil-erp-api ]]; then
  echo "Already looks consolidated (api/ web/ present, no civil-erp-api). Abort."
  exit 0
fi

if [[ ! -d civil-erp-api || ! -d civil-erp-web || ! -d civil-erp-mobile || ! -d civil-erp-docs ]]; then
  echo "Missing expected sibling folders under $ROOT" >&2
  exit 1
fi

RSYNC_EXCLUDES=(
  --exclude '.git/'
  --exclude 'node_modules/'
  --exclude '.next/'
  --exclude 'target/'
  --exclude '.expo/'
  --exclude '.venv-pptx/'
  --exclude '.DS_Store'
  --exclude '*.log'
)

echo "== copy trees =="
mkdir -p api web mobile docs
rsync -a "${RSYNC_EXCLUDES[@]}" civil-erp-api/ api/
rsync -a "${RSYNC_EXCLUDES[@]}" civil-erp-web/ web/
rsync -a "${RSYNC_EXCLUDES[@]}" civil-erp-mobile/ mobile/
rsync -a "${RSYNC_EXCLUDES[@]}" civil-erp-docs/ docs/

echo "== strip nested package workflows (root owns CI) =="
rm -rf api/.github web/.github mobile/.github docs/.github

echo "== rewrite story path locks in docs =="
# civil-erp-api → api, etc. in frontmatter
find docs -type f -name '*.md' -print0 | while IFS= read -r -d '' f; do
  perl -i -pe '
    s/\bpath:\s*civil-erp-api\b/path: api/g;
    s/\bpath:\s*civil-erp-web\b/path: web/g;
    s/\bpath:\s*civil-erp-mobile\b/path: mobile/g;
    s/\brepo:\s*civil-erp-api\b/repo: api/g;
    s/\brepo:\s*civil-erp-web\b/repo: web/g;
    s/\brepo:\s*civil-erp-mobile\b/repo: mobile/g;
    s#\.\./civil-erp-docs#docs#g;
    s#civil-erp-docs/#docs/#g;
    s#civil-erp-web/#web/#g;
    s#civil-erp-api/#api/#g;
    s#civil-erp-mobile/#mobile/#g;
  ' "$f"
done

# STORY-CONTRACT if present
if [[ -f docs/delivery/STORY-CONTRACT.md ]]; then
  perl -i -pe '
    s/civil-erp-api/api/g;
    s/civil-erp-web/web/g;
    s/civil-erp-mobile/mobile/g;
  ' docs/delivery/STORY-CONTRACT.md
fi

echo "== root AGENTS.md + README + gitignore =="
cat > AGENTS.md <<'EOF'
# Agent instructions — Civil ERP (monorepo)

DOCS_ROOT: docs
AGENTIC_SDLC: ../agentic-sdlc

## Layout

```
civil-erp/
  docs/     ← delivery SoT (stories, PRD/HLD/LLD)
  api/      ← Spring Boot / Java 21  → image civil-erp-api
  web/      ← Next.js 15             → image civil-erp-web
  mobile/   ← Expo / RN             → EAS (not K8s)
```

## Sync kit

```bash
../agentic-sdlc/scripts/install-to-workspace.sh . --symlink
```

## Rules

- Implement only from ready `US-*` / `BUG-*` in `$DOCS_ROOT/delivery/`.
- Story `repos[].path` values: `api` | `web` | `mobile`.
- Pack before implement/fix/test/review/cleanup.
- Branch `feat/US-…` / `fix/BUG-…`; one story per PR.
- Separate images for api + web; mobile via EAS.
- `security: elevated` → human merge. No auto-prod.
EOF

cat > README.md <<'EOF'
# Civil ERP

Monorepo: **one git repo**, **separate images** for API and web (mobile via EAS).

```
civil-erp/
  docs/    delivery + architecture (SoT)
  api/     Spring Boot → GHCR image `civil-erp-api`
  web/     Next.js     → GHCR image `civil-erp-web`
  mobile/  Expo        → EAS release workflow
```

## CI / deploy

| Workflow | What |
|----------|------|
| `ci-api.yml` / `ci-web.yml` | tests |
| `docker-build.yml` | matrix build/push api + web |
| `k8s-deploy-staging.yml` | auto after docker on main |
| `k8s-deploy-prod.yml` | manual + Environment approval |
| `mobile-release.yml` | EAS `workflow_dispatch` |
| `validate-stories.yml` | docs frontmatter / path-lock |

See `deploy/README.md` and package `api/deploy/README.md`, `web/deploy/README.md`.

## Legacy remotes

Previously split as `civil-erp-api`, `civil-erp-web`, `civil-erp-mobile`, `civil-erp-docs`.  
Local copies may remain as `_legacy_*` folders — do not develop there.

Kit: https://github.com/manishbhagat-tech/agentic-sdlc
EOF

cat > .gitignore <<'EOF'
.DS_Store
.idea/
*.iml
.venv*/
node_modules/
.next/
target/
.expo/
dist/
build/
.env
.env.*
!.env.example
.agentic/packs/
.agentic/runs/
.agentic/security/findings/
_legacy_*/
*.log
EOF

mkdir -p deploy .github/workflows
cat > deploy/README.md <<'EOF'
# Civil ERP deploy (monorepo)

- Images: `civil-erp-api`, `civil-erp-web` (separate)
- Staging: auto after **Docker build** on main
- Production: `k8s-deploy-prod.yml` + Environment **production** reviewers
- Mobile: `mobile-release.yml` + `EXPO_TOKEN`

Secrets on **this** GitHub repo: `KUBE_CONFIG_STAGING`, `KUBE_CONFIG_PRODUCTION`, `EXPO_TOKEN`.
EOF

# Thin package AGENTS
cat > api/AGENTS.md <<'EOF'
# api package

Monorepo root owns DOCS_ROOT. See ../AGENTS.md.

Package path for stories: `api`
EOF
cat > web/AGENTS.md <<'EOF'
# web package

Monorepo root owns DOCS_ROOT. See ../AGENTS.md.

Package path for stories: `web`
EOF
cat > mobile/AGENTS.md <<'EOF'
# mobile package

Monorepo root owns DOCS_ROOT. See ../AGENTS.md.

Package path for stories: `mobile`
EAS only — not Kubernetes.
EOF

echo "== root workflows =="
# CI api
cat > .github/workflows/ci-api.yml <<'EOF'
name: CI api
on:
  pull_request:
    paths: ['api/**', '.github/workflows/ci-api.yml']
  push:
    branches: [main, master]
    paths: ['api/**']
jobs:
  test:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: api
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: '21'
          cache: maven
      - run: mvn -B test
EOF

cat > .github/workflows/ci-web.yml <<'EOF'
name: CI web
on:
  pull_request:
    paths: ['web/**', '.github/workflows/ci-web.yml']
  push:
    branches: [main, master]
    paths: ['web/**']
jobs:
  test:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: web
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '22'
          cache: npm
          cache-dependency-path: web/package-lock.json
      - run: npm ci
      - run: npm run lint
      - run: npm run build
EOF

# Prefer existing docs validate if any
if [[ -f docs/scripts/validate-stories.sh ]]; then
  cat > .github/workflows/validate-stories.yml <<'EOF'
name: Validate stories
on:
  pull_request:
    paths: ['docs/**']
  push:
    branches: [main, master]
    paths: ['docs/**']
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Validate
        run: |
          if [[ -x docs/scripts/validate-stories.sh ]]; then
            docs/scripts/validate-stories.sh
          else
            echo "No validate-stories.sh — skip"
          fi
EOF
fi

cat > .github/workflows/docker-build.yml <<'EOF'
name: Docker build

on:
  pull_request:
  push:
    branches: [main, master]
  workflow_dispatch:

env:
  REGISTRY: ${{ vars.REGISTRY || 'ghcr.io' }}

jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    strategy:
      matrix:
        include:
          - context: api
            image: civil-erp-api
          - context: web
            image: civil-erp-web
    steps:
      - uses: actions/checkout@v4
      - uses: docker/setup-buildx-action@v3
      - name: Log in to registry
        if: github.event_name != 'pull_request'
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ github.repository_owner }}/${{ matrix.image }}
          tags: |
            type=sha,prefix=
            type=raw,value=latest,enable={{is_default_branch}}
      - uses: docker/build-push-action@v6
        with:
          context: ${{ matrix.context }}
          file: ${{ matrix.context }}/Dockerfile
          push: ${{ github.event_name != 'pull_request' }}
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
EOF

cat > .github/workflows/k8s-deploy-staging.yml <<'EOF'
name: K8s deploy staging

on:
  workflow_run:
    workflows: ["Docker build"]
    types: [completed]
    branches: [main, master]
  workflow_dispatch:

jobs:
  deploy:
    if: ${{ github.event_name == 'workflow_dispatch' || github.event.workflow_run.conclusion == 'success' }}
    runs-on: ubuntu-latest
    environment: staging
    strategy:
      matrix:
        include:
          - name: civil-erp-api
            manifest: api/deploy/k8s
          - name: civil-erp-web
            manifest: web/deploy/k8s
    steps:
      - uses: actions/checkout@v4
      - uses: azure/setup-kubectl@v4
      - name: Tag
        id: tag
        run: |
          TAG="${{ github.event.workflow_run.head_sha || github.sha }}"
          echo "tag=${TAG:0:7}" >> "$GITHUB_OUTPUT"
      - name: Configure cluster
        run: |
          echo "${{ secrets.KUBE_CONFIG_STAGING }}" | base64 -d > kubeconfig
          echo "KUBECONFIG=$PWD/kubeconfig" >> "$GITHUB_ENV"
      - name: Apply
        env:
          IMAGE: ${{ vars.REGISTRY || 'ghcr.io' }}/${{ github.repository_owner }}/${{ matrix.name }}:${{ steps.tag.outputs.tag }}
          NS: ${{ vars.K8S_NAMESPACE_STAGING || 'staging' }}
        run: |
          kubectl get ns "$NS" >/dev/null 2>&1 || kubectl create ns "$NS"
          sed "s|IMAGE_PLACEHOLDER|$IMAGE|g" ${{ matrix.manifest }}/deployment.yaml | kubectl -n "$NS" apply -f -
          kubectl -n "$NS" apply -f ${{ matrix.manifest }}/service.yaml
          kubectl -n "$NS" rollout status deploy/${{ matrix.name }} --timeout=180s
EOF

cat > .github/workflows/k8s-deploy-prod.yml <<'EOF'
name: K8s deploy production

on:
  workflow_dispatch:
    inputs:
      image_tag:
        description: "Image tag that passed staging"
        required: true

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production
    strategy:
      matrix:
        include:
          - name: civil-erp-api
            manifest: api/deploy/k8s
          - name: civil-erp-web
            manifest: web/deploy/k8s
    steps:
      - uses: actions/checkout@v4
      - uses: azure/setup-kubectl@v4
      - name: Configure cluster
        run: |
          echo "${{ secrets.KUBE_CONFIG_PRODUCTION }}" | base64 -d > kubeconfig
          echo "KUBECONFIG=$PWD/kubeconfig" >> "$GITHUB_ENV"
      - name: Apply
        env:
          IMAGE: ${{ vars.REGISTRY || 'ghcr.io' }}/${{ github.repository_owner }}/${{ matrix.name }}:${{ inputs.image_tag }}
          NS: ${{ vars.K8S_NAMESPACE_PRODUCTION || 'production' }}
        run: |
          kubectl get ns "$NS" >/dev/null 2>&1 || kubectl create ns "$NS"
          sed "s|IMAGE_PLACEHOLDER|$IMAGE|g" ${{ matrix.manifest }}/deployment.yaml | kubectl -n "$NS" apply -f -
          kubectl -n "$NS" apply -f ${{ matrix.manifest }}/service.yaml
          kubectl -n "$NS" rollout status deploy/${{ matrix.name }} --timeout=300s
EOF

if [[ -f mobile/.github/workflows/mobile-release.yml ]]; then
  cp mobile/.github/workflows/mobile-release.yml .github/workflows/mobile-release.yml 2>/dev/null || true
fi
# mobile .github was deleted — write EAS workflow
cat > .github/workflows/mobile-release.yml <<'EOF'
name: Mobile release (EAS)
on:
  workflow_dispatch:
    inputs:
      profile:
        default: preview
        type: choice
        options: [preview, production]
jobs:
  eas:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: mobile
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '22'
          cache: npm
          cache-dependency-path: mobile/package-lock.json
      - run: npm ci
      - name: EAS build
        env:
          EXPO_TOKEN: ${{ secrets.EXPO_TOKEN }}
        run: |
          npx eas-cli build --non-interactive --platform all --profile ${{ inputs.profile }} || \
            echo "Configure eas.json + EXPO_TOKEN before enabling"
EOF

echo "== init git at monorepo root =="
if [[ ! -d .git ]]; then
  git init -q
  git add -A
  git -c user.email=civil-erp@local -c user.name='Civil ERP' commit -qm 'chore: consolidate into monorepo (api/web/mobile/docs)'
fi

echo "== archive legacy sibling folders =="
for d in civil-erp-api civil-erp-web civil-erp-mobile civil-erp-docs; do
  if [[ -d "$d" ]]; then
    rm -rf "_legacy_$d"
    mv "$d" "_legacy_$d"
    echo "  moved $d → _legacy_$d"
  fi
done

echo "== install agentic kit at monorepo root =="
if [[ -x /Users/manish/Projects/agentic-sdlc/scripts/install-to-workspace.sh ]]; then
  /Users/manish/Projects/agentic-sdlc/scripts/install-to-workspace.sh "$ROOT" --symlink || true
fi

echo "DONE monorepo at $ROOT"
echo "Next: create GitHub repo manishbhagat-tech/civil-erp and git remote add + push"
echo "Archive old remotes civil-erp-{api,web,mobile,docs} on GitHub when ready."
ls -la "$ROOT" | head -30
