# Task 09 — YAML quoting sweep

**Phase:** 3 (Cleanup + closeout)
**Agent:** plan-executor-discovery
**Produces PR:** No

## Goal

Grep project-local skill directories (and any other skill dirs not already audited) for unquoted YAML descriptions containing colons. Fix any found.

Closes parent plan's Phase-8 follow-up #8.

## Context

Parent plan Task 17 fixed 6 specialist descriptions whose unquoted YAML strings contained colons (technically malformed). This task sweeps any project-local or other skill dirs for the same drift.

## Files

**Possibly affected:**
- Project-local `<repo>/.claude/skills/<name>/SKILL.md` (any tracked project)
- `~/.claude/skills/<name>/SKILL.md` if any drift slipped past parent plan

## Steps

1. Find all project-local skill directories on the local filesystem:
   ```bash
   find ~/Development -maxdepth 6 -type d -name "skills" 2>/dev/null | grep -v node_modules | grep -v ".git/"
   ```
2. For each found directory, walk its SKILL.md files and check the YAML frontmatter:
   - Parse with `python3 -c "import yaml; yaml.safe_load(open('PATH'))"`.
   - If parse fails AND the description field contains a colon AND the value isn't quoted → FIX (re-write description as a double-quoted string).
3. Also re-check `~/.claude/skills/*/SKILL.md` for any drift that slipped past Task 17.
4. Per-fix: edit the source file, re-run YAML parse, verify clean.
5. Write `audits/09-yaml-quoting-sweep.md`:
   - Directories scanned.
   - Files needing fix.
   - Files fixed.
   - Files clean (no fix needed).

## Acceptance criteria

- [ ] All discoverable skill directories scanned.
- [ ] Any malformed YAML descriptions fixed.
- [ ] Audit report written.

## Commit

If any fixes were made:
```
refactor(skill): YAML-quote unquoted descriptions across local skill dirs

Sweep per parent plan §"Phase-8 follow-ups #8". <N> files fixed:
<list>. <M> files were already clean.

Refs: parent plan skills-trim-and-discipline §"Phase-8 follow-ups #8"

Plan: skills-trim-followups
Task: 09
```

If no fixes:
- No commit; only the audit report.
