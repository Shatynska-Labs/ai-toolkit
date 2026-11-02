# Test plan: raise-the-plugin-version-on-release

Written by `change-test-writer`. Run one case with `bash tests/run.sh <case-name>`, several by naming them, or `bash tests/run.sh` for all. Every test named below is a case name the runner selects. The OpenSpec schema does not know this file, so it does not appear among `openspec instructions apply`'s context files.

The delta holds 16 scenarios, 14 under the ADDED requirement and 2 under the MODIFIED one. All 16 are accounted for below: 16 covered, one of them only in part.

## The check under test

`tests/cases/lib/plugin-version-rise.sh` is the check's logic, per design decision 2. It is test code written in this pass, and this change ships no other implementation of it. `plugin_version_check ROOT` returns 0 or 1, prints `compared base=… base_version=… trunk_version=… version=… shipped=…` once it has compared, and prints each refusal as `[TAG] reason` with the tags `no-trunk`, `unreadable`, `lowered`, `not-raised`, `trunk-took` and `too-small`. It unsets `GIT_DIR`, `GIT_WORK_TREE` and `GIT_INDEX_FILE` when sourced, and each case sources it first, so its fixture's git calls are covered too.

Cases source this file because it is the subject they exercise, as the dispatch and design decision 2 direct. It is not arrangement imported from another test module: each case's fixture is declared in the case.

## Scenarios

"State" is the state at authoring. Green at authoring is expected for scenarios 1 to 12, because the check arrives in the same pass: what establishes those cases is the refusal and the pass beside it in each case, and the mutation run below.

| # | Scenario | Case | State at authoring |
|---|---|---|---|
| 1 | A shipped change without a rise is refused | `plugin-version-rise-shipped-change-unraised-refused` | green |
| 2 | A lowered version is refused | `plugin-version-rise-lowered-refused` | green |
| 3 | A number the trunk already took is refused | `plugin-version-rise-trunk-number-refused` | green |
| 4 | A rise is sized from the trunk's tip where the trunk has risen | `plugin-version-rise-sized-from-trunk-tip` | green |
| 5 | A diff touching nothing shipped owes no rise | `plugin-version-rise-nothing-shipped-owes-nothing` | green |
| 6 | A fragment's major needs a plugin major | `plugin-version-rise-fragment-major-needs-major` | green |
| 7 | A fragment's minor needs at least a plugin minor | `plugin-version-rise-fragment-minor-needs-minor` | green |
| 8 | A new skill, agent, script or fragment needs at least a plugin minor | `plugin-version-rise-added-asset-needs-minor` | green |
| 9 | A removed skill, agent, script or fragment needs a plugin major | `plugin-version-rise-removed-asset-needs-major` | green |
| 10 | A sufficient rise passes | `plugin-version-rise-sufficient-rise-passes` | green |
| 11 | The trunk itself owes nothing | `plugin-version-rise-trunk-owes-nothing` | green |
| 12 | No trunk to compare with is a failure | `plugin-version-rise-no-trunk-fails` | green |
| 13 | The suite checks this repository | `plugin-version-rise-checks-this-repository` | green, and stays green through this change |
| 14 | The rule is stated | `plugin-version-rise-rule-stated` | **red** until task 1.1 |
| 15 | New skill needs no manifest change (MODIFIED) | `plugin-manifests-name-no-skill` | green; covered in part, see below |
| 16 | Enumeration is not used (MODIFIED) | `plugin-marketplace-no-skills-array` | green |

### Expected state of the repository case

`plugin-version-rise-checks-this-repository` does not depend on `plugin.json` rising. This branch's diff from its merge base with `origin/main` touches no shipped path, so the check passes at `1.0.0` and at `2.0.0`, and task 1.2 changes nothing in this case's result. That was observed in a scratch clone: green at the plugin's current version, green at `2.0.0`, and red, `[not-raised]`, with one shipped file touched and no rise. It goes red only on a branch that ships without the rise it owes.

## Uncovered scenarios

None is wholly uncovered. Part of scenario 15 is deliberately untested: "it is discovered in the next session" needs a Claude Code session, which this suite does not run. The case covers the other half, that no entry names a skill, and the delta's new clause, that the version in `plugin.json` is no such entry.

## Assertion classification

| Case | Specified | Derived | Deliberately untested |
|---|---|---|---|
| `…-shipped-change-unraised-refused` | each of the four directories, version unchanged, refused and named as not raised; design 3: an uncommitted edit counts | the control with a rise | |
| `…-lowered-refused` | lowered, whatever else changed | the 1.10.0 and 1.9.0 pair as the proof of "numerically" | |
| `…-trunk-number-refused` | a version equal to or below the tip's refused, naming the trunk's version | the control above the tip | |
| `…-sized-from-trunk-tip` | 2.0.0, 3.0.0, 3.0.1 owing a major refused | 3.1.0 refused, 4.0.0 passes, a minor sized the same way, a patch owed passes at 3.0.1 | |
| `…-nothing-shipped-owes-nothing` | unchanged and raised both pass; design 3: untracked files are not in the diff | near-miss paths (`docs/skills/…`, `tests/scripts/…`, `skillsets/…`, `rules.md`) are outside; a risen trunk owes this branch nothing; the shipped control | |
| `…-fragment-major-needs-major` | plugin minor and patch refused | plugin major passes; a fragment minor beside it does not lower what is owed; a `version:` in a body is no rise (design 4 names the frontmatter) | |
| `…-fragment-minor-needs-minor` | plugin patch refused | plugin minor and major pass; a fragment patch owes a patch | |
| `…-added-asset-needs-minor` | each of the four kinds at a patch refused | each at a minor passes | |
| `…-removed-asset-needs-major` | removed and renamed, each of four kinds, minor and patch refused; design 3: `--no-renames` | each at a major passes | |
| `…-sufficient-rise-passes` | at least what is required passes; design 3: an uncommitted rise counts; design 4: unnamed files and `rules/README.md` owe a patch, a fragment with no version has no rise | more than required passes; the unraised control | |
| `…-trunk-owes-nothing` | no diff passes | a shipped change the trunk already holds is no diff; an edit on top of it is | |
| `…-no-trunk-fails` | fails, says so, reports no comparison | the three forms: no `origin/main`, an unrelated one, no repository | |
| `…-checks-this-repository` | the check reads this branch's diff and version | the operationalisation: the report's base, version and shipped count equal what the case reads for itself, and over a fixture name the fixture's | |
| `…-rule-stated` | the version rises with every shipped change; each size's meaning | the rule is read from paragraphs naming the plugin's version with a rise, plus the list directly under each; the phrases accepted for each meaning | any wording outside those alternatives |
| `plugin-manifests-name-no-skill` | no entry names a skill; the version is no such entry | an entry is a `"skills"` key, a `skills/<name>` path or a string `"<name>"` | discovery in the next session |
| `plugin-marketplace-no-skills-array` | no `skills` array | any `"skills"` key anywhere in the file; the file must hold a `"plugins"` entry | |

### Discriminators (third situation)

The three static reads of this repository run their check over fixtures first: `plugin-version-rise-rule-stated`, `plugin-manifests-name-no-skill` and `plugin-marketplace-no-skills-array`. The rule-stated case includes a fixture holding the sizes only for a fragment, which is what `AGENTS.md` holds today, and it is refused. `plugin-version-rise-checks-this-repository` runs a refusing fixture first.

`plugin-version-rise-rule-stated` is red on the property that no paragraph of `AGENTS.md` states the rule (state 1, `[absent]`). Over a scratch copy of `AGENTS.md` with one such paragraph added it was green.

### Mutation run of the check

Each of 22 single edits to a scratch copy of `plugin-version-rise.sh` was run against the fixture cases, and each turned at least one case red: dropping `--no-renames`; sizing from the base; no tip check; no lowered check; no not-raised check; no size check; returning early on any diff; a removal owing a minor; an addition owing a patch; a fragment major owing a minor; ignoring a fragment minor; a fragment minor lowering a major; reading past the frontmatter; counting `rules/README.md` as named; counting every shipped file as named; passing on no `origin/main`; passing on no merge base; unanchored paths; prefix paths; text comparison; diffing against `HEAD`; counting untracked files. Two mutants first survived. One had edited a comment rather than the code, and red once corrected. The other showed the body-`version:` assertion was weak, and that fixture was strengthened in `plugin-version-rise-fragment-major-needs-major`.

## Obsolete tests

The change carries a MODIFIED delta, *Skills are discovered without manifest enumeration*. Comparing it with `openspec/specs/toolkit-structure/spec.md`, what is superseded is "adding a skill requires no manifest edit" and "with no edit to `plugin.json` or `marketplace.json`": a new skill now edits `plugin.json`'s version while still being enumerated nowhere.

No candidates. No bearing test was found by this search, which is not the same as none existing: the search covered `tests/cases/*.sh` and `tests/cases/lib/` for `plugin.json`, `marketplace` and `claude-plugin`, and no earlier `test-plan.md` was supplied. The only case naming those files is `plugin-version-semantic`, which asserts the version's form and floor, neither of which the delta supersedes. `tests/coverage.md` holds no row for either MODIFIED scenario.

## Unresolved project questions

| # | Question | Assumption taken | Tests depending |
|---|---|---|---|
| Q1 | Should the check fail wherever the suite runs without `origin/main`, such as a fresh copy of an installed plugin or a clone without that ref? Design decision 2 says it fails rather than skips, and the conventions do not address a copy with no repository. | It fails, in every such place. | `plugin-version-rise-checks-this-repository`, `plugin-version-rise-no-trunk-fails` |
| Q2 | Is the trunk always `origin/main`? The design names it; no convention covers a remote of another name. | Yes: `PVR_TRUNK` in the check. | every `plugin-version-rise-*` case but `-rule-stated` |
| Q3 | How may `AGENTS.md` lay the rule out? The delta states content, not form. | In paragraphs naming the plugin's version with a rise, with any list directly beneath. A form outside that needs the case's derived selector reconsidered, which is a change to a derived assertion. | `plugin-version-rise-rule-stated` |

No stack skill question arises: `bash` covers this stack. Convention files name `tests/lib.sh` as this suite's shared arrangement, so no question arises on that either.

## Missing shared arrangement

**Disposition: every entry kept local.** This project's conventions record no shared arrangement's location, and recording one is a testing-strategy decision, which `record-this-repositorys-shared-test-arrangement` holds.

Dispatched shared arrangement: `tests/lib.sh`. It holds no git fixture. Nothing was written to it. Each entry's proposed home is a new `tests/plugin-version-lib.sh`, beside `tests/task-board-lib.sh` and sourced the same way, unless the entry says otherwise. The set "the 13 fixture cases" means every `plugin-version-rise-*` case except `plugin-version-rise-rule-stated`, the 13 being the cases declaring these names.

| Declared | Declared in | Stands in for | Used by | Near-miss in the shared arrangement | Found in a test module |
|---|---|---|---|---|---|
| `R`, `OUT` | the 13 fixture cases | the fixture's path; the check's output | those cases | none | no |
| `die` | the 13 fixture cases | a failure helper | those cases | none: `assert_*` report on files and exit codes | `tests/task-board-lib.sh`, which is not dispatched arrangement and fixes a task-board project |
| `g` | the 13 fixture cases | checked git in the fixture | those cases | none | `tests/task-board-lib.sh`, as above |
| `commit_all` | the 13 fixture cases | a commit of everything | those cases | none | no |
| `set_version` | the 13 fixture cases | a `plugin.json` at a version | those cases | none | no |
| `fragment_at` | the 13 fixture cases | a fragment at a version | `…-fragment-major-needs-major`, `…-fragment-minor-needs-minor`, and `fixture_at` | `fragment_version` reads a fragment and writes none, and only `development-workflow.md` | `mkfx` in `rules-changelog-version-rise-recorded` writes similar fragments into a plain directory |
| `fixture_at`, `fixture` | the 13 fixture cases | a repository with a branch off `origin/main` holding one of each shipped kind | those cases | none | no |
| `expect` | the 13 fixture cases | running the check and reading its refusal | those cases | `assert_exit` reads a status and not a tag | same-named, differing helpers in `rules-changelog-version-rise-recorded` |
| `trunk_rises` | `…-trunk-number-refused`, `…-sized-from-trunk-tip`, `…-nothing-shipped-owes-nothing` | the trunk moving after the branch left | those three | none | no |
| `add` | `…-added-asset-needs-minor` | an asset at a path | that case | none | no; no proposed home, one case's need |
| `remove`, `rename` | `…-removed-asset-needs-major` | the two ways an asset goes | that case | none | no; no proposed home, one case's need |
| `assert_not_compared` | `…-no-trunk-fails` | a reading of the check's output | that case | none: `assert_contains` reads files | no; no proposed home, one case's need |
| `clean` | `plugin-manifests-name-no-skill` | two clean manifests | that case | none | no; no proposed home, one case's need |

`rule_lines`, `check_rule`, `check_manifests` and `check_marketplace` are those cases' own checks, not arrangement, and stay in them. The `expect` in each of these three cases is local on the pattern of `rules-changelog-version-rise-recorded` and needs no shared home.

## Baseline

Full: `bash tests/run.sh` at `1e54143`, before any test was written: 626 passed, 0 failed.

After this pass, full: 641 passed, 1 failed. The failure is `plugin-version-rise-rule-stated`, expected until task 1.1. The 626 baseline cases all still pass, with 16 added.
