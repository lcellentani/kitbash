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
5. Surfaced 7 open questions (below).
6. **Live-tested the plugin system for real** (not just schema validation): added the marketplace from
   a local path, installed `quartermaster-ledger` at user scope, watched Claude Code auto-install its
   `core` dependency, reloaded plugins mid-session, and actually invoked
   `quartermaster-ledger:git-commit` (which in turn pulled in `core:delegation-tiers`) to generate real
   commit messages. This closes open question #3 — see its entry below for what's now confirmed.
7. Split the session's own staged changes into 8 logically-separate commits using the freshly-tested
   `git-commit` skill and made them for real. See "Commits made this session" below.

## Corrections to earlier statements in this same session

- **"Skill naming preserves `/slash` muscle memory" was wrong.** Earlier in the session, renaming
  skill directories to match old command names (e.g. `commit-message-format` → `git-commit`) was
  justified as preserving the existing `/git-commit` invocation. That's false once the skill lives in
  a **plugin**: plugin-sourced skills are always invoked with a mandatory namespace prefix,
  `/plugin-name:skill-name` (confirmed against official docs: "Plugin skills are always namespaced...
  to prevent conflicts when multiple plugins have skills with the same name"). So it's actually
  `/quartermaster-ledger:git-commit`, `/spec-plan-workflow:spec-new`, etc. — the renaming itself is
  still fine (consistent, recognizable names), but "keeps your muscle memory" was never true for the
  plugin-installed form. Natural-language triggering is unaffected by this — when Claude auto-invokes
  a skill from conversation context rather than a typed slash command, it resolves the namespaced
  identifier internally and the user never needs to know or type it.

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
- **`/plugin marketplace add` accepts local filesystem paths**, not just GitHub `owner/repo` shorthand
  — `/plugin marketplace add ./` from inside a repo containing `.claude-plugin/marketplace.json` works
  and was used this session. No documented restriction against a repo installing a plugin from a
  marketplace defined inside that same repo (the self-hosting/chicken-and-egg concern raised this
  session turned out to be a non-issue) — live-tested successfully.
- **Three plugin install scopes exist**: `user` (global, all projects — what this session used),
  `project` (repo-specific, in `.claude/settings.json`), `local` (repo+user, not shared).
- **Plugin dependencies auto-install and were confirmed live**, not just documented: installing
  `quartermaster-ledger@kitbash` automatically installed `core` alongside it with no separate step.
- **Plugins installed from a local-path marketplace are cached, not read live** — Claude Code copies
  plugin content into `~/.claude/plugins/cache` at install time. Editing a `SKILL.md` in the repo does
  **not** automatically affect an already-installed copy. To pick up local edits: bump the plugin's
  `version` in `plugin.json`, then `/plugin marketplace update <marketplace-name>` followed by
  `/plugin update <plugin-name>@<marketplace-name>`. The `version` field is the actual update-detection
  signal (not cosmetic) when present; omitting it entirely falls back to content-hash-based change
  detection instead.
- **Switching a marketplace's source later is an in-place replace**: re-running
  `/plugin marketplace add ludocellentani/kitbash` on the still-registered `kitbash` marketplace name
  swaps its source from local path to GitHub with no `remove` step needed, and already-installed
  plugins keep working, resolving from the new source going forward.
- **Plugin skills are always namespaced**: `/plugin-name:skill-name`, mandatory and non-configurable,
  identical whether the plugin came from a local path or a published marketplace — this is NOT a
  local-dev-only quirk. See "Corrections to earlier statements" above.
- **Mid-session plugin installs may need `/reload-plugins`** for the new plugin's skills to appear in
  the active skill listing — confirmed needed this session after installing `quartermaster-ledger`.

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

## Commits made this session

The plugin scaffolding was committed as 8 separate commits, ordered so every intermediate commit is
self-contained (`marketplace.json` comes after the plugin directories it references, not before):

```
2748d74 [T2] docs(context): add session-2026-08-16 handoff doc
3be2889 [T3] docs(context): add original kitbash-handoff planning doc
c27398f [T2] feat: register all plugins in the marketplace
c262578 [T2] feat(cpp-engine-conventions): add clang-format and cpp-coding-standards skills
662f236 [T2] feat(spec-plan-workflow): add spec/plan authoring and review skills
933a5a0 [T2] feat(quartermaster-ledger): add git-commit skill, depends on core
c9708d9 [T2] feat(core): add core plugin with delegation-tiers skill
6d88ff3 [T2] docs: add CLAUDE.md for kitbash's plugin architecture
```

`kitbash-handoff.md` got **T3**, not the T2 applied to everything else — it predates this session
entirely (never written or edited by this session's AI), so tagging it T2 would have misrepresented
its provenance. Flagged during the split, user corrected to T3.

**Commit trailer note**: these 8 commits include a `Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>`
trailer (a standing instruction separate from the project's own `[Tn]` tagging). The user asked for this
removed going forward — **future commits in this repo should omit that trailer**, relying on the `[Tn]`
prefix alone as this project's chosen AI-involvement disclosure mechanism. Worth knowing why this
matters more than it might elsewhere: kitbash is a **public** repo, and research this session surfaced a
documented Claude Code issue (GitHub issue #66079) where, since Claude Code v2.1.165, a *second*
`Co-authored-by` trailer containing the user's real git-configured email (not just the noreply address)
gets appended automatically — a real privacy leak risk on a public repo. Worth the user independently
confirming this is/isn't still happening in their current Claude Code version, and using
`git log` to check future commits don't carry an unexpected second trailer even after the first is
dropped intentionally.

## Open questions (none resolved unless noted)

1. **`quartermaster-crew` and `code-review-craftsmanship`** are named in the original handoff doc's
   target architecture, but nothing in this repo maps to either — no subagent-routing content, no
   code-review content exists anywhere in what was migrated. Are these aspirational (author from
   scratch in a future session) or does source material exist elsewhere not yet reviewed?
2. **`quartermaster-ledger`'s scope** bundles commit-level delegation-tagging (`git-commit` skill) with
   the original handoff doc's stated purpose ("tracks and reports token consumption"). Agreed as a
   working assumption this session, never stress-tested against what actual token/cost reporting will
   need. Still open whether these stay one plugin or split later.
3. ~~**Build-order/validation gate deviation**~~ — **RESOLVED this session.** `quartermaster-ledger`
   (and its `core` dependency) were installed for real via `/plugin marketplace add ./` +
   `/plugin install quartermaster-ledger@kitbash` at user scope, inside the kitbash repo itself
   (confirming the self-hosting case works). Dependency auto-install, `/reload-plugins`, and the
   `git-commit` skill's actual behavior (reading `git diff --cached`, applying the `[Tn]` format,
   referencing `core:delegation-tiers` instead of redefining it, flagging unrelated concerns for a
   split) were all exercised live — see "Commits made this session" above. Still not done: the same
   validation for `spec-plan-workflow` and `cpp-engine-conventions`, and `quartermaster-crew` doesn't
   exist yet to validate at all (see #1). This was only ever tested from *inside* kitbash itself, not
   from a separate external consuming project — worth doing once before tagging `v0.1.0`, per the
   original doc's literal wording.
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

Open question #3 is now largely resolved (see above) — `quartermaster-ledger` + `core` were validated
live, including a real dependency install and a real functional test of `git-commit`. What's left
there is thin: repeat the install+exercise check for `spec-plan-workflow` and `cpp-engine-conventions`,
and do it once from an external project rather than from inside kitbash itself, before treating
`v0.1.0` as ready to tag. Otherwise, the two portability flags (#4, #5) or open question #1
(`quartermaster-crew` / `code-review-craftsmanship` — aspirational or sourced from elsewhere?) are the
next-most-actionable items.
