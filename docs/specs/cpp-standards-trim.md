# Trim C++ standards to project-specific content — SPEC

| Field | Value |
|-------|-------|
| **Status** | Ready |
| **Date** | 2026-10-25 |
| **Plan** | Not yet planned |
| **Supersedes** | N/A |

---

## 1. Problem

`cpp-coding-standards` ships 716 lines of C++ Core Guidelines content across 10 `references/*.md` files,
copied verbatim in audit Phase 3, plus a `SKILL.md` body (cross-cutting principles, checklist) built the
same way. Most of it restates guidance Claude already follows unaided, so each read costs tokens and
hides the few lines that are real project decisions. Evidence so far: the naming eval's Δ (+0.40) came
only from where `coding-style.md` departs from common style, and Claude matched the rest without the
plugin (audit Phase 4, finding b). Where the content does prescribe a choice, it can be the wrong one:
`errors.md` prescribes custom exception types, which isn't the project's error-handling policy.

## 2. Goals

- Every rule in the 10 reference files and in the `SKILL.md` body is classified as *keep*, *move* or
  *cut* in the classification log, each with a one-line reason; the shipped files contain only *keep*
  and *move* rules.
- `errors.md` states the project's error-handling policy (see Design) instead of the Core Guidelines'
  exception rules; the memory and concurrency policies (see Design) are stated in the reference files
  for those areas, replacing the guideline restatements there.
- Reference size is recorded before and after the trim (line count per file and in total).
- No regression on the existing evals, measured as the mean of 3 runs per arm
  (`docs/context/evals-usage.md`, step 4): `naming-conventions` keeps Δ ≥ +0.40 and
  `hook-formats-claude-edits` keeps with-plugin 1.00.
- A new eval case, "write a class that owns a resource and reports errors", scores with-plugin >
  without-plugin (mean of 3 runs per arm). Its graders check only *keep* rules, so a tie would mean the
  kept rules don't change behavior and the case, or the classification, gets revisited.
- `SKILL.md` matches the trimmed references: its index lists only reference files that still exist, and
  no listed file is empty.
- `cpp-engine-conventions` 0.6.0 is released through the CLAUDE.md release checklist, which proves
  Phase 6 setup step 7 end to end in `flywheel` on this Windows machine:
  - before starting: `claude plugin list` shows `cpp-engine-conventions@kitbash` 0.5.0 from a marketplace
    registered at `lcellentani/kitbash@release`;
  - after 0.6.0 is pushed to `main` only, `/plugin marketplace update kitbash` leaves `flywheel` on 0.5.0;
  - after the release, the same update installs 0.6.0;
  - a C++ task in `flywheel` then loads `cpp-coding-standards` from the 0.6.0 cache.

## 3. Non-Goals

- Changing the project conventions already in `coding-style.md` (naming, layout, module structure) —
  they earn the plugin its Δ. The file only receives *move* rules.
- Changing `.clang-format` or the formatting hook — unrelated to reference size.
- A per-area eval for each reference file — this spec replaces audit item 25b's stated approach ("add a
  case per reference area before cutting any of them") with review-first; per-area evals would cost
  ≈ $10–20 to mostly re-confirm that Claude knows RAII. Item 25b's text is updated to say so.
- `paths:` globs on the C++ skills (audit item 26) — dropped. Tested on Claude Code 2.1.310: `paths:` is
  ignored for plugin skills, and for project skills it hides the skill until a matching file has been
  touched and blocks explicit `/name` invocation until then, which would hurt both C++ skills if plugins
  ever honour it. Item 26 is closed as won't-do in the audit doc.
- Migrating `flywheel`'s existing `throw`s to the new error policy — separate `flywheel` work; the plugin
  only documents the policy.
- Turning exceptions off at the compiler level — a build decision per project, not a convention.
- Other kitbash plugins, and other open audit items (13b, 19, 20, 21) — separate work.

## 4. Design

### Key Decisions

- **Review-first classification.** Each rule is judged against criteria, not measured one by one;
  regression evals catch mistakes. Alternative: an eval case per reference area — rejected on cost and
  low expected information.
- **What a "rule" is.** Each row of a Key Rules table, and each bullet or numbered item. A code example
  belongs to the rule it illustrates and is kept or cut with it.
- **Three outcomes per rule:**
  - *keep*: (a) a project *choice* where the guidelines or common practice leave options open,
    (b) a project *deviation* from the guidelines or from Claude's usual default, or (c) a rule Claude is
    known to get wrong here. Each (b) or (c) keep records its basis: an eval result, an observed
    session, or reviewer judgment.
  - *move*: a kept rule that is a project convention rather than a guideline topic goes to
    `coding-style.md`, so conventions live in one file.
  - *cut*: a restatement of a guideline Claude follows unprompted.
- **The classification log is the reviewable artifact**, at `docs/context/cpp-standards-trim-log.md`,
  linked from this spec and from audit item 25b. The trim is judged by reading the log, not the diff
  alone. Rejected: trimming files directly with no record.
- **Error-handling policy** (decided 2026-10-25), replacing `errors.md`'s exception rules:
  - bugs (broken invariants, caller misuse) → the project's assert macro, with a message;
  - absence that isn't an error → `std::optional`;
  - recoverable failures → `expected<T, Error>`: `std::expected` on C++23, `tl::expected` (same
    interface) on C++17/20. `Error` is an `enum class` code plus optional context (message, source
    location). Errors propagate with a `TRY`-style macro; they're logged where they're handled, not
    where they're created;
  - fatal, unrecoverable failures → log and abort;
  - exceptions are not the error mechanism in engine code.
  Alternatives considered: error codes with out-parameters (forces `optional` or out-params alongside
  the code, easy to ignore, no context); asserts for everything (compiled out, no reporting).
- **Memory policy** (decided 2026-10-25). Arenas are lifetime and ownership scopes (e.g. Global, Level,
  Client/Server session, Frame); custom allocators are for fine-grained control of how memory behaves.
  - default: scoped objects and `std::make_unique`; `shared_ptr` only for real shared ownership
    (context line only — a guideline restatement);
  - if the project defines memory scopes (arenas): allocate from the arena matching the object's
    lifetime and let the arena own it — no `unique_ptr`/`delete` on arena memory; arena types are
    trivially destructible or registered with the arena;
  - never hold a raw pointer from a longer-lived scope into a shorter-lived one; cross-scope references
    use handles or IDs;
  - no custom allocators without a measured problem or explicit requirement; prefer `std::pmr` resources
    over hand-rolled allocators when one is needed;
  - don't introduce arenas or allocators unprompted in a project that doesn't have them.
  Rationale: the arena-owns model deviates from the guidelines' "own through smart pointers" (R.20/R.21),
  which Claude would otherwise apply; the conditional phrasing keeps small projects from being
  over-engineered (`flywheel` and `flatline` have no arenas today).
- **Concurrency policy** (decided 2026-10-25), same pattern:
  - default: RAII locks (`std::scoped_lock`, one call for several mutexes), `std::atomic` for simple
    flags and counters, no `detach()` (context line only);
  - if the project has a job system or task scheduler: submit work as jobs rather than creating
    `std::thread`s; don't block inside a job (locks, I/O, waiting on other jobs); express ordering as job
    dependencies;
  - respect thread ownership: subsystems bound to a thread (e.g. SDL windowing/events on the main
    thread, bgfx's API thread in `flywheel`) get work marshalled to that thread, not called from elsewhere
    behind a lock;
  - partition data per job or per frame (double-buffered where needed) rather than sharing mutable state
    behind a mutex; locks are the exception in hot paths;
  - don't introduce threads, pools or a job system unprompted; no `std::async` in engine code (unclear
    launch policy, hidden thread creation).
- **No size target.** Before/after is recorded, and the criteria decide; a target would push toward
  cutting rules that should stay.
- **Restore rule.** If the new case or a regression eval drops, read the failing grader, restore the
  log entries for that area, and rerun until the goal passes.
- **Empty areas disappear.** A reference file with no *keep* rules is deleted and dropped from the
  `SKILL.md` index. Rejected: stub files that only point at the Core Guidelines.
- **Shipped as a minor bump (0.5.0 → 0.6.0)** in one release, with the trim and the new error policy
  together.
- **`flywheel` is the end-to-end target.** It's a real C++ project with the kitbash plugins installed and
  in recent use; no dedicated test change is needed for Phase 6 step 7.

### How It Fits Existing Systems

- `plugins/cpp-engine-conventions/skills/cpp-coding-standards/`: `SKILL.md` (project naming table,
  cross-cutting principles, reference index, checklist) and `references/` (10 guideline files plus
  `coding-style.md`).
- `plugins/cpp-engine-conventions/evals/`: existing `naming-conventions` and `hook-formats-claude-edits`
  cases, plus the new resource-and-errors case. Run per `docs/context/evals-usage.md`.
- Release: the checklist in CLAUDE.md "Versioning" (bump, `validate --strict`, fast-forward `release`,
  `claude plugin tag`, update).
- Audit doc `docs/context/skill-recommendations-2026-10-07.md`: item 25b (approach replaced, then done),
  item 26 (won't-do, with the finding), Phase 6 setup step 7 (done from this release).

## 5. Open Questions

- [x] **How does `paths:` behave?** → Ignored for plugin skills; harmful if honoured. Item 26 dropped
  (see Non-Goals).
- [x] **Is the SKILL.md body in scope?** → Yes, same criteria.
- [x] **Which project choices are real?** → Error handling, memory and concurrency policies decided
  (see Design). Other areas follow the keep/move/cut criteria.
- [x] **Size target.** → None; record before/after.
- [x] **New eval case.** → One case, resource-owning class with error paths; graders check *keep* rules
  only; bar is with > without over 3 runs per arm.
- [x] **Where the classification log lives.** → `docs/context/cpp-standards-trim-log.md`.

---

## Status Legend

| Status | Meaning |
|--------|---------|
| Draft | Still being shaped; open questions may exist |
| Ready | Open questions resolved; safe to run `/spec-plan-workflow:plan-draft` |
| Implemented | All linked plan phases are Done |
| Superseded | Replaced by a newer spec — link it above |
