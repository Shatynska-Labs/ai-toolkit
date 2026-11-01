# Test plan: report-the-board-as-json

Derived from the change's delta spec before implementation. Every case below is selectable with `bash tests/run.sh <case>`, from the working tree. A case's header carries its own SPECIFIED and DERIVED lines; the tables here summarise them.

**Parser.** Cases that read the document use `python3` where present, else `jq`, through a local `jv`. Where neither is present such a case fails with `neither python3 nor jq is present, so the document cannot be parsed`; it never passes silently. Both backends gave identical values on a canned document, and the failure with neither was observed.

## Scenarios

25 scenarios in the delta spec, 25 accounted for: 20 covered by new cases, 5 by existing cases named below, none omitted. The count: 15 under the ADDED requirement, 6 under *The tool reports its outcome*, 4 under *The tool writes one self-contained page for one project*.

| Scenario | Delta | Cases |
|---|---|---|
| A document | ADDED | `task-board-json-a-document` |
| The same reading as the page | ADDED | `task-board-json-same-reading-as-the-page` |
| A value with quotes, backslashes and a tab | ADDED | `task-board-json-hard-characters` |
| Markup stays as written | ADDED | `task-board-json-markup-stays` |
| No origin | ADDED | `task-board-json-no-origin` |
| A failed fetch | ADDED | `task-board-json-failed-fetch` |
| A step of two workstreams | ADDED | `task-board-json-step-of-two-workstreams` |
| A step with another workstream's entry value | ADDED | `task-board-json-step-with-another-entry` |
| A workstream that is not open | ADDED | `task-board-json-workstream-not-open` |
| A task with no workstream | ADDED | `task-board-json-no-workstream` |
| Forge not reached | ADDED | `task-board-json-forge-not-reached` |
| A blocked run | ADDED | `task-board-json-blocked-run` |
| With an output | ADDED | `task-board-json-with-output` |
| A usage error with --json | ADDED | `task-board-json-usage-error` |
| A failed run | ADDED | `task-board-json-failed-run` |
| Not a repository | MODIFIED | `task-board-json-blocked-run` (under `--json`); `task-board-report-not-a-repository` (without) |
| No trunk | MODIFIED | `task-board-json-blocked-no-trunk`; `task-board-report-no-trunk`, `task-board-report-no-commit`, `task-board-report-no-commit-no-remote` |
| A single-file backlog | MODIFIED | `task-board-json-blocked-single-file`; `task-board-report-single-file-backlog` |
| Nothing to show | MODIFIED | `task-board-json-blocked-nothing-to-show`; `task-board-report-nothing-to-show` |
| Unwritable output | MODIFIED | `task-board-report-unwritable-output`, unchanged; no new case, see below |
| The report under --json | MODIFIED | `task-board-json-report-on-stderr` |
| Default output | MODIFIED | `task-board-default-output`, unchanged; `task-board-json-a-document` holds that `--json` writes no page |
| A named output | MODIFIED | `task-board-named-output`, unchanged; `task-board-json-without-flag-report-on-stdout` |
| The page states its moment | MODIFIED | `task-board-page-states-time`, `task-board-page-states-trunk-commit`, unchanged; no new case, see below |
| The page stands alone | MODIFIED | `task-board-page-refers-to-nothing-external`, `task-board-page-works-without-scripting`, unchanged; no new case, see below |

Requirement text no scenario reaches is covered by: `task-board-json-keys-and-version`, `-run-facts`, `-project-from-a-working-tree`, `-target-argument`, `-workstream-fields`, `-workstream-active`, `-lists-sorted-names-once`, `-task-status`, `-task-stage`, `-task-parts`, `-task-last-commit`, `-task-entry-values`, `-task-body-keeps-lines`, `-task-unplaced`, `-warnings-are-the-sum`, `-forge-partly-read`, `-forge-read-in-full`, all with the `task-board-json` prefix. Design-derived: `-control-character`, `-leaves-no-temporary-files`, `-help-names-the-flag`.

## Uncovered scenarios

No scenario is uncovered. Three have no new case, for the reasons here; each is covered by existing cases. *Default output* and *A named output* are held by existing cases too, each with a new case beside it.

- **Unwritable output.** `--json` writes no page and `--output` is refused with it, so the scenario has no `--json` form. The nearest is `task-board-json-failed-run`.
- **The page states its moment** and **The page stands alone.** The revision adds only "without `--json`"; what they state of the page is unchanged and held by the existing cases named above.

## Classification of assertions

**Specified** unless the table says otherwise; each case's header says the same in place.

| Case | Derived assertions |
|---|---|
| `task-board-json-a-document` | git status unchanged; two documents in sequence do not count as one |
| `task-board-json-keys-and-version` | the key sets are exact, from the design's Risks |
| `task-board-json-run-facts` | `trunk.ref` resolves in the project to the commit read |
| `task-board-json-target-argument` | the directory may come before or after the flag |
| `task-board-json-lists-sorted-names-once` | the fixture's use of an active `ws-z` to expose page order; the sort itself is specified |
| `task-board-json-task-stage` | the count `4/12` sits somewhere in the `build:applying` string |
| `task-board-json-task-parts` | the order of `parts` is not asserted |
| `task-board-json-task-body-keeps-lines` | newlines kept (design decision 2); frontmatter is not body text |
| `task-board-json-same-reading-as-the-page` | a count of 8 guards the loop against an empty list; a step of two workstreams is left to its own case |
| `task-board-json-control-character` | wholly derived, design decision 2 |
| `task-board-json-no-origin` | `remote_branches_read` false |
| `task-board-json-failed-fetch` | `remote_branches_read` false |
| `task-board-json-step-of-two-workstreams` | the order of the two names is not asserted |
| `task-board-json-with-output` | `--output --json` reads as the refusal, design decision 5 |
| `task-board-json-usage-error` | exit status not zero; no particular status is fixed |
| `task-board-json-failed-run` | the failure is arranged by an `awk` that does its work and then fails |
| `task-board-json-report-on-stderr` | the line prefixes, from `tests/README.md` |
| `task-board-json-leaves-no-temporary-files` | wholly derived, design decision 5 |
| `task-board-json-help-names-the-flag` | wholly derived, `tasks.md` 3.1 |

**Deliberately untested**, each with its reason:

- The rule on when `schema_version` rises. It binds future changes, and nothing can execute it; `task-board-json-keys-and-version` makes a change to the shape touch a case.
- Text that is not UTF-8. The design assumes it away.
- `--json` with `--help`, and `--json --output` with no value. Neither is stated, and a test would invent the answer.
- The JSON value of the stage `unknown`, and `merge_unchecked` on a task with a change of its name on the trunk. See the unresolved questions.
- `tasks.md` 3.2's run on commerce-ops. It is a manual verification on another repository.

## Obsolete tests

**None found, by this search.** This is a finding of the search, not proof that no such test exists: it covered `tests/cases/**`, and no earlier `test-plan.md` was dispatched.

The search: `grep -- --json` over `tests/cases/` and `tests/cases/lib/` matched nothing; no existing case passes the flag. For *The tool reports its outcome*, the delta adds the `--json` sentences and turns "warnings on the page" into "warnings"; the bearing cases `task-board-report-*`, and `task-board-report-counts-warnings` in particular, run without `--json`, and the fixture of `task-board-json-warnings-are-the-sum` already reports `Warnings: 4` on the page, the sum the requirement asks for. For *The tool writes one self-contained page for one project*, the delta adds "without `--json`"; `task-board-default-output`, `task-board-named-output` and `task-board-help-writes-nothing` still state what the revised requirement states.

Candidates for human confirmation: none. Nothing was edited or deleted.

## Unresolved project questions

1. **`merge_unchecked` on a task with a change on the trunk, the forge not read in full.** The field is "true where the page shows a task's unchecked mark"; *An unreachable forge* marks a task with no change of its name, while *A task in flight shows its stage* has every stage carry the mark. Assumption: untested. No case depends on it; `task-board-json-forge-not-reached` and `-forge-partly-read` use a step with no change.
2. **The stage's form in the document.** `stage` is "string or null", and the value for `unknown`, the form of the count and whether the string carries the unchecked mark are unstated. Assumption: the page's stage names; with the forge read in full, `plan:drafting`, `plan:exploring`, `ship:pr-open` and `ship:merged` are the whole string, and `build:applying` holds `4/12`. Depends: `task-board-json-task-stage`, `task-board-json-same-reading-as-the-page`.
3. **A case fails where neither parser is present.** The proposal says "the suite needs neither"; the dispatch says such a case fails with that reason. Assumption: the dispatch. On a machine with neither, every case declaring `jv` fails. Depends: all those cases.
4. **`trunk.ref`'s form.** Only "the reference read". Assumption: `git rev-parse` resolves it in the project. Depends: `task-board-json-run-facts`.
5. **`body`'s edges.** Assumption: frontmatter excluded, and leading or trailing blank lines free, so cases assert substrings. Depends: `task-board-json-task-body-keeps-lines`, `task-board-json-hard-characters`.
6. **The exit status of a usage error under `--json`.** The scenario names none; today's unknown flag exits 2. Assumption: not zero. Depends: `task-board-json-usage-error`.

## Missing shared arrangement

The dispatch named `tests/lib.sh` and `tests/task-board-lib.sh`. Both were used and neither edited. Every declaration below is local to the files named; no test file imports from another, and none was found in another test module. Proposed home for all: `tests/task-board-lib.sh`, where the repetition across these cases would go.

- **`STDOUT`, `STDERR`, `board_json`** — declared in every `tests/cases/task-board-json-*.sh` except `task-board-json-help-names-the-flag`. Stands in for the tool's runner with its streams apart. Used by those 39 cases. Near-miss: `board_in`, which captures both streams into `$REPORT`, so it cannot tell which stream a line went to. It carries the target-absent guard the dispatch asked for.
- **`jv`, `require_parser`, `doc`, `jis`** — declared in the 31 cases that read the document: all except `task-board-json-blocked-run`, `-blocked-no-trunk`, `-blocked-single-file`, `-blocked-nothing-to-show`, `-with-output`, `-usage-error`, `-failed-run`, `-without-flag-report-on-stdout` and `-help-names-the-flag`. Stands in for a reader of the document by `python3` or `jq`, with a guard for neither. Near-miss: none; `has` and `hasre` read text, not JSON.
- **`names`** — declared in `task-board-json-lists-sorted-names-once`, used there. Lists names from `jv`. Near-miss: none. Proposed home: none needed, one case.
- **`refused`** — declared in `task-board-json-with-output`, used there. The three assertions of one refused invocation. Near-miss: `blocked`, which reads `$REPORT`. Proposed home: none needed, one case.
- **`$TESTDIR/failing/awk`, written inline** — declared in `task-board-json-failed-run`, used there. Stands in for a failing renderer. Near-miss: none; `stub_gh` is the only stub in the shared arrangement. Proposed home: none needed, one case.

## Baseline

Scoped, taken before any test was written: `bash tests/run.sh` over the 156 existing `tests/cases/task-board-*.sh`. 156 passed, 0 failed.

## State of the new cases at authoring

Full suite with the 40 new cases: 563 passed, 39 failed. All 39 are new cases; the 562 existing cases all pass, and no existing file was touched.

Every case but one is red because `--json` is an unknown flag today: the tool exits 2 with `Outcome: BLOCKED` on standard output. Their setup ran and their first check failed, so **their later assertions have not executed**, and whether they are any good is unverified until the flag exists. A later assertion that fails against the implementation may be a defect in the case: reconsider it only where it is derived, per the table above, and record the change.

`task-board-json-without-flag-report-on-stdout` passes today, as it should: it runs existing behaviour, without `--json`, and holds that line. It is not a state-four alarm.

Checked without the implementation: ShellCheck clean over the new cases; the `jv` reader on a canned document under both backends; the page half of `task-board-json-same-reading-as-the-page` against the real page, with the statuses written by hand. That the fixture of `task-board-json-failed-run` strikes after reading has begun was observed without `--json`: the tool reports `Target:`, then `Outcome: ERROR`, exit 1.

## Dispositions at apply

- **Local arrangement:** kept in each case, for the reason `task-board` records: this project's conventions record no shared arrangement's location.
- **`merge_unchecked` beside a change on the trunk:** true where the forge is not read in full, since the requirement defines it as the page's mark, and the page marks every stage then.
- **Stage:** the page's text, `build:applying 4/12` and `unknown` included.
- **A parsing case with neither parser:** fails with that reason, as dispatched. The proposal's "the suite needs neither" holds for running the rest of the suite.

