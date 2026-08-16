# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Current state

This repo is pre-scaffolding: it currently contains only `README.md`, `LICENSE` (Apache 2.0), and
`docs/context/kitbash-handoff.md` (the planning doc this file is derived from). None of the structure
described below exists on disk yet — it is the target architecture, not a description of current files.
Check `git log` / repo contents before assuming a plugin or file already exists.

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

## Target repo structure

```
kitbash/
├── .claude-plugin/
│   └── marketplace.json        # root registry listing all plugins
├── plugins/
│   ├── cpp-engine-conventions/
│   │   ├── .claude-plugin/plugin.json
│   │   └── skills/
│   ├── quartermaster-ledger/   # Claude Code token consumption reporting
│   │   ├── .claude-plugin/plugin.json
│   │   └── skills/
│   ├── quartermaster-crew/     # subagent routing
│   │   ├── .claude-plugin/plugin.json
│   │   └── agents/
│   └── code-review-craftsmanship/
│       ├── .claude-plugin/plugin.json
│       └── skills/
├── README.md
└── LICENSE
```

Each plugin is self-contained under `plugins/<name>/` with its own `.claude-plugin/plugin.json`
(`name`, `description`, `version`), and is registered in the root `.claude-plugin/marketplace.json`
via `{ "name": "<name>", "source": "./plugins/<name>" }`.

## Commands

- Validate a plugin before committing it: `claude plugin validate ./plugins/<plugin-name>`
- Add the marketplace once per machine: `/plugin marketplace add ludocellentani/kitbash`
- Install a plugin into a project: `/plugin install <plugin-name>@kitbash`

There is no build, lint, or test suite yet — plugin correctness is verified via `claude plugin validate`
and by installing + exercising the plugin in a real project.

## Versioning

Tag releases (`v0.1.0`, semver) once a plugin stabilizes, so a mid-refactor commit on `main` doesn't
silently change behavior for a project currently depending on it. Day-to-day iteration happens directly
on `main`; tags are the stability boundary, not branches.

## Build order (from the handoff plan)

1. Scaffold `.claude-plugin/marketplace.json`.
2. Migrate `quartermaster-ledger` (consumption reporting) first; validate.
3. Migrate `quartermaster-crew` (subagent routing) second; validate.
4. Once both quartermaster plugins work end-to-end in a real project, tag `v0.1.0` and migrate
   `cpp-engine-conventions` and `code-review-craftsmanship`.

When adding a new plugin, follow this same pattern: scaffold it, validate it in isolation, then prove it
end-to-end in a real consuming project before treating it as stable.
