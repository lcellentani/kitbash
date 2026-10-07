---
name: git-commit
description: "Draft a git commit message for the staged changes, tagged with its delegation tier ([Tn] type(scope): subject). Use when asked to write or draft a commit message, before committing staged changes, or on /git-commit. Produces the message only — it doesn't run git commit."
argument-hint: "[T1|T2|T3|T4]"
allowed-tools: Bash(git diff *)
---

# git-commit

## Staged changes

!`git diff --cached --stat`

!`git diff --cached`

If the staged changes above are empty, say nothing is staged and stop.

## Delegation tier

The delegation tier is: $ARGUMENTS
Valid values: T1, T2, T3, T4 — see the `core:delegation-tiers` skill for what each tier means.
If $ARGUMENTS is empty or not a valid tier, stop and ask: "Which delegation tier? (T1/T2/T3/T4)"

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

Output only the final message(s), ready to copy. No explanation.
