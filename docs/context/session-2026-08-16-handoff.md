# kitbash — Session Handoff (2026-08-16)

> Paste this in at the start of a new Claude Code session to pick up exactly where this one left off.
> This supersedes `docs/context/kitbash-handoff.md` as the current-state reference — that doc still
> holds the original vision and decisions table, but the architecture has since evolved beyond its
> original 4-plugin plan (see "Deviations from the original handoff doc" below).

## What happened this session

Starting from a pre-scaffolding repo (only `README.md`, `LICENSE`, `docs/context/kitbash-handoff.md`),
this session:
1. Wrote the initial `CLAUDE.md`.
2. Inventoried the project's `.claude/` folder (7 commands, 1 rule, 8 skills) via `/auto-mode-setup`.
3. Established that Claude Code commands are legacy — merged into skills — and used that finding to
   drive a full consolidation: every command was folded into its paired skill, then that skill was
   migrated into a plugin. `.claude/` is now empty and has been deleted.
4. Scaffolded `.claude-plugin/marketplace.json` and 4 plugins: `core`, `quartermaster-ledger`,
   `spec-plan-workflow`, `cpp-engine-conventions`. All validate clean via `claude plugin validate`.
5. Surfaced 7 open questions (below), none yet resolved except where noted.

## Verified platform facts (don't re-derive these — confirmed against official docs this session)

- **Commands are legacy, merged into skills.** A file at `.claude/commands/x.md` and a skill at
  `.claude/skills/x/SKILL.md` both create `/x` and work the same way. Commands still function, but
  skills are the recommended, richer mechanism (frontmatter: `user-invocable`,
  `disable-model-invocation`, `allowed-tools`, `model`, etc.; commands only support a small subset).
- **`marketplace.json` schema**: required top-level `name` (kebab-case), `owner.name`, `plugins[]`.
  Each plugin entry needs `name` + `source`; optional `description`, `version`, `author`, `keywords`,
  `category`, `strict`, etc.
- **`plugin.json` schema**: required `name` (kebab-case, convention expects it to match the directory).
  Optional `description`, `version`, `author`, `homepage`, `keywords`, `dependencies`, and component
  path overrides (`skills`, `commands`, `agents`, `hooks`, `mcpServers`, `lspServers`). An
  empty/near-empty plugin (manifest only, no skills yet) is valid.
- **Plugin dependencies are real and enforced.** `"dependencies": ["core"]` in `plugin.json` causes
  Claude Code to auto-install the dependency when the dependent plugin is installed; if the dependency
  is missing/disabled, Claude Code surfaces a `dependency-unsatisfied` error rather than silently
  loading with a dangling reference. This is the chosen mechanism for cross-plugin content sharing in
  this repo (see decisions below) — the documented alternative (symlinks within the marketplace repo,
  for file-level sharing without a dependency edge) was considered and rejected for this repo because
  of Windows symlink checkout friction (needs Developer Mode / admin rights).
- **Rules are NOT plugin-packageable — confirmed gap.** `.claude/rules/*.md` (path-glob-scoped or
  unconditional context injection) is a real, current, documented mechanism, but plugin.json's schema
  has no `rules` component, the official plugin-migration guide covers commands/agents/skills but
  omits rules, skills have no native path-glob trigger field, and plugin hooks are tool-event-based
  (not file-path-based) so they can't replicate it either. **No official recommended migration pattern
  exists for this case.** This session's resolution: convert the rule's content into a skill (see
  `cpp-coding-standards` below) rather than leaving it as an uninstallable project-level file.
- **Skills can bundle non-SKILL.md reference/asset files** (e.g. `assets/template.md`,
  `references/*.md`) that are not independently invocable or triggered — they're pulled in only when
  the skill's own body tells Claude to read them. Used this session to move a former rule's content
  into `cpp-coding-standards/references/coding-style.md` without creating a second skill with an
  overlapping/competing trigger description.
- **Remote Control** (phone pairing to a live session) can't be activated from inside a running
  session — it requires launching a new terminal with `claude --remote-control`, which prints a
  URL/QR code to pair from the Claude mobile app. Full-scope login required (not an API key).

## Architectural decisions made

| Decision | Choice | Why |
|---|---|---|
| Plugin grouping | By concern, not source project (reaffirmed from original handoff doc) | Plugins must be useful across unrelated codebases |
| `core` plugin scope | Narrow: only content genuinely shared by 2+ other plugins — not a general catch-all | A bucket defined by "doesn't fit elsewhere" tends to become a junk drawer; a bucket defined by "duplicated across 2+ plugins" stays honest |
| Cross-plugin sharing mechanism | `plugin.json` `dependencies` field | Enforced, cross-platform, no Windows symlink friction; a dependency stays correct as `core` evolves where a symlink is a frozen copy |
| Delegation taxonomy (T1–T4): rule or skill? | Skill, `user-invocable: false`, lives in `core` | Rules aren't plugin-packageable (see gap above); a rule's trigger models (path-glob or unconditional) don't fit a task-triggered concept like tagging a commit or plan task |
| `git-commit` plugin placement | `quartermaster-ledger`, not `core`, not a new plugin | It's a delegation-tier *ledger entry format* — matches quartermaster-ledger's "tracks/reports AI involvement" concern even though the handoff doc originally scoped that plugin to token/cost metrics only (flagged as open question #2) |
| `spec-plan-workflow` granularity | One plugin for all 5 skills (spec-new, spec-review, plan-draft, plan-review, plan-update), not split into spec-workflow + plan-workflow | Matches how they already function as one pipeline; avoids a second dependency edge (plan → spec) on top of the plan skills' existing dependency on `core` |
| Skill naming after consolidation | Renamed to match the **existing command names** (e.g. `commit-message-format` → `git-commit`, `spec-authoring` → `spec-new`, `plan-drafting` → `plan-draft`), not kept as original skill names | Preserves existing `/slash` muscle memory; skill directory name determines the slash invocation post-merge |
| Model-invocation on folded skills | Enabled (no `disable-model-invocation` flag) — skills work both as typed `/command` and via natural-language auto-trigger | User's explicit choice on the `git-commit` test case; applied consistently to the rest of the consolidation pass |

## Deviations from the original `docs/context/kitbash-handoff.md`

- Added **`core`** and **`spec-plan-workflow`** — neither exists in the original doc's 4-plugin plan.
  `spec-plan-workflow` covers 5 skills (spec-authoring/review, plan-drafting/review/update) that had
  **no home at all** in the original plan — this was open question #1 from earlier in the session and
  is now resolved by scaffolding the plugin.
- The original doc's build order says: scaffold → migrate `quartermaster-ledger` → migrate
  `quartermaster-crew` → **validate both end-to-end in a real consuming project** → tag `v0.1.0` → only
  then migrate `cpp-engine-conventions` and `code-review-craftsmanship`. This session migrated
  `cpp-engine-conventions` without that end-to-end validation gate, and without `quartermaster-crew`
  existing at all yet. This is open question #3 below — not an oversight, but not yet resolved either.

## Current repo state (verified via filesystem, not from memory)

```
kitbash/
├── .claude-plugin/marketplace.json         — registers all 4 plugins below
├── CLAUDE.md
├── README.md                               — still the original 1-line stub, unchanged
├── LICENSE                                 — Apache 2.0
├── docs/context/
│   ├── kitbash-handoff.md                  — original planning doc (superseded by this file for current state)
│   └── session-2026-08-16-handoff.md       — this file
└── plugins/
    ├── core/
    │   ├── .claude-plugin/plugin.json      — no dependencies
    │   └── skills/delegation-tiers/SKILL.md  — user-invocable: false; T1–T4 definitions, single source of truth
    ├── quartermaster-ledger/
    │   ├── .claude-plugin/plugin.json      — dependencies: ["core"]
    │   └── skills/git-commit/SKILL.md      — user-invocable + model-invocable; references core's delegation-tiers
    ├── spec-plan-workflow/
    │   ├── .claude-plugin/plugin.json      — dependencies: ["core"]
    │   └── skills/
    │       ├── spec-new/ (SKILL.md + assets/template.md)
    │       ├── spec-review/SKILL.md
    │       ├── plan-draft/ (SKILL.md + assets/template.md)  — delegation tag section references core, no longer inline-defines T1-T4
    │       ├── plan-review/SKILL.md
    │       └── plan-update/SKILL.md
    └── cpp-engine-conventions/
        ├── .claude-plugin/plugin.json      — no dependencies
        └── skills/
            ├── clang-format/SKILL.md
            └── cpp-coding-standards/
                ├── SKILL.md                — description broadened to cover formatting/naming; points to references/
                └── references/coding-style.md  — former rule content (paths: frontmatter stripped, trailing self-reference removed)
```

`.claude/` no longer exists — every original command/rule/skill was migrated into one of the 4 plugins
above and the empty directory tree was deleted.

Current `marketplace.json`:
```json
{
  "name": "kitbash",
  "owner": { "name": "Ludovico Cellentani" },
  "plugins": [
    { "name": "core", "source": "./plugins/core", "description": "Cross-cutting conventions and primitives shared by other kitbash plugins" },
    { "name": "quartermaster-ledger", "source": "./plugins/quartermaster-ledger", "description": "Tracks and reports how much AI involvement went into work — commit-level delegation tagging today, token/cost consumption reporting planned" },
    { "name": "spec-plan-workflow", "source": "./plugins/spec-plan-workflow", "description": "Spec-to-plan authoring and review pipeline: draft SPECs, draft Implementation Plans against them, audit both, and update plan status as work progresses" },
    { "name": "cpp-engine-conventions", "source": "./plugins/cpp-engine-conventions", "description": "Modern C++ (C++17/20/23) coding standards, this project's concrete style conventions, and clang-format automation for game-engine-style codebases" }
  ]
}
```

Note: `marketplace.json` has no top-level `description` field — the original handoff doc's example had
one; current schema makes it optional and it was dropped. See open question #7.

## Established consolidation pattern (precedent for any future command/skill work)

Every command→skill fold this session followed the same recipe — apply it again if new commands ever
show up, or if `quartermaster-crew` / `code-review-craftsmanship` get built from scratch and need it:

1. Rename the skill directory (and its frontmatter `name:`) to match the **existing command's** name,
   so the `/slash` invocation doesn't change.
2. Fold the command's `.md` body (usually just `$ARGUMENTS` handling and a one-line pointer to the
   skill) directly into the skill's own body.
3. Drop `user-invocable: false` (or leave frontmatter unrestricted) so the skill is both explicit-invoke
   and model-invocable.
4. Delete the old `.claude/commands/<name>.md` and `.claude/skills/<old-name>/` after the new plugin
   copy is validated.
5. Re-run `claude plugin validate ./plugins/<plugin-name>` before considering it done.

## Open questions (none resolved unless noted)

1. **`quartermaster-crew` and `code-review-craftsmanship`** are named in the original handoff doc's
   target architecture, but nothing in this repo maps to either — no subagent-routing content, no
   code-review content exists anywhere in what was migrated. Are these aspirational (author from
   scratch in a future session) or does source material exist elsewhere not yet reviewed?
2. **`quartermaster-ledger`'s scope** bundles commit-level delegation-tagging (`git-commit` skill) with
   the original handoff doc's stated purpose ("tracks and reports token consumption"). Agreed as a
   working assumption this session, never stress-tested against what actual token/cost reporting will
   need. Still open whether these stay one plugin or split later.
3. **Build-order/validation gate deviation** (see "Deviations" above): no plugin has been installed and
   exercised in a real consuming project yet — only schema-level `claude plugin validate` has been run.
   The original handoff doc gates tagging `v0.1.0` on exactly that end-to-end check for the
   quartermaster plugins before migrating further. Decide: backfill that validation now, or keep
   building structure and validate once at the end?
4. **`clang-format` skill portability**: `cpp-engine-conventions/skills/clang-format/SKILL.md`'s
   whole-repo fallback file-set hardcodes `src/`, `test_*.cpp`, and specifically `wizard_of_oz_demo.cpp`
   — a literal filename from whichever project this content was originally extracted from, sitting
   inside a plugin meant to be reusable across unrelated codebases. Needs genericizing (or making
   configurable) before this plugin is stable.
5. **`spec-new` portability**: `spec-plan-workflow/skills/spec-new/SKILL.md`'s interview-question list
   asks "What existing systems (ECS components, render passes, input bindings, etc.) does this touch or
   build on?" — game-engine-specific example language inside an otherwise domain-agnostic spec-writing
   skill. Same class of issue as #4, needs genericizing.
6. **README.md** is still the original 1-line stub (`# kitbash`). The original handoff doc calls for a
   disclaimer: "built for personal workflow, no compatibility guarantees, use at your own risk" — not
   yet written.
7. **`marketplace.json` top-level `description`** field is currently omitted (schema-optional). The
   original handoff doc's own example included one ("Personal Claude Code skills, commands, and
   conventions"). Cheap to add back for parity with original intent; low priority.

## Suggested next step

Open question #3 (validation gate) blocks the most — it's the actual criterion the original doc sets
for tagging `v0.1.0`, and no plugin has been through it yet. Picking one plugin (probably
`quartermaster-ledger`, since it's smallest) and actually installing it into a real project via
`/plugin marketplace add` + `/plugin install` would validate both the plugin itself and the `core`
dependency-resolution mechanism end-to-end for the first time this session only checked via
`claude plugin validate` (schema-only, not an install/runtime check).
