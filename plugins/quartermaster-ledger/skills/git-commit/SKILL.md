---
name: git-commit
description: "Use when asked to write or draft a commit message, or before committing staged changes. Produces the message only; it doesn't run git commit."
when_to_use: "\"write a commit message\", \"draft the commit\", \"commit these changes\", /git-commit. Messages are tagged [Tn] type(scope): subject with a delegation tier."
argument-hint: "[T1|T2|T3|T4]"
allowed-tools: Bash(git diff *) AskUserQuestion
---

# git-commit

## Staged changes

!`git diff --cached --stat`

!`git diff --cached`

If the staged changes above are empty, say nothing is staged and stop.

## Delegation tier

The delegation tier argument is: $ARGUMENTS
Valid values: T1, T2, T3, T4 — see the `core:delegation-tiers` skill for what each tier means and
how to tell adjacent tiers apart.

- If the argument is a valid tier, use it without asking.
- Otherwise, propose a tier and confirm it before drafting:
  1. Judge from this conversation who wrote the staged code and whether the author read it, using
     the `core:delegation-tiers` discriminators. If the conversation gives no evidence, propose
     the higher-ownership tier (T2) and say the rationale is a guess.
  2. Call `AskUserQuestion` with one question, "Which delegation tier for this commit?". Put your
     proposed tier first, labeled "<Tn> (Recommended)", with the one-line rationale as its
     description; list the other three tiers as options. Don't draft the message until answered.

## Format

`[Tn] type(scope): subject`

- `[Tn]` is the delegation tier prefix: [T1], [T2], [T3], or [T4]
- `type(scope)` follows Conventional Commits
- `Subject` uses imperative mood, ≤72 chars, no trailing period

## Example

```
[T1] feat(ecs): add sparse set component storage

Replaces the naive vector<any> prototype with a proper sparse set.
Lookup is O(1), iteration is cache-friendly, removal is O(1) swap-erase.
```

## Splitting unrelated concerns

If the staged diff spans unrelated concerns, propose how to split into separate commits before generating a message.

## Output

Once the tier is settled, output only the final message(s), ready to copy. No explanation (this
doesn't apply to the tier confirmation above).
