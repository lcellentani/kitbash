# Using the plugin evals

How to use the `claude plugin eval` suites under `plugins/*/evals/` when changing kitbash skills.
Run commands are also in CLAUDE.md ("Commands"); results from the first full run are in
`skill-recommendations-2026-10-07.md` (Phase 4).

## What evals are for

Evals are a local check you run against your working tree after changing a skill, to catch regressions.
Four details matter for how you use them:

1. **They only check what the graders check.** A passing suite means "the behaviors we wrote cases for
   still work", not "nothing changed". If you change something no case covers, the evals won't notice. So
   when you add or change behavior, add or adjust a case for it.
2. **Results vary between runs.** The same prompt can produce different answers. One failure in one run
   might be a fluke, so re-run with `--runs 3` before trusting a failure, or a pass.
3. **You get two different numbers:**
   - **WITH score:** "does the skill still do its job?" This is the regression signal. A drop from 1.00
     means something broke.
   - **Δ (with minus without):** "is the skill still adding anything over plain Claude?" A shrinking Δ
     while WITH stays at 1.00 isn't a bug. It means plain Claude has caught up, and that part of the
     skill could be trimmed (this is how the naming table was judged for #25b).
4. **Each run costs money, and new models change results.** Every run and every `llm` grader is a real,
   billed model call (the first full set cost about $3 at list price, counted against plan usage). Re-run
   after a Claude model update too, not just after your own edits.

## The usage flow

**1. Edit the skill** in this repo (the working tree; evals load plugins from here, not from the
installed cache).

**2. Quick regression check on the plugin you touched.** One run, with the plugin only, so it's cheap
(roughly $0.10–0.50 per plugin):

| Plugin | Command (run from the folder shown) |
|---|---|
| `core`, `cpp-engine-conventions` | `plugins/<name>`: `claude plugin eval . --trust-plugin --runs 1 --ablation none --allow-tools Write` |
| `spec-plan-workflow` | `plugins/`: `claude plugin eval . --eval-dir spec-plan-workflow/evals --trust-plugin --runs 1 --ablation none --scaffold --allow-tools Write` |
| One case only | Add `--case <name>`, e.g. `--case naming-conventions` |

The final table shows WITH per case. Anything below 1.00, or `skill-fired … 0x`, needs a look.

`spec-plan-workflow` (and `quartermaster-ledger`) depend on `core`. Their cases list both plugin
folders (`plugins: ["../..", "../../../core"]`), and the eval tool only loads plugins from inside the
folder it runs against, so these suites must run from `plugins/`. Run from the plugin's own folder,
the dependency doesn't resolve and the plugin silently doesn't load.

**3. If something fails, find out why.** The terminal shows each grader as ✓/✗ with a reason, and
`report.html` in `evals/results/<timestamp>/` has the full detail. There are three usual causes:

- **The skill broke.** Fix the skill.
- **The grader was too strict.** For example, a regex expecting a specific word when the answer is still
  right. Fix the grader, not the skill.
- **A one-off fluke.** Re-run with `--runs 3`. If it passes 3 out of 3, move on.

If `skill-fired` shows `0x`, the skill didn't trigger or the plugin didn't load (the `core` dependency
problem above is the usual cause).

**4. Before publishing (bump, then push), run a full check of what you changed.** Use the same command
without `--ablation none`, and with `--runs 3`. That adds the without-plugin baseline, so you can
confirm Δ hasn't dropped. Then bump the version, push, and run `/plugin marketplace update kitbash`.

**5. For new behavior, write the case first.** Add an `evals/<case>/` folder (`prompt.md` +
`graders/*.md`, plus `case.yaml` + `setup.sh` if it needs fixture files), run it, and watch it fail or
show Δ 0. Then change the skill and watch it pass. This is the test-first approach from
`superpowers:writing-skills`. It's how the naming case became useful: the first version passed both
with and without the plugin, so it wasn't testing anything.

## Limits on this machine (native Windows)

- The `git-commit` case (`quartermaster-ledger`, tagged `needs-bash`) needs `Bash` access in the eval's
  sandbox, and native Windows doesn't provide one. It only runs on macOS, Linux or WSL2. For
  `git-commit` changes, the fallback is a quick manual check with
  `claude --plugin-dir ./plugins/core --plugin-dir ./plugins/quartermaster-ledger`.
- Cases granted `Write` (or read-only tools) run natively. Scaffold scripts (`--scaffold`) run directly
  through Git Bash, outside the sandbox.
- `--keep-temp` folders can't be locked down on Windows; delete them after inspecting
  (`claude-eval-*` under `%TEMP%`).
