# Skill improvement recommendations — 2026-10-07

Audit of all kitbash skills against the Claude Code docs (skills, plugin manifest, plugin loading,
plugin evals) as of Claude Code 2.1.292, plus the `superpowers:writing-skills` and `skill-creator`
guidance. Numbering is stable — reference items by number.

Legend: ✅ done · ⬜ open. 🔴 changes behavior now · 🟡 worth doing · ⚪ optional.

## Phase 1 — done (2026-10-07)

- ✅ 1 🔴 `cpp-coding-standards` naming examples contradicted `references/coding-style.md`
  (`tcp_connection`, `max_buffer_size`, `PI`/`MAX_SENSORS`, lowercase enumerators, `lookup_table`).
  Aligned to PascalCase types / `kMixedCase` constants / PascalCase enumerators.
- ✅ 2 🔴 Source-project leakage removed: `clang-format`'s hard-coded `src/`, `test_*.cpp`,
  `wizard_of_oz_demo.cpp` (now `git ls-files` minus vendored/build dirs); ECS/render-pass/`ghost-chase-ai`
  examples in `spec-new`, its template, and `plan-draft` made domain-neutral.
- ✅ 3 🔴 `git-commit` description now says it drafts the message only (no `git commit`). Kept
  model-invocable per the earlier explicit choice.
- ✅ 7 🔴 `model: haiku` overrides the model for the rest of the turn. Dropped from `git-commit`;
  `clang-format` now runs as `context: fork` + `model: haiku` + `background: false`.
- ✅ 8 🔴 Slash references namespaced (`/spec-plan-workflow:plan-draft`, …), including the templates.
- ✅ 9 🔴 `spec-review` / `plan-review` run as `context: fork`, `agent: Explore`, `background: false`;
  stale "Task tool" wording removed. `plan-draft` research delegates to an Explore subagent.
- ✅ 10 (partial) `argument-hint` on all user-facing skills; `allowed-tools` on `git-commit` and
  `clang-format`.
- ✅ 11 Templates referenced via `${CLAUDE_SKILL_DIR}/assets/template.md`.
- ✅ 14 Dev loop documented in CLAUDE.md: develop with `--plugin-dir`, publish with bump + push (Option A).
- ✅ 17 🔴 `git-commit` injects `git diff --cached` via `` !`…` `` (verified: 1 turn, no tool calls;
  empty stage handled).
- ✅ 23 🔴 `.ixx` added to `clang-format`'s extension list.

Smoke-tested headlessly with `claude -p --plugin-dir …` in a scratch repo: `git-commit` (staged +
empty), `clang-format` (fork formatted the file), `spec-review` (fork returned findings).

## Phase 2 — done (2026-10-07)

- ✅ 22 🔴 `hooks/hooks.json`: `PostToolUse(Edit|Write)` records C++ files Claude edits to a per-session
  list in `${CLAUDE_PLUGIN_DATA}`; `Stop` runs `clang-format -i --style=file --fallback-style=none` on
  them once per turn. Scoped to Claude's own edits (hand edits untouched), skips vendored dirs, no-op
  without a `.clang-format` or `clang-format` on PATH, always exits 0. `.gitattributes` keeps `*.sh` LF.
  The skill now covers explicit runs only.
- ✅ 24 🟡 Reference `.clang-format` (from flatline, which mirrors `coding-style.md`) ships in
  `skills/clang-format/assets/`; the skill points to it when a project has none.
- ✅ Style doc ↔ config gaps closed: "two blank lines between top-level declarations" was unenforceable
  (clang-format can't insert a second line; `MaxEmptyLinesToKeep: 1` removed it) → doc now says one,
  config adds `SeparateDefinitionBlocks: Always`. Google's `AllowShortFunctionsOnASingleLine: All`
  collapsed out-of-class bodies → `Inline`. Doc examples now use `template <…>` (clang-format's
  Google output, and what flatline's own code uses). All "correct" doc examples are clang-format-stable.

Verified: script unit test (filtering, dedupe, cleanup) and a live `claude -p --plugin-dir` run where a
Claude-written file was formatted at Stop and an untouched file wasn't.

## Phase 3 — done (2026-10-07)

- ✅ 4 / 25 🔴 `cpp-coding-standards` SKILL.md 749 → 86 lines: project naming cheat sheet, cross-cutting
  principles, a "read this file when deciding X" index, and the checklist. The 13 Core Guidelines
  sections moved verbatim into 10 `references/*.md` files (each says `coding-style.md` wins on naming).
  The C++20 module file layout — a project convention, not a Core Guideline — moved into
  `coding-style.md`. Verified: no guideline content lost (line-level diff); live `claude -p` run read
  only coding-style + concurrency + source-files for a thread-safe header and followed every convention.

## Phase 4 — done (2026-10-07)

- ✅ 13 🟡 `claude plugin eval` suites (run commands in CLAUDE.md), one run per arm, ~$3 list-price total:

  | Plugin | Case | With | W/out | Δ |
  |---|---|---|---|---|
  | core | tier-from-description | 1.00 | 0.00 | +1.00 |
  | cpp-engine-conventions | hook-formats-claude-edits | 1.00 | 0.00 | +1.00 |
  | cpp-engine-conventions | naming-conventions (2 runs/arm) | 1.00 | 0.60 | +0.40 |
  | spec-plan-workflow | plan-draft-from-spec | 1.00 | 0.00 | +1.00 |
  | spec-plan-workflow | spec-new-writes-spec | 1.00 | 0.00 | +1.00 |
  | spec-plan-workflow | spec-review-flags-gaps | 1.00 | 1.00 | 0.00 |
  | quartermaster-ledger | commit-message-format | — | — | needs-bash, not run on Windows |

  Findings: (a) a plugin with `dependencies` doesn't load when evaluated from its own dir — cases list
  both plugin dirs and run from `plugins/`; (b) naming Δ comes from the two places the conventions
  differ from Google style (snake_case methods, PascalCase enumerators) — Claude already matches the
  rest unaided; (c) spec-review's planted gaps are found without the skill too.

## Phase 5 — done (2026-10-07)

- ✅ 16 🟡 `core:delegation-tiers`: "Telling adjacent tiers apart" section with one discriminator per
  boundary (who wrote the landed code, who read it); description rewritten as a trigger, phrases in
  `when_to_use`. New eval cases `tier-boundary-t4` / `tier-boundary-t2`: with 1.00, without 0.00 (Δ +1.00).
- ✅ 18 🟡 `git-commit`: a missing/invalid tier argument no longer stops with a bare question. It
  proposes a tier from the conversation (T2 guess if no evidence) and confirms via `AskUserQuestion`
  (mandatory; `allowed-tools` extended). New `needs-bash` case `tier-proposed-when-missing` — written,
  **not run** (no Bash sandbox on native Windows); run it under WSL2.
- ✅ 12 🟡 All 9 descriptions lead with triggers; phrase lists and workflow summaries moved to
  `when_to_use`. Validate passes; spec-plan-workflow and cpp-engine-conventions evals unchanged
  (plan-draft +0.60, spec-new +0.25, spec-review 0.00, hook +1.00, naming +0.40). `/skill-doctor` not run.

## Open

- ⬜ 13b ⚪ spec-review eval with subtler gaps (unstated assumptions, status mismatch hidden in prose) so
  its Δ measures the checklist, not obvious problems.


- ⬜ 25b 🟡 Trim the per-area references to what Claude doesn't already know. Eval evidence so far: the
  naming table earns its place (Δ +0.40); add a case per reference area before cutting any of them.
- ⬜ 15 ⚪ `claude plugin validate --strict`; look at `claude plugin tag` for the v0.1.0 tag.
- ⬜ 19 ⚪ quartermaster-ledger cost reporting toolbox: `Stop`/`SessionEnd` hooks → `${CLAUDE_PLUGIN_DATA}`,
  `${CLAUDE_SESSION_ID}`, `PreToolUse` hook enforcing `[Tn]` on `git commit`.
- ⬜ 20 🟡 Inject review targets (`` !`git diff -- docs/plans/` ``) into the forked reviews.
- ⬜ 21 ⚪ `userConfig` for `specs_dir` / `plans_dir` if a project ever needs different folders.
- ⬜ 26 🟡 `paths:` globs on both C++ skills so they auto-load only around C++ files.
- ⬜ 27 🟡 Pin the marketplace to a tag/ref so `v*` tags are a real stability boundary (today every
  project tracks `main` on `/plugin marketplace update`). Check the marketplace-source ref syntax first.

## Release

- ✅ 5 / 6 / 15 Tagged `v0.1.0` (2026-10-07) after the eval suites and an external install-and-exercise
  check in `flatline` from the GitHub-installed copies: core tier answer, git-commit empty-stage
  injection, spec-new Draft spec, forked spec-review, and the Stop hook formatting a Claude-written file.
