---
name: plan-review
description: "Use whenever an Implementation Plan has just been drafted or edited, before starting work on it, or when the user asks to review, check, or approve a plan."
when_to_use: "\"review the plan\", \"is this plan ready\", \"check the plan\". Audits against engineering-principles and completeness checks."
argument-hint: "[feature-slug | path]"
context: fork
agent: Explore
background: false
---

# plan-review

Review an Implementation Plan: $ARGUMENTS

- No argument: review `git diff -- docs/plans/` (just-edited parts of a plan).
- A feature slug or path: review that plan file in full.

A plan-level audit: read-only, returns a structured findings list, and never edits the plan itself — the checkpoint between drafting and acting on it.

This skill runs in a forked read-only subagent, so it doesn't see the conversation that produced the plan — judge the plan file (and its spec, for scope drift) on their own. Return only the findings list.

## Checklist

- **Every task has acceptance criteria** that are testable, not descriptive.
- **Every task has a delegation tag** — none left as `[T1 / T2 / T3 / T4]` placeholder text. If the tier is genuinely ambiguous, that itself is a finding.
- **Every phase has a rollback line.**
- **Files to Modify entries have an LOC estimate and a risk rating** — an empty or vague entry is a gap.
- **Scope is explicit** — In Scope / Out of Scope aren't left as inherited boilerplate from the spec without being checked against what the tasks actually do.
- **No scope drift from the spec** — if a task does something the spec's Non-Goals excluded, or introduces a goal the spec never stated, flag it. That's a signal to go back to `/spec-plan-workflow:spec-review` or amend the spec, not silently expand the plan.
- **No TODO/TBD left in the body.**
- **Phase/task numbering is consistent** if this is an appended plan (Phase 2 doesn't quietly restart at Task 1.1).

## Output format

Same as `spec-review`: `[Severity] Section — what's wrong — suggested fix`, severity `Blocking / Should-fix / Nice-to-have`. If clean: `Approved — ready to implement.`
