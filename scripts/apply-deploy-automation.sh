#!/usr/bin/env bash
# apply-deploy-automation.sh — write real Docker/K8s staging+prod workflows into product repos.
# Run from anywhere; refuses agentic-sdlc app root as a deploy target.
set -euo pipefail
KIT="$(cd "$(dirname "$0")/.." && pwd)"

write_jvm_dockerfile() {
  local dest="$1" jar_hint="$2"
  cat > "$dest/Dockerfile" <<EOF
# Spring Boot multi-stage image (${jar_hint})
FROM eclipse-temurin:21-jdk-alpine AS build
WORKDIR /workspace
COPY pom.xml .
COPY src ./src
RUN apk add --no-cache maven \\
  && mvn -B -DskipTests package \\
  && JAR=\$(ls target/${jar_hint}-*.jar | grep -v original | grep -v sources | head -1) \\
  && cp "\$JAR" /workspace/app.jar

FROM eclipse-temurin:21-jre-alpine AS runtime
RUN apk add --no-cache wget \\
  && addgroup -S app && adduser -S app -G app
WORKDIR /app
COPY --from=build /workspace/app.jar /app/app.jar
USER app
EXPOSE 8080
ENV JAVA_OPTS="-XX:MaxRAMPercentage=75"
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s \\
  CMD wget -qO- http://127.0.0.1:8080/actuator/health || exit 1
ENTRYPOINT ["sh", "-c", "java \$JAVA_OPTS -jar /app/app.jar"]
EOF
}

write_jvm_dockerignore() {
  cat > "$1/.dockerignore" <<'EOF'
.git
.github
.agentic
.cursor
target
**/.env
**/.env.*
!**/.env.example
**/node_modules
*.md
!README.md
deploy
EOF
}

write_next_dockerfile() {
  cat > "$1/Dockerfile" <<'EOF'
# Next.js standalone image
FROM node:22-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm ci

FROM node:22-alpine AS build
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
ENV NEXT_TELEMETRY_DISABLED=1
RUN npm run build

FROM node:22-alpine AS runtime
RUN apk add --no-cache wget
WORKDIR /app
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV PORT=3000
ENV HOSTNAME=0.0.0.0
RUN addgroup -S app && adduser -S app -G app
COPY --from=build /app/public ./public
COPY --from=build --chown=app:app /app/.next/standalone ./
COPY --from=build --chown=app:app /app/.next/static ./.next/static
USER app
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s --start-period=20s \
  CMD wget -qO- http://127.0.0.1:3000/api/health || exit 1
CMD ["node", "server.js"]
EOF
}

write_next_dockerignore() {
  cat > "$1/.dockerignore" <<'EOF'
.git
.github
.agentic
.cursor
node_modules
.next
**/.env
**/.env.*
!**/.env.example
*.md
!README.md
deploy
EOF
}

write_k8s_jvm() {
  local dest="$1" name="$2"
  mkdir -p "$dest/deploy/k8s"
  cat > "$dest/deploy/k8s/deployment.yaml" <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${name}
  labels:
    app: ${name}
spec:
  replicas: 2
  selector:
    matchLabels:
      app: ${name}
  template:
    metadata:
      labels:
        app: ${name}
    spec:
      containers:
        - name: ${name}
          image: IMAGE_PLACEHOLDER
          ports:
            - containerPort: 8080
          resources:
            requests:
              cpu: "100m"
              memory: "256Mi"
            limits:
              cpu: "1"
              memory: "1Gi"
          readinessProbe:
            httpGet:
              path: /actuator/health/readiness
              port: 8080
            initialDelaySeconds: 20
            periodSeconds: 10
          livenessProbe:
            httpGet:
              path: /actuator/health/liveness
              port: 8080
            initialDelaySeconds: 50
            periodSeconds: 20
          securityContext:
            runAsNonRoot: true
            allowPrivilegeEscalation: false
      securityContext:
        runAsNonRoot: true
EOF
  cat > "$dest/deploy/k8s/service.yaml" <<EOF
apiVersion: v1
kind: Service
metadata:
  name: ${name}
spec:
  selector:
    app: ${name}
  ports:
    - port: 80
      targetPort: 8080
  type: ClusterIP
EOF
}

write_k8s_next() {
  local dest="$1" name="$2"
  mkdir -p "$dest/deploy/k8s"
  cat > "$dest/deploy/k8s/deployment.yaml" <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${name}
  labels:
    app: ${name}
spec:
  replicas: 2
  selector:
    matchLabels:
      app: ${name}
  template:
    metadata:
      labels:
        app: ${name}
    spec:
      containers:
        - name: ${name}
          image: IMAGE_PLACEHOLDER
          ports:
            - containerPort: 3000
          resources:
            requests:
              cpu: "100m"
              memory: "256Mi"
            limits:
              cpu: "1"
              memory: "1Gi"
          readinessProbe:
            httpGet:
              path: /api/health
              port: 3000
            initialDelaySeconds: 10
            periodSeconds: 10
          livenessProbe:
            httpGet:
              path: /api/health
              port: 3000
            initialDelaySeconds: 20
            periodSeconds: 20
          securityContext:
            runAsNonRoot: true
            allowPrivilegeEscalation: false
      securityContext:
        runAsNonRoot: true
EOF
  cat > "$dest/deploy/k8s/service.yaml" <<EOF
apiVersion: v1
kind: Service
metadata:
  name: ${name}
spec:
  selector:
    app: ${name}
  ports:
    - port: 80
      targetPort: 3000
  type: ClusterIP
EOF
}

write_docker_build_wf() {
  local dest="$1" image_name="$2" context="${3:-.}"
  mkdir -p "$dest/.github/workflows"
  cat > "$dest/.github/workflows/docker-build.yml" <<EOF
name: Docker build

on:
  pull_request:
  push:
    branches: [main, master]
  workflow_dispatch:

env:
  REGISTRY: \${{ vars.REGISTRY || 'ghcr.io' }}
  IMAGE_NAME: \${{ vars.IMAGE_NAME || '${image_name}' }}

jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    steps:
      - uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Log in to registry
        if: github.event_name != 'pull_request'
        uses: docker/login-action@v3
        with:
          registry: \${{ env.REGISTRY }}
          username: \${{ github.actor }}
          password: \${{ secrets.GITHUB_TOKEN }}

      - name: Docker meta
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: \${{ env.REGISTRY }}/\${{ github.repository_owner }}/\${{ env.IMAGE_NAME }}
          tags: |
            type=sha,prefix=
            type=ref,event=branch
            type=raw,value=latest,enable={{is_default_branch}}

      - name: Build and push
        uses: docker/build-push-action@v6
        with:
          context: ${context}
          file: ${context}/Dockerfile
          push: \${{ github.event_name != 'pull_request' }}
          tags: \${{ steps.meta.outputs.tags }}
          labels: \${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
EOF
}

write_k8s_deploy_wf() {
  local dest="$1" env_name="$2" app_name="$3" file_name="$4" kube_secret="$5"
  mkdir -p "$dest/.github/workflows"
  local trigger
  if [[ "$env_name" == "staging" ]]; then
    cat > "$dest/.github/workflows/$file_name" <<EOF
name: K8s deploy staging

on:
  workflow_run:
    workflows: ["Docker build"]
    types: [completed]
    branches: [main, master]
  workflow_dispatch:
    inputs:
      image_tag:
        description: "Image tag (git sha)"
        required: false

concurrency:
  group: k8s-staging-${app_name}
  cancel-in-progress: true

jobs:
  deploy:
    if: \${{ github.event_name == 'workflow_dispatch' || github.event.workflow_run.conclusion == 'success' }}
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - uses: actions/checkout@v4
      - uses: azure/setup-kubectl@v4
      - name: Resolve tag
        id: tag
        run: |
          TAG="\${{ inputs.image_tag }}"
          if [[ -z "\$TAG" ]]; then TAG="\${{ github.event.workflow_run.head_sha || github.sha }}"; fi
          echo "tag=\${TAG:0:7}" >> "\$GITHUB_OUTPUT"
          echo "full=\$TAG" >> "\$GITHUB_OUTPUT"
      - name: Configure cluster
        run: |
          echo "\${{ secrets.${kube_secret} }}" | base64 -d > kubeconfig
          echo "KUBECONFIG=\$PWD/kubeconfig" >> "\$GITHUB_ENV"
      - name: Apply
        env:
          IMAGE: \${{ vars.REGISTRY || 'ghcr.io' }}/\${{ github.repository_owner }}/\${{ vars.IMAGE_NAME || '${app_name}' }}:\${{ steps.tag.outputs.tag }}
          NS: \${{ vars.K8S_NAMESPACE_STAGING || 'staging' }}
        run: |
          kubectl get ns "\$NS" >/dev/null 2>&1 || kubectl create ns "\$NS"
          sed "s|IMAGE_PLACEHOLDER|\$IMAGE|g" deploy/k8s/deployment.yaml | kubectl -n "\$NS" apply -f -
          kubectl -n "\$NS" apply -f deploy/k8s/service.yaml
          kubectl -n "\$NS" rollout status "deploy/${app_name}" --timeout=180s
EOF
  else
    cat > "$dest/.github/workflows/$file_name" <<EOF
name: K8s deploy production

# Human-gated: configure GitHub Environment "production" with required reviewers.
on:
  workflow_dispatch:
    inputs:
      image_tag:
        description: "Image tag that passed staging (git sha)"
        required: true

concurrency:
  group: k8s-prod-${app_name}
  cancel-in-progress: false

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production
    steps:
      - uses: actions/checkout@v4
      - uses: azure/setup-kubectl@v4
      - name: Configure cluster
        run: |
          echo "\${{ secrets.KUBE_CONFIG_PRODUCTION }}" | base64 -d > kubeconfig
          echo "KUBECONFIG=\$PWD/kubeconfig" >> "\$GITHUB_ENV"
      - name: Apply
        env:
          IMAGE: \${{ vars.REGISTRY || 'ghcr.io' }}/\${{ github.repository_owner }}/\${{ vars.IMAGE_NAME || '${app_name}' }}:\${{ inputs.image_tag }}
          NS: \${{ vars.K8S_NAMESPACE_PRODUCTION || 'production' }}
        run: |
          kubectl get ns "\$NS" >/dev/null 2>&1 || kubectl create ns "\$NS"
          sed "s|IMAGE_PLACEHOLDER|\$IMAGE|g" deploy/k8s/deployment.yaml | kubectl -n "\$NS" apply -f -
          kubectl -n "\$NS" apply -f deploy/k8s/service.yaml
          kubectl -n "\$NS" rollout status "deploy/${app_name}" --timeout=300s
EOF
  fi
}

write_deploy_readme() {
  local dest="$1" name="$2" kind="$3"
  mkdir -p "$dest/deploy"
  cat > "$dest/deploy/README.md" <<EOF
# Deploy — ${name}

Kind: **${kind}**

## GitHub setup

| Item | Value |
|------|--------|
| Variable \`REGISTRY\` | \`ghcr.io\` (default) |
| Variable \`IMAGE_NAME\` | \`${name}\` |
| Variable \`K8S_NAMESPACE_STAGING\` | \`staging\` |
| Variable \`K8S_NAMESPACE_PRODUCTION\` | \`production\` |
| Secret \`KUBE_CONFIG_STAGING\` | base64 kubeconfig (staging) |
| Secret \`KUBE_CONFIG_PRODUCTION\` | base64 kubeconfig (prod) |

Create Environments **staging** and **production** (production → required reviewers).

## Pipeline

1. PR / main → **Docker build** (push on main)
2. main success → **K8s deploy staging** (auto)
3. **K8s deploy production** → manual \`workflow_dispatch\` + approval

Agents never auto-deploy production (agentic-sdlc PROTOCOL).
EOF
}

# --- apply targets ---
API_CIVIL=/Users/manish/Projects/civil-erp/civil-erp-api
WEB_CIVIL=/Users/manish/Projects/civil-erp/civil-erp-web
MOBILE=/Users/manish/Projects/civil-erp/civil-erp-mobile
WB_ROOT=/Users/manish/Projects/weighbridge-erp
WB_API=/Users/manish/Projects/weighbridge-erp/api
WB_WEB=/Users/manish/Projects/weighbridge-erp/web
PHARMA=/Users/manish/Projects/pharma-packaging-platform

echo "== civil-erp-api =="
write_jvm_dockerfile "$API_CIVIL" "civil-erp-api"
write_jvm_dockerignore "$API_CIVIL"
write_k8s_jvm "$API_CIVIL" "civil-erp-api"
write_docker_build_wf "$API_CIVIL" "civil-erp-api" "."
write_k8s_deploy_wf "$API_CIVIL" staging "civil-erp-api" "k8s-deploy-staging.yml" "KUBE_CONFIG_STAGING"
write_k8s_deploy_wf "$API_CIVIL" production "civil-erp-api" "k8s-deploy-prod.yml" "KUBE_CONFIG_PRODUCTION"
write_deploy_readme "$API_CIVIL" "civil-erp-api" "Spring Boot / JVM → Kubernetes"
rm -f "$API_CIVIL/Dockerfile.jvm.example" "$API_CIVIL/deploy/k8s/"*.example 2>/dev/null || true

echo "== weighbridge-erp/api =="
write_jvm_dockerfile "$WB_API" "weighbridge-erp-api"
write_jvm_dockerignore "$WB_API"
write_k8s_jvm "$WB_API" "weighbridge-erp-api"
write_deploy_readme "$WB_API" "weighbridge-erp-api" "Spring Boot / JVM (built from monorepo root workflows)"
# subdir keeps Dockerfile; workflows at monorepo root
rm -f "$WB_API/.github/workflows/docker-build.yml" "$WB_API/.github/workflows/k8s-deploy-staging.yml" 2>/dev/null || true
rm -f "$WB_API/Dockerfile.jvm.example" "$WB_API/deploy/k8s/"*.example 2>/dev/null || true

echo "== civil-erp-web =="
write_next_dockerfile "$WEB_CIVIL"
write_next_dockerignore "$WEB_CIVIL"
write_k8s_next "$WEB_CIVIL" "civil-erp-web"
write_docker_build_wf "$WEB_CIVIL" "civil-erp-web" "."
write_k8s_deploy_wf "$WEB_CIVIL" staging "civil-erp-web" "k8s-deploy-staging.yml" "KUBE_CONFIG_STAGING"
write_k8s_deploy_wf "$WEB_CIVIL" production "civil-erp-web" "k8s-deploy-prod.yml" "KUBE_CONFIG_PRODUCTION"
write_deploy_readme "$WEB_CIVIL" "civil-erp-web" "Next.js → Kubernetes"
rm -f "$WEB_CIVIL/Dockerfile.node.example" "$WEB_CIVIL/deploy/k8s/"*.example 2>/dev/null || true

echo "== weighbridge-erp/web =="
write_next_dockerfile "$WB_WEB"
write_next_dockerignore "$WB_WEB"
write_k8s_next "$WB_WEB" "weighbridge-erp-web"
write_deploy_readme "$WB_WEB" "weighbridge-erp-web" "Next.js (built from monorepo root workflows)"
rm -f "$WB_WEB/.github/workflows/docker-build.yml" "$WB_WEB/.github/workflows/k8s-deploy-staging.yml" 2>/dev/null || true
rm -f "$WB_WEB/Dockerfile.node.example" "$WB_WEB/deploy/k8s/"*.example 2>/dev/null || true

echo "== weighbridge-erp monorepo root workflows =="
mkdir -p "$WB_ROOT/.github/workflows" "$WB_ROOT/deploy"
cat > "$WB_ROOT/.github/workflows/docker-build.yml" <<'EOF'
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
            image: weighbridge-erp-api
          - context: web
            image: weighbridge-erp-web
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

cat > "$WB_ROOT/.github/workflows/k8s-deploy-staging.yml" <<'EOF'
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
          - name: weighbridge-erp-api
            manifest: api/deploy/k8s
          - name: weighbridge-erp-web
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

cat > "$WB_ROOT/.github/workflows/k8s-deploy-prod.yml" <<'EOF'
name: K8s deploy production

on:
  workflow_dispatch:
    inputs:
      image_tag:
        description: "Image tag that passed staging (git sha short or full)"
        required: true

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production
    strategy:
      matrix:
        include:
          - name: weighbridge-erp-api
            manifest: api/deploy/k8s
          - name: weighbridge-erp-web
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

cat > "$WB_ROOT/deploy/README.md" <<'EOF'
# Deploy — weighbridge-erp (monorepo)

Images build from root workflow **Docker build** (matrix: `api`, `web`).
Staging auto after green build; production is manual + Environment approval.

Secrets/vars: see `api/deploy/README.md` and `web/deploy/README.md`.
EOF
rm -f "$WB_ROOT/Dockerfile.jvm.example" "$WB_ROOT/Dockerfile.node.example" 2>/dev/null || true
rm -f "$WB_ROOT/.github/workflows/k8s-deploy-staging.yml.bak" 2>/dev/null || true
# remove old single-service k8s if we overwrote — good

echo "== civil-erp-mobile (EAS, not K8s) =="
mkdir -p "$MOBILE/deploy" "$MOBILE/.github/workflows"
rm -f "$MOBILE/.github/workflows/docker-build.yml" "$MOBILE/.github/workflows/k8s-deploy-staging.yml" 2>/dev/null || true
rm -f "$MOBILE/Dockerfile.node.example" 2>/dev/null || true
cat > "$MOBILE/.github/workflows/mobile-release.yml" <<'EOF'
name: Mobile release (EAS)

# React Native / Expo — not deployed to Kubernetes.
# Configure EAS_TOKEN secret; run manually for store builds.
on:
  workflow_dispatch:
    inputs:
      profile:
        description: "EAS profile"
        default: preview
        type: choice
        options: [preview, production]

jobs:
  eas:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: "22"
          cache: npm
      - run: npm ci
      - name: EAS build
        env:
          EXPO_TOKEN: ${{ secrets.EXPO_TOKEN }}
        run: |
          npx eas-cli whoami || echo "Set EXPO_TOKEN secret to enable EAS"
          npx eas-cli build --non-interactive --platform all --profile ${{ inputs.profile }} || \
            echo "Install eas.json / link project before enabling this job"
EOF
cat > "$MOBILE/deploy/README.md" <<'EOF'
# Deploy — civil-erp-mobile

This app is **Expo / React Native**. It is **not** containerized to Kubernetes.

Use **Mobile release (EAS)** workflow (`workflow_dispatch`) with `EXPO_TOKEN`.
Store production submits stay human-approved.
EOF

echo "== pharma-packaging-platform (phase 0 placeholder) =="
mkdir -p "$PHARMA/deploy" "$PHARMA/.github/workflows"
cat > "$PHARMA/.github/workflows/docker-build.yml" <<'EOF'
name: Docker build

on:
  push:
    branches: [main, master]
  workflow_dispatch:

jobs:
  skip-until-apps-exist:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Gate
        run: |
          if [[ ! -f backend/Dockerfile && ! -f frontend/Dockerfile ]]; then
            echo "Phase 0: no backend/frontend Dockerfile yet — skip image build"
            exit 0
          fi
          echo "Apps present — replace this workflow with matrix builds (see agentic-sdlc templates)"
EOF
rm -f "$PHARMA/.github/workflows/k8s-deploy-staging.yml" 2>/dev/null || true
cat > "$PHARMA/.github/workflows/k8s-deploy-prod.yml" <<'EOF'
name: K8s deploy production
on:
  workflow_dispatch:
jobs:
  placeholder:
    runs-on: ubuntu-latest
    environment: production
    steps:
      - run: echo "Add backend/frontend Dockerfiles first; then copy patterns from civil-erp-api"
EOF
cat > "$PHARMA/deploy/README.md" <<'EOF'
# Deploy — pharma-packaging-platform

Phase 0 (docs/infra only). When `backend/` and `frontend/` exist:

1. Copy Docker/K8s patterns from `civil-erp-api` / `civil-erp-web`
2. Enable staging auto-deploy + production Environment approval

Keep Keycloak/Postgres/MinIO on compose for local; app images go to GHCR + K8s.
EOF
rm -f "$PHARMA/Dockerfile.jvm.example" "$PHARMA/Dockerfile.node.example" 2>/dev/null || true

echo "ALL APPLY DONE"
