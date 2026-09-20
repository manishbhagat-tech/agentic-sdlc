#!/usr/bin/env bash
# security-check.sh — secrets on git diff; optional gitleaks; dependency audit hints.
# Exit non-zero on obvious secrets / gitleaks findings.
# Env:
#   AGENTIC_SECURITY_STRICT=1  fail if npm lockfile present but npm missing, or gitleaks recommended
#   AGENTIC_SKIP_GITLEAKS=1    skip gitleaks even if installed
set -euo pipefail

ROOT="${WORKSPACE_ROOT:-$(pwd)}"
cd "$ROOT"

FAIL=0
WARN=0

DIFF=$(git diff --no-ext-diff HEAD 2>/dev/null || true)
if [[ -z "$DIFF" ]]; then
  DIFF=$(git diff --no-ext-diff --cached 2>/dev/null || true)
fi
if [[ -z "$DIFF" ]]; then
  DIFF=$(git diff --no-ext-diff 2>/dev/null || true)
fi

if [[ -z "$DIFF" ]]; then
  echo "WARN: no git diff to scan (clean tree?)"
  WARN=1
fi

SECRET_PATTERNS=(
  '-----BEGIN[[:space:]]+(RSA[[:space:]]+)?PRIVATE[[:space:]]+KEY-----'
  'AKIA[0-9A-Z]{16}'
  'ghp_[A-Za-z0-9]{20,}'
  'github_pat_[A-Za-z0-9_]{20,}'
  'xox[baprs]-[A-Za-z0-9-]{10,}'
  'sk_live_[A-Za-z0-9]{20,}'
  'sk-[A-Za-z0-9]{20,}'
  'api[_-]?key[[:space:]]*[:=][[:space:]]*['\''\"][^'\''\"]{12,}'
  'password[[:space:]]*[:=][[:space:]]*['\''\"][^'\''\"]{8,}'
  'SECRET[_A-Z0-9]*[[:space:]]*[:=][[:space:]]*['\''\"][^'\''\"]{8,}'
  'AWS_SECRET_ACCESS_KEY'
)

echo "== secret patterns on diff =="
for pat in "${SECRET_PATTERNS[@]}"; do
  if [[ -n "$DIFF" ]] && printf '%s' "$DIFF" | grep -Eiq -- "$pat"; then
    echo "FAIL: possible secret pattern matched: $pat"
    FAIL=1
  fi
done

if git status --porcelain 2>/dev/null | grep -Eiq '(\.env$|\.env\.|id_rsa|\.pem$|credentials\.json)'; then
  echo "FAIL: sensitive-looking path in working tree status"
  FAIL=1
fi

echo "== gitleaks (optional) =="
if [[ "${AGENTIC_SKIP_GITLEAKS:-0}" == "1" ]]; then
  echo "NOTE: gitleaks skipped (AGENTIC_SKIP_GITLEAKS=1)"
elif command -v gitleaks >/dev/null 2>&1; then
  # Prefer scanning git history window; fall back to dir scan
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    if ! gitleaks detect --no-banner --source . --log-opts="-n 20" -v; then
      echo "FAIL: gitleaks reported findings"
      FAIL=1
    else
      echo "OK gitleaks"
    fi
  else
    echo "WARN: not a git repo — skip gitleaks"
    WARN=1
  fi
else
  echo "WARN: gitleaks not installed (recommend in CI)"
  WARN=1
  if [[ "${AGENTIC_SECURITY_STRICT:-0}" == "1" ]]; then
    echo "FAIL: AGENTIC_SECURITY_STRICT=1 requires gitleaks"
    FAIL=1
  fi
fi

echo "== dependency audit =="
if [[ -f package-lock.json || -f pnpm-lock.yaml || -f yarn.lock ]]; then
  if command -v npm >/dev/null 2>&1 && [[ -f package-lock.json || -f package.json ]]; then
    echo "NOTE: running npm audit --audit-level=high (informational unless STRICT)"
    if ! npm audit --audit-level=high; then
      if [[ "${AGENTIC_SECURITY_STRICT:-0}" == "1" ]]; then
        echo "FAIL: npm audit high+ vulnerabilities"
        FAIL=1
      else
        echo "WARN: npm audit reported issues (set AGENTIC_SECURITY_STRICT=1 to fail)"
        WARN=1
      fi
    fi
  else
    echo "WARN: npm not found; cannot run npm audit"
    WARN=1
  fi
fi
if [[ -f pom.xml ]]; then
  echo "NOTE: run OWASP dependency-check / mvn in product CI (not auto-run here)"
fi

# Semgrep optional
if command -v semgrep >/dev/null 2>&1; then
  echo "== semgrep (optional) =="
  if [[ -n "${SEMGREP_RULES:-}" ]]; then
    if ! semgrep --error --config "$SEMGREP_RULES" .; then
      echo "FAIL: semgrep findings"
      FAIL=1
    fi
  else
    echo "NOTE: semgrep installed; set SEMGREP_RULES=p/ci or path to enable"
  fi
fi

if [[ $FAIL -ne 0 ]]; then
  echo "SECURITY-CHECK FAIL"
  exit 1
fi
echo "SECURITY-CHECK OK (warnings=$WARN)"
exit 0
