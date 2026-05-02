# Task 08 — Extract web-audio-howler examples

**Phase:** 2 (Heavy SKILL.md trims)
**Agent:** plan-executor-implementer
**Produces PR:** Yes

## Goal

Move the "minimal correct setup" full module (~80 lines) and the
MediaSession effect blocks (~60 lines) out of
`web-audio-howler/SKILL.md` into sibling
`skills/web-audio-howler/examples/*.example.ts` files.

Targets ~5k bytes saved per activation (the largest specialist trim).

## Context

The skill currently inlines complete TypeScript modules as fenced code
blocks. They're useful when implementing exactly that pattern, but
they make the SKILL.md heavy on every activation regardless of need.

Pattern: SKILL.md keeps prose principles + decision tables +
**short illustrative snippets**. Full code lives in `examples/` and is
referenced by filename. Future agents reading the skill see the
pointer, fetch the example only when implementing.

Source: essay #9 §"Hotspot 3 — Domain specialists with embedded code blocks"
and §"P1.2".

## Files

**Affected:**
- `~/dotfiles/claude/.claude/skills/web-audio-howler/SKILL.md`

**Created:**
- `~/dotfiles/claude/.claude/skills/web-audio-howler/examples/audio-engine.example.ts`
- `~/dotfiles/claude/.claude/skills/web-audio-howler/examples/mediasession.example.ts`

## Steps

1. Read current SKILL.md. Identify the two large code blocks:
   - "minimal correct setup" — full audio-engine module
   - MediaSession effect blocks — identity-vs-position split, action handlers
2. Create the `examples/` directory under the skill dir.
3. Write each block as a standalone `.example.ts` file. Include a
   header comment block: `// example for ~/.claude/skills/web-audio-howler/SKILL.md`
   plus a one-line summary of what the example demonstrates.
4. In SKILL.md, replace each block with a pointer block:
   ```
   See `~/.claude/skills/web-audio-howler/examples/audio-engine.example.ts`
   for the minimal correct setup (Howler instantiation, AudioContext priming,
   WeakMap caching of MediaElementAudioSourceNode).
   ```
5. Keep short illustrative snippets inline where they earn their bytes
   (a 3–4 line API call demonstrating an idiom — fine; a 60-line
   module — out).
6. Stow + verify both example files.
7. Commit + PR.

## Acceptance criteria

- [ ] `web-audio-howler/SKILL.md` byte size in the range 5,500–6,500
      (down from ~10k).
- [ ] Both example files exist as symlinks under
      `~/.claude/skills/web-audio-howler/examples/`.
- [ ] No content lost (pointer + example file = original block content).
- [ ] PR description shows byte delta.

## Validation

- Activate skill in a fresh session ("how do I set up Howler with
  MediaSession?"); confirm body points to examples and the examples
  resolve.

## Commit / PR

- Commit message:
  ```
  refactor(skill): extract web-audio-howler code blocks to examples/

  Move audio-engine and MediaSession code blocks from SKILL.md into
  examples/*.example.ts. SKILL.md keeps principles, decision tables,
  and short snippets. Saves ~5k bytes per activation.

  Refs: essay skill-system-token-efficiency-audit.md §Hotspot 3

  Plan: skills-trim-and-discipline
  Task: 08
  ```
- PR target: `main`.
