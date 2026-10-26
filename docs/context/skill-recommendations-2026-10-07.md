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
  **Verified in real use (2026-10-25 check):** in `flywheel`, from the installed 0.4.0 copy (commit
  `d045d73`), sessions on 2026-10-08 and 2026-10-12 called `git-commit` with no tier; it asked "Which
  delegation tier for this commit?" with a conversation-based `T4 (Recommended)` option, and `core` was
  auto-installed as a dependency. The eval stays useful as a regression guard, not as the only proof.
- ✅ 12 🟡 All 9 descriptions lead with triggers; phrase lists and workflow summaries moved to
  `when_to_use`. Validate passes; spec-plan-workflow and cpp-engine-conventions evals unchanged
  (plan-draft +0.60, spec-new +0.25, spec-review 0.00, hook +1.00, naming +0.40). `/skill-doctor` not run.

## Phase 6 — in progress (items 15 + 27)

Deliberately **not** executed in the session that logged it. The two items are coupled and the real work
is deciding a release model, so it needs a dedicated session with room to explore the problem, weigh
trade-offs and decide at a deliberate pace — not a quick edit pass. 2026-10-25: ref syntax researched,
release model decided (see "Findings", "Release model" and "Release checklist" below); setup steps 2–6
done, the end-to-end proof remains.

- ⬜ 15 ⚪ `claude plugin validate --strict` and `claude plugin tag`.
- ⬜ 27 🟡 Pin the marketplace to a tag/ref so `v*` tags are a real stability boundary (today every
  project tracks `main` on `/plugin marketplace update`).

### What 15 is

Release hygiene, two halves:

1. **`--strict` validation.** Plain `validate` only checks manifests are well-formed; `--strict` is the
   stricter pre-release check. Status: already run (2026-10-07) on all four plugins and on the root
   marketplace manifest — **all five pass**. Nothing to fix; it remains to make it a standing
   pre-release step (e.g. written into CLAUDE.md's Commands).
2. **`claude plugin tag`.** Creates a `{plugin}--v{version}` git tag per plugin (e.g. `core--v0.2.0`),
   after checking that `plugin.json` and the enclosing marketplace entry agree on the version. Options:
   `--dry-run`, `--push`, `--remote`, `-m/--message`, `-f/--force`; it refuses a dirty tree or an
   existing tag unless forced. The audit asked to look at it for the `v0.1.0` tag; that tag was made by
   hand instead (repo-wide, `v0.1.0`, the only tag today), so the tool has never been used here.

### How 15 and 27 connect

- **Pinning needs something to pin to.** 27 only helps if the ref it points at is meaningful. That
  depends on 15's tagging scheme.
- **`claude plugin tag` enforces the `plugin.json` ↔ marketplace-entry version agreement**, which is the
  guard that keeps a pin honest.
- Current versions differ per plugin (core 0.2.0, cpp-engine-conventions 0.5.0, quartermaster-ledger
  0.4.0, spec-plan-workflow 0.3.0), and the one existing tag is a single repo-wide `v0.1.0`. The two
  tag models don't line up: per-plugin tags (`core--v0.2.0`) describe releases accurately; a repo-wide
  tag is simpler to pin a marketplace to.

### Open questions — all decided 2026-10-25

1. **Ref syntax.** What does a marketplace-source ref look like (tag, branch, commit; in `marketplace.json`
   and in `/plugin marketplace add`)? Check the docs first — it decides which tagging model can work at all.
   → Answered, see Findings.
2. **Tagging model.** One repo-wide tag per release, per-plugin tags via `claude plugin tag`, or both
   (per-plugin tags for history, a repo-wide tag as the pin target)?
   → **Decided:** per-plugin tags as the record, a `release` branch as the pin target (see Release model).
3. **Trade-off to confirm.** Pinning stops `/plugin marketplace update` from tracking `main`; every
   project then needs its pin moved to receive changes. That is the price of stability. Today every
   project follows `main` automatically — confirm the new friction fits the workflow, and how pin bumps
   are done (per project, or once if the pin lives in the marketplace registration).
   → **Accepted.** With a `release` branch the pin never moves per machine; the friction is one
   fast-forward per release. The model relies on discipline, which is acceptable because it is written
   down as a checklist and its risky steps are checked by `git` and `claude plugin tag` (see Release
   checklist).
4. **Existing `v0.1.0`.** Keep as-is, retag, or leave as history once a new scheme exists.
   → **Decided:** keep as history; no mechanism reads a repo-wide tag except a marketplace-level `#ref`.
5. **`core` version ranges** in `quartermaster-ledger` / `spec-plan-workflow` (raised by the Findings).
   → **Decided: not now.** All three ship from the same `release` branch, so they are always released
   and tested together; a range only guards against `core` being released apart from its dependents.
   Revisit if `core` ever makes a breaking change.

### Findings (2026-10-25, docs on code.claude.com + `claude` 2.1.310)

Sources: plugins/marketplace-reference, plugins/host-marketplace, plugins/dependencies.

- **Marketplace-level pin.** `/plugin marketplace add lcellentani/kitbash#<ref>` (`@<ref>` also accepted)
  stores `"ref"` (branch or tag) on the marketplace source; default is the repo's default branch. It
  pins the catalog *and* every relative-path plugin, since `./plugins/<name>` resolves inside that
  checkout. The pin lives in each machine's registration (or `extraKnownMarketplaces`).
- **Entry-level pin.** `github`, `url` and `git-subdir` plugin sources take `ref` (branch or tag) and
  `sha` (full 40-char commit; wins over `ref`). For this monorepo that means
  `{ "source": "git-subdir", "url": "lcellentani/kitbash", "path": "plugins/core", "ref": "core--v0.2.0" }`.
  Relative-path sources can't carry a ref. Non-relative entries show only the entry's own fields in
  `/plugin` before install.
- **Updates are detected by computed `version`, not ref.** A moved pin with an unchanged `version` leaves
  users on their cached copy. Every release still needs the bump.
- **`<plugin>--v<version>` tags are the official convention.** `claude plugin tag` creates them after
  validating, checking `plugin.json` ↔ marketplace entry version agreement, requiring a clean tree and
  refusing an existing tag. Dependency version ranges (e.g. `{ "name": "core", "version": "^0.2" }`)
  resolve against these tags; for a relative-path dependency with no matching tag, the marketplace's
  current copy is used and the range is checked at load.
- **Dry run at `7126272`** (all four pass the version-agreement check): `core--v0.2.0`,
  `quartermaster-ledger--v0.4.0`, `spec-plan-workflow--v0.3.0`, `cpp-engine-conventions--v0.5.0`.

### Release model (decided 2026-10-25, not yet set up)

- **`release` branch as the distribution pointer.** Each machine registers `lcellentani/kitbash#release`
  once. `marketplace.json` stays on relative paths. `main` is where work happens; nothing on it reaches
  an install (existing or fresh) until `release` moves. This is the docs' release-channel pattern with
  a single channel.
- **Per-plugin tags as the record.** Each release commit gets `<plugin>--v<version>` tags via
  `claude plugin tag --push` for the plugins it bumps: fixed points to diff or roll back to, and the
  targets dependency ranges would resolve against if they are ever added.
- **Rule:** `release` only ever fast-forwards from `main`; never commit on it directly. Otherwise the same
  version number can again mean different content.
- **Mechanical guards** behind the rules, so the protocol doesn't rest on memory alone:

  | Rule | Guard |
  |---|---|
  | `release` only fast-forwards from `main` | Release with `git push origin main:release` — git rejects a non-fast-forward without `--force`. A GitHub ruleset on `release` blocks force-push and deletion. |
  | Every changed plugin gets a version bump | `git diff <plugin>--v<version>..main -- plugins/<plugin>`: changes since the last tag with an unchanged version mean a missed bump. `claude plugin tag` also refuses an existing tag. |
  | `plugin.json` and marketplace entry agree | `claude plugin tag` checks it before tagging. |
  | Manifests are valid | `claude plugin validate --strict`, first step of the checklist. |

  If steps ever get skipped in practice, turn the checklist into a project-local `release` skill.
- Rejected alternative: per-entry `git-subdir` pins to tags — fixed per-plugin pins and no per-machine
  step, but a catalog edit per release and non-relative entries. Revisit if plugins ever need to
  release on independent lines.

### Release checklist (goes into CLAUDE.md in setup step 5)

1. On `main`, clean tree, up to date with `origin/main`.
2. For each plugin, `git diff <plugin>--v<version>..main -- plugins/<plugin>`. Any plugin with changes
   gets a `version` bump in its `plugin.json`; commit the bumps.
3. `claude plugin validate --strict` on each plugin and on the repo root (marketplace manifest).
4. `git push origin main` then `git push origin main:release` (fast-forward only; never `--force`).
5. `claude plugin tag plugins/<plugin> --push` for each bumped plugin.
6. `/plugin marketplace update kitbash` on each machine (or rely on auto-update), then `/reload-plugins`.

### Setup steps

1. ✅ Decide the model and the open questions (2026-10-25).
2. ✅ (2026-10-25) `release` created at `4977147` (= `main`) and pushed. Tags `core--v0.2.0`,
   `quartermaster-ledger--v0.4.0`, `spec-plan-workflow--v0.3.0`, `cpp-engine-conventions--v0.5.0`
   created with `claude plugin tag --push`, all at `4977147`.
3. ✅ (2026-10-25) GitHub ruleset "release branch protection" (id 25827063) on `refs/heads/release`:
   `non_fast_forward` + `deletion`, no bypass actors — it applies to the owner too.
4. ✅ (2026-10-25, this Windows machine) Registration now `lcellentani/kitbash@release`; all four
   plugins enabled at the same versions. How to migrate a machine (repeat on others):
   - Add `"ref": "release"` to the `kitbash` source under `extraKnownMarketplaces` in
     `~/.claude/settings.json`. Don't use `marketplace remove` (it uninstalls the plugins).
   - Then start a **new interactive** `claude` session: its background check sees the changed source,
     re-fetches from `release` and says `Plugins changed. Run /reload-plugins to activate.` Run
     `/reload-plugins`.
   - Gotcha: until that happens, shell commands compare the new settings against the stale
     `known_marketplaces.json` — `claude plugin marketplace update kitbash` reports
     `Marketplace 'kitbash' not found` and `claude plugin list` shows the plugins as
     `failed to load`. Expected; it clears after the re-fetch. Back up `settings.json` first.
5. ✅ (2026-10-25) Release model, checklist and machine migration documented in CLAUDE.md (Current
   state, Commands, Versioning); README's add command and Versioning updated to `#release`.
6. ✅ Rollback answered by step 3: `release` can't move backwards (no force-push, even for the owner),
   so rollback = revert on `main`, bump the version, release forward. The "does an update apply a lower
   version" question no longer matters.
7. ⬜ Prove end-to-end from an external project (as done for v0.1.0 in `flatline`): install from
   `#release`, push an unreleased change to `main` and confirm it doesn't arrive, release it and
   confirm it does.


## Open

- ⬜ 13b ⚪ spec-review eval with subtler gaps (unstated assumptions, status mismatch hidden in prose) so
  its Δ measures the checklist, not obvious problems.


- ⬜ 25b 🟡 Trim the per-area references to what Claude doesn't already know. Eval evidence so far: the
  naming table earns its place (Δ +0.40); add a case per reference area before cutting any of them.
  **Approach replaced (2026-10-25):** review-first classification with regression evals instead of a
  case per area — see `docs/specs/cpp-standards-trim.md` and its log
  `docs/context/cpp-standards-trim-log.md`.
- ⬜ 19 ⚪ quartermaster-ledger cost reporting toolbox: `Stop`/`SessionEnd` hooks → `${CLAUDE_PLUGIN_DATA}`,
  `${CLAUDE_SESSION_ID}`, `PreToolUse` hook enforcing `[Tn]` on `git commit`.
- ⬜ 20 🟡 Inject review targets (`` !`git diff -- docs/plans/` ``) into the forked reviews.
- ⬜ 21 ⚪ `userConfig` for `specs_dir` / `plans_dir` if a project ever needs different folders.
- ✖ 26 🟡 `paths:` globs on both C++ skills so they auto-load only around C++ files. **Won't do**
  (2026-10-25, tested on 2.1.310 with `--plugin-dir`): `paths:` is ignored for plugin skills — they stay
  unconditional even with a never-matching glob. For project skills it hides the skill until a matching
  file is touched (Read/Write/Edit), so a "write widget.h" prompt in an empty folder gets the skill only
  after the file is written, and it blocks explicit `/name` until then. Both would hurt the C++ skills
  if plugins ever honour it. See `docs/specs/cpp-standards-trim.md`.

## Release

- ✅ 5 / 6 / 15 Tagged `v0.1.0` (2026-10-07) after the eval suites and an external install-and-exercise
  check in `flatline` from the GitHub-installed copies: core tier answer, git-commit empty-stage
  injection, spec-new Draft spec, forked spec-review, and the Stop hook formatting a Claude-written file.
