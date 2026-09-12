---
id: US-GOLDEN-COMPANY
project: fixture
title: Golden company pack test
status: ready
revision: 1
security: standard
budget:
  max_context_tokens: 8000
  max_files_read: 6
  max_file_lines: 80
must_read:
  - delivery/epics/PLATFORM/features/FEAT-AUTH/PRD.md
repos:
  - path: mini-repo
    allow: ["src/Company.java"]
tests:
  - repo: mini-repo
    cmd: "test -f src/Company.java"
---

# US-GOLDEN-COMPANY

Minimal golden for harness.
