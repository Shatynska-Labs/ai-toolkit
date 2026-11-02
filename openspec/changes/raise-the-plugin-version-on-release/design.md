## Context

See `proposal.md`. `/plugin update` reads the version in `.claude-plugin/plugin.json`; `.claude-plugin/marketplace.json` carries none, so that is the only number to move. Fragments already carry semantic versions with stated meanings. This repository has no CI, so `bash tests/run.sh`, which the workflow runs before a pull request, is the only place a rule can be enforced. A static-read case with fixtures is the suite's established shape, for example `tests/cases/rules-changelog-version-rise-recorded.sh`.

## Goals / Non-Goals

**Goals:**
- A shipped change cannot pass the suite without a version rise.
- The rise's size is checked as far as a diff can show it.

**Non-Goals:**
- A required check on the forge, or CI.
- A changelog for the plugin. `rules/changelog` records fragments, a project hears of them through `scripts/project-update`, and the plugin's history is its commits.
- A release process, tags or a publishing step.
- A check that a local suite cannot make: refusing a merge, or seeing the forge's trunk without a fetch.
- Detecting a removed flag or a changed behaviour inside a script.

## Decisions

**1. The version rises on every merge changing a shipped path.** The operator, 2026-11-01. A release-only rise needs a release process this repository lacks, delays fixes, and leaves a test unable to tell a forgotten rise from one not yet due.

**2. The test is the enforcement, and it fails rather than skips.** The check lives in test code, as other repository rules do, not in a shipped script, because only this repository needs it. Its logic sits in `tests/cases/lib/`, sourced by the cases that run it over fixture repositories and by one case that runs it over this repository, so a green suite means this repository was checked. Where the base cannot be found it fails: a skip would read as success, which is the failure the workflow warns of.

**3. The diff's base is `git merge-base HEAD origin/main`, compared with the working tree, and a rise owed must also clear `origin/main`'s tip.** Against the merge base, a branch is judged on its own diff rather than on what the trunk gained since. That alone misses two branches making the same rise: identical edits merge with no conflict, and each passes against its base. So the raised version must also be above the tip's, and the rise is sized from the higher of the two, so that a diff owing a major cannot land as a patch above a trunk that rose meanwhile. Comparing with the working tree means an uncommitted edit counts during development; untracked files do not, and a verification run on the branch head sees them committed. `--no-renames` makes a rename a removal and an addition, so it needs a major.

**4. What needs a minor when added and a major when removed is what a caller names.** `skills/<name>/SKILL.md`, `agents/<name>.md`, `rules/<name>.md` other than `rules/README.md`, and a file directly under `scripts/`. Other files under those directories count as shipped paths but add or remove nothing a caller names. A fragment's rise is read from its frontmatter `version` at both ends; one with no `version` has no rise.

**5. The requirement is added, not folded into *Repository is an installable plugin*.** The backlog entry expected a delta to that requirement, but it states the plugin's shape, and this is a rule about diffs with scenarios of its own. Its version scenario still holds. The clause in *One directory level for every asset type* and `project-bootstrap` that a fragment's version is unrelated to the plugin's stays as written, since the numbers remain separate; the new requirement says a fragment's rise is only a floor, rather than rewriting two long requirements for one clause.

**6. The first rise is `2.0.0`.** Since `a559b93` set `1.0.0`, `development-workflow` and `workstreams` have each reached `2.0.0` and scripts have been added, so the rule read over that span requires a major. This change's own diff touches no shipped path and owes nothing, so the rise is made deliberately, and is what lets the effect be confirmed.

## Risks / Trade-offs

- [Two branches take one number] → The comparison with the trunk's tip refuses it, but only as fresh as the local `origin/main`, so a rise merged after the last fetch slips past. Without CI a local suite can narrow that window and not close it; the workflow's fetch before the pull request narrows it further.
- [A merge without running the suite skips the check] → Accepted without CI; the workflow requires the run and the pull request description reports it.
- [A stale `origin/main` gives an older base] → The merge base is still a true ancestor, so the diff is only larger, and sizing stays sound.
- [A size judged wrongly by the author] → Delivery is unaffected, since any rise reaches `/plugin update`; only the number misleads.

## Migration Plan

The first `/plugin update` after this merges takes the operator's copy from `0.2.0` to `2.0.0`. Where the update does not take from a copy that old, reinstall once.
