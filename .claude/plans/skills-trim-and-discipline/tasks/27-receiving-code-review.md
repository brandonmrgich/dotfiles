# Task 27 — Create receiving-code-review skill

**Phase:** 6 (Ritual skills)
**Agent:** plan-executor-implementer
**Produces PR:** Yes

## Goal

Add a `[HomebrewSkill] receiving-code-review` skill enforcing a 6-step
review-response protocol with explicit ban on performative agreement.

## Context

Per essay #8 §"Gap 3", local skills cover commit/PR mechanics (`github`)
but not the *discipline* of giving or receiving review. Receiving is
the higher-impact half — it fights the sycophancy default
("You're absolutely right!" is forbidden).

Cross-references: `github` for PR mechanics; this skill is about how to
respond to feedback, not how to mechanically apply it.

## Files

**Created:**
- `~/dotfiles/claude/.claude/skills/receiving-code-review/SKILL.md`

## Steps

1. RED — pressure-test: present a sub-agent with a fake review comment
   ("this is wrong; X should be Y") and observe whether it agrees
   reflexively or evaluates.
2. GREEN — write skill body:
   - Frontmatter: triggers like "review feedback", "PR comment",
     "addressing review comments".
   - Body:
     - **Iron law** — "DO NOT AGREE PERFORMATIVELY. EVALUATE THE
       REVIEWER'S POINT BEFORE RESPONDING."
     - **6-step protocol** — READ → UNDERSTAND → VERIFY → EVALUATE →
       RESPOND → IMPLEMENT.
     - **Banned phrases** — "You're absolutely right!", "Great catch!",
       "I should have done X" (without first verifying the reviewer's
       claim is correct).
     - **Cross-ref** — `github` for PR mechanics, sibling
       `requesting-code-review`.
   - Target body: <500 words.
3. REFACTOR — iterate.
4. Stow + verify.
5. Commit + PR.

## Acceptance criteria

- [ ] Skill exists; iron law and 6-step protocol present.
- [ ] Banned-phrase list present.
- [ ] PR description includes RED→GREEN→REFACTOR trace.

## Validation

- Activation: "addressing review comments on PR #123"; activates.
- Behavioral: present sub-agent with a wrong-but-confident review
  comment WITH skill; observe whether it pushes back or capitulates.

## Commit / PR

- Commit message:
  ```
  feat(skill): add receiving-code-review ritual skill

  6-step protocol (READ -> UNDERSTAND -> VERIFY -> EVALUATE -> RESPOND
  -> IMPLEMENT) with banned-phrase list. Counters sycophancy default.

  Pressure-tested per references/skill-pressure-testing.md.

  Refs: essay skill-system-vs-superpowers.md §Gap 3

  Plan: skills-trim-and-discipline
  Task: 27
  ```
- PR target: `main`.
