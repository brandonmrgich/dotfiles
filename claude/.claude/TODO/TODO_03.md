Replacing Changelogs With a Doc-Invalidation Mechanism
Good call. Let me think through this carefully — the changelog wasn't load-bearing for much, but doc invalidation is genuinely important and we shouldn't lose it.
What the changelog was actually doing
Two distinct jobs that happened to share a file:

Doc invalidation routing. "Did the API change recently? Then re-read docs/04-backend.md." Used by agents to decide whether their cached understanding of a doc is stale.
Human historical narrative. "What changed in this repo over the past month?" — useful for orientation, code review prep, retrospectives.

Job 2 is fully duplicated by git log. We don't need a changelog file for that.
Job 1 is the real question. Let me think about what it actually requires.
What doc-invalidation actually needs
Concrete scenario: an agent is about to work on the API. It loaded docs/04-backend.md from a previous session's understanding. Should it re-read?
What the agent needs to know:

Has the file itself changed since I last read it? → easy: file mtime or git log on the file
Has the domain the file describes changed even if the doc didn't get updated? → harder: requires mapping code paths to docs

The second one is the actual pain. The doc is a description of code; if the code drifts and the doc doesn't get updated, the doc becomes stale silently. The changelog was a manual check on this — if you forgot to update the doc, at least the changelog said "API routes changed today" and the next agent knew to read carefully.
The mechanisms available without a changelog
Mechanism 1: File mtime + git log
For checking "did this doc change," git log -1 --format=%cd <file> gives the last modification date. Trivial. No infrastructure needed.
Mechanism 2: Code-to-doc mapping
A static map: "doc X describes code in paths Y." Agent checks git log --since=<doc-last-modified> -- <Y paths> to see if code changed after the doc did. If yes → doc is potentially stale.
This is better than the changelog because it's automatic and accurate. You don't have to remember to write changelog entries. Drift is detected by comparing two git log results.
Mechanism 3: Front-matter staleness markers
Each doc carries front-matter declaring what code paths it describes:
yaml---
covers:

- apps/api/src/routes/
- apps/api/src/services/
- packages/catalog/
  last-verified: 2026-04-12

---

last-verified is the date a human last confirmed the doc accurately describes the code. An agent checking the doc runs git log --since=<last-verified> -- <covers> — anything in there means the doc may be stale. If the agent verifies the doc still matches current code, it bumps last-verified.
Mechanism 4: Doc-coverage manifest
A single file (docs/\_meta.yaml or similar) maps every doc to its covered paths and last-verified date. Centralized. No per-doc front-matter editing.
My recommendation
Mechanism 3 — front-matter on each doc — is the right fit.
Reasons:

Locality. The "what does this doc describe" claim lives with the doc. When you split or rename a doc, its coverage moves with it. With a central manifest you have to remember to update the manifest too.
Discoverability. A new agent reading the doc sees its scope and verification date immediately, without consulting another file.
Durable across reorganization. If you reshuffle docs/, the front-matter survives the move.
Self-documenting. The pattern is obvious to humans and agents both; no skill needed to understand it, only to act on it.

The skill's job becomes:

Before reading a doc: check its front-matter, compare last-verified to git log of covers paths. If staleness detected, surface a warning.
After verifying a doc: offer to bump last-verified if the agent confirms the doc still matches current code.
When updating a doc: automatically bump last-verified to the commit date.

What dies with the changelog

The flat .claude/changelog.md and the .claude/changelogs/<YYYY-MM>.md rotation — both gone, never created
The "After any edit, append to changelog" rule in CLAUDE.md
The migration of historical changelog entries — they go to git history (which already has them anyway)

What gets added

Front-matter on every doc in docs/ (and the user-wide skills, eventually — but start with project docs)
A user-wide skill doc-freshness that handles staleness detection and last-verified bumping
A small CLAUDE.md update describing the new pattern

A few things to consider before I write the prompt
Granularity of covers. Should it be directories, file globs, or specific files? I lean toward directories with optional globs — apps/api/src/services/ covers everything under it; apps/api/src/routes/admin/\*.ts if you need finer.
What counts as "change in covered paths"? Any commit that touches a covered path bumps the staleness signal. Even minor commits (formatting, dependency bumps) count, which is noisy but safe — the agent just verifies and bumps last-verified. Better to over-warn than under-warn.
Reference docs vs. living docs. Some docs/reference/ files are basically static (DDEX standards reference, e.g.). They don't really go stale because they describe an external standard, not your code. Front-matter for those should have covers: [] or static: true and be skipped by the freshness check.
Doc-of-docs. docs/01-overview.md references everything. Its covers would be massive. I'd say: high-level overview docs get covers: [] and rely on their own update cadence (someone updates them deliberately when the architecture shifts), not on automatic staleness detection.
Backfill. Existing docs need last-verified set to today during migration — there's no way to know when they were last actually verified. That's fine; the mechanism starts from now forward.
Want me to write the prompt?
If you're good with this design, I'll write the migration + new-skill prompt that:

Removes changelog from the multi-plan migration prompt I sent earlier (you haven't run that yet, right? if you have, I'll write a separate undo)
Adds front-matter to every doc under docs/ in music-platform-monorepo with appropriate covers and today's last-verified
Creates the user-wide doc-freshness skill
Updates the project CLAUDE.md to reference the new pattern instead of changelogs
Updates the existing user-wide skills (plan-executor, etc.) to use the freshness skill instead of writing to a changelog

Confirm before I write:

You haven't yet run the multi-plan migration prompt — correct? (If you have, the changelog removal is more involved.)
Front-matter on docs is the right approach (vs. centralized manifest)?
Static reference docs like DDEX_Standards_Reference_Guide.md get covers: [] to opt out of staleness checks — sound right?
