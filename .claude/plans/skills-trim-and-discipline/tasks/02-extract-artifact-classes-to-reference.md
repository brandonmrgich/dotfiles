# Task 02 — Extract artifact-classes detail to a reference

**Phase:** 1 (CLAUDE.md trims)
**Agent:** plan-executor-implementer
**Produces PR:** Yes

## Goal

Move the six-row artifact-class matrix, three-row purpose matrix, and
ASCII anchor-chain diagram out of CLAUDE.md into
`references/artifact-classes.md`. CLAUDE.md keeps a one-paragraph
introduction plus the six-line "where each lives" list and a pointer.

Targets ~3,314 bytes saved on every session.

## Context

The detailed class matrix is consulted when creating a new
artifact (essay, plan, doc, idea, mantra, memory) — not on every session.
The principle "don't conflate the classes" needs to ride in CLAUDE.md;
the field-by-field detail does not.

Source: essay #9 §"Hotspot 1" and §"P0.2 — Move artifact-class detail
to a reference".

## Files

**Affected:**
- `~/dotfiles/claude/.claude/CLAUDE.md`

**Created:**
- `~/dotfiles/claude/.claude/references/artifact-classes.md`

## Steps

1. Identify the section: from `## Artifact classes and front-matter` through
   the end of the `### Three front-matter *purposes* across these classes`
   subsection (just before the next `---`).
2. Create `references/artifact-classes.md` with:
   - Frontmatter: `title`, `description`, `static: true`.
   - Full extracted section body (six-class table, anchor chain ASCII,
     three-purposes table, pointer to `cross-claude-mantras-and-skills-integration.md`).
3. Replace the CLAUDE.md section with a 6–8 line stub:
   ```
   ## Artifact classes

   Six artifact classes share the YAML front-matter mechanism but answer
   different questions: **memory**, **mantra**, **idea**, **essay**,
   **plan**, **doc**. The anchor chain is `idea → essay → plan → doc → code`,
   with mantras informing it. Each class has its own minimal schema —
   don't add fields it doesn't need.

   Full table, anchor-chain diagram, and field-purpose breakdown:
   `~/.claude/references/artifact-classes.md`.
   See also `~/.claude/essays/cross-claude-mantras-and-skills-integration.md`
   for rationale.
   ```
4. Stow + verify.
5. Sweep all SKILL.md and reference files for `## Artifact classes`-shaped
   citations; if any pointed at the inline CLAUDE.md anchor, repoint at
   the reference.
6. Commit + PR.

## Acceptance criteria

- [ ] `references/artifact-classes.md` symlink exists with full content.
- [ ] CLAUDE.md keeps the principle paragraph + six-class line + pointer.
- [ ] No skill cross-reference is broken (grep for "artifact classes"
      across `~/.claude/`).
- [ ] PR description includes measured CLAUDE.md byte delta.

## Validation

- `wc -c` on CLAUDE.md drops by ~3,300 bytes.
- `~/.claude/references/cross-claude-mantras-and-skills-integration.md`
  pointer continues to resolve (it's still cited from the new reference).

## Commit / PR

- Commit message:
  ```
  refactor(claude): extract artifact-classes detail to references/

  Move the six-class table, anchor-chain ASCII, and three-purposes table
  out of CLAUDE.md. CLAUDE.md keeps the principle + classes list + pointer.
  Saves ~3.3k bytes from the always-loaded baseline.

  Refs: essay skill-system-token-efficiency-audit.md §P0.2

  Plan: skills-trim-and-discipline
  Task: 02
  ```
- PR target: `main`. Standard PR body.
