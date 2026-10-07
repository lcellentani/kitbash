---
description: git-commit drafts a [Tn]-prefixed Conventional Commit message from the staged diff. Needs a Bash grant, so it only runs where Claude Code has a sandbox (macOS, Linux, WSL2), not native Windows.
tags: [needs-bash]
plugins: ["../..", "../../../core"]
max_turns: 6
allowed_tools: [Skill]
---

/quartermaster-ledger:git-commit T2
