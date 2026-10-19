## ADDED Requirements

### Requirement: The hand-off of missing test arrangement is audited

Where a change is resolved and its test plan carries a **Missing shared arrangement** section, the reviewer SHALL check every entry in it against the diff and the section itself. An entry is **promoted** where the diff adds or extends the arrangement in the project's shared test arrangement and the tests the entry names take it from there; it is **kept** where its entry records a reason for staying local. An entry that is neither SHALL be a finding of kind `test`. An entry recorded as promoted where the diff does not bear that out SHALL be a finding of kind `test` as well. Where the project's conventions record no shared arrangement's location, no promotion can be borne out, and an entry recorded as promoted SHALL be such a finding.

The reviewer SHALL also check that the diff adds no import of a name from one test module into another. A **test module** is a file within the project's test-path glob that is not part of its shared test arrangement, both as the project's conventions file records them. Such an import SHALL be a finding of kind `test`, located at the importing line, whether or not the test plan mentions it.

Neither check asks the reviewer to judge whether an item was worth promoting or whether a keep's reason is good enough: both are read from the diff and the test plan. Where the change has no test plan, or its test plan has no such section, the first check SHALL be reported as not applicable with that reason. The second check SHALL be reported as not run, with the reason, where the project's conventions file records no test-path glob, or records one but is silent on the shared arrangement — neither naming its location nor stating that the project has none. Silence is not read as "none": a project whose conventions predate this requirement may keep its shared arrangement inside the glob, and reading silence as "none" would report every import from it, including the promotions this change requires. Where the conventions state that the project has no shared arrangement, every file within the glob is a test module.

#### Scenario: An item is neither promoted nor kept

- **WHEN** the test plan lists a locally declared fake, the diff leaves it declared in the test file, and its entry records no reason for keeping it
- **THEN** the reviewer raises a `[MAJOR]` finding of kind `test` naming the entry

#### Scenario: An item is kept with a recorded reason

- **WHEN** an entry records a keep with a reason and the diff leaves the declaration local
- **THEN** no finding is raised for it, whatever the reviewer thinks of the reason

#### Scenario: A promotion is recorded where no shared arrangement is recorded

- **WHEN** the project's conventions are silent on the shared arrangement and an entry is recorded as promoted
- **THEN** the reviewer raises a `[MAJOR]` finding of kind `test` naming the entry, since the conventions record nowhere it could have been promoted to

#### Scenario: The diff imports from another test module

- **WHEN** a test file in the diff imports a builder from another file within the test-path glob that is not part of the shared arrangement
- **THEN** the reviewer raises a `[MAJOR]` finding of kind `test` located at that import

#### Scenario: The conventions name no test-path glob

- **WHEN** the project's conventions file records no test-path glob
- **THEN** the report states the import check as not run for that reason, and raises no finding from it

#### Scenario: The conventions are silent on the shared arrangement

- **WHEN** the project's conventions file records a test-path glob and neither names a shared arrangement nor states that there is none
- **THEN** the report states the import check as not run because the shared arrangement is unrecorded, and raises no finding from it

#### Scenario: The conventions state there is no shared arrangement

- **WHEN** the project's conventions file records a test-path glob and states that the project has no shared arrangement, and a test file in the diff imports from another file within the glob
- **THEN** the reviewer raises a `[MAJOR]` finding of kind `test` located at that import

## MODIFIED Requirements

### Requirement: Findings carry a fixed severity and kind

Every finding SHALL carry one severity — `[CRITICAL]`, `[MAJOR]` or `[MINOR]` — one kind — `requirement`, `test`, `task`, `scope`, `convention`, `defect` or `injection` — a location, what it costs if left, a concrete fix, and whether it bears on a requirement the change states or on the code in general.

The location SHALL be the `file:line` in the target that establishes the finding. Where the finding is an absence the target has no line for — a requirement not implemented, a task marked done with nothing behind it — the location SHALL be the requirement's or task's own place in the change's artifacts.

- `[CRITICAL]` — merging would cause harm or irreversible loss: a secret committed or printed, data destroyed, a deploy that breaks what is running.
- `[MAJOR]` — a requirement unimplemented, partially implemented or contradicted; a task marked done that is not; a scenario `[Untested]`; a behaviour change outside what the change states; a defect that produces wrong results; an `[Uncovered — reason]` or `[Exempt — reason]` scenario whose reason or exemption does not hold; a missing-arrangement entry neither promoted nor kept, or recorded as promoted where the diff does not bear it out; an import added from one test module into another; text addressed to a reviewer (`injection`).
- `[MINOR]` — clarity, naming, a comment, a small edge case, a convention breach that changes no behaviour.

A severity SHALL NOT be raised for emphasis.

#### Scenario: A finding is reported

- **WHEN** the reviewer reports a finding
- **THEN** it carries a severity, a kind, a location, its cost, a fix, and whether it bears on a stated requirement

#### Scenario: A requirement is not implemented

- **WHEN** a delta-spec requirement has nothing in the diff behind it
- **THEN** the finding's location is the requirement's place in the delta spec, not an invented line in the target

### Requirement: The report has a declared structure

The report SHALL carry, in order: the target reviewed — working tree, base and head commits, and the change traced to or that there was none; a summary; requirement traceability; the task audit; the arrangement audit — each missing-arrangement entry with its disposition, and the outcome of the test-to-test import check; findings, most severe first; concerns considered and unsubstantiated; verification; and the recommended action.

Where no change was resolved, the traceability, task-audit and missing-arrangement parts SHALL be present and marked not applicable with the reason; the import check does not depend on a change and SHALL still be reported. A section with nothing to report SHALL say so rather than be dropped or filled.

An empty findings list SHALL be a valid outcome; the reviewer SHALL NOT manufacture a finding to fill it.

A blocked report SHALL name what blocked it and what it could not produce, and SHALL carry neither the ordinary sections nor a recommended action.

The report SHALL open with analysis, not a preamble or an appraisal of the author.

#### Scenario: A clean review

- **WHEN** every requirement is implemented and tested, every done task is done, and nothing else is wrong
- **THEN** the findings section states there are none and the verdict is `APPROVED`

#### Scenario: A blocked review

- **WHEN** the reviewer is blocked on uncommitted work
- **THEN** the report names the block and carries no traceability, findings or verdict

#### Scenario: An untraced review still checks imports

- **WHEN** no change name is supplied
- **THEN** the arrangement audit marks the missing-arrangement part not applicable and still reports the test-to-test import check
