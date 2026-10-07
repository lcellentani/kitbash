# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Current state

The repo is scaffolded and live: `.claude-plugin/marketplace.json` registers four plugins, each with a
real `plugin.json` and at least one skill. The marketplace is published on GitHub
(`lcellentani/kitbash`). Tagged `v0.1.0` on 2026-10-07, after all four plugins passed their eval suites
and an install-and-exercise check from an external project (`flatline`, installed copies from GitHub).
See "Plugins" below for what exists today, `docs/context/skill-recommendations-2026-10-07.md` for the
skill audit and what's still open, and `docs/context/session-2026-08-16-handoff.md` for earlier history
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

- Validate a plugin before committing it: `claude plugin validate ./plugins/<plugin-name>`
- Add the marketplace once per machine: `/plugin marketplace add lcellentani/kitbash` (or the CLI form,
  `claude plugin marketplace add lcellentani/kitbash`)
- Install a plugin into a project: `/plugin install <plugin-name>@kitbash`

Behavior is tested with `claude plugin eval` suites in each plugin's `evals/` (one directory per case:
`prompt.md` + `graders/*.md`, optional `case.yaml` + `setup.sh` fixtures). Each case runs with and
without the plugin and reports the difference (Δ). Every run is a real, billed model call — iterate
with `--runs 1`, and cap with `--max-cost-usd`.

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
already-installed copy (the `kitbash` marketplace is registered from GitHub, and each `version` pins the
cache). Two loops:

- **Develop**: `claude --plugin-dir ./plugins/<plugin-name>` (repeatable for several plugins). That
  session loads the plugin from the working tree, silently shadowing the installed copy of the same
  name; `/reload-plugins` picks up edits. Other projects keep the stable cached version.
- **Publish**: bump `version` in that plugin's `plugin.json`, push, then `/plugin marketplace update
  kitbash` — that refreshes the catalog *and* updates every installed plugin whose version changed
  (auto-update is off for this marketplace, so this step is manual). Then `/reload-plugins` or restart.

## Versioning

Tag releases (semver; `v0.1.0` is the first) once plugins stabilize. Day-to-day iteration happens directly
on `main`. Caveat: the marketplace is registered from GitHub without a pinned ref, so
`/plugin marketplace update kitbash` gives every project what's on `main` — today a tag marks a
known-good point to return to or diff against, not a boundary projects are held behind.

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
