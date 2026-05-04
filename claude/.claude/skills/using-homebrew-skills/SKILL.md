---
name: "[HomebrewSkill] using-homebrew-skills"
class: ritual
description: "Use before responding to any user prompt. Activates on every first response in a session and on phrases like 'scan skills', 'what skills do I have', 'list my skills', 'before responding'. Enforces iron-law: BEFORE RESPONDING, SCAN LOADED SKILLS. IF ANY PLAUSIBLY APPLY, INVOKE — even before asking clarifying questions. Rationalization table covers 'simple case', 'quick response', 'I already know this', 'mid-conversation' excuses. Do NOT trigger for tool-output-only responses or for explicit user direction to skip skill invocation."
---

# using-homebrew-skills

## Iron law

**BEFORE RESPONDING, SCAN LOADED SKILLS. IF ANY PLAUSIBLY APPLY, INVOKE.**

The scan precedes every other reflex — including clarifying questions,
quick acknowledgements, and "let me just answer." A loaded skill the
prompt matches is not optional context; it is the assigned tool.

## Procedure

1. **Read the available-skills list.** It is in the system reminder.
2. **Match the user prompt against each skill's triggers.** Phrase
   match, file-path match, or domain match all count.
3. **If any skill plausibly applies, invoke it before answering.**
   Invocation precedes drafting prose, even one-line replies.

## First-response trigger

On every first response in a session, run the scan check before
drafting any other reply.

## Rationalization counters

| Excuse | Counter |
|---|---|
| "I'll just answer directly — no need for a skill." | Direct answers without scanning are the failure mode this skill exists to prevent. Scan first; the skill decides, not the impulse. |
| "Quick response — scanning slows me down." | The scan is one pass over a list already in context. Slowness is not the cost; missed invocation is. |
| "Simple question — skills are for substantive work." | Skills declare their own scope via triggers. "Simple" is your judgment, not the skill's gate. |
| "I already know how to do this." | Knowing the answer is orthogonal to whether a skill owns the workflow. Skills enforce procedure, not knowledge. |
| "Mid-conversation — the first-response rule doesn't apply now." | Every turn is a response. Scan applies per turn, not per session. |
| "The user wants speed, not ceremony." | Speed never overrides invocation. The user opted into skills by loading them. |
| "I'll invoke later if it turns out to matter." | Later invocation cannot undo a non-skill answer already in flight. Scan upstream of the reply. |
| "This is a one-off — formal flow is overkill." | One-offs are the modal case skills are tuned for. Frequency is not the gate. |
| "Tool output already arrived — just summarize it." | Tool-output-only summaries are the documented exemption. Anything beyond a summary re-enters scope. |
