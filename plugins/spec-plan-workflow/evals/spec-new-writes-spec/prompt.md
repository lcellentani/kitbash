---
description: spec-new turns a fully specified feature into a Draft SPEC at the conventional path.
tags: [spec]
plugins: ["../..", "../../../core"]
max_turns: 12
timeout_seconds: 480
allowed_tools: [Read, Glob, Grep, Skill, Write]
---

Write a spec for a new feature called "undo history" in this repo. I've already answered everything, so don't ask me anything else:

- Problem: users of our text editor can't undo edits; one mistake means retyping.
- Success: Ctrl+Z undoes the last edit and Ctrl+Shift+Z redoes it, for at least 100 steps, with each step applying in under 16 ms.
- Out of scope: undo across sessions, collaborative editing, a visible history panel.
- It builds on the existing command dispatcher that every text edit already goes through.
- Still undecided: whether redo survives a new edit after an undo.
