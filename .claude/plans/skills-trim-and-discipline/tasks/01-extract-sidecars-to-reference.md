# Task 01 — Extract sidecar conventions to a reference

**Phase:** 1 (CLAUDE.md trims)
**Agent:** plan-executor-implementer
**Produces PR:** Yes

## Goal

Move the full sidecar-conventions section out of CLAUDE.md into a sibling
reference file. CLAUDE.md keeps a 5-line stub: name + one-line definition +
"see `references/sidecar-conventions.md`".

Targets ~4,533 bytes saved on every session (essay #9 Hotspot 1).

## Context

The sidecar taxonomy (label table, role table, when-to-create rules,
sidecar maxims) is consulted **only when creating or editing a sidecar**,
not on every session. It is reference-shaped content currently paying
always-loaded tax.

Source: essay #9 §"Hotspot 1 — CLAUDE.md (19k always-loaded)" and
§"P0.1 — Move sidecar conventions out of CLAUDE.md".

## Files

**Affected:**
- `~/dotfiles/claude/.claude/CLAUDE.md` (strip section, replace with stub)

**Created:**
- `~/dotfiles/claude/.claude/references/sidecar-conventions.md`

## Steps

1. Read the current `## Sidecar conventions` section of CLAUDE.md
   (everything from the heading through the `## Essay convention` heading,
   exclusive).
2. Create `~/dotfiles/claude/.claude/references/sidecar-conventions.md` with:
   - YAML frontmatter: `title`, `description`, `static: true` (per
     `doc-freshness` skill — this is reference-shaped, not code-derived).
   - The full extracted section as the body.
3. Replace the CLAUDE.md section with a 5-line stub:
   ```
   ## Sidecar conventions

   Every non-trivial source file should have a sibling `.claude` sidecar
   carrying design decisions, invariants, and gotchas the code cannot.
   **Read before editing; update after changes that affect intent.**
   See `~/.claude/references/sidecar-conventions.md` for label/role
   taxonomy, when-to-create rules, and sidecar maxims.
   ```
4. Run stow: `cd ~/dotfiles && stow claude`. Verify with
   `ls -la ~/.claude/references/sidecar-conventions.md` (must be a symlink).
5. Verify CLAUDE.md still parses cleanly (no broken markdown, no
   orphaned references in surrounding sections).
6. Commit. Open PR targeting `main`.

## Acceptance criteria

- [ ] `~/.claude/references/sidecar-conventions.md` exists as a symlink
      and contains the full extracted content.
- [ ] CLAUDE.md `## Sidecar conventions` section is the 5-line stub.
- [ ] No content lost: word-count of (new reference + stub) ≈ word-count
      of (old section).
- [ ] `stow --simulate` shows no conflicts.
- [ ] PR description includes before/after `wc -c` for CLAUDE.md.

## Validation

- `wc -c ~/.claude/CLAUDE.md` drops by ~4,500 bytes.
- Search any skill that references the sidecar concept; confirm the
  pointer in the stub is enough for them to find the full taxonomy.

## Commit / PR

- Commit message:
  ```
  refactor(claude): extract sidecar conventions to references/

  Move the full sidecar taxonomy (labels, roles, when-to-create, maxims)
  out of CLAUDE.md into references/sidecar-conventions.md. CLAUDE.md
  keeps a 5-line stub. Saves ~4.5k bytes from the always-loaded baseline.

  Refs: essay skill-system-token-efficiency-audit.md §P0.1

  Plan: skills-trim-and-discipline
  Task: 01
  ```
- PR title: `refactor(claude): extract sidecar conventions to references/`
- PR body: Summary (savings target + measured), Test plan (stow OK,
  symlink verified, CLAUDE.md still loads cleanly), Refs (essay #9 §P0.1).
