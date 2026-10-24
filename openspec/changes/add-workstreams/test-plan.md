# Test plan: add-workstreams

Derived by `ai-toolkit:change-test-writer` from the delta specs as committed at `48bdfe7` (branch `add-workstreams`). This file is not an artifact the OpenSpec schema defines, so `openspec instructions apply` does not list it: read it on purpose before implementing.

Every case is a file under `tests/cases/`. Run the whole suite with `bash tests/run.sh`. To run one case, give it the environment `run.sh` exports:

```
TOOLKIT_ROOT="$PWD" TESTLIB="$PWD/tests/lib.sh" PROJECT_INIT="$PWD/scripts/project-init" TESTDIR="$(mktemp -d)" bash tests/cases/<case>.sh
```

## Baseline

**Full baseline** at `48bdfe7`, before any case was written: `bash tests/run.sh` reported `154 passed, 0 failed` (exit 0).

**After this pass:** `185` cases, `155 passed, 30 failed`. The 154 existing cases still pass. One new case, `workflow-fragment-backlog-routing-names-no-workstream`, passes already (see its entry below). The other 30 new cases fail. Each failure was read and is one of two kinds:

- **Target absent (state 2).** The file or paragraph the case reads does not exist yet: `docs/workstreams/README.md` is not seeded, the fragment has no draft or archive workstream paragraph, and SKILL.md has no `workstreams` section. The assertions have not been exercised yet.
- **Red on the property (static reads).** The file exists but does not yet carry the property: the backlog shape has no `**Workstream**` line, and the skill and fragment cases' `scan`/`line_scan` report the missing property by its `[tag]`. Each of these discriminators ran over its own conforming fixture and one mutant per scan, and passed in every case. The failures are therefore on the real target, not in the check.

`shellcheck` 0.9.0 is clean on all 31 new files.

## What `apply` must make pass, by task

| Task | Cases that must go from failing to passing |
|---|---|
| 1.1 backlog Workstream line | `backlog-seeded-workstream-field`, `backlog-seeded-workstream-default` |
| 1.2 seed `docs/workstreams/README.md` | `workstreams-seeded-new-project`, `workstreams-seeded-adoption`, `workstreams-existing-preserved`, `workstreams-dangling-symlink-not-written-through`, `repeated-execution-workstreams`, `partial-init-reports-workstreams`, `workstreams-report-line-after-backlog`, `workstreams-write-failure-errors`, `workstreams-seeded-statements`, `workstreams-seeded-no-status-field`, `workstreams-seeded-precedence`, `workstreams-seeded-order-gates-nothing`, `workstreams-seeded-archive-on-done`, `workstreams-seeded-abandoned` |
| 2.1 fragment v11 | `workflow-fragment-status-row-workstream-first`, `workflow-fragment-status-row-workstream-source`, `workflow-fragment-draft-names-workstream`, `workflow-fragment-archive-workstream-reread`, `workflow-fragment-workstream-rules-not-restated`; must stay green: `workflow-fragment-backlog-routing-names-no-workstream` and every existing `workflow-fragment-*` case |
| 3.1 skill fields, record/pick/close/sweep | `backlog-skill-absent-workstream-register`, `backlog-skill-workstream-rules-not-restated`, `backlog-skill-record-workstream`, `backlog-skill-pick-workstream`, `backlog-skill-close-workstream`, `backlog-skill-sweep-workstream` |
| 3.2 workstreams operation, description | `backlog-skill-workstreams-operation`, `backlog-skill-identity-workstreams` |
| 3.3 audit brief | `backlog-skill-audit-workstream` |
| 5.1 | all of the above, plus all 154 existing cases |

## Scenario accounting

The deltas hold 75 scenarios: `project-bootstrap` 19, `session-workflow` 13, `backlog-maintenance` 43. Each is accounted for exactly once below. "In part" means the case reads the text the scenario depends on, not the conduct of a session running it. A scenario carried over verbatim keeps its existing case.

### project-bootstrap (19)

| # | Scenario | Accounting |
|---|---|---|
| 1 | Repeated execution is not destructive | Covered: `repeated-execution-workstreams` (new), `repeated-execution-idempotent`, `repeated-execution-backlog` |
| 2 | A partially initialized directory is completed, not refused | Covered: `partial-init-reports-workstreams` (new), `existing-git-no-openspec`, `partial-init-reports-backlog` |
| 3 | Existing specification tooling is skipped, not reinitialized | Covered (carried over verbatim): `existing-git-and-openspec` |
| 4 | A project without a backlog receives the seeded file | Covered: `backlog-seeded-new-project`, `backlog-seeded-adoption`, `backlog-seeded-structured-statements`, `backlog-seeded-priority-statements`; the new workstream statement by `backlog-seeded-workstream-default` (new) |
| 5 | An existing backlog is preserved exactly | Covered (verbatim): `backlog-existing-preserved`, `backlog-dangling-symlink-not-written-through` |
| 6 | The seeded file carries no numbering | Covered (verbatim): `backlog-seeded-no-entry-numbering` |
| 7 | The seeded entry shape carries the structured fields | Covered: `backlog-seeded-workstream-field` (new), `backlog-seeded-structured-fields`, `backlog-seeded-priority-field` |
| 8 | A fix is distinguished from a change by what it owes | Covered (verbatim): `backlog-seeded-kind-definition` |
| 9 | Priority's values and default are stated | Covered (verbatim): `backlog-seeded-priority-values` |
| 10 | The seeded file offers no low priority | Covered (verbatim): `backlog-seeded-priority-no-low` |
| 11 | The seeded file states how an entry leaves parked and high | Covered (verbatim): `backlog-seeded-priority-transitions` |
| 12 | Workstream's default is stated | Covered: `backlog-seeded-workstream-default` |
| 13 | A project without a workstream register receives the seeded file | Covered: `workstreams-seeded-new-project`, `workstreams-seeded-adoption`, `workstreams-seeded-statements` |
| 14 | An existing workstream register is preserved exactly | Covered: `workstreams-existing-preserved`, `workstreams-dangling-symlink-not-written-through` |
| 15 | The seeded register carries no status field | Covered: `workstreams-seeded-no-status-field` |
| 16 | An abandoned workstream is archived, not deleted | Covered in part (the text read): `workstreams-seeded-abandoned` |
| 17 | A finished workstream is archived | Covered in part (the text read): `workstreams-seeded-archive-on-done` |
| 18 | A step matching two sources takes the first status | Covered in part (the stated precedence): `workstreams-seeded-precedence` |
| 19 | Step order is not a dependency | Covered in part (the text read): `workstreams-seeded-order-gates-nothing` |

### session-workflow (13)

| # | Scenario | Accounting |
|---|---|---|
| 20 | A session resumes a working tree left by another session | Uncovered. Carried over verbatim; it describes a session's conduct, which no program here runs. Its accounting in `tests/coverage.md` (session-workflow section) is unchanged |
| 21 | The report is a row, not a paragraph | Covered in part: `workflow-fragment-status-row-workstream-first` (the revised fixed order). A session printing a row is conduct |
| 22 | A session reports on the way out as well as the way in | Uncovered. Carried over verbatim; session conduct; accounting unchanged |
| 23 | An unprovisioned working tree's green is not reported as a result | Uncovered. Carried over verbatim; session conduct; accounting unchanged |
| 24 | The report is derived rather than recalled | Uncovered. Carried over verbatim; session conduct; accounting unchanged |
| 25 | The row names the workstream first | Covered in part: `workflow-fragment-status-row-workstream-first`, `workflow-fragment-status-row-workstream-source` |
| 26 | A change with no proposal takes its workstream from the plan | Covered in part (the source order puts the steps first): `workflow-fragment-status-row-workstream-source` |
| 27 | A proposal in a workstream names it | Covered in part: `workflow-fragment-draft-names-workstream` |
| 28 | A proposal in no workstream says so | Covered in part: `workflow-fragment-draft-names-workstream` |
| 29 | A workstream is proposed, not opened | Covered in part: `workflow-fragment-draft-names-workstream` (the proposal direction). The "not without the operator" half is deliberately untested, see below |
| 30 | Derived work is attached by the backlog's rule, not the fragment's | Covered in part: `workflow-fragment-backlog-routing-names-no-workstream` (the fragment's half), `backlog-seeded-workstream-default` (the file's half) |
| 31 | Archiving the last step archives the workstream | Covered in part: `workflow-fragment-archive-workstream-reread` |
| 32 | The fragment defers the workstream rules to the README | Covered in part: `workflow-fragment-workstream-rules-not-restated` |

### backlog-maintenance (43)

| # | Scenario | Accounting |
|---|---|---|
| 33 | A project's preamble differs from the seeded one | Covered in part (verbatim): `backlog-skill-restates-no-entry-rule` |
| 34 | The skill does not mandate an audit cadence | Covered (verbatim): `backlog-skill-no-audit-cadence` |
| 35 | A project's workstream README differs from the seeded one | Covered in part: `backlog-skill-workstream-rules-not-restated` |
| 36 | Invoked from a consuming project | Covered in part: `backlog-skill-identity`, `backlog-skill-identity-workstreams` (new: six operations) |
| 37 | No backlog exists | Covered in part (verbatim): `backlog-skill-absent-backlog` |
| 38 | No workstream register exists | Covered in part: `backlog-skill-absent-workstream-register` |
| 39 | A name already used by an archived change | Covered in part (verbatim): `backlog-skill-record` |
| 40 | An overlapping entry exists | Covered in part (verbatim): `backlog-skill-record` |
| 41 | Work the change can fold in | Covered in part (verbatim): `backlog-skill-record-fold-in` |
| 42 | Record defaults Priority | Covered in part (verbatim): `backlog-skill-record-priority` |
| 43 | Record parks an entry only on the operator's word | Covered in part (verbatim): `backlog-skill-record-priority` |
| 44 | Record carries the change's workstream | Covered in part: `backlog-skill-record-workstream` |
| 45 | Record refuses a workstream that is not open | Covered in part: `backlog-skill-record-workstream` |
| 46 | A blocked entry is not offered | Covered in part (verbatim): `backlog-skill-pick` |
| 47 | A wait already satisfied but not updated | Covered in part (verbatim): `backlog-skill-pick` |
| 48 | Pick narrowed to files | Covered in part (verbatim): `backlog-skill-pick` |
| 49 | A parked entry is not offered as takeable | Covered in part (verbatim): `backlog-skill-pick-priority` |
| 50 | A parked entry whose condition holds | Covered in part (verbatim): `backlog-skill-pick-priority` |
| 51 | A parked entry still waiting | Covered in part (verbatim): `backlog-skill-pick-priority` |
| 52 | High entries come first | Covered in part (verbatim): `backlog-skill-pick-priority` |
| 53 | Pick lists a workstream's entries in step order | Covered in part: `backlog-skill-pick-workstream` |
| 54 | A high step leads its workstream's group | Covered in part: `backlog-skill-pick-workstream` |
| 55 | An unplaced entry is shown under its workstream | Covered in part: `backlog-skill-pick-workstream` |
| 56 | A closed entry was another's only wait | Covered in part (verbatim): `backlog-skill-close` |
| 57 | A closed entry was a workstream's step | Covered in part: `backlog-skill-close-workstream` |
| 58 | An entry finished without being named | Covered in part (verbatim): `backlog-skill-sweep` |
| 59 | Sweep after a squash merge | Covered in part (verbatim): `backlog-skill-sweep` |
| 60 | Sweep after the record has landed | Covered in part (verbatim): `backlog-skill-sweep` |
| 61 | A change fulfils a parked entry's condition | Covered in part (verbatim): `backlog-skill-sweep-priority` |
| 62 | A change removes a high entry's evidence | Covered in part (verbatim): `backlog-skill-sweep-priority` |
| 63 | Entries naming a workstream being archived | Covered in part: `backlog-skill-sweep-workstream` |
| 64 | An entry done by an unmentioning change | Covered in part (verbatim): `backlog-skill-audit` |
| 65 | The report is not applied unasked | Covered in part (verbatim): `backlog-skill-audit` |
| 66 | Two entries recorded for one change | Covered in part (verbatim): `backlog-skill-audit` |
| 67 | A parked entry whose condition has fired | Covered in part (verbatim): `backlog-skill-audit-priority` |
| 68 | An entry names an archived workstream | Covered in part: `backlog-skill-audit-workstream` |
| 69 | A step's status comes from the repository | Covered in part: `backlog-skill-workstreams-operation` |
| 70 | A step in two sources | Covered in part: `backlog-skill-workstreams-operation` |
| 71 | The next step is named | Covered in part: `backlog-skill-workstreams-operation` |
| 72 | A waiting step is not next | Covered in part: `backlog-skill-workstreams-operation` |
| 73 | Every step done | Covered in part: `backlog-skill-workstreams-operation` |
| 74 | Unplaced entries are shown | Covered in part: `backlog-skill-workstreams-operation` |
| 75 | A change opened under another name is surfaced | Covered in part: `backlog-skill-workstreams-operation` |

Count: 75 in the deltas, 75 accounted for (71 covered, fully or in part, and 4 uncovered).

## Assertion classification

Each case header also states its classification. In summary:

**Specified** (traces to a scenario or requirement):

- The register's existence in both modes, and `docs/workstreams/` created with it; no `archive/`; no workstream in the file; byte-for-byte preservation; a dangling link counted as present and not written through; second run unchanged; separate report per concern.
- The seven shape fields and no status field; the listed README statements; first-match precedence in the order done, in flight, recorded, planned; order gates nothing, with the reader sent to Waits on; archive on Done when, and abandonment.
- The backlog shape names Workstream with its default and `nothing`.
- The row's first cell is the workstream, and its source order is steps, proposal, backlog entry, `none`.
- At draft, the proposal names its workstream or says it advances none, and proposes opening one. At archive, the workstream is re-read.
- The fragment defers to `docs/workstreams/README.md`, names `docs/workstreams/`, restates no field, shape or archive path, names no entry field, does not direct creating the README, and says nothing about an entry's workstream where it routes work.
- What each skill operation states, as listed under its requirement.

**Derived** (inferred; no stated requirement fixes it, so open to review):

- **Report tokens.** `workstreams: created` and `workstreams: already present` come from design.md decision 12. The line directly following `backlog:` (`workstreams-report-line-after-backlog`) comes from concern order, Q1.
- **Write failure.** `workstreams-write-failure-errors` (ERROR, exit 1, a Reason naming the workstream) comes from tasks.md 1.2 and the existing three-outcomes requirement.
- **Seeded wording.** Every phrase `workstreams-seeded-*` and `backlog-seeded-workstream-*` match is design.md decision 8 or 9's text. A rewording that keeps the statement fails.
- **Placement in the seeded files.** The shape and fields are in the fenced example. Precedence, order, archive and abandonment are each one paragraph. Workstream sits between Design with and Recorded by.
- **"No status field"** is operationalised as no fenced line carrying `status`, `progress`, `in flight`, a checkbox, or `done:`.
- **"No workstream"** is operationalised as exactly one heading outside fences, and README.md alone in the directory.
- **Fragment template and example.** The literal template `| <workstream> | <change> | <stage> |` and example `| none | some-change | plan:explore |`, and the absence of the v10 template and example, come from design.md decision 13.
- **Fragment operationalisation.** Selectors, regexes and same-paragraph placement come from decision 10's text. Paragraphs are located by content, not by step (Q4).
- **Skill structure.** The skill cases assume a section per operation, including one headed `workstreams` (Q3). The audit statements are in `references/audit.md` (decision 11, tasks 3.3). Each regex operationalises one spec clause.
- **Description wording.** The description phrasing (`stand` or `in flight`, from decision 11) and SKILL.md not saying "five operations".
- **README phrases forbidden in the skill.** `backlog-skill-workstream-rules-not-restated`'s phrase list comes from decision 8.

**Deliberately untested** (each with its reason):

- **"SHALL NOT direct opening one without the operator"** (#29). A forbid scan would fail a compliant sentence that says not to. Verified by reading.
- **"creates nothing", "SHALL NOT create the file"** in the skill (#38). Same reason.
- **Whether the draft and archive paragraphs sit inside the draft and archive steps.** The fragment's step layout is not a fixed structure a scan can anchor on without reading the implementation. Verified by reading.
- **The entering report's verification cell.** The spec requires it, but design.md decision 13 deliberately keeps the v10 row without it and records `reconcile-the-status-row-verification-cell` in the backlog. Asserting it would fail the planned implementation by design.
- **Where the archived-or-absent entry sits in the audit report** ("under stale facts"). The brief's report structure is not fixed by the spec.
- **Every operation's conduct.** Statuses actually derived from a repository, ordering actually produced, entries actually found. No program here runs a skill. The cold-run and trigger checks (tasks.md 3.2) are where that is established.

## Discriminator record

- **Static reads of `rules/development-workflow.md`, `skills/backlog/SKILL.md` and `skills/backlog/references/audit.md`.** Each scan was run over a fixture the case writes, and over one mutant per scan, and the mutant was rejected by that scan's own tag. That was observed in this pass for every new static case. All are red at authoring on the property they name, except `workflow-fragment-backlog-routing-names-no-workstream`.
- **`workflow-fragment-backlog-routing-names-no-workstream` passes on its first run.** The pre-change fragment names no workstream at all, so the pass establishes nothing by itself. Its conforming and violating fixtures are what establish that it can fail, and both behaved as expected.
- **`old-row-template` forbid scan.** In `workflow-fragment-status-row-workstream-first`, this scan is red at authoring on the v10 row `| <change> | <stage> | <task progress> | <commits> |`, which the fragment still carries.
- **`no-five` forbid scan.** In `backlog-skill-identity-workstreams`, this scan is red at authoring on the current description's "five operations".
- **Seeded-file cases.** These run `scripts/project-init` and read what it writes, following this suite's convention for such cases ("Executes the tool; no fixture owed"). All are red at authoring (state 2, or the field absent).

## Obsolete tests

**No superseded test was found by this search. These candidates are for human confirmation.** The search covered `tests/cases/**` only, using:

- the v10 row tokens (`<change>`, `<stage>`, `<task progress>`, `some-change`, `plan:explore`, `status row`);
- the skill description's operation count (`five`);
- the report lines and concern list (`backlog:`, `already present`, `docs/`);
- and each existing case named for the modified requirements (`backlog-seeded-*`, `backlog-skill-*`, `repeated-execution-*`, `partial-init-*`, `workflow-fragment-*`).

No earlier `test-plan.md` was supplied. What each MODIFIED delta supersedes, compared with `openspec/specs/` (it supersedes nothing an existing case asserts):

- **Each concern is checked independently** (project-bootstrap) adds a concern. `repeated-execution-idempotent`, `repeated-execution-backlog`, `existing-git-no-openspec` and `partial-init-reports-backlog` assert concerns that still exist. `backlog-report-line-after-ignore-file` asserts backlog directly after the ignore file, which concern order keeps. It would break only if the workstreams line were printed between them, contrary to Q1's assumption.
- **A backlog is seeded where none exists** (project-bootstrap) adds a field and a statement. `backlog-seeded-structured-fields` asserts fields that remain and does not assert that the field list is closed.
- **A session reports where its change stands** (session-workflow) prepends a cell. No case in `tests/cases/` asserts the v10 row. The 5 carried-over scenarios are uncovered, as before.
- **The skill operates on the project it is invoked in** changes "five operations" to "six". `backlog-skill-identity` asserts the five operation names, not the count, so it still holds. Only its header comment says "five operations", which is a comment, not an assertion.
- **Restates neither, record, pick, close, sweep, audit** (backlog-maintenance) are additive. Every existing `backlog-skill-*` scan reads a clause the delta keeps verbatim.
- `inlined-body-matches-fragment`, `managed-block-current-version` and `managed-block-older-version` read the version through `fragment_version`, so the bump to 11 does not supersede them.

No REMOVED or RENAMED delta exists.

## Unresolved project questions

- **Q1. The `workstreams:` report line is absent from `tests/README.md`'s report contract.** That contract says it is normative and that "the script and this suite must agree on them", but tasks.md has no task updating it. **Assumption:** the line is `workstreams: created | already present`, printed directly after `backlog:`, following the concern order of the revised requirement. **Depends on it:** `workstreams-report-line-after-backlog`. The tokens are used by `workstreams-seeded-new-project`, `workstreams-seeded-adoption`, `workstreams-existing-preserved`, `workstreams-dangling-symlink-not-written-through`, `repeated-execution-workstreams` and `partial-init-reports-workstreams`. This is a planning gap for the dispatcher: `openspec-update-change` should add the contract line to tasks, or `apply` should take it as a fold-in.
- **Q2. A failed write ends ERROR naming the workstream register.** No scenario states the failure mode; tasks.md 1.2 names "its error path". **Assumption:** this mirrors `backlog-write-failure-errors`: ERROR, exit 1, and a `Reason:` line containing "workstream". **Depends on it:** `workstreams-write-failure-errors`.
- **Q3. SKILL.md has one section per operation, the new one under a heading naming `workstreams`.** This extends the structural assumption earlier skill cases already make (add-backlog-skill's Q1). The skill's audit statements are in `references/audit.md`. **Depends on it:** `backlog-skill-workstreams-operation`, `backlog-skill-record-workstream`, `backlog-skill-pick-workstream`, `backlog-skill-close-workstream`, `backlog-skill-sweep-workstream` and `backlog-skill-audit-workstream`. Note that a heading like "Reading the workstreams" placed above the operation would be taken as its section.
- **Q4. Each fragment insertion is one paragraph, located by its content.** The draft paragraph carries `docs/workstreams/` and `proposal`. The archive paragraph carries `docs/workstreams/README.md` and `advanced`. The source-order sentence carries workstream, proposal, backlog and none. **Depends on it:** `workflow-fragment-draft-names-workstream`, `workflow-fragment-archive-workstream-reread` and `workflow-fragment-status-row-workstream-source`.
- **Q5. A tension between tasks.md 3.2 and the spec.** Tasks.md 3.2 asks the workstreams operation to carry "decision 3's precedence and sources". The spec says the skill takes them from the README and restates no workstream rule, though its own text quotes the seeded precedence. **Assumption:** naming the statuses and sources is allowed; reproducing the README's sentences is not. **Depends on it:** `backlog-skill-workstream-rules-not-restated` forbids only the README's distinctive phrases.
- **No stack-specific question.** The library's `bash` skill was loaded alongside `testing`.

## Missing shared arrangement

The dispatch names `tests/lib.sh` and `tests/cases/lib/` (`static-scan.sh`, `line-scan.sh`) as the shared arrangement, and `tests/README.md` names `tests/lib.sh`, so no question is raised about its location. These local declarations were made because it lacks them:

1. **`check` and `expect` in `tests/cases/workflow-fragment-status-row-workstream-source.sh`.**
   - *Stands in for:* a fixture-driven check harness with three expected outcomes: pass, a tagged failure (status 1), and absent (status 2).
   - *Used by:* `tests/cases/workflow-fragment-status-row-workstream-source.sh`.
   - *Near-miss:* `tests/cases/lib/line-scan.sh`. Its scans are per-pattern; it cannot express an ordered conjunction (steps, then proposal, then backlog, then none). Its rule that a require regex must not overlap a selector also rules out selecting by the same words the order is read from.
   - *Found in test module:* the same `check` and `expect` pattern appears in `tests/cases/workflow-fragment-archive-reread-names-no-field.sh`.
   - *Proposed home:* a small `fixture_expect` helper in `tests/cases/lib/`.
2. **`check` and `expect` in `tests/cases/workflow-fragment-backlog-routing-names-no-workstream.sh`.**
   - *Stands in for:* the same harness, with an exclusion selector (lines naming `docs/backlog.md` and `record` but not `re-read`).
   - *Used by:* `tests/cases/workflow-fragment-backlog-routing-names-no-workstream.sh`.
   - *Near-miss:* `tests/cases/lib/line-scan.sh` and `static-scan.sh`. Their selectors are positive only, so they cannot exclude the archive re-read paragraph.
   - *Found in test module:* `tests/cases/workflow-fragment-archive-reread-names-no-field.sh` (same pattern).
   - *Proposed home:* as entry 1, with negative selectors added to `line-scan.sh` as an alternative.
3. **`fenced_line` in `tests/cases/backlog-seeded-workstream-field.sh`.**
   - *Stands in for:* "line number of the fenced `**<label>**` line in a markdown file".
   - *Used by:* `tests/cases/backlog-seeded-workstream-field.sh`.
   - *Near-miss:* none in the shared arrangement.
   - *Found in test module:* an identical `fenced_line` in `tests/cases/backlog-seeded-priority-field.sh`.
   - *Proposed home:* `tests/lib.sh`.

Not declared as functions but repeated inline, and worth the same promotion decision: the awk fence extractor `'/^[[:space:]]*(```|~~~)/ { infence = !infence; next } infence { print }'`. It is used in `workstreams-seeded-no-status-field`, `backlog-seeded-workstream-default` and `workstreams-seeded-new-project` (the out-of-fence variant). It appears the same way in `backlog-seeded-structured-fields`, `backlog-seeded-new-project` and `backlog-seeded-priority-statements`.

## Findings from the artifacts

- No artifact carries an instruction addressed to the test author.
- **Report contract gap (Q1).** `tests/README.md`'s report contract is not in tasks.md, though decision 12 adds a report line.
- **Accepted row drift.** The spec's row requirement still asks for an entering-only verification cell. Design.md decision 13 acknowledges the v10 row does not carry it and defers it to `reconcile-the-status-row-verification-cell`. No case asserts that cell.
