# Test plan: define-what-a-step-is

Written by `change-test-writer` before implementation. This file is not an artifact the OpenSpec schema knows about: it does not appear among `openspec instructions apply`'s context files and must be read on purpose.

Run any case with `bash tests/run.sh <case>` from the working tree root. Every case named below is a file `tests/cases/<case>.sh`.

## Inputs

- Delta: `specs/project-bootstrap/spec.md`, one MODIFIED requirement, *A workstream register is seeded where none exists*, 18 scenarios.
- Superseded behaviour established by comparing the delta with `openspec/specs/project-bootstrap/spec.md` (not by reading code): the status statement gains a fix's merged pull request as a source of done and a sentence on an unreachable forge; a new statement that a change is a step of one workstream only; "every step being archived" becomes "every step being done" in the Done when statement, the shape's Done when and the *Done when asks for an observable effect of the Goal* scenario; four scenarios added. The other 13 scenarios are textually unchanged.
- Convention files read: `AGENTS.md`, `tests/README.md`. Shared arrangement read: `tests/lib.sh`.
- `.openspec.yaml` carries no `skip_specs`; the change is not exempt.

## Baseline

Full suite, before any case was written: `bash tests/run.sh` — 357 passed, 0 failed. A scoped run of the 26 `workstreams-*` cases also passed (26 passed, 0 failed).

After writing: the six new cases each fail (0 passed, 6 failed), each in state 1 on the property it names (the tool runs and writes the 1.0.0 text), as recorded per case below. No existing case was touched.

## Scenarios (18 in the delta, 18 accounted for)

| # | Scenario | Covered by | Note |
|---|---|---|---|
| 1 | A project without a workstream register receives the seeded file | new: `workstreams-seeded-fix-step-done`, `workstreams-seeded-forge-unreachable`, `workstreams-seeded-one-workstream-per-change`, `workstreams-seeded-done-when-step-done-statement`, `workstreams-seeded-done-when-step-done-shape`; existing: `workstreams-seeded-statements`, `workstreams-seeded-new-project`, `workstreams-seeded-adoption`, `workstreams-block-new-project`, `workstreams-block-reserved-names`, `workstreams-seeded-edit-rule-what-it-holds`, `workstreams-seeded-abandoned-item` and the other `workstreams-seeded-*` cases asserting a listed statement | "every statement listed above" now includes the three revised/added statements; the new cases assert those |
| 2 | An existing workstream register is preserved exactly | existing: `workstreams-block-existing-preserved`, `workstreams-dangling-symlink-not-written-through` | unchanged by this delta; no new case |
| 3 | The seeded register carries no status field | existing: `workstreams-seeded-no-status-field`, `workstreams-seeded-shape-sections-no-status` | unchanged; no new case |
| 4 | An abandoned workstream is archived, not deleted | existing: `workstreams-seeded-abandoned` | unchanged; no new case |
| 5 | A finished workstream is archived | existing: `workstreams-seeded-archive-on-done` | unchanged; no new case |
| 6 | A step matching two sources takes the first status | existing: `workstreams-seeded-precedence` | unchanged; design decision 1 keeps the four statuses in order on one line, so this case is expected to stay green |
| 7 | Step order is not a dependency | existing: `workstreams-dir-order-names-waits-on` | unchanged; no new case |
| 8 | The seeded workstream's fields are a list | existing: `workstreams-seeded-fields-are-a-list`, `workstreams-seeded-fields-list-then-sections` | unchanged; no new case |
| 9 | A step is recorded by its entry file | existing: `workstreams-dir-step-recorded-by-entry-file` | unchanged; no new case |
| 10 | Done when asks for an observable effect of the Goal (revised) | new: `workstreams-seeded-done-when-step-done-statement`, `workstreams-seeded-done-when-step-done-shape`; existing for the unchanged clauses: `workstreams-seeded-done-when-statement`, `workstreams-seeded-done-when-shape` (each holds one obsolete assertion, below) | |
| 11 | Research shared by several steps has a place in the workstream | existing: `workstreams-seeded-shared-research-placed` | unchanged; no new case |
| 12 | A decision for one step stays in that step's design | existing: `workstreams-seeded-one-step-decision-in-design` | unchanged; no new case |
| 13 | What a workstream holds is not progress | existing: `workstreams-seeded-holds-not-progress` | unchanged; no new case |
| 14 | Overturned content is revised in place | existing: `workstreams-seeded-overturned-revised-in-place` | unchanged; no new case |
| 15 | A step taken as a fix reads as done | new: `workstreams-seeded-fix-step-done` | |
| 16 | A change whose work has merged is still in flight | new: `workstreams-seeded-merged-change-in-flight` | |
| 17 | A fix step without the forge | new: `workstreams-seeded-forge-unreachable` | |
| 18 | A change needed by two workstreams is listed in one | new: `workstreams-seeded-one-workstream-per-change` | |

No scenario is uncovered. None arrives through a REMOVED or RENAMED delta.

## Assertions and their classification

All six cases run `scripts/project-init` in an empty directory and read `docs/workstreams/AGENTS.md`. Following this suite's own classification of its seeded-text cases (e.g. `workstreams-seeded-done-when-shape`), they are treated as executing the tool (second situation). Each was red at authoring on the property named, in state 1; that red-to-green transition as task 1.1 lands is what establishes they discriminate on real content. Each local helper is checked inside its case against specimens it must accept and reject.

### `workstreams-seeded-fix-step-done`
- Specified: a merged pull request from a branch of the step's name is a source of done for a step whose name is no change on the trunk, open or archived (scenario 15; statement in scenario 1).
- Derived (wording, design decision 1): phrases "no change of that name, open or archived", "a pull request from a branch of that name has merged", "taken as a fix", on the precedence line found by "the first of these that holds wins".
- Derived (placement, design decision 1): the pull-request phrase stands after "done when" and before "in flight when" on that line.
- Red at authoring: precedence line lacks "no change of that name, open or archived".

### `workstreams-seeded-merged-change-in-flight`
- Specified: the pull request counts toward done only where the trunk holds no change of that name; an open change makes the step in flight (scenario 16).
- Derived (wording, design decision 1): "no change of that name, open or archived", "a pull request from a branch of that name has merged", "an open change of that name".
- Derived (placement): on the precedence line, the no-change condition precedes the pull-request phrase, both precede "in flight when", and "an open change of that name" follows "in flight when".
- Red at authoring: precedence line lacks the no-change condition.

### `workstreams-seeded-forge-unreachable`
- Specified: a session that cannot reach the forge says so rather than reading the step as planned (scenario 17; statement in scenario 1).
- Derived (wording, design decision 1): "forge cannot be reached", "say so", "rather than reading as planned".
- Derived (placement, design decision 1 "one sentence after the lookups"): on the precedence line, after "planned otherwise".
- Red at authoring: no "forge cannot be reached".

### `workstreams-seeded-one-workstream-per-change`
- Specified: a change is a step of one workstream only; the other workstream does not list it; its dependent step names the change in its entry's `waits_on`, an entry recorded where it has none (scenario 18; statement in scenario 1).
- Derived (placement): one prose line outside fenced code found by "A change is a step of one workstream only".
- Derived (wording, design decision 3): "another workstream", "does not list it among its steps", "`waits_on`", "has no entry yet", "recorded".
- Derived (order, design decision 3, not the requirement): the previous non-blank line contains "gates nothing".
- Red at authoring: no such paragraph.

### `workstreams-seeded-done-when-step-done-statement`
- Specified: the prose paragraph names every step being done beside the effect, and no longer every step being archived (scenario 10 as revised; the modification note "every step being done replaces every step being archived").
- Derived (placement): the prose line containing "never in its place".
- Derived (wording, design decision 4): "every step is done" present, "every step is archived" absent, case-insensitive.
- Red at authoring: paragraph reads "Every step is archived".

### `workstreams-seeded-done-when-step-done-shape`
- Specified: the shape's Done when offers every step being done beside the effect, not every step being archived.
- Derived (placement): the fenced `**Done when**` line via `tests/lib.sh` `fenced_line`.
- Derived (wording, design decision 4): "every step is done" and "beside it" present, "every step is archived" absent.
- Red at authoring: line lacks "every step is done".

### Deliberately untested
- The Context-level prose of the requirement (the "A fix's merged pull request is its record" and "A change is a step of one workstream only" rationale paragraphs) — rationale, not a statement the block is required to carry.
- The version rise to `2.0.0` (task 1.2) — not stated in the delta scenarios (the requirement points to *Which part rises is decided by what the project must do*, which this change does not modify). Existing version cases were not inspected by this pass.
- This repository's `docs/workstreams/AGENTS.md` and `docs/workstreams/complete-the-workstream-loop.md` (tasks 1.3, design decision 7) and the `backlog` skill's **close** rewording (task 1.4) — no delta scenario states them; design decision 5 says the close scenario holds as it stands.

## Obsolete tests (candidates for human confirmation)

Searched within `tests/cases/**` only, for "every step is archived", "step being archived" and the done/forge/pull-request wording. No earlier `test-plan.md` was supplied.

1. `workstreams-seeded-done-when-statement` — candidate for human confirmation.
   - Superseded by: the MODIFIED *A workstream register is seeded where none exists*, the Done when statement and scenario *Done when asks for an observable effect of the Goal* ("every step being done" replaces "every step being archived"; design decision 4).
   - Evidence: the case asserts `grep -q -i -F -- "every step is archived"` on the "never in its place" paragraph ("FAIL: the paragraph does not name every step being archived"), and its header cites "every step being archived may stand beside that effect".
   - Only that assertion is superseded; its other assertions (effect of its Goal, what to look at, the forge or production, provokes it, means the Goal holds, worked through, a list missing a step, placement before the archive paragraph) remain current. The replacement is asserted by `workstreams-seeded-done-when-step-done-statement`.
2. `workstreams-seeded-done-when-shape` — candidate for human confirmation.
   - Superseded by: the same MODIFIED requirement, the shape statement's Done when ("with every step being done beside it"; design decision 4).
   - Evidence: `assert_contains "$TESTDIR/done-when.txt" "every step is archived" "every step being archived offered in the shape"`.
   - Only that assertion is superseded; "effect of the Goal", "observ", "the forge or production" and "beside it" remain current. The replacement is asserted by `workstreams-seeded-done-when-step-done-shape`.

Both will fail once task 1.1 lands. Neither was edited by this pass. No other bearing test was found by this search; `workstreams-seeded-statements` and `workstreams-seeded-precedence` assert phrases decision 1 keeps ("archived change of that name", the done/in flight/recorded/planned order), and `backlog-skill-workstreams-operation` and `backlog-skill-close-workstream` assert skill text the delta does not supersede. That is "none found by this search", not "none exists": `tests/coverage.md` lies outside this pass's read set and was not consulted.

## Unresolved project questions

1. No stack skill beyond `bash` was needed; `bash` exists and was loaded. Its `set -euo pipefail` preamble is not this suite's convention (no case uses it), so the new cases follow the suite's own style instead. Assumption: suite style wins, per `bash`'s own deference. All six cases depend on it.
2. Situation classification: the suite treats seeded-text cases as executing the tool (second situation) and owes no fixture beyond local-helper discriminators. They could be read as static reads of the fragment's text (third situation), which would oblige a fixture-driven discriminator per check. Assumption: the suite's existing classification holds; the red-at-authoring record above stands in for the fixture on the real content. All six cases depend on it.
3. `tests/cases/lib/` (`line-scan.sh`, `static-scan.sh`) sits inside the test-path glob but was not dispatched as shared arrangement, so it was treated as a test module and not imported. Assumption: only `tests/lib.sh` is shared. Affects none of the new cases' behaviour, only where their helpers live.

## Missing shared arrangement

Shared arrangement dispatched: `tests/lib.sh`. Three local declarations:

1. `offset_in` — declared in `workstreams-seeded-fix-step-done.sh`, `workstreams-seeded-merged-change-in-flight.sh`, `workstreams-seeded-forge-unreachable.sh`.
   - Stands in for: the 1-based offset of a phrase in a line (order checks on the precedence line).
   - Used by: `workstreams-seeded-fix-step-done`, `workstreams-seeded-merged-change-in-flight`, `workstreams-seeded-forge-unreachable`.
   - Near-miss in `tests/lib.sh`: none. Found inline (not as a function) in `workstreams-seeded-precedence.sh`, a test module.
   - Proposed home: `tests/lib.sh`.
2. `prose_line` — declared in `workstreams-seeded-one-workstream-per-change.sh` and `workstreams-seeded-done-when-step-done-statement.sh`.
   - Stands in for: the line number of the first line outside fenced code containing a phrase.
   - Used by: `workstreams-seeded-one-workstream-per-change`, `workstreams-seeded-done-when-step-done-statement`.
   - Near-miss in `tests/lib.sh`: `fenced_line`, which reads only inside fences and matches a label at a line's start, so it cannot find a prose paragraph.
   - Found in test module `workstreams-seeded-done-when-statement.sh` (identical declaration, not imported).
   - Proposed home: `tests/lib.sh`, beside `fenced_line`.
3. `prev_nonblank` — declared in `workstreams-seeded-one-workstream-per-change.sh`.
   - Stands in for: the line number of the last non-blank line before a given line (placement after the "gates nothing" paragraph).
   - Used by: `workstreams-seeded-one-workstream-per-change`.
   - Near-miss: none in `tests/lib.sh`; `next_nonblank` in test module `workstreams-seeded-done-when-statement.sh` goes the other direction.
   - Proposed home: `tests/lib.sh`.
