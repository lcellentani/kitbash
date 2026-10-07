---
name: spec-review
description: Audit a SPEC for ambiguity, missing non-goals, unfalsifiable goals, or unresolved open questions before implementation planning starts. Use whenever a spec has just been drafted or edited and before it's declared ready, or whenever the user asks to review, check, or audit a spec.
argument-hint: "[feature-slug | path]"
context: fork
agent: Explore
background: false
---

# spec-review

Review a SPEC for gaps: $ARGUMENTS

- No argument: review the most recently modified file under `docs/specs/`.
- A feature slug or path: review that spec directly.

A spec-level audit: read-only, returns a structured findings list, and never edits the spec itself — the same checkpoint discipline this workflow uses before any content gets relied on downstream.

This skill runs in a forked read-only subagent, so it doesn't see the conversation that produced the spec — judge the spec file on its own. Return only the findings list; the gap-analysis reasoning stays in the fork.

## Checklist

- **Ambiguous requirements** — any sentence in Goals or Design that could be read two different ways.
- **Goals aren't falsifiable** — "make it feel better" is not a goal; "input latency under 50ms" is.
- **Non-Goals are too thin or missing** — a spec with zero exclusions usually means scope wasn't actually thought through.
- **Design makes unstated assumptions** — about existing systems, performance budgets, or platform constraints that aren't written down.
- **Open Questions left unresolved without being flagged** — if the Design section quietly assumes an answer to something genuinely unsettled, that's a gap, not a decision.
- **Status mismatch** — a spec marked `Ready` that still has unchecked Open Questions.

## Output format

For each finding: `[Severity] Section — what's wrong — suggested fix.` Severity is one of `Blocking` (don't plan against this yet), `Should-fix` (fixable in five minutes, do it before planning), `Nice-to-have` (note it, don't block on it).

If there are no findings: say so plainly — `No gaps found — ready for /spec-plan-workflow:plan-draft.` Don't manufacture findings to seem thorough.
