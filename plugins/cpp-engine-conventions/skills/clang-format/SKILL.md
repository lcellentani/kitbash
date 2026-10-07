---
name: clang-format
description: "Apply the project's .clang-format style via `clang-format -i`. Use when asked to format or run clang-format, after writing/editing .cpp/.hpp/.cc/.hh/.cxx/.h/.ixx files, or before committing C++ changes."
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

## Resolving the file set
C++ extensions: `.cpp`, `.cc`, `.cxx`, `.h`, `.hh`, `.hpp`, `.ixx`.

- Explicit paths given (`$ARGUMENTS`) → use exactly those.
- Otherwise, uncommitted changes exist → `git diff --name-only` +
  `git diff --cached --name-only`, filtered to C++ extensions.
- Otherwise (explicit whole-repo request only) → `git ls-files`, filtered to
  C++ extensions. Skip vendored and generated code: anything under
  `third_party/`, `external/`, `vendor/`, or `build/`.

## Running
`clang-format -i <files>` in one invocation. If `clang-format` isn't on
PATH, or the project has no `.clang-format`, say so and stop — don't guess a
path or fall back to a built-in style.

## Reporting
clang-format is silent on success, so report via `git diff --stat` after
running: which files actually changed. Don't enumerate untouched files.

## What not to do
- Don't run on every micro-edit mid-task — batch at a natural checkpoint
  (end of turn, before a commit).
- Don't reformat files outside the current change scope.
