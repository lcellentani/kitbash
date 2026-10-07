---
description: With no tier argument, git-commit proposes a tier and confirms it through AskUserQuestion instead of drafting immediately. Needs a Bash grant, so it only runs where Claude Code has a sandbox (macOS, Linux, WSL2), not native Windows.
tags: [needs-bash]
plugins: ["../..", "../../../core"]
max_turns: 6
allowed_tools: [Skill]
---

/quartermaster-ledger:git-commit
