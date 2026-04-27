# Console Discipline Reference

Single source of truth for output discipline. Skills cite this; they do not restate it.

**Core rule:** structured or long content belongs in a file; the chat gets a short status line.

---

## Core rule

A reply over ~15 lines, OR any reply with structure (lists, tables, multi-section markdown),
belongs in a file — not printed to the terminal. The chat output should be a status line
(1–3 lines): what happened, where the detail lives, what's next.

---

## Plan-executor application

Phase 4 completion summary and audit report → write to files:
- `.claude/plan-states/<plan-name>-summary.md` — orchestrator summary at plan completion
- `.claude/plan-states/<plan-name>-audit.md` — final auditor verdict

These are runtime state — covered by the `.claude/plan-states/` gitignore rule.
See `~/.claude/references/plan-system.md`.

Chat output at completion: 2–3 lines — verdict, file path, next action. Example:
```
Plan complete. 8/8 tasks passed audit. Full report: .claude/plan-states/my-plan-summary.md
Cleanup artifacts? (yes / no / keep-completion-report-only)
```

---

## Plan-auditor application

Audit verdict → write to `.claude/plan-states/<plan-name>-audit.md` (or alongside
the tasks directory as `audits/<task-id>-audit.md` for per-task audits).

Chat output: verdict + file path only. Example:
```
PASS. Full audit: .claude/plan-states/my-plan-audit.md
```

---

## Github skill application

Long PR bodies and release notes → PR description (`gh pr create --body ...`), not chat.

Chat output: PR URL + one-sentence summary. Example:
```
PR #42 opened: https://github.com/user/repo/pull/42 — Migrate auth to v2
```

---

## When the rule does NOT apply

- Direct user question where the answer is itself short (Q&A, not structured output)
- Code shown as a diff (the diff IS the artifact)
- Quick lookups where writing a file would be overkill
