# Test plan: seed-the-backlog

Written by the derived-tests pass before implementation. This file is not an artifact the OpenSpec schema knows about; it does not appear among `openspec instructions apply`'s context files and must be read on purpose.

Test command: `bash tests/run.sh` (from the worktree root). Tests are named by case file stem under `tests/cases/`; the runner reports each stem as `ok` / `FAIL`. To run one case on its own, run the full command and read its stem's line. The harness offers no per-case selector, which is recorded below as an unresolved question.

## Baseline

Full suite, taken at commit `2a28fb6` before any case was written: **73 passed, 0 failed.**

After this pass: **74 passed, 11 failed.** The 11 failures are all new cases from this pass. No case that passed before this pass now fails. One new case passes (`workflow-fragment-backlog-rules-not-restated`). It reads the fragment statically, and its fixtures establish that it can fail.

## Scenario accounting

There are 16 scenarios in the delta specs: 6 in `project-bootstrap` (3 ADDED, 3 MODIFIED) and 10 in `session-workflow` (all under one MODIFIED requirement). All 16 are accounted for below.

### project-bootstrap: ADDED "A backlog is seeded where none exists"

| # | Scenario | Tests | State at authoring |
|---|---|---|---|
| 1 | A project without a backlog receives the seeded file | `backlog-seeded-new-project`, `backlog-seeded-adoption` | FAIL: the file is absent (target absent) |
| 2 | An existing backlog is preserved exactly | `backlog-existing-preserved`, `backlog-dangling-symlink-not-written-through` | FAIL: no `backlog:` report line. The byte-for-byte assertion already passes, because the tool does not touch `docs/` yet. That pass is not evidence. |
| 3 | The seeded file carries no numbering | `backlog-seeded-no-numbering` | FAIL: the file is absent (target absent) |

### project-bootstrap: MODIFIED "Each concern is checked independently and is safe to repeat"

| # | Scenario (as revised) | Tests | State at authoring |
|---|---|---|---|
| 4 | Repeated execution is not destructive | `repeated-execution-backlog` (new; covers the backlog concern the revision adds). Also the existing `repeated-execution-idempotent`, unchanged, which covers the other concerns. | new: FAIL (target absent); existing: ok |
| 5 | A partially initialized directory is completed, not refused | `partial-init-reports-backlog` (new). Also the existing `existing-git-no-openspec`, unchanged. | new: FAIL (no `backlog:` line); existing: ok |
| 6 | Existing specification tooling is skipped, not reinitialized | Existing `existing-git-and-openspec`, unchanged. No new test: the scenario's text is unchanged, and it concerns only the repository and specification-tooling concerns, which the backlog concern does not affect. | ok |

### session-workflow: MODIFIED "A second change surfacing in a session is recorded in the backlog"

| # | Scenario (as revised) | Tests | Notes |
|---|---|---|---|
| 7 | A blocking dependency survives the session ending | **Uncovered.** This is session behavior, not checkable by a token scan, and the scenario is unchanged by this delta. | No existing case claims it. Verified by reading. |
| 8 | An unrelated improvement is recorded rather than implemented | **Uncovered.** This is session behavior and is unchanged by this delta. The path half is held by the existing `workflow-fragment-fixed-paths` (`docs/backlog.md` assertion). | Verified by reading. |
| 9 | A backlog entry is cited by name | `backlog-seeded-new-project` (the seeded file says "only by that name") and `workflow-fragment-backlog-no-entry-numbers` (the fragment mentions no entry number) | Revised: the seeded file now directs naming. Both FAIL at authoring. |
| 10 | The scope rule and the backlog are one obligation | **Uncovered.** This is a reconciliation stated in prose, unchanged by this delta. | Verified by reading. |
| 11 | The backlog does not yet exist | `workflow-fragment-backlog-not-created-by-fragment` (the fragment does not direct creating it). The tool-creates half is `backlog-seeded-new-project` and `backlog-seeded-adoption`. | Revised. FAIL at authoring. The fragment still carries "creating that file if absent". |
| 12 | Entry rules are read from the backlog, not the fragment | `workflow-fragment-backlog-rules-not-restated`, `workflow-fragment-backlog-no-entry-numbers`, `backlog-seeded-no-numbering`. The how-it-is-headed/shaped/deleted half in the file: `backlog-seeded-new-project`. | New scenario. `rules-not-restated` is green at authoring and fixture-backed. The other three FAIL. |
| 13 | An identified change is opened without a proposal | Existing `workflow-fragment-names-handoff` (mechanical half), unchanged | Unchanged by this delta |
| 14 | A handoff is not left uncommitted on a branch the session leaves | **Uncovered.** This is session behavior, unchanged by this delta. | Verified by reading. |
| 15 | An opened-and-left branch does not become the session's working branch | Existing `workflow-fragment-no-proposal-only-branch` (mechanical half), unchanged | Unchanged by this delta |
| 16 | A deferral outlives the change that recorded it | **Uncovered.** This is prose about the reason the backlog sits outside a change, unchanged by this delta. | Verified by reading. |

Not traced to a scenario (derived, design/tasks only): `backlog-report-line-after-ignore-file`, `backlog-write-failure-errors`.

## Assertion classification

Specified: traces to a delta-spec statement or an existing requirement.

- `backlog-seeded-new-project`: the exit code, the file created with `docs/` created for it, the presence of each of the six listed statements, and that there is no entry (no `##` heading outside a fence).
- `backlog-seeded-adoption`: the exit code, and the file created in adoption mode.
- `backlog-existing-preserved`: the file is unchanged byte-for-byte.
- `backlog-dangling-symlink-not-written-through`: the link counts as present, nothing is written at its target, and the link is unchanged.
- `backlog-seeded-no-numbering`: no heading begins with a digit.
- `repeated-execution-backlog`: the second run succeeds, the backlog is unchanged, and the backlog is reported as already satisfied.
- `partial-init-reports-backlog`: the backlog concern is completed and reported on its own line.
- `workflow-fragment-backlog-no-entry-numbers`, `workflow-fragment-backlog-not-created-by-fragment`, `workflow-fragment-backlog-rules-not-restated`: the prohibition each one enforces ("SHALL NOT mention entry numbers", "SHALL NOT direct creating", "SHALL NOT restate").
- `backlog-write-failure-errors`: the project's own `docs` file is unchanged. This is the existing never-overwrite requirement.

Derived: inferred by this pass. No delta-spec statement fixes these.

- **Exact report tokens.** `backlog: created` and `backlog: already present` come from design.md's "Report line". The spec says only that the report "states" the outcome. These tokens are used in every runtime case.
- **Statement phrases** in `backlog-seeded-new-project`: "not yet archived", "instead of being folded into the change that found it", "kebab-case", "the name its branch and change directory will take", "only by that name", "carries no meaning", "when its change is archived", "as a fix rather than a change", "will not be made", "when it has no entries", "has not seen the work that found it", "Recorded by", "Depends on". All are taken from design.md's seeded text. The spec deliberately leaves the wording editable. A rewording that keeps a statement but drops its phrase fails this case, and that failure is a derived constraint to revisit, not a spec violation.
- `backlog-seeded-adoption`: the adoption-mode file is byte-identical to a new-project run's file.
- `backlog-seeded-no-numbering`: the word `number` in any form appears nowhere in the seeded file. This is a stricter stand-in for "no sentence refers to an entry's number".
- `workflow-fragment-backlog-no-entry-numbers`: the prohibition is applied only to lines mentioning `backlog|entry|entries`. A paragraph mentioning entry numbers without one of those words is not reached.
- `workflow-fragment-backlog-not-created-by-fragment`: the creation direction is recognised by a regex covering absence conditions and creation verbs on lines mentioning `backlog`. Other wordings are not reached.
- `workflow-fragment-backlog-rules-not-restated`: a restatement is recognised by the phrases `kebab-case`, `carries no meaning`, `Recorded by:`, `Depends on:` and `has no entries`. A paraphrase is not reached.
- `backlog-report-line-after-ignore-file`: the `backlog:` line directly follows the `ignore file:` line. This comes from design.md.
- `backlog-write-failure-errors`: when `docs` is a regular file, the run ends with exit 1, `Outcome: ERROR`, and a `Reason:` that names the backlog. This comes from tasks.md 1.2.

Deliberately untested, with reasons:

- That the fragment *states* the backlog file carries the entry rules (scenario 12, positive half). The requirement fixes no wording for it, so it is verified by reading.
- The deletion and keep-when-empty statements as *behavior* (deleting entries, keeping the file). These are session conduct and cannot be observed by a test.
- `--help` mentioning the backlog (tasks 1.3). It is conditional ("if the wording needs it") and no spec states it.
- The fragment `version` going from 4 to 5 (tasks 2.3). The fragment-version requirement is not in this change's deltas. The existing `managed-block-current-version` and `inlined-body-matches-fragment` cases read the version through `fragment_version` and will follow it.
- Whether a BLOCKED run creates `docs/` or `docs/backlog.md`. No delta scenario states it. The existing BLOCKED cases assert other paths are absent but not `docs/`. The implementer may want to extend them; that is outside this pass's additive scope for existing files.

### Static-read discriminators

The three `workflow-fragment-backlog-*` cases read `rules/development-workflow.md` without executing anything. Each one runs its check function over a violating fixture and a conforming fixture written to `$TESTDIR`, and fails if the check does not tell them apart. All six fixture runs passed in this pass, so the check functions do discriminate.

Two of the three were also red on the real fragment at authoring:

- `no-entry-numbers` is red on fragment line "entry's number is an identifier … never by number".
- `not-created-by-fragment` is red on "creating that file if absent".

Each should go green as tasks 2.1 and 2.2 land. `rules-not-restated` was green at authoring, so its discrimination rests on its fixtures alone.

## Obsolete tests

All entries are **candidates for human confirmation**, not conclusions. They were searched for within `tests/cases/**` only, by grepping for `backlog`, `by number`, `not stable`, `if absent` and `creat…absent`, then reading the matching cases. No earlier `test-plan.md` was supplied.

- **`workflow-fragment-fixed-paths`**, its assertion `assert_contains "$fragment" "cite an entry by name, never by number"`.
  - Superseded by: session-workflow MODIFIED "A second change surfacing in a session is recorded in the backlog". The requirement drops the clause that obliged the fragment to state the entry-number rule, and adds "The fragment SHALL NOT mention entry numbers".
  - Evidence: the assertion matches the superseded clause verbatim, and its message reads "cited by its stable name, not its unstable number".
  - Once task 2.2 lands, this assertion fails, and it directly contradicts `workflow-fragment-backlog-no-entry-numbers`.
  - Its header comment also names "The backlog does not yet exist" and "the create-it-if-absent direction". Both now describe superseded behavior: the revised scenario says the fragment does *not* direct creating it.
  - Its `.worktrees/` and `docs/backlog.md` assertions are **not** superseded.
  - tasks.md 3.2 already plans this edit. It was not made here, because this pass never edits existing tests.

Searched and judged **not** obsolete:

- `repeated-execution-idempotent` and `existing-git-no-openspec` are still correct under the revised concern list. They are incomplete rather than superseded, and the new cases add the backlog half.
- `workflow-fragment-names-handoff` and `workflow-fragment-no-proposal-only-branch` assert only the presence of `docs/backlog.md`, which still holds.
- The comments in `initial-branch-corrupted-head-not-rewritten` and `initial-branch-missing-head-not-rewritten` mention `docs/backlog.md` only as a cross-reference.

## Unresolved project questions

1. **Stack skill.** `bash` was loaded and the cases follow its practice. They are shellcheck-clean, with SC1090 disabled narrowly with a reason, as in the existing cases. No question is open here.
2. **`tests/lib.sh` helper signatures.** `lib.sh` sits outside the test-path glob and was not read. The helpers were used as `tests/README.md` and the existing cases show them: `assert_exit expected actual [msg]`, `assert_file path [msg]`, `assert_file_absent path [msg]`, `assert_unchanged path md5 [msg]`, `assert_contains file needle [msg]`. Every new case depends on this. It was observed working: the helpers produced the expected failure messages in the post-pass run.
3. **Per-case selection.** `tests/run.sh` runs every case and has no documented single-case selector. Assumption: the case file stem is the runner-selectable identifier, read from `run.sh`'s per-case `ok`/`FAIL` line. All cases depend on this.
4. **Where test classifications are recorded.** The project records them in case header comments and `tests/coverage.md`. This pass recorded them in header comments and here. `tests/coverage.md` is outside the glob, so tasks.md 3.3 must account for these cases there.

## What implementation must make pass

All eleven failing cases:

- `backlog-seeded-new-project`
- `backlog-seeded-adoption`
- `backlog-existing-preserved`
- `backlog-dangling-symlink-not-written-through`
- `backlog-seeded-no-numbering`
- `repeated-execution-backlog`
- `partial-init-reports-backlog`
- `backlog-report-line-after-ignore-file`
- `backlog-write-failure-errors`
- `workflow-fragment-backlog-no-entry-numbers`
- `workflow-fragment-backlog-not-created-by-fragment`

`workflow-fragment-backlog-rules-not-restated` must also stay green, along with every case that was in the baseline. The exception is `workflow-fragment-fixed-paths`'s number assertion, listed above as an obsolete candidate.
