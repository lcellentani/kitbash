# kitbash

Ludovico Cellentani's personal monorepo of [Claude Code](https://claude.com/claude-code) plugins —
skills, agents, and conventions packaged for reuse across projects instead of being copy-pasted and
re-tweaked in each one.

Distributed through Claude Code's native plugin marketplace mechanism: one root
`.claude-plugin/marketplace.json` registry, and one self-contained plugin per concern under `plugins/`.
Plugins are grouped by what they do, not by which project they were pulled out of, so each one stays
useful in unrelated codebases.

## Plugins

| Plugin | What it's for |
|---|---|
| [`core`](plugins/core) | Cross-cutting conventions and primitives shared by other kitbash plugins (e.g. the delegation-tier taxonomy used to tag AI involvement) |
| [`quartermaster-ledger`](plugins/quartermaster-ledger) | Tracks and reports how much AI involvement went into work — commit-level delegation tagging today, token/cost consumption reporting planned |
| [`spec-plan-workflow`](plugins/spec-plan-workflow) | Spec-to-plan authoring and review pipeline: draft SPECs, draft Implementation Plans against them, audit both, and update plan status as work progresses |
| [`cpp-engine-conventions`](plugins/cpp-engine-conventions) | Modern C++ (C++17/20/23) coding standards, concrete style conventions, and clang-format automation for game-engine-style codebases |

The current plugin set reflects what's actually been migrated so far, not a fixed roadmap — plugins get
added here as workflows worth reusing show up.

## Using these plugins

Add the marketplace once per machine:

```
/plugin marketplace add lcellentani/kitbash
```

Then install whichever plugin a project needs:

```
/plugin install <plugin-name>@kitbash
```

Plugin authors validating changes in this repo:

```
claude plugin validate ./plugins/<plugin-name>
```

## Versioning

Day-to-day iteration happens directly on `main`. Once a plugin stabilizes it gets tagged (`v0.1.0`,
semver) so a mid-refactor commit on `main` doesn't silently change behavior for a project currently
depending on it.

## Disclaimer

This is a personal workflow tool, built for how I work and shared publicly as-is. No compatibility
guarantees between versions, and no issue/PR triage expectations — use at your own risk.

## License

Apache 2.0 — see [LICENSE](LICENSE).
