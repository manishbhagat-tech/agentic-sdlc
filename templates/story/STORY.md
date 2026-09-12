---
id: US-MODULE-000
project: your-project
title: Short title
status: draft
revision: 1
security: standard
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
    outline_only: []
tests:
  - repo: your-api
    cmd: echo "define tests"
feedback: []
---

# US-MODULE-000 — Title

## User story

As a …, I want …, so that ….

## Acceptance criteria

1. Given … when … then …
2. …

## Definition of done

- [ ] AC met
- [ ] Tests green
- [ ] `story-review` passed (security + lean)
- [ ] `story-cleanup` run
- [ ] PR cites this id

## Notes

(minimal)
