# Task 38 — Essays resolved + final umbrella PR

**Phase:** 9 (Closeout)
**Agent:** plan-executor-documenter
**Produces PR:** Yes (umbrella PR, user-merged)

## Goal

Mark both source essays `status: resolved`. Populate `anchors.produced`
on each. Append to essay #9 a "Measured outcome" section with the
real numbers. Open the umbrella PR linking every sub-PR. User merges
the umbrella PR; one MAJOR tag bump finalizes the plan.

## Context

This is the closer. After it merges, the plan is complete and the
durable record of the work is the two updated essays + the merged
sub-PRs + the MAJOR-tagged release.

## Files

**Affected:**
- `~/dotfiles/claude/.claude/essays/skill-system-token-efficiency-audit.md`
- `~/dotfiles/claude/.claude/essays/skill-system-vs-superpowers.md`

## Steps

1. Update essay #9 (`skill-system-token-efficiency-audit.md`):
   - Frontmatter: `status: resolved`, `last-active: <today>`,
     `anchors.produced: [./plans/skills-trim-and-discipline/MasterPlan.md]`
     (path relative to dotfiles repo; or absolute under `~/.claude/plans/...`
     if that's the convention — check existing essay anchors).
   - Append a `## Measured outcome` section with:
     - Cumulative bytes saved (before vs after).
     - Per-scenario % savings (A–F) from Task 37 audit.
     - Items that exceeded projection.
     - Items that fell short and why.
2. Update essay #8 (`skill-system-vs-superpowers.md`):
   - Frontmatter: `status: resolved`, `last-active: <today>`,
     `anchors.produced` populated.
   - Append a brief `## Outcome` section: which gaps were closed
     (P0/P1/P2/P3 from the essay's backlog), pointing at the sub-PRs
     by number.
3. Stow + verify (essays don't move; the symlinks already exist).
4. Open the umbrella PR:
   - Branch: `claude/skills-trim-and-discipline`.
   - Target: `main`.
   - Title: `feat(claude): skills trim and discipline — final closeout`
   - Body:
     - Summary: 2–3 sentences on what landed.
     - PR list: every sub-PR by number with one-line description.
     - Measured outcome: copy of the "Measured outcome" section from
       essay #9.
     - Refs: links to both source essays.
     - Test plan: stow OK; cold-session smoke; activation regression
       sweep results.
     - Notes: this PR closes the plan. Merge bumps MAJOR tag.
5. Do NOT merge the umbrella PR. User merges manually per direction.
6. **Do NOT push tags.** The MAJOR tag bump is a user action after merge.
   Include the exact commands in the umbrella PR body under a "Post-merge
   actions" section so the user has a copy-pasteable block:
   ```
   # Post-merge (user runs):
   git -C ~/dotfiles tag --list --sort=-v:refname | head    # find current top tag
   git -C ~/dotfiles tag -a vX.Y -m "Skills trim & discipline: ~40% token reduction; +8 new discipline/ritual skills"
   git -C ~/dotfiles push origin vX.Y
   gh release create vX.Y --title "vX.Y — skills trim & discipline" --notes "<paste essay #9 'Measured outcome' here>"
   ```
   Where vX.Y is the next MAJOR (next major minor=0).

## Acceptance criteria

- [ ] Essay #9 marked `resolved`; "Measured outcome" present;
      `anchors.produced` populated.
- [ ] Essay #8 marked `resolved`; "Outcome" section present;
      `anchors.produced` populated.
- [ ] Umbrella PR opened against `main`; body lists every sub-PR;
      includes measured outcome.
- [ ] PR is set to user-merge (not auto-merge).
- [ ] PR body includes the exact post-merge tag-bump commands as a
      copy-pasteable block. **Agent does NOT execute them.**

## Validation

- Both essays' frontmatter parses; both link to the plan via
  `anchors.produced`.
- Umbrella PR description renders cleanly on GitHub.
- All sub-PR links resolve.

## Commit / PR

- Commit message (the closeout commit, in the umbrella PR):
  ```
  docs(claude): mark skills-trim-and-discipline essays resolved

  Both source essays (skill-system-token-efficiency-audit and
  skill-system-vs-superpowers) marked status: resolved with anchors.
  produced populated. Measured outcome appended to essay #9.

  This commit is the closer for the skills-trim-and-discipline plan.
  Sub-PRs already merged; umbrella PR aggregates them for the MAJOR
  tag bump.

  Refs: ~/dotfiles/.claude/plans/skills-trim-and-discipline/MasterPlan.md

  Plan: skills-trim-and-discipline
  Task: 38
  ```
- PR target: `main`. User merges.
