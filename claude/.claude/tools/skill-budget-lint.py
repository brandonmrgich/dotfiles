#!/usr/bin/env python3
"""skill-budget-lint — measure SKILL.md description chars + body bytes
against per-class budgets.

WARN-only by default. Pass --fail (or set SKILL_BUDGET_LINT_FAIL=1) to
exit non-zero when any FAIL-level violation is detected.

Per-class budgets are defined inline below; class is read from each
SKILL.md frontmatter.

Refs: essay skill-system-token-efficiency-audit.md §P3.1
"""

from __future__ import annotations

import argparse
import os
import re
import sys
from pathlib import Path

# Per-class budgets: (description_chars, body_bytes, total_bytes)
BUDGETS = {
    "specialist":           (1024, 6000, 8000),
    "workflow":             ( 500, 4000, 5000),
    "complex-orchestrator": ( 500, 6500, 7500),
    "capture":              ( 500, 4000, 5000),
    "meta":                 ( 800, 5500, 6500),
    "ritual":               ( 700, 4000, 5000),
    "discipline":           ( 700, 4000, 5000),
    # "policy" removed at Task 12 (zero members; re-add when needed).
}

WARN_PCT = 0.10  # within +10% of budget = WARN; over that = FAIL.

SKILLS_DIR = Path(os.path.expanduser("~/.claude/skills"))


def split_frontmatter(text: str) -> tuple[str, str]:
    """Return (frontmatter, body). Both may be empty if no frontmatter."""
    if not text.startswith("---"):
        return "", text
    # Find closing --- on its own line.
    m = re.match(r"^---\s*\n(.*?)\n---\s*\n?(.*)$", text, re.DOTALL)
    if not m:
        return "", text
    return m.group(1), m.group(2)


def parse_frontmatter(fm: str) -> dict[str, str]:
    """Tiny YAML-ish parser sufficient for our flat frontmatter:
    `key: value` pairs, with optional single/double quoting on the value.
    Multi-line values are not supported (none of our SKILL.md uses them
    in a way that affects class/description; description is on one line)."""
    out: dict[str, str] = {}
    for line in fm.splitlines():
        line = line.rstrip()
        if not line or line.startswith("#"):
            continue
        m = re.match(r"^([A-Za-z_][A-Za-z0-9_-]*):\s*(.*)$", line)
        if not m:
            continue
        key, val = m.group(1), m.group(2).strip()
        # Strip a single layer of matching quotes if present.
        if len(val) >= 2 and val[0] == val[-1] and val[0] in ("'", '"'):
            val = val[1:-1]
        out[key] = val
    return out


def verdict_for(actual: int, budget: int) -> str:
    if actual <= budget:
        return "OK"
    if actual <= int(budget * (1 + WARN_PCT)):
        return "WARN"
    return "FAIL"


def worst(verdicts: list[str]) -> str:
    order = {"OK": 0, "WARN": 1, "FAIL": 2}
    return max(verdicts, key=lambda v: order[v])


def main() -> int:
    assert __doc__, "module docstring required"
    ap = argparse.ArgumentParser(description=(__doc__).splitlines()[0])
    ap.add_argument(
        "--fail",
        action="store_true",
        help="Exit non-zero when any FAIL-level violation is detected.",
    )
    args = ap.parse_args()

    fail_mode = args.fail or os.environ.get("SKILL_BUDGET_LINT_FAIL") == "1"

    if not SKILLS_DIR.is_dir():
        print(f"error: skills dir not found: {SKILLS_DIR}", file=sys.stderr)
        return 2

    rows: list[tuple[str, str, int, int, int, str]] = []
    counts = {"OK": 0, "WARN": 0, "FAIL": 0, "UNKNOWN": 0}

    for skill_md in sorted(SKILLS_DIR.glob("*/SKILL.md")):
        skill_name = skill_md.parent.name
        text = skill_md.read_text(encoding="utf-8")
        fm_text, body = split_frontmatter(text)
        fm = parse_frontmatter(fm_text)

        cls = fm.get("class", "")
        desc = fm.get("description", "")
        desc_chars = len(desc)
        body_bytes = len(body.encode("utf-8"))
        total_bytes = desc_chars + body_bytes  # approx: desc chars ~= bytes

        if cls not in BUDGETS:
            verdict = "UNKNOWN"
            counts["UNKNOWN"] += 1
            rows.append((skill_name, cls or "(none)", desc_chars,
                         body_bytes, total_bytes, verdict))
            continue

        d_b, b_b, t_b = BUDGETS[cls]
        v = worst([
            verdict_for(desc_chars, d_b),
            verdict_for(body_bytes, b_b),
            verdict_for(total_bytes, t_b),
        ])
        counts[v] += 1
        rows.append((skill_name, cls, desc_chars, body_bytes,
                     total_bytes, v))

    # Render table.
    name_w = max(len(r[0]) for r in rows) if rows else 4
    cls_w = max(len(r[1]) for r in rows) if rows else 5
    header = (f"{'skill':<{name_w}}  {'class':<{cls_w}}  "
              f"{'desc':>5}  {'body':>5}  {'total':>6}  verdict")
    print(header)
    print("-" * len(header))
    for name, cls, dc, bb, tb, v in rows:
        budget_hint = ""
        if cls in BUDGETS:
            d_b, b_b, t_b = BUDGETS[cls]
            tags = []
            if dc > d_b:
                tags.append(f"desc>{d_b}")
            if bb > b_b:
                tags.append(f"body>{b_b}")
            if tb > t_b:
                tags.append(f"total>{t_b}")
            if tags:
                budget_hint = "  [" + ", ".join(tags) + "]"
        print(f"{name:<{name_w}}  {cls:<{cls_w}}  "
              f"{dc:>5}  {bb:>5}  {tb:>6}  {v}{budget_hint}")

    print()
    print(f"summary: OK={counts['OK']}  WARN={counts['WARN']}  "
          f"FAIL={counts['FAIL']}  UNKNOWN={counts['UNKNOWN']}  "
          f"(total={sum(counts.values())})")

    if fail_mode and (counts["FAIL"] > 0 or counts["UNKNOWN"] > 0):
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
