# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Current state

The repo is scaffolded and live: `.claude-plugin/marketplace.json` registers four plugins, each with a
real `plugin.json` and at least one skill. The marketplace is published on GitHub
(`lcellentani/kitbash`). Tagged `v0.1.0` on 2026-10-07, after all four plugins passed their eval suites
and an install-and-exercise check from an external project (`flatline`, installed copies from GitHub).
Since 2026-10-25 installs track a `release` branch, not `main`, with per-plugin `<plugin>--v<version>`
tags as the release record (see "Versioning"). See "Plugins" below for what exists today,
`docs/context/skill-recommendations-2026-10-07.md` for the skill audit and what's still open, and `docs/context/session-2026-08-16-handoff.md` for earlier history
and verified platform facts. Check `git log` / repo contents before assuming anything beyond this has
changed.

## What this repo is

**kitbash** is Ludovico Cellentani's personal monorepo for packaging Claude Code skills, commands, and
rules as installable **Claude Code plugins**, distributed via Claude Code's native plugin marketplace
mechanism (`.claude-plugin/marketplace.json` + one `plugin.json` per plugin). It replaces re-copying the
same Claude Code setup across multiple personal/work-adjacent projects.

Key architectural decisions:
- **Single monorepo**, not a marketplace fronting separate external repos — the marketplace registry and
  every plugin live in this one repo.
- **Grouping by concern, not by source project** — a plugin must be useful across unrelated codebases, not
  tied to the specifics of whichever project it was extracted from.
- Public GitHub repo with no compatibility guarantees or issue/PR triage expectations (personal workflow
  tool, not a product).

## Plugins (current, on disk)

```
kitbash/
├── .claude-plugin/
│   └── marketplace.json        # root registry listing all plugins
├── plugins/
│   ├── core/                          # cross-cutting primitives shared by other kitbash plugins
│   │   ├── .claude-plugin/plugin.json   #   no dependencies
│   │   └── skills/delegation-tiers/     #   T1-T4 AI-involvement taxonomy; user-invocable: false
│   ├── quartermaster-ledger/          # tracks/reports AI involvement — commit-level tagging today
│   │   ├── .claude-plugin/plugin.json   #   dependencies: ["core"]
│   │   └── skills/git-commit/
│   ├── spec-plan-workflow/            # spec -> plan authoring/review pipeline
│   │   ├── .claude-plugin/plugin.json   #   dependencies: ["core"]
│   │   └── skills/                      #   spec-new, spec-review, plan-draft, plan-review, plan-update
│   └── cpp-engine-conventions/        # C++17/20/23 conventions + clang-format automation
│       ├── .claude-plugin/plugin.json   #   no dependencies
│       ├── hooks/hooks.json             #   PostToolUse records edited C++ files, Stop formats them
│       ├── scripts/                     #   clang-format-hook.sh (kept LF via .gitattributes)
│       └── skills/                      #   clang-format (+ reference .clang-format), cpp-coding-standards
├── docs/context/                      # planning + session-handoff docs, not part of the plugin content
├── README.md
└── LICENSE
```

Each plugin is self-contained under `plugins/<name>/` with its own `.claude-plugin/plugin.json`
(`name`, `description`, `version`, optional `dependencies`), and is registered in the root
`.claude-plugin/marketplace.json` via `{ "name": "<name>", "source": "./plugins/<name>" }`.
Cross-plugin sharing goes through the `dependencies` field (not symlinks — see session handoff doc for
why), and Claude Code auto-installs a listed dependency alongside the plugin that declares it.

`quartermaster-crew` (subagent routing) and `code-review-craftsmanship`, named in the original planning
doc (`docs/context/kitbash-handoff.md`), do **not** exist yet — whether they're still planned or
superseded by `spec-plan-workflow`/`core` is an open question, not a build-order gap. Don't assume they
exist without checking `plugins/` first.

## Commands

- Validate a plugin before committing it: `claude plugin validate ./plugins/<plugin-name>`; before a
  release, `claude plugin validate --strict` on each plugin and on the repo root (marketplace manifest)
- Add the marketplace once per machine, pinned to the release branch:
  `/plugin marketplace add lcellentani/kitbash#release` (or the CLI form,
  `claude plugin marketplace add lcellentani/kitbash#release`)
- Install a plugin into a project: `/plugin install <plugin-name>@kitbash`
- Tag a plugin release: `claude plugin tag plugins/<plugin-name> --push` (`--dry-run` to preview)

Behavior is tested with `claude plugin eval` suites in each plugin's `evals/` (one directory per case:
`prompt.md` + `graders/*.md`, optional `case.yaml` + `setup.sh` fixtures). Each case runs with and
without the plugin and reports the difference (Δ). Every run is a real, billed model call — iterate
with `--runs 1`, and cap with `--max-cost-usd`. When and how to run them after a skill change (and how to
read failures) is in `docs/context/evals-usage.md`.

- **Dependency-free plugins** (`core`, `cpp-engine-conventions`): from the plugin dir,
  `claude plugin eval . --trust-plugin --runs 1 --allow-tools Write`.
- **Plugins depending on `core`**: their cases list `plugins: ["../..", "../../../core"]`, and the eval
  only loads plugins under the directory it runs against, so run from `plugins/`:
  `claude plugin eval . --eval-dir spec-plan-workflow/evals --trust-plugin --runs 1 --scaffold --allow-tools Write`.
  Run from the plugin dir instead, the dependency doesn't resolve and the plugin silently doesn't load
  (the `skill-fired` indicator shows `0x`).
- Cases tagged `needs-bash` (e.g. `git-commit`) need a `Bash` grant, which requires Claude Code's OS
  sandbox — macOS, Linux, or WSL2, not native Windows. Exclude them elsewhere by running other tags.

Installed plugins are **cached**, not read live from this repo — editing a skill here does not affect an
already-installed copy (the `kitbash` marketplace is registered from GitHub at the `release` branch, and
each `version` pins the cache). Two loops:

- **Develop**: `claude --plugin-dir ./plugins/<plugin-name>` (repeatable for several plugins). That
  session loads the plugin from the working tree, silently shadowing the installed copy of the same
  name; `/reload-plugins` picks up edits. Other projects keep the stable cached version.
- **Release**: follow the release checklist under "Versioning". Pushing to `main` alone reaches no
  install, existing or fresh.

## Versioning

Day-to-day iteration happens directly on `main`. Every machine registers the marketplace at
`lcellentani/kitbash#release`, so installs only ever see what's on the `release` branch. A release
moves `release` forward to a commit on `main` and tags each bumped plugin `<plugin>--v<version>`
(semver per plugin). `v0.1.0` is a historical repo-wide tag from before this scheme; nothing reads it.

Rules:
- `release` only fast-forwards from `main`; never commit on it directly. A GitHub ruleset blocks
  force-push and deletion on `release` (for the owner too), so it can never move backwards: roll back by
  reverting on `main`, bumping the version, and releasing forward.
- Every plugin with changes since its last tag gets a `version` bump. Updates are detected by `version`,
  not by commit, so an unbumped change is never delivered to existing installs, while fresh installs
  would get it — the same version would then mean different content on different machines.

Release checklist:

1. On `main`, clean tree, up to date with `origin/main`.
2. For each plugin, `git diff <plugin>--v<version>..main -- plugins/<plugin>`. Any plugin with changes
   gets a `version` bump in its `plugin.json`; commit the bumps.
3. `claude plugin validate --strict` on each plugin and on the repo root.
4. `git push origin main`, then `git push origin main:release` (git rejects a non-fast-forward; never
   `--force`).
5. `claude plugin tag plugins/<plugin> --push` for each bumped plugin (it also checks that `plugin.json`
   and the marketplace entry agree, and refuses an existing tag).
6. On each machine, `/plugin marketplace update kitbash` (auto-update is off for this marketplace), then
   `/reload-plugins` or restart.

To move a machine registered before 2026-10-25 (no ref, tracking `main`) onto `release`: add
`"ref": "release"` to the `kitbash` source under `extraKnownMarketplaces` in `~/.claude/settings.json`,
then start a new interactive session and run `/reload-plugins` once it reports `Plugins changed`. Don't
use `claude plugin marketplace remove` — it uninstalls the plugins. Until that session re-fetches, shell
commands report the marketplace as not found and its plugins as failed to load; that clears on its own.
Details and findings: Phase 6 in `docs/context/skill-recommendations-2026-10-07.md`.

## How plugins got here

The original plan (`docs/context/kitbash-handoff.md`) called for `quartermaster-ledger` and
`quartermaster-crew` first, then a `v0.1.0` tag, then `cpp-engine-conventions` and
`code-review-craftsmanship`. What actually happened deviated from that (see the session handoff doc's
"Deviations" section for why): `core` and `spec-plan-workflow` were added, `quartermaster-crew` and
`code-review-craftsmanship` were never built, and `cpp-engine-conventions` was migrated without waiting
for a `v0.1.0` tag.

When adding a new plugin: scaffold it, `claude plugin validate` it, give it an `evals/` suite, then
prove it end-to-end from the installed copy (install from the marketplace + invoke a skill) in a real
consuming project before treating it as stable.
