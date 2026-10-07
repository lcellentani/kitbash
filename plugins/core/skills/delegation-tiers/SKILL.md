---
name: delegation-tiers
description: "Use when assigning, proposing, or checking a delegation tier (T1-T4) for a commit or task, or when asked how much AI was involved in a piece of work."
when_to_use: "Tagging a commit or plan task with [Tn] / Tn; deciding between adjacent tiers; any question about how much of the work was AI-written or AI-assisted."
user-invocable: false
---

# Delegation tiers

- `T1` — written independently
- `T2` — written with AI answering questions
- `T3` — AI-drafted, author owns every line
- `T4` — fully delegated

## Telling adjacent tiers apart

Two questions decide it: **who wrote the code that landed**, and **who read it**.

- **T1 vs T2** — Did AI contribute anything beyond answers? If it only explained, advised, or
  pointed at docs and no AI-written code was kept, it's T2. No AI input at all is T1.
- **T2 vs T3** — Did AI-written code end up in the work? If yes, it's T3, even if the author
  edited it heavily. If the author wrote every line and AI only advised, it's T2.
- **T3 vs T4** — Did the author read every line and take responsibility for it? If yes, T3.
  If it was accepted on behavior or passing tests without a line-by-line read, T4.

## Usage

This skill is the single source of truth for what each tier *means*. Consuming
skills decide their own tag format for *where* the tier appears — a `[Tn]`
commit-message prefix, a per-task `**Tag:** Tn — rationale` line, etc.

If the evidence doesn't settle a boundary, pick the higher-ownership tier (the lower
number) and say so in the rationale, rather than leaving it undecided.
