# Test plan: observe-what-finishes-a-workstream

Written by `change-test-writer` before implementation. Not an artifact the OpenSpec schema knows about: it does not appear among `openspec instructions apply`'s context files and must be read on purpose.

Tests are named as the runner selects them: `bash tests/run.sh <case>` (file name in `tests/cases/`, with or without `.sh`).

## Baseline

Full suite, taken before any case was written: `bash tests/run.sh` — 243 passed, 0 failed.

After this pass: the two new cases fail (below); every other case is unchanged.

## Scenarios

Delta: `specs/project-bootstrap/spec.md`, one `MODIFIED` requirement, *A workstream register is seeded where none exists*, with 10 scenarios. All 10 are accounted for below. Nine restate the current requirement's scenarios word for word. The current spec under `specsRoot` differs from the delta in five places only: the "Modified by" note, one added statement bullet, the Done when clause of the shape bullet, the "Done when names an effect of the Goal" rationale paragraph, and the new scenario. Where a scenario is unchanged, existing cases already cover it, and they were not touched.

| # | Scenario | Covered by | Written by this pass |
|---|---|---|---|
| 1 | A project without a workstream register receives the seeded file | `workstreams-seeded-new-project`, `workstreams-seeded-adoption`, `workstreams-seeded-statements` (existing); added statement and revised shape clause: `workstreams-seeded-done-when-statement`, `workstreams-seeded-done-when-shape` | the last two |
| 2 | An existing workstream register is preserved exactly | `workstreams-existing-preserved`, `workstreams-dangling-symlink-not-written-through` (existing) | no, scenario unchanged |
| 3 | The seeded register carries no status field | `workstreams-seeded-no-status-field` (existing) | no, scenario unchanged |
| 4 | An abandoned workstream is archived, not deleted | `workstreams-seeded-abandoned`, `workstreams-seeded-abandoned-item` (existing) | no, scenario unchanged |
| 5 | A finished workstream is archived | `workstreams-seeded-archive-on-done` (existing) | no, scenario unchanged |
| 6 | A step matching two sources takes the first status | `workstreams-seeded-precedence` (existing) | no, scenario unchanged |
| 7 | Step order is not a dependency | `workstreams-dir-order-names-waits-on` (existing) | no, scenario unchanged |
| 8 | The seeded workstream's fields are a list | `workstreams-seeded-fields-are-a-list` (existing) | no, scenario unchanged |
| 9 | A step is recorded by its entry file | `workstreams-dir-step-recorded-by-entry-file` (existing) | no, scenario unchanged |
| 10 | Done when asks for an observable effect of the Goal | `workstreams-seeded-done-when-shape` (shape half), `workstreams-seeded-done-when-statement` (prose half) | yes |

No scenario is left uncovered.

The mapping of existing cases to scenarios 2–9 comes from each case's header comment. `tests/coverage.md` was not read because it is outside this pass's read set. Task 2.1 records the mapping there.

The existing cases for scenarios 3, 5 and 8 read the Done when line or the archive paragraph, which this change touches. I checked them against the design's new text by reading, not by running anything. `workstreams-seeded-no-status-field` forbids `status|progress|in flight|done:` in the fenced shape, and the new shape line contains none of these. `workstreams-seeded-fields-are-a-list` needs `**Done when**` as an unmarked fenced line, and that still holds. `workstreams-seeded-archive-on-done` needs "Done when" on the archive paragraph's line, which the change leaves alone. All three should stay green.

## New cases and assertion classification

Both cases run `scripts/project-init` and read the README it writes. The target exists and the asserted property is not yet present, so each case runs and gets the wrong value (state 1). This was observed:

- `workstreams-seeded-done-when-shape` fails at `effect of the Goal`. The tool still writes the old shape line. Red on the property "the shape's Done when names an effect of the Goal".
- `workstreams-seeded-done-when-statement` fails at "no prose paragraph ... never in its place". The tool writes no such paragraph. Red on the property "the prose states what finishes a workstream". Its locator discriminator ran and passed first.

Both should go green when task 1.1 lands. ShellCheck is clean on both files.

### `workstreams-seeded-done-when-shape`

- **Specified**: the shape's Done when names an observable effect of the Goal, checked against the repository, the forge or production, with every step being archived beside it (the shape bullet; scenario 10's first clause).
- **Derived (placement)**: the shape is the fenced example, and its Done when is the fenced line starting `**Done when**`, found with `fenced_line` from `tests/lib.sh`.
- **Derived (wording)**: one phrase per clause, each common to the requirement and design.md decision 1: `effect of the Goal`; `observ` (which matches both "observable" and "can be observed"); `the forge or production`; `every step is archived`; `beside it`.

### `workstreams-seeded-done-when-statement`

- **Specified**: the added statement. What finishes a workstream is an observable effect of its Goal: what to look at, in the repository, the forge or production; what provokes it; and the result that means the Goal holds. Every step being archived may stand beside that effect but never in its place, since it shows only that the step list was worked through, which a list missing a step satisfies as well. This also covers scenario 10's second clause, "its prose states ...".
- **Derived (placement)**: the statement is one paragraph on one line (AGENTS.md: prose is not hard-wrapped), outside fenced code, located by "never in its place". Every phrase is asserted on that line.
- **Derived (wording)**: `effect of its Goal`; `what to look at`; `the forge or production`; `provokes it`; `means the Goal holds`; `every step is archived` (case-insensitive, since the design starts a sentence with it); `worked through`; `a list missing a step`; `never in its place`. Each is common to the requirement and design.md decision 2.
- **Derived (order, design.md decision 2 only, not the requirement)**: the paragraph comes immediately before the archive paragraph. The next non-blank line must contain `archive/<YYYY-MM-DD>-<name>.md`. This assertion is the one most open to reconsideration: it binds a design decision that the requirement does not state.
- **Discriminator**: the local locators `prose_line` and `next_nonblank` are checked against specimens before the real read. `prose_line` must skip a fenced match and find a prose one. `next_nonblank` must skip blank lines.

### Deliberately untested

- **This repository's own `docs/workstreams/README.md` matching the seed** (task 1.2). This is not a scenario of the delta. The task's own verification is a diff against the heredoc.
- **The rationale paragraph "Done when names an effect of the Goal because ..."**. This is requirement rationale, not a statement the created file is required to carry.
- **The absence of the old wording "a condition that can be checked" from the shape**. The positive assertions already fail on the old line, so a negative assertion would add a constraint without adding discrimination.

## Obsolete tests

The delta is `MODIFIED`, so I searched for superseded tests within `tests/cases/**` only. No earlier `test-plan.md` was supplied. The superseded text is the shape's old Done when clause, "a condition that can be checked against the repository, the forge or production". I searched `tests/cases/` for `done when`, `condition that can be checked` and `every step is archived`, and read each hit:

- `workstreams-seeded-archive-on-done`, `workstreams-seeded-precedence` and `workstreams-seeded-fields-are-a-list` use "Done when" as a label or as precedence wording. None of them asserts the old clause.
- `workstreams-seeded-no-status-field` reads only the label.
- `workflow-fragment-workstream-rules-not-restated` has `**Done when**: a condition that can be checked.` only as a forbid-specimen, a sample restatement that the fragment must not carry. It does not assert the seeded text, and the change does not supersede it.
- `backlog-skill-workstreams-operation` asserts the backlog skill's own text ("done when"), which the proposal says this change does not touch.
- `backlog-dir-seeded-waits-on-names-only` and `backlog-dir-seeded-priority-values` match "condition that can be checked" in the backlog README's `waits_for` and `parked_until`. That is a different statement, which this change does not modify.

Result: no superseded test was found by this search. That means none was found inside `tests/cases/**`. It does not establish that none exists anywhere. design.md decision 4 reaches the same conclusion independently.

## Unresolved project questions

- **No stack skill for the runner.** The harness is plain bash, and the `bash` skill was loaded. The project records no test-runner skill beyond `tests/README.md`, so nothing is unresolved here.
- **Where shared arrangement lives.** AGENTS.md does not name `tests/lib.sh` as the shared arrangement and does not say the project has none. The dispatch supplied it by hand. I assumed `tests/lib.sh` is the whole shared arrangement and that `tests/cases/lib/*.sh` (`line-scan.sh`, `static-scan.sh`) are test modules, not shared arrangement, and neither new case imports from them. Dependent tests: `workstreams-seeded-done-when-shape` and `workstreams-seeded-done-when-statement`. Recording this in AGENTS.md or `tests/README.md` would settle it.
- **Where scenario-to-case mapping is recorded.** `tests/README.md` points to `tests/coverage.md`, which is outside this pass's read and write set, so the new cases are recorded here and task 2.1 carries them there.

## Missing shared arrangement

The dispatch named `tests/lib.sh` as the shared arrangement. Two local declarations were made, both in `tests/cases/workstreams-seeded-done-when-statement.sh`:

- **`prose_line <file> <phrase>`**
  - What it stands in for: a locator for the first line outside fenced code that contains a phrase.
  - Used by: `workstreams-seeded-done-when-statement`.
  - Near-miss: `tests/lib.sh`'s `fenced_line`. It reads only inside fences and matches a `**<label>**` at the start of a line, so it cannot find a prose paragraph by a phrase inside it.
  - Found in another test module: no. `workstreams-seeded-archive-on-done` does a similar inline `grep`, but it is not a helper and it does not skip fences.
  - Proposed home: `tests/lib.sh`, beside `fenced_line`.
- **`next_nonblank <file> <line>`**
  - What it stands in for: the line number of the first non-blank line after a given line.
  - Used by: `workstreams-seeded-done-when-statement`.
  - Near-miss: none.
  - Found in another test module: no.
  - Proposed home: `tests/lib.sh`.

`workstreams-seeded-done-when-shape` declares nothing locally. It uses `fenced_line`, `assert_*` from `tests/lib.sh`.
