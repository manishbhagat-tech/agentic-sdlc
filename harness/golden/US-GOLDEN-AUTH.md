---
id: US-GOLDEN-AUTH
project: fixture
title: Golden auth pack test
status: ready
revision: 1
security: elevated
budget:
  max_context_tokens: 8000
  max_files_read: 6
  max_file_lines: 80
must_read:
  - delivery/epics/PLATFORM/features/FEAT-AUTH/PRD.md
repos:
  - path: mini-repo
    allow: ["src/Auth.java"]
tests:
  - repo: mini-repo
    cmd: "test -f src/Auth.java"
feedback: []
---

# US-GOLDEN-AUTH

## Acceptance criteria

1. Packer includes story + parent PRD + Auth outline.
