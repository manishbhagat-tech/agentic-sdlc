#!/usr/bin/env python3
"""Generate thin 1:1 wrappers under skills/<ns>/<name>/ for each vendored skill
and skills/addy-agents/<name>/ for each vendored Addy agents/*.md persona.

Run after every vendor bump so skills + agents stay covered.
"""
from __future__ import annotations

import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parents[1]

WRAPPER_TPL = """---
name: {ns}-{name}
description: >-
  Thin wrapper for vendored {ns}/{name}. Apply WRAPPER-ESSENTIALS first;
  then execute the full upstream skill. Our essentials win on conflict.
---

# {ns}/{name}

## Preconditions

- Invoked via an orchestrator or listed in story `skills:`.
- Do **not** open other vendor trees in this run unless also listed.

## Steps

1. Read and apply [`docs/WRAPPER-ESSENTIALS.md`](../../../docs/WRAPPER-ESSENTIALS.md) (pack, channels, ledger, git-safe, token-min).
2. Read and execute **in full** the vendored skill at:
   `{vendor_rel}`
3. If any upstream step conflicts with WRAPPER-ESSENTIALS (secrets, force-push, path allowlist, budgets, channels), **skip that step**, log override in the run log, continue.
4. On completion, return control to the calling orchestrator with outcome pass/fail.

## Refuse

- Loading this skill when story `skills:` / channels do not require it.
- Reading raw `vendor/` paths other than the file above for this skill.
"""

# Persona wrappers: regeneratable. Kit pairing lives in WRAPPER-MAP / orchestrators.
AGENT_TPL = """---
name: addy-agents-{name}
description: >-
  Thin persona wrapper for vendored Addy agent `{name}`. Apply WRAPPER-ESSENTIALS
  first; adopt perspective + output format from the vendor persona file.
---

# addy-agents/{name}

## Role

Persona overlay (**who** + output format). Procedure (**how**) stays in the paired
`skills/addy/*` skill listed by the calling orchestrator / WRAPPER-MAP.

## Preconditions

- Invoked via an orchestrator `personas:` entry (or listed in story `skills:`).
- Pack / diff context already loaded by the orchestrator when applicable.

## Steps

1. Read and apply [`docs/WRAPPER-ESSENTIALS.md`](../../../docs/WRAPPER-ESSENTIALS.md).
2. Read and adopt the vendored persona at:
   `{vendor_rel}`
3. Use the persona's framework, severity labels, and output template.
4. Stay inside pack allowlists / story scope — do not expand beyond the orchestrator brief.
5. On conflict with WRAPPER-ESSENTIALS (secrets, budgets, channels, git-safe, ledger), **essentials win**; log override.
{extra_steps}
## Refuse

- Reading raw `vendor/` paths other than the persona file above (plus any reference named here).
- Auto-merging `security: elevated` or force-push / auto-prod.
"""

# Optional kit-specific steps injected per known agent (preserved across regenerations).
AGENT_EXTRA: dict[str, str] = {
    "security-auditor": """
6. Optionally skim `vendor/addy-agent-skills/references/security-checklist.md` for gaps vs
   `skills/story-security/ATTACK-CLASSES.md` — do not dump the whole references tree.
7. Map Critical/High into `.agentic/security/` ledger / findings — not chat-only.
""",
    "code-reviewer": """
6. Map security-dimension hits to slim review checklist or defer deep work to `story-security`.
""",
    "web-performance-auditor": """
6. Default to **quick mode** (no fabricated metrics). Deep mode only with artifacts / allowlisted MCP.
7. Skip when story channels exclude `web` unless the orchestrator explicitly requires it.
""",
    "test-engineer": """
6. Prefer lowest useful test level; prove-it for bugs; stay inside story `tests[]` and allowlists.
""",
}

VENDORS = {
    "addy": ("vendor/addy-agent-skills/skills", True),
    "sivalabs": ("vendor/sivalabs-agent-skills/skills", True),
    "vercel": ("vendor/vercel-agent-skills/skills", True),
    "next": ("vendor/nextjs-skills/skills", True),
    "ui-skills": ("vendor/ui-skills", False),
}

ADDY_AGENTS_DIR = ROOT / "vendor" / "addy-agent-skills" / "agents"


def slug_from_agent_filename(path: pathlib.Path) -> str:
    return path.stem  # code-reviewer.md → code-reviewer


def generate_skill_wrappers() -> list[str]:
    generated: list[str] = []
    for ns, (rel, _nested) in VENDORS.items():
        base = ROOT / rel
        if not base.exists():
            print(f"skip missing {rel}")
            continue
        dirs = [p for p in sorted(base.iterdir()) if p.is_dir() and (p / "SKILL.md").exists()]
        for p in dirs:
            name = p.name
            out = ROOT / "skills" / ns / name
            out.mkdir(parents=True, exist_ok=True)
            vendor_rel = f"{rel}/{name}/SKILL.md"
            (out / "SKILL.md").write_text(
                WRAPPER_TPL.format(ns=ns, name=name, vendor_rel=vendor_rel),
                encoding="utf-8",
            )
            generated.append(f"{ns}/{name}")
    return generated


def generate_agent_wrappers() -> list[str]:
    generated: list[str] = []
    if not ADDY_AGENTS_DIR.is_dir():
        print("skip missing vendor/addy-agent-skills/agents")
        return generated
    for path in sorted(ADDY_AGENTS_DIR.glob("*.md")):
        if path.name.startswith("."):
            continue
        name = slug_from_agent_filename(path)
        out = ROOT / "skills" / "addy-agents" / name
        out.mkdir(parents=True, exist_ok=True)
        vendor_rel = f"vendor/addy-agent-skills/agents/{path.name}"
        extra = AGENT_EXTRA.get(name, "")
        if extra and not extra.endswith("\n"):
            extra += "\n"
        (out / "SKILL.md").write_text(
            AGENT_TPL.format(name=name, vendor_rel=vendor_rel, extra_steps=extra),
            encoding="utf-8",
        )
        generated.append(f"addy-agents/{name}")
    return generated


def main() -> None:
    skills = generate_skill_wrappers()
    agents = generate_agent_wrappers()
    print(f"Generated {len(skills)} skill wrappers + {len(agents)} agent persona wrappers")
    for g in skills + agents:
        print(g)


if __name__ == "__main__":
    main()
