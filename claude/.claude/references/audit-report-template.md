---
title: Audit report template
description: Canonical template for plan-task audit reports. Sections, evidence requirements, authoring notes per section.
static: true
---

# Audit report template

Every audit report produced by the `plan-auditor` skill MUST follow
this exact structure. The skill body owns the audit *procedure* and
*verdict semantics*; this reference owns the *write-time* template
and the per-section authoring notes.

Write the report to the audits directory (typically a sibling of the
tasks directory). Name the file `<task-id>-audit.md`.

---

## Template

```
Audit Report — <Task ID and Name>
Auditor: Plan Compliance Auditor
Date: <ISO 8601>
Branch / Commit / PR: <ref>
Master plan reference: <relevant sections>

Verdict
<PASS | CONDITIONAL PASS | FAIL | ESCALATED>
<One-sentence summary of the verdict.>

Prerequisites check
| Prerequisite task | Audit status | Notes |
| --- | --- | --- |
| <task> | <PASS / FAIL / MISSING> | <notes> |

Deliverables check
| Deliverable | Present? | Evidence |
| --- | --- | --- |
| <item from task file> | <YES / NO> | <file path or note> |

Acceptance criteria verification
Criterion 1: <verbatim criterion>

  Evidence: <files inspected, commands run, outputs observed>
  Verdict: MET / NOT MET / UNVERIFIABLE
  Gap (if any): <what is missing>

Criterion 2: ...
(repeat for every criterion)

Validation steps execution
| Step | Command | Expected | Actual | Pass? |
| --- | --- | --- | --- | --- |
| 1 | <cmd> | <expected> | <actual> | YES/NO |

Master plan alignment
- Architecture / structure: <ALIGNED / DEVIATES — explain>
- Contracts / models: <ALIGNED / DEVIATES — explain>
- Standards / rules: <ALIGNED / DEVIATES — explain>
- Constraints: <ALIGNED / DEVIATES — explain>

Drift and risk
- <Pattern divergence from prior tasks, if any>
- <Technical debt introduced, if any>
- <Downstream task risk, if any>

Required actions before this task can be marked complete
- <Specific, actionable item>
- <Specific, actionable item>

(If verdict is PASS, write: "None. Task is complete.")

Recommendations for future tasks
<Forward-looking observations — patterns to encourage or avoid in
upcoming tasks. Not blocking for the current task.>
```

---

## Per-section authoring notes

### Header block

`Auditor`, `Date`, `Branch / Commit / PR`, `Master plan reference`
are fixed metadata. The branch / commit / PR field must be a
resolvable git ref — never a paraphrase like "the latest work".
Master plan reference cites the specific sections you used to
adjudicate the task (e.g. "§4 Acceptance criteria, §6 Standards").

### Verdict

One of `PASS`, `CONDITIONAL PASS`, `FAIL`, `ESCALATED` (defined in
the SKILL.md body). Followed by a single sentence — not a paragraph.
The detail belongs in the body of the report, not the verdict line.

### Prerequisites check

Lists every prerequisite the task file declares. **Evidence:** the
existence of a prior audit report whose verdict is `PASS` or
`CONDITIONAL PASS`. `MISSING` means the audit report does not exist
on disk; `FAIL` means it exists with a FAIL verdict. Either is an
escalation trigger if work has proceeded anyway.

### Deliverables check

One row per item in the task's "Deliverables" section. **Evidence:**
file path (verified to exist) or a precise note ("config block added
to `path/to/file.toml`, lines 42–58"). A commit message claiming the
deliverable is not evidence; the file on disk is.

### Acceptance criteria verification

Restate each criterion **verbatim** — paraphrasing loses precision
and lets failures slip through. **Evidence:** files inspected (with
paths), commands run (with exact command lines), outputs observed
(quoted or summarized faithfully). Never cite the implementer's
summary as evidence. Verdict is one of `MET`, `NOT MET`,
`UNVERIFIABLE`. If `NOT MET` or `UNVERIFIABLE`, the gap field states
precisely what is missing or what evidence would resolve it.

### Validation steps execution

One row per command in the task's "Validation Steps" section. Run
every command — do not infer pass from the implementer's claim.
Record the actual output, not "as expected". A failed validation
step is a `FAIL` regardless of how close the rest of the work is.

### Master plan alignment

Four fixed dimensions: architecture, contracts, standards,
constraints. Each is `ALIGNED` or `DEVIATES — <reason>`. A deviation
is not automatically a `FAIL` — it may be a `CONDITIONAL PASS` with
a tracked observation — but it must be surfaced explicitly here.

### Drift and risk

Forward-looking observations that don't block the current task but
will compound if ignored. Examples: a pattern that diverges from
earlier tasks, suppressed warnings or `TODO` comments, fragile
rollback assumptions, documentation that wasn't updated alongside
code. Empty section is fine; write "None observed." rather than
omitting it.

### Required actions

Only populated when verdict is `FAIL` or `ESCALATED`. Each action
must be specific and actionable — "fix the bug" is not an action;
"restore the `validateInput()` call removed in commit abc1234" is.
For `PASS` and `CONDITIONAL PASS`, write the canonical line:

> None. Task is complete.

### Recommendations for future tasks

Non-blocking. Use this section to capture patterns to encourage or
avoid in upcoming tasks — observations that will save the next
auditor or implementer time. If nothing comes to mind, omit.

---

## Authoring discipline

- **Verbatim where the task is verbatim.** Acceptance criteria and
  deliverables must be quoted exactly. Paraphrasing is how partial
  passes slip through.
- **Evidence is observable, not claimed.** File paths, command
  output, diff hunks. Not commit messages, not task summaries.
- **No diplomatic softening.** `NOT MET` is `NOT MET`. Don't write
  "mostly met" — that's not in the verdict taxonomy.
- **Empty sections stay, with a note.** If a section is genuinely
  not applicable, write "None." rather than removing it. The
  template's shape itself communicates audit completeness.
