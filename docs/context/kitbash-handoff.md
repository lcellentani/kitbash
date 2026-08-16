# kitbash — Project Handoff

> Context doc for Claude Code CLI. Paste this in at the start of a session (or drop it in the repo root as `PLAN.md`) to pick up where this planning conversation left off.

## Goal

Ludovico Cellentani (Technical Director, Frostbite/EA) has been building Claude Code skills, commands, and rules across several personal and work-adjacent projects for a few months. Every new project currently means re-copying and re-tweaking the same setup. The fix: a single personal repo — codenamed **kitbash** — that packages this work as installable **Claude Code plugins**, distributed through Claude Code's native plugin marketplace mechanism.

## Decisions made

| Decision | Choice |
|---|---|
| Repo name | **kitbash** |
| Repo topology | **Single monorepo** — one repo holds the marketplace registry and every plugin, not a central marketplace fronting separate external repos |
| Visibility | **Public** on GitHub |
| Distribution mechanism | Claude Code's plugin marketplace (`.claude-plugin/marketplace.json` + one `plugin.json` per plugin) |
| Grouping principle | Plugins are organized by **concern**, not by source project — a plugin should be useful across unrelated codebases |
| Quartermaster components | **Resolved** — `quartermaster-ledger` (consumption reporting) and `quartermaster-crew` (subagent routing) fold into kitbash as two plugins, not standalone repos |

## Repo structure

```
kitbash/
├── .claude-plugin/
│   └── marketplace.json
├── plugins/
│   ├── cpp-engine-conventions/
│   │   ├── .claude-plugin/plugin.json
│   │   └── skills/
│   ├── quartermaster-ledger/
│   │   ├── .claude-plugin/plugin.json
│   │   └── skills/          # consumption reporting
│   ├── quartermaster-crew/
│   │   ├── .claude-plugin/plugin.json
│   │   └── agents/          # subagent routing
│   └── code-review-craftsmanship/
│       ├── .claude-plugin/plugin.json
│       └── skills/
├── README.md
└── LICENSE                   # Apache 2.0
```

## marketplace.json (root registry)

```json
{
  "name": "kitbash",
  "owner": { "name": "Ludovico Cellentani" },
  "description": "Personal Claude Code skills, commands, and conventions",
  "plugins": [
    { "name": "cpp-engine-conventions", "source": "./plugins/cpp-engine-conventions" },
    { "name": "quartermaster-ledger", "source": "./plugins/quartermaster-ledger" },
    { "name": "quartermaster-crew", "source": "./plugins/quartermaster-crew" },
    { "name": "code-review-craftsmanship", "source": "./plugins/code-review-craftsmanship" }
  ]
}
```

## plugin.json (per plugin, e.g. quartermaster-ledger)

```json
{
  "name": "quartermaster-ledger",
  "description": "Tracks and reports Claude Code token consumption",
  "version": "0.1.0"
}
```

## How the plugins get used

- **Once per machine:** `/plugin marketplace add ludocellentani/kitbash`
- **Per project, as needed:** `/plugin install <plugin-name>@kitbash`
- **Validation before committing a plugin:** `claude plugin validate ./plugins/<plugin-name>`

## Versioning approach

Because the repo is public, tag releases (`v0.1.0`, semver) once a plugin stabilizes, so a mid-refactor commit on `main` never silently changes behavior in a project currently in flight. Day-to-day iteration tracks `main` directly.

Add a plain disclaimer to `README.md` — built for personal workflow, no compatibility guarantees, use at your own risk — to keep the public repo low-maintenance (no issue/PR triage expectation).

## Next steps

1. Scaffold the repo structure and root `marketplace.json`.
2. Migrate `quartermaster-ledger` in first (consumption reporting); run `claude plugin validate` on it.
3. Migrate `quartermaster-crew` in second (subagent routing); validate.
4. Add `README.md` (with disclaimer) and `LICENSE` (Apache 2.0).
5. Once both quartermaster plugins work end-to-end in a real project, tag `v0.1.0` and start migrating `cpp-engine-conventions` and `code-review-craftsmanship`.
