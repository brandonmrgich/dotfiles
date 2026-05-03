---
title: SKILL.md description format
description: Canonical rules for the `description:` field in SKILL.md frontmatter. Loading-signal mechanics, char limits, anti-patterns, migration recipe, worked examples. Drives description rewrites and new-skill authoring.
static: true
---

# SKILL.md description format

## Purpose

The `description:` field in SKILL.md frontmatter is the **only signal**
Claude uses when deciding whether to load a skill's body. It is read
eagerly (with all other skill descriptions) at session start and matched
against the current prompt and context to gate body load.

Two failure modes follow from that:

- **Pre-summarized descriptions cause silent skips.** If the description
  reads like a body summary ("Orchestrate sequential execution of…"),
  Claude can shortcut the skill — read the description, decide it has
  enough, and skip loading the body. Triggers (when to load) and
  contents (what's in the body) are different jobs; the description is
  only the first.
- **Bloated descriptions tax every session.** All descriptions are in
  the always-loaded budget. A 1900-char description costs ~475 tokens
  on every cold session, whether or not the skill activates.

Rationale for the rules below comes from
`~/.claude/essays/skill-system-vs-superpowers.md` §Gap 7 (loading-signal
mechanics) and `~/.claude/essays/skill-system-token-efficiency-audit.md`
§Hotspot 4 (eight local descriptions over 1024 chars; ~1500 tokens
cuttable per session).

---

## Rules

1. **Max 1024 characters.** Hard ceiling. If keyword density forces a
   tradeoff, prefer dropping prose over dropping keywords (see Rule 5).
2. **Third person.** "Captures essays…", not "I capture essays…" or
   "You can use this to…".
3. **Open with "Use when…" or "Activates when…".** First clause is the
   trigger. Anything else is later.
4. **Triggers ONLY.** No workflow summaries (what the body does), no
   concept explanations (what essays/plans/skills *are*), no embedded
   policy (which mode to operate in). Those belong in the body.
5. **Keyword density is preserved — compress prose, not keywords.**
   Activation recall depends on the keyword pool. Trim narrative
   asides ("the cross-browser audio library", "(Digital Data
   Exchange)") and synonym chains, not the trigger words themselves.
6. **No synonym-chain bloat.** Replace enumerations with patterns when
   the pattern preserves recall:
   `"client:load, client:idle, client:visible, client:media, client:only"`
   → `"client:* directives"`. Same for verb chains: `"create, capture,
   save, write, draft a skill"` → `"author a skill"`.

---

## Anti-patterns

Concrete examples drawn from current local SKILL.md descriptions
flagged in essay #8 Appendix A.

### Anti-pattern 1 — Workflow summary in the lead

`plan-executor` opens with **"Orchestrate sequential execution of a
multi-task plan by dispatching specialized sub-agents for each task."**
That is the body's job statement. It tells Claude *what the skill does*
when activated, not *when to activate it*. The triggers ("execute this
plan", "run the plan", …) appear later, behind a clause that already
gives Claude enough to feel oriented without loading the body.

Fix: lead with `Use when the user asks to "execute this plan", "run the
plan",…`. Drop the orchestration sentence — the body explains itself.

### Anti-pattern 2 — Embedded policy

`skill-author`'s description carries the proactive-mode policy
("Also activates when the user is in a session that involved extensive
research, web searches, repeated context-gathering on a niche topic,
or substantial domain-specific work… once activated, the skill
prompts the user proactively to ask whether to capture the work.")
That is *operating policy* (what the skill does in proactive mode),
not a trigger. The trigger is "the session shows the proactive
heuristic conditions"; the policy belongs in the body's
`## Proactive trigger heuristic` section.

Fix: trigger clause says "Also activates implicitly when the session
shows multi-doc research, niche concept exploration, or substantial
domain work that produced a repeatable pattern." Move the
"prompts the user proactively" mechanism into the body.

### Anti-pattern 3 — Concept explanation

`essay`'s description spends sentences explaining what essays *are*
("Knows essays are compressed logs of decisions — not verbatim
transcripts. Knows the status taxonomy: open, resolved, superseded,
archived. Integrates with the anchoring system: essays produce
artifacts (plans, docs); artifacts cite essays via from-essay:
front-matter."). None of that gates activation; it's body content
that leaked forward.

Fix: drop those sentences entirely. The triggers ("essay this",
"capture as an essay", "open the X essay", …) are sufficient. The
body explains the taxonomy.

### Anti-pattern 4 — Synonym-chain bloat

`nextjs-app-router`'s description lists every `client:*` directive
separately ("client:load, client:idle, client:visible, client:media,
client:only") and every routing file by name ("layout.tsx, page.tsx,
loading.tsx, error.tsx, not-found.tsx"). Each enumeration eats ~80
chars to add zero recall vs the pattern form ("client:* directives",
"app/ routing files like layout.tsx / page.tsx / error.tsx").

Fix: collapse enumerations to patterns where the pattern is itself a
keyword Claude will recognize. Keep one or two anchor names per
pattern for grep-style recall.

---

## Migration recipe

Step-by-step procedure for rewriting an existing description to the
spec.

1. **Extract triggers.** Read the current description. List every
   phrase that genuinely gates activation: explicit user phrases
   ("execute this plan"), file/path indicators (`turbo.json`,
   `app/` directory), keyword pools (technology names, API names),
   trigger conditions ("a non-trivial decision was reached").
2. **Group and pattern-collapse.** Cluster synonyms, replace with
   pattern forms where recall is preserved (Rule 6).
3. **Prepend "Use when…" or "Activates when…".** First trigger group
   becomes the lead clause.
4. **Drop summary clauses.** Anything that explains *what the skill
   does* (orchestration verbs, workflow steps, output formats) gets
   cut. If the body needs that content and currently lacks it, add
   a body section in the same edit — but do not leave it in the
   description.
5. **Drop concept prose.** Anything that explains *what a domain
   thing is* (what essays are, what DDEX means, what a sidecar
   carries) gets cut. The body covers domain definitions.
6. **Drop embedded policy.** Anything describing operating modes,
   procedural rules, or "does NOT do X" *behavior* rules gets cut.
   "Do NOT trigger for…" *gating* rules can stay if they prevent
   real false positives.
7. **Verify char count.** `wc -c` the description string (excluding
   the YAML key). Must be ≤1024. If still over, re-trim by removing
   redundant trigger phrases (the keyword pool tends to have 2–3x
   the words actually needed for recall).
8. **Smoke-check first-clause readability.** A reader scanning only
   the first sentence should see clearly *when this skill loads*,
   not *what it does* once loaded.

---

## Worked examples

Three rewrites of real local skills flagged "Rewrite" in essay #8
Appendix A. The "after" forms are illustrative targets for Tasks
15-17, not yet committed.

### Example 1 — `plan-executor`

**Before** (711 chars, leads with workflow summary):

> Orchestrate sequential execution of a multi-task plan by
> dispatching specialized sub-agents for each task. Trigger when
> the user asks to "execute this plan", "run the plan", "start
> executing tasks", "orchestrate the master plan", "run all tasks
> in order", or any similar request involving a master plan file
> and a tasks directory containing numbered task files. Also
> trigger on resume requests like "resume the plan", "continue
> executing where we left off", or "pick up the plan execution".
> Do NOT trigger for single-task execution, ad-hoc coding requests,
> or PR review. The plan must have a master plan file and discrete
> task files (typically numbered 00-discovery.md, 01-foo.md, etc.)
> for this skill to apply.

**After** (~440 chars, triggers-only, lead with "Use when…"):

> Use when the user asks to "execute this plan", "run the plan",
> "start executing tasks", "orchestrate the master plan", "run
> all tasks in order", or to "resume the plan" / "continue where
> we left off". Activates on a master plan file plus a tasks
> directory of numbered task files (00-discovery.md, 01-foo.md,
> …). Do NOT trigger for single-task execution, ad-hoc coding,
> or PR review.

What changed: dropped the orchestration summary (the body's job),
collapsed the resume-phrase enumeration, kept the explicit phrases
verbatim (high-recall triggers), kept the negative gates.

### Example 2 — `essay`

**Before** (~1075 chars, mixes triggers with concept explanation):

> Captures and maintains essay-format records of design
> discussions, decisions, and reasoning. Activates on phrases
> like 'essay this', 'capture as an essay', 'save as an essay',
> 'open the X essay', 'continue the X essay', 'update the X
> essay', 'find essays about Y', 'what essays touch Z', 'resolve
> the X essay', 'supersede X with Y', 'list my essays'. Also
> activates implicitly — but only proactively offers — when a
> conversation has clearly produced a non-trivial decision with
> rationale that wasn't obvious upfront, AND that decision is
> likely to produce or affect artifacts (plans, docs, code), AND
> no essay on the topic already exists. Knows two storage
> locations: user-wide ~/.claude/essays/ and project-local
> <repo>/.claude/essays/. Picks based on whether the essay's
> anchors point at a specific repo. Knows essays are compressed
> logs of decisions — not verbatim transcripts. Knows the status
> taxonomy: open, resolved, superseded, archived. Integrates
> with the anchoring system: essays produce artifacts (plans,
> docs); artifacts cite essays via from-essay: front-matter.

**After** (~580 chars, triggers-only):

> Activates when the user says "essay this", "capture as an
> essay", "save as an essay", "open / continue / update the X
> essay", "find essays about Y", "what essays touch Z",
> "resolve the X essay", "supersede X with Y", or "list my
> essays". Also activates implicitly when a conversation has
> produced a non-trivial decision with non-obvious rationale
> that will affect artifacts (plans, docs, code) and no essay
> on the topic exists yet — in that case the skill offers
> capture rather than acting.

What changed: dropped the lead workflow sentence ("Captures and
maintains…"), dropped all four "Knows…" sentences (concept and
mechanism, both belong in the body), collapsed the
open/continue/update verbs to one slash-separated form, kept the
proactive-trigger condition since it genuinely gates a different
loading mode but trimmed the prose.

### Example 3 — `nextjs-app-router`

**Before** (1865 chars; over the 1024 cap; long synonym chains):

> Next.js 13+ App Router specialist covering server components,
> client components ("use client"), server actions ("use
> server"), route handlers, middleware, streaming, suspense
> boundaries, parallel and intercepting routes, data fetching
> patterns, the four caching layers (Request Memoization, Data
> Cache, Full Route Cache, Router Cache), revalidation
> strategies (revalidatePath, revalidateTag, router.refresh),
> dynamic vs static rendering decisions, hydration patterns
> including persisted Zustand stores with skipHydration,
> theme-via-cookie SSR patterns, and the BFF
> (backend-for-frontend) proxy pattern for same-origin admin
> traffic. Trigger when the prompt or files in scope reference
> any of: Next.js, app router, server component, client
> component, "use client", "use server", server action, route
> handler, middleware, layout.tsx, page.tsx, loading.tsx,
> error.tsx, not-found.tsx, generateMetadata,
> generateStaticParams, revalidatePath, revalidateTag,
> unstable_cache, fetch cache, cookies, headers, redirect,
> notFound, useFormStatus, useFormState, useOptimistic, app/
> directory routing, parallel routes, intercepting routes,
> route groups, dynamic segments, catch-all segments, app/api/
> proxy routes, BFF proxy, skipHydration, persist.rehydrate,
> hydration mismatch, /app/, .tsx files in app/, next.config.js,
> next.config.mjs. Do NOT trigger for Pages Router (pages/
> directory) — that is a different paradigm. Do NOT trigger for
> general React unrelated to Next.js framework features. DO
> trigger for core Next.js API questions (revalidatePath,
> revalidateTag, caching, server components, etc.) even when
> inside a monorepo — framework questions are always in scope.
> Do NOT trigger for questions about a specific monorepo's BFF
> proxy wiring or app-level architecture — defer those to
> project-local specialists like music-platform-api or
> music-platform-architecture.

**After** (~990 chars, under cap; pattern-collapsed):

> Use when the prompt or files in scope reference Next.js
> 13+ App Router: server / client components, "use client" /
> "use server" directives, server actions, route handlers,
> middleware, app/ routing files (layout.tsx / page.tsx /
> loading.tsx / error.tsx / not-found.tsx), generateMetadata,
> generateStaticParams, the four caching layers (Request
> Memoization, Data Cache, Full Route Cache, Router Cache),
> revalidatePath / revalidateTag / unstable_cache /
> router.refresh, cookies / headers / redirect / notFound,
> useFormStatus / useFormState / useOptimistic, parallel and
> intercepting routes, route groups, dynamic and catch-all
> segments, BFF proxy under app/api/, skipHydration /
> persist.rehydrate / hydration mismatch, next.config.{js,mjs}.
> Do NOT trigger for Pages Router (pages/ directory) — different
> paradigm. Do NOT trigger for generic React unrelated to
> framework features. Do NOT trigger for one specific
> monorepo's BFF wiring — defer to project-local specialists
> (music-platform-api, music-platform-architecture). DO trigger
> for core Next.js API questions inside a monorepo — framework
> questions are always in scope.

What changed: dropped the lead "specialist covering…" workflow
summary, collapsed the parenthetical-aside list ("hydration
patterns including persisted Zustand stores with skipHydration,
theme-via-cookie SSR patterns, and the BFF proxy pattern…")
into pattern keywords, deduplicated the keyword pool (the
"Trigger when… any of:" list repeated half the keywords from
the lead sentence), kept all the negative-gate clauses since
they prevent real false positives.

---

## Cross-references

- `~/.claude/essays/skill-system-vs-superpowers.md` §Gap 7 +
  Appendix A — the description-format audit table that drives
  Tasks 15-17.
- `~/.claude/essays/skill-system-token-efficiency-audit.md`
  §Hotspot 4 + §P2.1-P2.3 — the per-skill char-count rankings
  and prioritized cleanup order.
- `~/.claude/skills/skill-author/SKILL.md` — cites this
  reference; new skills are authored against this spec.
- `~/.claude/references/skill-authoring-guide.md` — full skill
  authoring procedure (this reference is the description-only
  slice).
