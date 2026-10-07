---
name: clang-format
description: "Use when asked to format or run clang-format on specific files, uncommitted changes, or the whole repo, or to set up a .clang-format for a C++ project."
when_to_use: "\"format this\", \"run clang-format\", \"set up a .clang-format\". Files Claude edits are already formatted automatically at the end of each turn by this plugin's hook, so this is for explicit runs only."
argument-hint: "[paths...]"
context: fork
model: haiku
background: false
allowed-tools: Bash(clang-format *) Bash(git diff *) Bash(git ls-files *)
---

# clang-format

Apply clang-format to: $ARGUMENTS

Runs `clang-format -i` against the project's `.clang-format`
(BasedOnStyle: Google, 4-space indent, 120-col — see the `cpp-coding-standards`
skill's `references/coding-style.md`).

This plugin's hook already formats every C++ file Claude edits, once at the end
of each turn. This skill covers what the hook doesn't: files edited by hand,
explicit whole-repo runs, and projects without a `.clang-format` yet.

## Resolving the file set
C++ extensions: `.cpp`, `.cc`, `.cxx`, `.h`, `.hh`, `.hpp`, `.ixx`.

- Explicit paths given (`$ARGUMENTS`) → use exactly those.
- Otherwise, uncommitted changes exist → `git diff --name-only` +
  `git diff --cached --name-only`, filtered to C++ extensions.
- Otherwise (explicit whole-repo request only) → `git ls-files`, filtered to
  C++ extensions. Skip vendored and generated code: anything under
  `third_party/`, `external/`, `vendor/`, or `build/`.

## Running
`clang-format -i --style=file --fallback-style=none <files>` in one invocation.

- `clang-format` not on PATH → say so and stop; don't guess a path.
- No `.clang-format` (or `_clang-format`) at the repository root → format
  nothing. Report that the project has none and that a reference config
  matching these conventions ships at
  `${CLAUDE_SKILL_DIR}/assets/.clang-format`, so it can be copied to the
  repository root if the user wants it.

## Reporting
clang-format is silent on success, so report via `git diff --stat` after
running: which files actually changed. Don't enumerate untouched files.

## What not to do
- Don't reformat files outside the requested scope.
