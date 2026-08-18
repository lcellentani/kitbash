# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Current state

The repo is scaffolded and live: `.claude-plugin/marketplace.json` registers four plugins, each with a
real `plugin.json` and at least one skill. The marketplace is published on GitHub
(`lcellentani/kitbash`) and has been installed and exercised end-to-end (not just schema-validated) from
inside this repo. See "Plugins" below for what actually exists today, and
`docs/context/session-2026-08-16-handoff.md` for full session history, verified platform facts, and open
questions. Still pre-`v0.1.0`: no plugin has been tagged yet, and the marketplace/plugins haven't been
validated from an *external* consuming project (see that doc's open question #3). Check `git log` / repo
contents before assuming anything beyond this has changed.

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
│       └── skills/                      #   clang-format, cpp-coding-standards
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

There is no build, lint, or test suite yet — plugin correctness is verified via `claude plugin validate`
and by installing + exercising the plugin in a real project.

Installed plugins are **cached**, not read live from this repo — editing a skill here does not affect an
already-installed copy. To pick up local edits: bump `version` in that plugin's `plugin.json`, then
`/plugin marketplace update kitbash` followed by `/plugin update <plugin-name>@kitbash`.

## Versioning

Tag releases (`v0.1.0`, semver) once a plugin stabilizes, so a mid-refactor commit on `main` doesn't
silently change behavior for a project currently depending on it. Day-to-day iteration happens directly
on `main`; tags are the stability boundary, not branches.

## How plugins got here, and what's left before v0.1.0

The original plan (`docs/context/kitbash-handoff.md`) called for `quartermaster-ledger` and
`quartermaster-crew` first, then a `v0.1.0` tag, then `cpp-engine-conventions` and
`code-review-craftsmanship`. What actually happened deviated from that (see the session handoff doc's
"Deviations" section for why): `core` and `spec-plan-workflow` were added, `quartermaster-crew` and
`code-review-craftsmanship` were never built, and `cpp-engine-conventions` was migrated without waiting
for a `v0.1.0` tag.

Still open before tagging `v0.1.0`:
- `quartermaster-ledger` + `core` have been installed and exercised live, but only from *inside* this
  repo — not yet from a separate external consuming project.
- `spec-plan-workflow` and `cpp-engine-conventions` haven't had that same live install-and-exercise pass
  at all yet.

When adding a new plugin, follow the pattern that worked for `quartermaster-ledger`: scaffold it,
`claude plugin validate` it in isolation, then prove it end-to-end (install + actually invoke a skill)
in a real consuming project before treating it as stable.
