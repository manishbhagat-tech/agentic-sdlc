---
id: BUG-MODULE-000
story: US-MODULE-000
project: your-project
title: Short bug title
status: draft
revision: 1
severity: medium
security: standard
# Required at design time — same rules as US-*
skills:
  - addy/debugging-and-error-recovery
  - addy/context-engineering
  - addy/test-driven-development
  - addy/security-and-hardening
  - addy/code-review-and-quality
  - addy/code-simplification
external_id: null
budget:
  max_context_tokens: 8000
  max_files_read: 8
  max_file_lines: 200
must_read: []
repos:
  - path: your-api
    allow: []
tests:
  - repo: your-api
    cmd: echo "define failing or regression test"
repro: |
  Steps / logs...
feedback: []
---

# BUG-MODULE-000 — Title

## Linked story

`US-MODULE-000` (remains `done` unless supersede required)

## Expected vs actual

- Expected:
- Actual:

## Definition of done

- [ ] Repro fixed; regression test when possible
- [ ] Architect: change fits linked story LLD / allowlist
- [ ] `story-test` green
- [ ] `story-security` (+ ledger if finding)
- [ ] `ui-review` if web/mobile touched
- [ ] `story-review` + `story-cleanup`
- [ ] PR cites this id; elevated → human merge

## Fix notes

(agent fills after fix)
