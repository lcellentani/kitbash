# Trim C++ standards to project-specific content — Implementation Plan

| Field | Value |
|-------|-------|
| **Spec** | `docs/specs/cpp-standards-trim.md` |
| **Date** | 2026-10-26 |
| **Status** | Not Started |
| **Effort** | 3–4 sessions, plus ≈ $10–15 of eval runs |

---

## 1. Overview

### Goal

`cpp-coding-standards` ships only *keep* and *move* rules, with every rule's fate recorded in a
classification log. `errors.md` carries the expected-based error policy, and the memory and concurrency
policies replace the guideline restatements in `resources.md` and `concurrency.md`. The evals show no
regression plus a positive Δ on a new resource-and-errors case. The result ships as
`cpp-engine-conventions` 0.6.0 through the release checklist, which proves Phase 6 step 7 end to end in
`flywheel`.

### Approach

- Test-first: write the new eval case against the three decided policies before touching the skill, and
  run it once against 0.5.0, so the trim has a target that fails today.
- The classification log (`docs/context/cpp-standards-trim-log.md`) is written and reviewed before any
  reference file changes. The trim only applies what the reviewed log says.
- Keep filenames where an area survives (`errors.md`, `resources.md`, `concurrency.md` take the
  policies). No renames, so the `SKILL.md` index and the `.clang-format` comment change as little as
  possible.
- Reuse the existing eval layout (`prompt.md` + regex graders, no `case.yaml`/`setup.sh`, like
  `naming-conventions`). Reuse the CLAUDE.md release checklist unchanged. The only addition is a pause
  between pushing `main` and pushing `release`, to observe that nothing arrives.
- Commits from Phases 1–4 go to `main` freely. Installs track `release`, so none of them reach
  `flywheel` until Phase 5.

### Scope

**In Scope:**
- the classification log;
- trimmed `SKILL.md` and `references/`;
- the three policies;
- the new eval case;
- regression evals (3 runs per arm);
- the 0.6.0 release and end-to-end proof in `flywheel`;
- audit-doc updates (item 25b done, Phase 6 step 7 done).

**Out of Scope** (from the spec's Non-Goals):
- `coding-style.md`'s existing conventions;
- `.clang-format` and the hook;
- per-area evals;
- `paths:`;
- migrating `flywheel`'s `throw`s;
- compiler exception flags;
- other plugins and audit items.

---

## 2. Phased Task Breakdown

### Phase 1: Baseline and test-first eval case — Not Started

**Objective:** Record the before state and add a failing eval case that encodes the decided policies.

#### Task 1.1: Start the classification log with before-sizes

**New File:** `docs/context/cpp-standards-trim-log.md`
**Tag:** T4 — mechanical: line counts and a document skeleton, no judgment.

**Changes:**
- Header linking the spec and plan. A "Sizes" table with `wc -l` per file for `SKILL.md` and all 11
  references, before column filled.
- Empty per-area sections (`SKILL.md` body + 10 references), each a table: rule (ID or short text) |
  outcome | criterion (a/b/c) | basis | reason.
- Correct the spec's Problem statement: the 10 references total 696 lines, not 716. Set the spec's
  **Plan** field to `docs/plans/cpp-standards-trim.md`.

**Acceptance Criteria:**
- The log exists, and its before-sizes match `wc -l` (references other than `coding-style.md` total 696,
  `SKILL.md` 87, `coding-style.md` 275).
- The spec says 696 and links this plan.

#### Task 1.2: Confirm the end-to-end precondition in `flywheel`

**File:** none (observation, recorded in the log)
**Tag:** T4 — a read-only check against a stated expectation.

**Changes:**
- From `flywheel`, run `claude plugin list` and `claude plugin marketplace list`, and record the output
  in the log.

**Acceptance Criteria:**
- `cpp-engine-conventions@kitbash` is 0.5.0 and enabled, and the `kitbash` marketplace source shows ref
  `release`. If not, stop and fix the install before Phase 5 depends on it: follow the machine-migration
  steps in CLAUDE.md "Versioning" if the ref is missing, or `/plugin install
  cpp-engine-conventions@kitbash` if the plugin is.

#### Task 1.3: Add the `resource-and-errors` eval case

**New Files:** `plugins/cpp-engine-conventions/evals/resource-and-errors/prompt.md`, `graders/*.md`
**Tag:** T2 — the graders decide what "the policy changed behavior" means, so the user owns which checks
count. Claude drafts them.

**Changes:**
- `prompt.md` frontmatter modeled on `naming-conventions`: `tags: [cpp, standards]`, `max_turns: 15`,
  `timeout_seconds: 480`, `allowed_tools: [Read, Glob, Grep, Skill, Write]`.
- Prompt: a C++20 project. Write `texture_loader.h`, with a class that owns a texture loaded from disk
  and reports load failures to its caller. Follow the project's C++ coding standards, and don't compile
  or test.
- Regex graders, *keep* rules only, each with `target: { source: file, path: texture_loader.h }`:
  - `skill-fired`: copied from `naming-conventions`;
  - `no-throw`: `not_contains` a throw *statement*, `\bthrow\s+[\w:{(]|\bthrow\s*;`. A comment such as
    "never throws" doesn't match;
  - `uses-expected`: `(std|tl)::expected<`;
  - `error-enum-class`: an `enum class \w*Error`.
- No case for memory or concurrency. Their rules are conditional on arenas or a job system, which this
  prompt doesn't set up.

**Acceptance Criteria:**
- `claude plugin validate ./plugins/cpp-engine-conventions` passes.
- From the plugin dir,
  `claude plugin eval . --trust-plugin --runs 1 --case resource-and-errors --allow-tools Write --max-cost-usd 2`
  runs both arms. Both scores are recorded in the log as the 0.5.0 baseline.
- With-plugin < 1.00 on 0.5.0, since its `errors.md` prescribes exceptions.
- **Stop condition:** if without-plugin already scores 1.00, the case can't show a Δ. Revise the prompt
  or graders, with the user, before Phase 2.

**Rollback:** git revert the Phase 1 commit(s).

---

### Phase 2: Classification — Not Started

**Objective:** Classify every rule as keep, move or cut, and get the log approved before any file
changes.

#### Task 2.1: Classify the `SKILL.md` body and the 10 references

**File:** `docs/context/cpp-standards-trim-log.md`
**Tag:** T3 — Claude applies the spec's criteria rule by rule; the user's review in 2.2 is the gate.

**Changes:**
- One row per rule (Key Rules table row, bullet or numbered item; code examples go with their rule)
  across all sections of `SKILL.md`, including:
  - the Cross-Cutting Principles;
  - the 19-item checklist;
  - the "When to Use" mention of "exceptions vs error codes".
- Known conflicts, classified explicitly:
  - `errors.md` E.2/E.14/E.15/E.17 and the `AppError` hierarchy → cut, replaced by the policy;
  - `resources.md`'s throwing `FileHandle` and R.20–R.22 → cut or replaced by the memory policy;
  - `concurrency.md`'s blocking `ThreadSafeQueue` → cut, replaced by the concurrency policy;
  - `SKILL.md` checklist line 85 ("custom exception types") → cut;
  - lines 70 and 84 → classify against the new policies.
- `source-files.md`'s project content goes to *move*, to `coding-style.md`, unless it already exists
  there. This covers the NL.10 row, the `PROJECT_MODULE_WIDGET_H` guard and the naming example, which
  uses `namespace my_project` against `project::module`.
- The per-file line-3 boilerplate is classified once, as a group.
- A summary per file: keep/move/cut counts, and whether the file survives.

**Acceptance Criteria:**
- Every rule in the 11 sources has exactly one row. Each *keep* names its criterion, and each (b)/(c)
  keep names its basis.
- Every file that ends with zero *keep* rows is marked for deletion.

#### Task 2.2: User review of the log

**File:** `docs/context/cpp-standards-trim-log.md`
**Tag:** T1 — the keep/cut judgments are the user's to approve; this task is that decision.

**Changes:**
- The user reads the log. Claude applies any reclassifications, and the log is marked "Approved
  (date)".

**Acceptance Criteria:**
- The log header says Approved, and no row is left unresolved.

**Rollback:** git revert the Phase 2 commit(s).

---

### Phase 3: Apply the trim — Not Started

**Objective:** Make the shipped files match the approved log.

#### Task 3.1: Write the three policy files

**Files:** `references/errors.md`, `references/resources.md`, `references/concurrency.md`
**Tag:** T3 — the policy text is fixed by the spec's Design. Claude writes it as reference prose with
short examples, and the user reviews it.

**Changes:**
- `errors.md`:
  - the error-handling policy (assert / `optional` / `expected<T, Error>` / log and abort / no
    exceptions);
  - one short example, an `enum class` error with context and a `TRY`-style propagation;
  - the surviving *keep* rows (e.g. E.12, E.16 if kept).
- `resources.md`: the memory policy, including the default as a context line, plus the surviving *keep*
  rows.
- `concurrency.md`: the concurrency policy, with the same structure.

**Acceptance Criteria:**
- Each file states its policy's bullets from the spec. None of the three contains `throw` outside an
  explicit "don't".
- Every non-policy line traces to a *keep* row in the log.

#### Task 3.2: Apply cuts, moves and deletions to the other references

**Files:** `references/*.md`, `references/coding-style.md`
**Tag:** T4 — mechanical execution of an approved log, verified by the acceptance check.

**Changes:**
- Delete *cut* rows and their examples. Move *move* rules into the right section of `coding-style.md`.
- Delete files with no *keep* rows.
- Fix or drop the line-3 boilerplate, per the log.

**Acceptance Criteria:**
- Every surviving rule in the shipped references has a *keep* or *move* row in the log, and every *cut*
  row is absent from the files.
- No surviving file is empty.

#### Task 3.3: Update `SKILL.md`

**File:** `plugins/cpp-engine-conventions/skills/cpp-coding-standards/SKILL.md`
**Tag:** T3 — mostly the log's verdicts. The index descriptions for the policy files are new wording,
which the user reviews.

**Changes:**
- Apply the log to Cross-Cutting Principles and the checklist.
- Drop index rows for deleted files.
- Reword the `errors.md`, `resources.md` and `concurrency.md` index rows to describe the policies.
- Reword "When to Use"'s "exceptions vs error codes".

**Acceptance Criteria:**
- Every reference in the index exists, and every existing reference is in the index.
- `grep -n "exception" SKILL.md` finds no prescriptive use of exceptions.
- `claude plugin validate --strict ./plugins/cpp-engine-conventions` passes.

#### Task 3.4: Record after-sizes

**File:** `docs/context/cpp-standards-trim-log.md`
**Tag:** T4 — mechanical.

**Changes:**
- Fill the after column with `wc -l`, and add the totals and the delta.

**Acceptance Criteria:**
- The after-sizes match `wc -l` on the working tree. Deleted files show as removed.

**Rollback:** git revert the Phase 3 commit(s).

---

### Phase 4: Eval verification — Not Started

**Objective:** Show no regression and a positive Δ on the new case, at 3 runs per arm.

#### Task 4.1: Full eval run, and the restore loop if needed

**File:** `docs/context/cpp-standards-trim-log.md` (results); references/log only if the restore rule
fires
**Tag:** T3 — Claude runs the evals and proposes restores; the user confirms any restore, because it
changes an approved classification.

**Changes:**
- From `plugins/cpp-engine-conventions`, run
  `claude plugin eval . --trust-plugin --runs 3 --allow-tools Write --max-cost-usd 10`.
- Record with/without/Δ per case in the log.
- If a goal fails, apply the spec's restore rule:
  1. Read the failing grader.
  2. Restore that area's log entries and file content.
  3. Rerun the affected case with `--case <name> --runs 3 --max-cost-usd 4`.

**Acceptance Criteria:**
- `naming-conventions`: Δ ≥ +0.40.
- `hook-formats-claude-edits`: with-plugin 1.00.
- `resource-and-errors`: with > without.
- All are means of 3 runs per arm, recorded in the log.
- `skill-fired` is > 0x in the with-plugin arm of `naming-conventions` and `resource-and-errors`.

**Rollback:** git revert the Phase 4 commit(s), which removes the results and any restores.

---

### Phase 5: Release 0.6.0 and end-to-end proof — Not Started

**Objective:** Ship 0.6.0 through the CLAUDE.md release checklist, and observe in `flywheel` that only
the release reaches installs.

#### Task 5.1: Bump, validate, push to `main` only

**File:** `plugins/cpp-engine-conventions/.claude-plugin/plugin.json`
**Tag:** T4 — checklist steps 1–4a, mechanical.

**Changes:**
- Checklist step 2: `git diff cpp-engine-conventions--v0.5.0..main -- plugins/cpp-engine-conventions`
  shows changes, so set `version` to `0.6.0` and commit. The diff for the other plugins is checked too:
  they're expected to be empty (they are as of 2026-10-26). If any has changed, stop and ask the user,
  because `main:release` would ship it and releasing other plugins is out of scope here. The marketplace
  entry carries no version, so there's nothing to keep in sync there.
- Step 3: `claude plugin validate --strict` on the plugin and on the repo root.
- Step 4, first half: `git push origin main` only.

**Acceptance Criteria:**
- `origin/main` has 0.6.0, and `origin/release` is still at its previous commit.

#### Task 5.2: Confirm an unreleased `main` doesn't arrive

**File:** none (observation, recorded in the log)
**Tag:** T2 — the user runs the interactive `/plugin` commands in `flywheel` and reports the result;
Claude only records it in the log.

**Changes:**
- In a `flywheel` session: `/plugin marketplace update kitbash`, then `claude plugin list`.

**Acceptance Criteria:**
- `cpp-engine-conventions` is still 0.5.0.

#### Task 5.3: Release and tag

**File:** none (git operations)
**Tag:** T4 — checklist steps 4b–5, mechanical, with git and the tag command enforcing the guards.

**Changes:**
- `git push origin main:release` (fast-forward; never `--force`).
- `claude plugin tag plugins/cpp-engine-conventions --push`.

**Acceptance Criteria:**
- `origin/release` equals `origin/main`, and the tag `cpp-engine-conventions--v0.6.0` exists on the
  remote.

#### Task 5.4: Confirm the release arrives and loads

**File:** none (observation, recorded in the log)
**Tag:** T2 — the user runs `/plugin marketplace update`, `/reload-plugins` and the C++ task in
`flywheel`; Claude only records the result.

**Changes:**
- In `flywheel`: run `/plugin marketplace update kitbash`, then `/reload-plugins`.
- Then give a small C++ task (e.g. "how should this loader report a missing file?"), which should load
  `cpp-coding-standards`.

**Acceptance Criteria:**
- `claude plugin list` shows 0.6.0.
- The skill loads from `~/.claude/plugins/cache/kitbash/cpp-engine-conventions/0.6.0/`, seen in the
  session's tool call or the transcript path.

#### Task 5.5: Close out the docs

**Files:** `docs/context/skill-recommendations-2026-10-07.md`, `docs/specs/cpp-standards-trim.md`, this
plan
**Tag:** T3 — Claude writes the summaries from recorded results; the user reviews.

**Changes:**
- Audit doc:
  - item 25b → ✅, with before/after sizes and eval results;
  - Phase 6 setup step 7 → ✅, citing the 5.2 and 5.4 observations. Whether to close items 15 and 27
    (Phase 6 itself) is a separate decision, outside this spec.
- Spec Status → Implemented, through `/spec-plan-workflow:plan-update`.

**Acceptance Criteria:**
- The audit doc has no ⬜ for 25b or step 7.
- The spec says Implemented, and the plan says Done.

**Rollback:** `release` can't move backwards. Revert on `main`, bump to 0.6.1, and release forward (CLAUDE.md
"Versioning"). The docs commit is reverted normally.

---

## 3. Files to Modify

All plugin paths are under `plugins/cpp-engine-conventions/`.

| Path | Purpose | Est. LOC | Risk |
|------|---------|----------|------|
| `docs/context/cpp-standards-trim-log.md` | **New**: sizes, classification, eval results, e2e observations | ~150 | Low |
| `docs/specs/cpp-standards-trim.md` | Fix 716→696; Plan link; Status at the end | ~3 | Low |
| `evals/resource-and-errors/prompt.md` | **New**: case prompt | ~15 | Low |
| `evals/resource-and-errors/graders/*.md` | **New**: 4 regex graders | ~30 | Medium |
| `skills/cpp-coding-standards/SKILL.md` | Apply log; index; checklist | −30 / +10 | Medium |
| `skills/cpp-coding-standards/references/errors.md` | Replace with error policy | −50 / +35 | Medium |
| `skills/cpp-coding-standards/references/resources.md` | Replace with memory policy | −60 / +25 | Medium |
| `skills/cpp-coding-standards/references/concurrency.md` | Replace with concurrency policy | −55 / +25 | Medium |
| `skills/cpp-coding-standards/references/{7 others}.md` | Cut/delete per log | up to −490 | Medium |
| `skills/cpp-coding-standards/references/coding-style.md` | Receives *move* rules | +0–20 | Low |
| `.claude-plugin/plugin.json` | 0.5.0 → 0.6.0 | 1 | Low |
| `docs/context/skill-recommendations-2026-10-07.md` | 25b, step 7, Phase 6 status | ~10 | Low |
| `docs/plans/cpp-standards-trim.md` | Status updates | — | Low |

---

## 4. Validation Checklist

### Functional
- [ ] The log has one row per rule, and it is approved (2.1, 2.2).
- [ ] The three policy files state their policies, and nothing in the skill prescribes exceptions (3.1,
      3.3).
- [ ] `resource-and-errors`: with > without, at 3 runs per arm (4.1).

### Integration
- [ ] The `SKILL.md` index and `references/` agree, and no file is empty (3.3).
- [ ] `claude plugin validate --strict` passes on the plugin and the repo root (5.1).
- [ ] `flywheel` stays on 0.5.0 after a push to `main` only, and gets 0.6.0 after the release (5.2,
      5.4).

### Regression
- [ ] `naming-conventions` Δ ≥ +0.40, and `hook-formats-claude-edits` with-plugin 1.00, at 3 runs per
      arm (4.1).
- [ ] `clang-format`'s reference `.clang-format` still names `references/coding-style.md`, which still
      exists.

---

## 5. Risk Summary

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Over-cutting drops a rule that was quietly earning Δ (e.g. naming via `source-files.md`) | Medium | Medium | Move project content instead of cutting it. Restore rule in 4.1. The log keeps every cut reviewable. |
| New case ties because plain Claude already writes `std::expected`/no-throw code | Medium | Low | The 1.3 baseline records both arms before any trim, and its stop condition fires if without-plugin is already 1.00 (spec: "the case … gets revisited"). |
| Eval cost overrun from restore loops | Low | Low | `--max-cost-usd` on every run; rerun only the failing case. |
| Marketplace update behaves unexpectedly on Windows (like the earlier "not found" during migration) | Low | Medium | 1.2 confirms the precondition first. The migration gotcha is documented in CLAUDE.md. |

---

## Status Legend

| Marker | Meaning |
|--------|---------|
| Not Started | Work hasn't begun |
| In Progress | Currently being implemented |
| Done | Phase implemented and verified |

Update the header `Status` field as phases complete (e.g. `In Progress (2/4 phases done)`). `/spec-plan-workflow:plan-update` does this automatically.
