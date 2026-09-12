---
id: BUG-MODULE-000
story: US-MODULE-000
project: your-project
title: Short bug title
status: draft
revision: 1
severity: medium
security: standard
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

## Fix notes

(agent fills after fix)
