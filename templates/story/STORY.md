---
id: US-MODULE-000
project: your-project
title: Short title
status: draft
revision: 1
security: standard
channels: [api, web, mobile]
# Design-time SoT — feature-stories writes this; runtime loads only these wrappers
# (intersected with WRAPPER-MAP phase). Every entry must exist under skills/<ns>/<name>/.
skills:
  - addy/context-engineering
  - addy/incremental-implementation
  - addy/test-driven-development
  - addy/security-and-hardening
  - addy/code-review-and-quality
  - addy/code-simplification
  # stack examples (gate by stacks: + channels):
  # - sivalabs/spring-boot
  # - vercel/react-best-practices
  # - ui-skills/baseline-ui
blocked_by: []
supersedes: null
superseded_by: null
external_id: null
budget:
  max_context_tokens: 12000
  max_files_read: 12
  max_file_lines: 200
must_read: []
repos:
  - path: your-api
    allow: []
  - path: your-web
    allow: []
  - path: your-mobile
    allow: []
tests:
  - repo: your-api
    cmd: echo "api tests"
  - repo: your-web
    cmd: echo "web build/test"
  - repo: your-mobile
    cmd: echo "mobile test"
feedback: []
---

# US-MODULE-000 — Title

## User story

As a …, I want …, so that ….

## Acceptance criteria

1. Given … when … then … (API)
2. … (Web UI)
3. … (Mobile UI)
4. …

## Definition of done

- [ ] API done
- [ ] Web UI done (design tokens only)
- [ ] Mobile UI done (theme tokens only)
- [ ] Architect: LLD (+UI if web/mobile) referenced; reuse map followed
- [ ] Tests green (`tests[]`) via `story-test`
- [ ] Security: `story-security` + ledger notes; checklist passed
- [ ] UI: `ui-review` passed (or N/A for api-only)
- [ ] Vulnerability check noted
- [ ] `story-review` + `story-cleanup`
- [ ] PR cites this id; elevated → human merge

## Notes

Full-slice contract: see product `delivery/STORY-CONTRACT.md` when applicable.
Parents: feature PRD / HLD / LLD / UI under `DOCS_ROOT`.
