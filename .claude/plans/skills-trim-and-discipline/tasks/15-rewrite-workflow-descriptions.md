# Task 15 — Rewrite workflow/discipline descriptions

**Phase:** 3 (Description format conventions)
**Agent:** plan-executor-implementer
**Produces PR:** Yes

## Goal

Rewrite the `description:` field of the 8 workflow/discipline skills per
the spec in `references/description-format.md`. Pull workflow narration
into the body where useful; descriptions become triggers-only.

## Context

Per essay #8 Appendix A, every workflow/discipline skill leads with a
workflow summary. They are the worst offenders: `plan-executor`,
`session-ready`, `top-down-sweep`, `doc-freshness`, `worktree-orchestrator`,
`zoom-in`, `zoom-out`, `plan-auditor`. Eight skills, one PR.

## Files

**Affected:** YAML frontmatter only (no body changes; body changes that
fall out of moving narration belong in this PR too if minimal).
- `~/dotfiles/claude/.claude/skills/plan-executor/SKILL.md`
- `~/dotfiles/claude/.claude/skills/plan-auditor/SKILL.md`
- `~/dotfiles/claude/.claude/skills/session-ready/SKILL.md`
- `~/dotfiles/claude/.claude/skills/top-down-sweep/SKILL.md`
- `~/dotfiles/claude/.claude/skills/doc-freshness/SKILL.md`
- `~/dotfiles/claude/.claude/skills/worktree-orchestrator/SKILL.md`
- `~/dotfiles/claude/.claude/skills/zoom-in/SKILL.md`
- `~/dotfiles/claude/.claude/skills/zoom-out/SKILL.md`

## Steps

For each skill:
1. Extract the current trigger phrases from the existing description
   (typically buried after the workflow summary).
2. Draft a new description following the spec: "Use when…" prefix,
   triggers-only, ≤1024 chars, no workflow narration.
3. If the description had genuinely useful narration that wasn't already
   in the body, move it to the body (top of file, after frontmatter).
4. Verify char count: `python3 -c "import yaml; print(len(yaml.safe_load(open('SKILL.md'))['description']))"` or similar.
5. Stow (no new files; just file content changed — symlinks already exist).
6. After all 8 done, commit as one PR.

## Acceptance criteria

- [ ] All 8 descriptions ≤1024 chars.
- [ ] All 8 start with "Use when…" or "Activates when…".
- [ ] Workflow narration removed from descriptions.
- [ ] Trigger phrases preserved (no activation regression).
- [ ] PR description shows before/after char counts per skill.

## Validation

- Open a fresh session and trigger each skill via its canonical trigger
  phrase. Each must still activate.
- Pressure test: type an *adjacent* phrase that should NOT trigger
  (e.g., "let me think about this" — should NOT trigger
  `essay`/`brainstorming`). Confirm no over-eager activation.

## Commit / PR

- Commit message:
  ```
  refactor(claude): rewrite workflow-skill descriptions to triggers-only

  Apply references/description-format.md to the 8 workflow/discipline
  skills (plan-executor, plan-auditor, session-ready, top-down-sweep,
  doc-freshness, worktree-orchestrator, zoom-in, zoom-out). Workflow
  summaries moved to body where retained.

  Per-skill before/after char counts in PR description.

  Refs: essays skill-system-vs-superpowers.md §Gap 7 / Appendix A and
        skill-system-token-efficiency-audit.md §Hotspot 4

  Plan: skills-trim-and-discipline
  Task: 15
  ```
- PR target: `main`.
