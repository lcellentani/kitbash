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

## Open


- ⬜ 25b 🟡 Trim the per-area references to what Claude doesn't already know — needs the #13 eval
  (with/without the skill) to decide; content was moved verbatim in phase 3, not trimmed.
- ⬜ 12 🟡 Descriptions: lead with triggers, don't summarize the workflow (agents may follow the
  description instead of the body); move trigger phrases to `when_to_use`; check with `/skill-doctor`.
- ⬜ 13 🟡 `claude plugin eval` suite per plugin (`evals/<case>/prompt.md` + `graders/*.md`; 2–3 cases
  per skill; `--ablation none --runs 1` while iterating; `--max-cost-usd`). Bash-granting cases need
  WSL2 (no sandbox backend on native Windows). Add `evals/**/results/` to `.gitignore`. Doubles as the
  pre-v0.1.0 end-to-end proof.
- ⬜ 15 ⚪ `claude plugin validate --strict`; look at `claude plugin tag` for the v0.1.0 tag.
- ⬜ 16 🟡 `core:delegation-tiers`: one-line discriminators for T2/T3 and T3/T4 boundaries; description
  phrased as when-to-use.
- ⬜ 18 🟡 `git-commit`, model-invoked with no tier: propose a tier with rationale, confirm via
  `AskUserQuestion`.
- ⬜ 19 ⚪ quartermaster-ledger cost reporting toolbox: `Stop`/`SessionEnd` hooks → `${CLAUDE_PLUGIN_DATA}`,
  `${CLAUDE_SESSION_ID}`, `PreToolUse` hook enforcing `[Tn]` on `git commit`.
- ⬜ 20 🟡 Inject review targets (`` !`git diff -- docs/plans/` ``) into the forked reviews.
- ⬜ 21 ⚪ `userConfig` for `specs_dir` / `plans_dir` if a project ever needs different folders.
- ⬜ 26 🟡 `paths:` globs on both C++ skills so they auto-load only around C++ files.
- ⬜ 5 ⚪ Versions are 0.2.0/0.3.0 in manifests but nothing is tagged — reconcile at v0.1.0 tagging.
- ⬜ 6 Release gate (CLAUDE.md): external-project install + exercise for all four plugins.
