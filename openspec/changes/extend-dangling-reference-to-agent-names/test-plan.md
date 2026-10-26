# Test plan — extend-dangling-reference-to-agent-names

Written by `ai-toolkit:change-test-writer` against the plan committed at bd95d5c. This file is not an OpenSpec schema artifact: `openspec instructions apply` does not list it, so read it on purpose before implementing.

Test command: `bash tests/run.sh` from the working-tree root. The runner selects by file; a single case runs as `TESTLIB=tests/lib.sh TOOLKIT_ROOT="$PWD" TESTDIR="$(mktemp -d)" bash tests/cases/<case>.sh`.

## Baseline

Full suite, taken before any test was written: `bash tests/run.sh` — 236 passed, 0 failed, exit 0. Working tree clean.

After this pass: 237 passed, 0 failed, exit 0. The one added case passes.

## Delta

`specs/session-workflow/spec.md` carries one `MODIFIED` requirement, *The session obligations are published in the workflow fragment and one binding fragment*. Compared with `openspec/specs/session-workflow/spec.md`, the delta adds one paragraph (neither fragment SHALL name an `ai-toolkit:` agent or skill the library does not ship) and one scenario. Every other sentence and the four other scenarios are identical. Nothing is removed or reworded.

## Scenarios (5 in the delta, 5 accounted for)

| # | Scenario | Accounting |
|---|---|---|
| 1 | A session obligation is stated once | Carried through verbatim; not re-derived by this pass. Its existing coverage stands: `tests/cases/workflow-fragment-publication-set.sh` (mechanical half), per `tests/coverage.md`. |
| 2 | A reader of a project's conventions finds no dangling reference | Carried through verbatim; not re-derived. Existing case: `tests/cases/workflow-fragment-no-dangling-reference.sh`, whose header names this scenario (mechanical half). Note that `tests/coverage.md` records the same case as covering no scenario. That is an existing inconsistency, reported here and not resolved. |
| 3 | **A fragment names only agents and skills the library ships** | **Covered** by `tests/cases/workflow-fragment-names-shipped-assets.sh` (new). |
| 4 | A project without a deploy is not served by a conditional | Carried through verbatim; not re-derived. Existing case: `tests/cases/workflow-fragment-states-assumptions.sh` (mechanical half). |
| 5 | A second publication does not arrive unowned | Carried through verbatim. Uncovered: `tests/coverage.md` records that there is no artifact to assert against, and this delta does not change that. |

## The new case: `tests/cases/workflow-fragment-names-shipped-assets.sh`

This is a static check (the third situation in `testing`): it reads the fragments and does not run them. The fragments already carry the property, so the case passed on its first run. For a static check, that pass establishes nothing on its own. What establishes that the check can fail is its two fixture-driven discriminators, which live inside the case and run on every suite run.

| Assertion | Classification |
|---|---|
| Every `ai-toolkit:<name>` in the body of `rules/development-workflow.md` and `rules/development-workflow-database.md` resolves to `agents/<name>.md` or `skills/<name>/SKILL.md`. Otherwise the case fails and prints each unresolved name. | Specified: the new paragraph and scenario 3 ("the library ships an agent or a skill of that name"). |
| Discriminator 1: a fixture body under `$TESTDIR` naming `ai-toolkit:no-such-agent-for-dangling-scan` is reported, and the report names it. | Specified: scenario 3 ("a name it does not ship is reported rather than passing unnoticed"). Shape from design.md decision 3. |
| Discriminator 2: a fixture body naming `ai-toolkit:change-test-writer` (a shipped agent) and `ai-toolkit:testing` (a shipped skill) is not reported. | Specified: scenario 3 ("an agent or a skill"). Design decision 1 rules out an agents-only scan. |
| Only the body is scanned. The frontmatter (up to the second `---`) is stripped, and a missing delimiter or an empty body fails the case. | Derived: the scenario says "either fragment's body". The extraction mirrors `workflow-fragment-no-dangling-reference.sh`. |
| A name is matched as `ai-toolkit:[a-z0-9][a-z0-9-]*`. | Derived from design.md decision 2. The scenario states no pattern. |
| The guards that check `$TOOLKIT_ROOT` holds `agents/` and `skills/`, that the absent fixture name really is unshipped, and that the shipped fixture names really are shipped. | Derived. These are guards on the test's own premises. |
| Deliberately untested: whether a named agent is the right one for its gate. | design.md *Non-Goals*: that is prose, verified by reading. |
| Deliberately untested: other `rules/` fragments, skills and agents. | design.md *Non-Goals*: the requirement binds the two session fragments only. |
| Deliberately untested: plugin names other than `ai-toolkit`. | design.md *Risks*: the plugin's name is fixed. |

Discrimination was confirmed by mutation during this pass. The mutated copies were kept in a scratch directory and then removed; none is in the suite.

- With the pattern replaced by one that never matches, discriminator 1 fails.
- With an agents-only resolution, discriminator 2 fails on `ai-toolkit:testing`.
- Run over a scratch `TOOLKIT_ROOT` whose workflow fragment body names `ai-toolkit:ghost-reviewer`, the real-fragment scan fails and prints that name.

Task 1.2 (temporarily naming an absent agent in the real `rules/development-workflow.md`) is still the implementation step's job. This pass writes only inside `tests/cases/**`.

## Obsolete tests

None found by this search, which covered `tests/cases/**` only. No earlier `test-plan.md` was supplied. The `MODIFIED` delta only adds text: it supersedes no sentence and no scenario of the existing requirement. So none of the cases bearing on the requirement asserts behaviour this delta changes. Those cases are `workflow-fragment-publication-set.sh`, `workflow-fragment-no-dangling-reference.sh` and `workflow-fragment-states-assumptions.sh`. Treat this as a candidate finding for human confirmation, not a conclusion.

## Missing shared arrangement

The dispatch named no shared arrangement, and the dispatched conventions do not name one either. `tests/README.md` documents `tests/lib.sh` as the assertion helpers sourced via `$TESTLIB`. That is recorded below as an unresolved question.

One local declaration:

- **`unshipped_names`**, declared in `tests/cases/workflow-fragment-names-shipped-assets.sh`.
  - What it stands in for: a scan that returns a status instead of exiting, which design decision 3 requires.
  - Tests using it: `tests/cases/workflow-fragment-names-shipped-assets.sh`.
  - Near-miss in a shared arrangement: none known.
  - Found in another test module: no. The body-extraction lines are copied, not imported, from `tests/cases/workflow-fragment-no-dangling-reference.sh`.
  - Proposed home: none to propose, since no shared arrangement was named.

## Unresolved project questions

1. **No stack skill for this repository's test idiom.** The library carries a `bash` skill, which was loaded. No skill covers this repository's harness specifically. Assumption: follow the shape of the existing cases. This affects the new case.
2. **Is `tests/lib.sh` a shared arrangement?** The conventions neither name it as one nor say the project has none. Assumption: treat it as outside this pass's read set. Only `assert_file` is used, according to the interface `tests/README.md` documents. This affects the new case.
3. **Whether `set -e`/`pipefail` is in force inside a case** depends on `tests/lib.sh`, which was not read. Assumption: neither is relied on. Statuses are branched on explicitly, and the `grep` pipeline carries `|| true`. This affects the new case.
4. **Does `workflow-fragment-no-dangling-reference.sh` cover scenario 2?** Its header and `tests/coverage.md` disagree (see the table above). This is an existing inconsistency and affects no test written here.
