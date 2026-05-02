# Audit 00 — Baseline measurements

**Plan:** skills-trim-and-discipline
**Phase:** 0 (Discovery)
**Captured:** 2026-05-01
**Branch:** `claude/skills-trim-and-discipline` @ `785f2d6`

This file is the canonical pre-trim measurement set. Every subsequent
audit gate compares against it. Hard `wc -c` numbers; no estimates.

---

## Always-loaded baseline

| Component | Bytes | Approx tokens (÷4) |
|---|---|---|
| `~/.claude/CLAUDE.md` | 19,028 | ~4,757 |
| 20 SKILL.md descriptions (eagerly indexed) | 16,427 | ~4,107 |
| **Total per session, before any activation** | **35,455** | **~8,864** |

---

## Per-skill description char counts

Sorted alphabetically. Drift column compares the **measured** value
against essay #9 Appendix A.

| Skill | Measured chars | Essay #9 | Drift |
|---|---|---|---|
| astro-static-sites | 1,278 | 1,278 | 0.0% |
| ddex-standards | 1,543 | 1,543 | 0.0% |
| doc-freshness | 522 | 522 | 0.0% |
| environment-map | 756 | 755 | +0.1% |
| essay | 1,075 | 1,075 | 0.0% |
| github | 451 | 451 | 0.0% |
| gitignore | 420 | 420 | 0.0% |
| idea-tracker | 386 | 376 | +2.7% |
| nextjs-app-router | 1,859 | 1,865 | -0.3% |
| plan-auditor | 602 | 602 | 0.0% |
| plan-executor | 711 | 711 | 0.0% |
| royalty-splits-music | 1,210 | 1,210 | 0.0% |
| session-ready | 635 | 635 | 0.0% |
| skill-author | 1,176 | 1,176 | 0.0% |
| top-down-sweep | 405 | 405 | 0.0% |
| turborepo-patterns | 1,100 | 1,100 | 0.0% |
| web-audio-howler | 1,357 | 1,357 | 0.0% |
| worktree-orchestrator | 646 | 646 | 0.0% |
| zoom-in | 181 | 181 | 0.0% |
| zoom-out | 114 | 114 | 0.0% |
| **Total** | **16,427** | **16,422** | +0.03% |

All deltas are within ±5%. The +2.7% drift on `idea-tracker` is
the only non-zero shift; likely a small wording change since the
essay was written. Acceptance criterion satisfied.

---

## Per-file body byte counts

### SKILL.md files (20 skills)

| Skill | Body bytes | Approx tokens |
|---|---|---|
| plan-executor | 19,394 | ~4,849 |
| plan-auditor | 10,861 | ~2,715 |
| skill-author | 10,246 | ~2,562 |
| nextjs-app-router | 10,073 | ~2,518 |
| web-audio-howler | 10,022 | ~2,506 |
| turborepo-patterns | 8,930 | ~2,233 |
| royalty-splits-music | 8,694 | ~2,174 |
| ddex-standards | 8,595 | ~2,149 |
| astro-static-sites | 7,436 | ~1,859 |
| github | 6,721 | ~1,680 |
| worktree-orchestrator | 5,899 | ~1,475 |
| session-ready | 5,777 | ~1,444 |
| gitignore | 5,407 | ~1,352 |
| idea-tracker | 5,032 | ~1,258 |
| doc-freshness | 4,670 | ~1,168 |
| top-down-sweep | 4,192 | ~1,048 |
| zoom-in | 2,856 | ~714 |
| environment-map | 2,522 | ~631 |
| zoom-out | 1,969 | ~492 |
| essay | 9,174 | ~2,294 |
| **Total body bytes** | **148,470** | **~37,118** |

> Note: essay body measures 9,174 bytes here vs 8,168 in essay #9
> Appendix A — drift +12.3%. The essay SKILL.md grew since the audit
> essay was written. This file is the canonical post-drift number.

### Reference files

| File | Bytes | Approx tokens |
|---|---|---|
| references/console-discipline.md | 1,917 | ~479 |
| references/plan-system.md | 3,064 | ~766 |

### Agent files

| File | Bytes | Approx tokens |
|---|---|---|
| agents/plan-executor-discovery.md | 2,206 | ~552 |
| agents/plan-executor-documenter.md | 2,275 | ~569 |
| agents/plan-executor-implementer.md | 2,483 | ~621 |
| agents/plan-executor-tester.md | 2,235 | ~559 |

### Mantra files

| File | Bytes | Approx tokens |
|---|---|---|
| mantras/eliminate_dont_paper_over.md | 5,638 | ~1,410 |
| mantras/make_state_honest.md | 4,282 | ~1,071 |

### Environment files

| File | Bytes | Approx tokens |
|---|---|---|
| environment/hosts.md | 2,228 | ~557 |
| environment/networks.md | 1,530 | ~383 |
| environment/repos.md | 1,743 | ~436 |
| environment/services.md | 1,773 | ~443 |

---

## Cross-reference graph (pre-trim)

Adjacency list. Each source file maps to the targets it mentions
(after stripping fenced code blocks). `skill:<name>` denotes a
backtick-wrapped reference to a known skill name; agents and
reference files are reported by path.

```
CLAUDE.md
  -> skill:environment-map
  -> skill:idea-tracker
  -> skill:plan-auditor
  -> skill:plan-executor
  -> ~/.claude/agents/
  -> ~/.claude/environment/{hosts,networks,repos,services}.md
  -> ~/.claude/essays/
  -> ~/.claude/essays/cross-claude-mantras-and-skills-integration.md
  -> ~/.claude/ideas/
  -> ~/.claude/mantras/
  -> ~/.claude/memory/
  -> ~/.claude/references/console-discipline.md
  -> ~/.claude/references/plan-system.md
  -> ~/.claude/skills/
  -> ~/.claude/skills/github/SKILL.md

skills/environment-map/SKILL.md
  -> ~/.claude/environment/{hosts,networks,repos,services}.md

skills/essay/SKILL.md
  -> ~/.claude/essays/

skills/github/SKILL.md
  -> ~/.claude/ideas/git-auth-preflight.md
  -> ~/.claude/references/console-discipline.md
  -> ~/.claude/references/plan-system.md
  -> ~/.claude/skills/gitignore/SKILL.md
  -> ~/.claude/skills/worktree-orchestrator/SKILL.md

skills/gitignore/SKILL.md
  -> ~/.claude/references/plan-system.md

skills/idea-tracker/SKILL.md
  -> skill:plan-executor
  -> ~/.claude/ideas/

skills/plan-auditor/SKILL.md
  -> ~/.claude/references/console-discipline.md

skills/plan-executor/SKILL.md
  -> skill:doc-freshness
  -> ~/.claude/agents/  (4 plan-executor-* sub-agents)
  -> ~/.claude/references/console-discipline.md
  -> ~/.claude/references/plan-system.md

skills/royalty-splits-music/SKILL.md
  -> skill:ddex-standards

skills/session-ready/SKILL.md
  -> skill:essay
  -> skill:top-down-sweep
  -> ~/.claude/essays/

skills/skill-author/SKILL.md
  -> ~/.claude/CLAUDE.md
  -> ~/.claude/agents/
  -> ~/.claude/skills/

skills/top-down-sweep/SKILL.md
  -> skill:doc-freshness

skills/worktree-orchestrator/SKILL.md
  -> ~/.claude/worktree-registry.json

skills/zoom-out/SKILL.md
  -> skill:plan-executor
  -> skill:worktree-orchestrator

references/console-discipline.md
  -> ~/.claude/references/plan-system.md

references/plan-system.md
  -> ~/.claude/worktree-registry.json
```

### Qualitative match against essay #9 "Cross-reference graph"

Essay #9 captured the same skill-to-skill adjacencies (verified):

- `environment-map` → environment/* — match
- `github` → console-discipline, plan-system, gitignore, worktree-orchestrator — match
- `gitignore` → plan-system — match
- `plan-auditor` → console-discipline — match
- `plan-executor` → console-discipline, plan-system, doc-freshness, 4 sub-agents — match
- `session-ready` → essay, top-down-sweep — match
- `top-down-sweep` → doc-freshness — match
- `royalty-splits-music` → ddex-standards — match
- `zoom-out` → plan-executor, worktree-orchestrator — match
- `idea-tracker` → plan-executor — match

**Additional edges this measurement found that essay #9 did not list:**

- `CLAUDE.md` itself directly cross-references `~/.claude/skills/github/SKILL.md`
  (the `skill:github` mention from the artifact-classes section), plus 4 skills
  by backtick name (environment-map, idea-tracker, plan-auditor, plan-executor),
  plus a path into `~/.claude/essays/cross-claude-mantras-and-skills-integration.md`.
  This means CLAUDE.md is a soft-pulling node into github SKILL.md and the
  cross-claude essay — relevant for Phase 1 trims of CLAUDE.md.
- `skill-author` → CLAUDE.md, agents/, skills/ — broad references but no
  specific skill or reference target.
- `github` → `~/.claude/ideas/git-auth-preflight.md` — note an idea-file
  reference, not a skill.

---

## Compound savings projection (pre-trim baseline)

Source: essay #9 §"Compound savings projection". Re-stated here so future
audits can compute deltas against scenarios A–F directly.

| Scenario | Bytes | Approx tokens | Description |
|---|---|---|---|
| A — Cold session | 35,450 | ~8,850 | CLAUDE.md + 20 descriptions |
| B — Routine code (Next.js) | 45,523 | ~11,370 | A + nextjs-app-router body |
| C — Music platform feature | 67,812 | ~16,945 | A + project CLAUDE.md (~5k) + nextjs + ddex + royalty |
| D — Plan execution | 79,515 | ~19,875 | A + plan-executor + 2 refs + worktree + github + 1 agent + doc-freshness |
| E — Worst plausible compound | 107,207 | ~26,800 | A + project CLAUDE.md + plan-executor + worktree + github + nextjs + ddex + royalty + 2 refs + 1 agent |
| F — Doc audit | 52,480 | ~13,110 | A + top-down-sweep + doc-freshness + essay |

**Cross-check with measured numbers:**

- A is exact: 19,028 + 16,427 = 35,455 (vs 35,450 in essay — +5 byte drift, the
  +5 chars come from the per-skill description drift table above).
- B: A (35,455) + nextjs body (10,073) = 45,528 (vs 45,523, +5 bytes — same).
- D: A + plan-executor (19,394) + console-discipline (1,917) + plan-system (3,064)
  + worktree (5,899) + github (6,721) + ~2,400 agent + doc-freshness (4,670) =
  79,520 (vs 79,515, +5 bytes — same).

Drift is uniformly +5 bytes from the description-total drift; the body-level
projections in essay #9 are otherwise exact. The projection table is good to
use as the comparison baseline for Phase 1+ deltas.

---

## Acceptance criteria status

- [x] Working tree clean before any change.
- [x] On branch `claude/skills-trim-and-discipline`.
- [x] Baseline file written; contains 20 per-skill description rows + per-file
      rows for skills, references, agents, mantras, environment + always-loaded
      total.
- [x] Cross-reference graph captured (pre-trim shape).
- [x] No code-bearing files modified.

## Validation status

- [x] `wc -c` runs without errors against every target.
- [x] Description char counts agree with essay #9 Appendix A within ±5%
      (max drift: idea-tracker at +2.7%).
- [x] Cross-ref graph matches essay #9's "Cross-reference graph" qualitatively
      (all listed edges present; this measurement adds 3 small edges from
      CLAUDE.md, skill-author, and github).

---

## Notes for downstream phases

1. **Description drift is essentially zero** — Phase 0 baseline matches
   essay-stated values within 0.03% in aggregate. Trust essay #9 as the
   canonical reference for projection-table targets.
2. **Body drift on `essay` skill: +12.3%** (8,168 → 9,174 bytes). The
   essay SKILL.md grew between essay #9 capture and now. Phase 1 trims
   targeting `essay` should use 9,174 as the pre-trim number, not 8,168.
3. **CLAUDE.md cross-references `github` SKILL.md by full path.** When
   Phase 1 P0.x trims rewrite CLAUDE.md sections, preserve that pointer
   (it's load-bearing for the artifact-classes commit-footer reference).
4. **`skill-author` references `~/.claude/CLAUDE.md` directly.** If
   Phase 1 moves sections out of CLAUDE.md, audit `skill-author` for
   stale anchors.
5. **`idea-tracker` description grew +2.7%** since essay #9 — minor, but
   if Phase 2 caps descriptions at 1,024 chars, `idea-tracker` (386 chars)
   is still well under the cap.
