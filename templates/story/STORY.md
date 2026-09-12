---
id: US-MODULE-000
project: your-project
title: Short title
status: draft
revision: 1
security: standard
channels: [api, web, mobile]
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
- [ ] Tests green (`tests[]`)
- [ ] Security checklist passed
- [ ] Vulnerability check noted
- [ ] `story-review` + `story-cleanup`
- [ ] PR cites this id

## Notes

Full-slice contract: see product `delivery/STORY-CONTRACT.md` when applicable.
