---
name: delegation-tiers
description: "Reference for the T1-T4 delegation-tier taxonomy describing how much AI involvement went into a unit of work. Not user-invocable directly — referenced by other plugins' skills (e.g. quartermaster-ledger's git-commit, spec-plan-workflow's plan-drafting) that tag commits or tasks with a tier."
user-invocable: false
---

# Delegation tiers

- `T1` — written independently
- `T2` — written with AI answering questions
- `T3` — AI-drafted, author owns every line
- `T4` — fully delegated

## Usage

This skill is the single source of truth for what each tier *means*. Consuming
skills decide their own tag format for *where* the tier appears — a `[Tn]`
commit-message prefix, a per-task `**Tag:** Tn — rationale` line, etc.

If the right tier is unclear, default to the higher-ownership tier (T1/T2) and
say so in the rationale, rather than leaving it undecided.
