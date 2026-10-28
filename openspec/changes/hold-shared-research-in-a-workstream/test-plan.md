# Test plan: hold-shared-research-in-a-workstream

Written by `change-test-writer` before implementation. Not an artifact the OpenSpec schema knows about: it does not appear among `openspec instructions apply`'s context files and must be read on purpose.

Tests are named as the runner selects them: `bash tests/run.sh <case>` (file name in `tests/cases/`, with or without `.sh`), run from the working-tree root.

## Baseline

Full suite, taken before any case was written: `bash tests/run.sh` — 250 passed, 0 failed.

After this pass: the seven new cases fail (below); every other case is unchanged and still passes. ShellCheck (`shellcheck tests/*.sh tests/cases/*.sh tests/cases/lib/*.sh`) is clean.

## Scenarios

Delta: `specs/project-bootstrap/spec.md`, one `MODIFIED` requirement, *A workstream register is seeded where none exists*, with 14 scenarios. All 14 are accounted for below.

The current requirement under `specsRoot` differs from the delta in these places: the "Modified by" note; the edit-statement bullet (widened to "the plan or what it holds", with "context or a decision added or revised"); the "kept short ... decisions recorded in a document" bullet, replaced by four bullets (what a workstream holds besides its plan, the one-step boundary, not progress, revised in place) and a separate "README is kept" bullet; the shape bullet (no `Decisions` item, Open questions' answer "recorded under Decisions", `## Context` then `## Decisions` sections); a new rationale paragraph; the archive rationale's wording; scenarios 3 and 8 revised; scenarios 11–14 added. The other eight scenarios are word-for-word unchanged and stay with their existing cases, which were not touched.

| # | Scenario | Covered by | Written by this pass |
|---|---|---|---|
| 1 | A project without a workstream register receives the seeded file | existing: `workstreams-seeded-new-project`, `workstreams-seeded-adoption`, `workstreams-seeded-statements` (the unchanged statements); revised and added statements: `workstreams-seeded-edit-rule-what-it-holds`, `workstreams-seeded-shared-research-placed`, `workstreams-seeded-one-step-decision-in-design`, `workstreams-seeded-holds-not-progress`, `workstreams-seeded-overturned-revised-in-place`, `workstreams-seeded-fields-list-then-sections` (shape bullet) | the six named after "revised" |
| 2 | An existing workstream register is preserved exactly | `workstreams-existing-preserved`, `workstreams-dangling-symlink-not-written-through` (existing) | no, scenario unchanged |
| 3 | The seeded register carries no status field (revised) | `workstreams-seeded-shape-sections-no-status` | yes |
| 4 | An abandoned workstream is archived, not deleted | `workstreams-seeded-abandoned`, `workstreams-seeded-abandoned-item` (existing) | no, scenario unchanged |
| 5 | A finished workstream is archived | `workstreams-seeded-archive-on-done` (existing) | no, scenario unchanged |
| 6 | A step matching two sources takes the first status | `workstreams-seeded-precedence` (existing) | no, scenario unchanged |
| 7 | Step order is not a dependency | `workstreams-dir-order-names-waits-on` (existing) | no, scenario unchanged |
| 8 | The seeded workstream's fields are a list (revised) | `workstreams-seeded-fields-list-then-sections` | yes |
| 9 | A step is recorded by its entry file | `workstreams-dir-step-recorded-by-entry-file` (existing) | no, scenario unchanged |
| 10 | Done when asks for an observable effect of the Goal | `workstreams-seeded-done-when-shape`, `workstreams-seeded-done-when-statement` (existing) | no, scenario unchanged |
| 11 | Research shared by several steps has a place in the workstream | `workstreams-seeded-shared-research-placed` | yes |
| 12 | A decision for one step stays in that step's design | `workstreams-seeded-one-step-decision-in-design` | yes |
| 13 | What a workstream holds is not progress | `workstreams-seeded-holds-not-progress` | yes |
| 14 | Overturned content is revised in place | `workstreams-seeded-overturned-revised-in-place` | yes |

No scenario is left uncovered. 14 scenarios in the delta, 14 accounted for.

The mapping of existing cases to unchanged scenarios comes from each case's header comment. `tests/coverage.md` was not read: it is outside this pass's read set. Task 2.2 records the mapping there.

**Existing cases checked against the new text.** I built the seeded README the design describes (the current tool output, with design.md decision 7's text substituted) in a scratch directory and ran the workstream cases against it through a stand-in `PROJECT_INIT` that copies that file. This was a check on the tests, not on any implementation. Results: all seven new cases pass; `workstreams-seeded-new-project`, `-adoption`, `-precedence`, `-archive-on-done`, `-abandoned`, `-abandoned-item`, `-done-when-shape`, `-done-when-statement`, `workstreams-dir-order-names-waits-on` and `workstreams-dir-step-recorded-by-entry-file` stay green; `workstreams-seeded-statements`, `workstreams-seeded-fields-are-a-list` and `workstreams-seeded-no-status-field` fail, which are the obsolete entries below. One dependency for the implementer: `workstreams-seeded-new-project` allows exactly one heading outside fenced code, so the shape's `## Context` and `## Decisions` lines must sit **inside** the fenced example, as decision 7 places them. Headings outside the fence fail that case for a reason this change did not intend.

## New cases and assertion classification

All seven cases run `scripts/project-init` and read the README it writes. The target exists and the asserted property is not yet present, so each case runs and gets the wrong value (state 1). This was observed. Each case first runs its discriminator (the line-scan or static-scan mutants, or the local shape check over specimens), and every discriminator passed before the real read failed:

- `workstreams-seeded-edit-rule-what-it-holds` fails at `[plan-or-holds]` and `[context-decision]`. The tool writes "only when the plan changes".
- `workstreams-seeded-shared-research-placed` fails with no paragraph saying "besides its plan", and at the forbid scans `[short]` and `[separate-document]`, because the tool still writes the "Keep a workstream short" paragraph.
- `workstreams-seeded-one-step-decision-in-design` fails with no paragraph saying "shapes one step only".
- `workstreams-seeded-holds-not-progress` fails with no paragraph saying "context and decisions say".
- `workstreams-seeded-overturned-revised-in-place` fails with no paragraph saying "state what is held now".
- `workstreams-seeded-shape-sections-no-status` fails at "carries no `## Context` section".
- `workstreams-seeded-fields-list-then-sections` fails at "the three field items span lines 34-37". The tool still writes `- **Decisions**` between Open questions and Opened.

All seven should go green when task 1.1 lands.

The prose cases use `tests/cases/lib/line-scan.sh` (`line_select`, `line_scan`, `line_discriminate`, `line_check`). `line_check` runs on the generated file directly, not through `line_run`, because `line_run` reads `$TOOLKIT_ROOT` and this file exists only in the case's `$TESTDIR`. A status of 2 (no paragraph matches the selector) is reported as a failure, not as an absent target. The tool runs; what is missing is the paragraph it should write.

### `workstreams-seeded-edit-rule-what-it-holds`

- **Specified**: the revised edit statement. The file is edited only when the plan or what it holds changes, and the events include context or a decision added or revised, beside the events that were already listed.
- **Derived (placement)**: the statement is on one line (AGENTS.md: one paragraph per line), selected by `edit the file only when`.
- **Derived (wording)**: `the plan or what it holds changes`; `context or a decision added or revised`; `added, removed, reordered or renamed`; `open question added or answered`; `workstream archived`. Each phrase is common to the requirement and design.md decision 7.

### `workstreams-seeded-shared-research-placed`

- **Specified**: the "besides its plan" statement. Under `## Context` go research, findings, options considered, and why one was chosen. Under `## Decisions` go decisions that shape more than one step or were taken before any step's proposal existed, with who took them, when and why, and a decision already recorded in a change's design is pointed to rather than copied. Also scenario 11's negative clause: the file "does not direct it to a separate document or keep the workstream short".
- **Derived (placement)**: one line, selected by `besides its plan`.
- **Derived (wording)**: `` `## context` ``, `research`, `findings`, `options considered`, `why one option was chosen`, `` `## decisions` ``, `more than one step`, `before any step's proposal existed`, `who took it`, `pointed to rather than copied`.
- **Derived (operationalisation of the negative clause)**: the whole file must not contain `keep a workstream short` or `belong in a document`. These are the two phrases of the paragraph this change replaces. A redirection to a separate document worded some other way is not caught by this scan.

### `workstreams-seeded-one-step-decision-in-design`

- **Specified**: a decision that shapes one step only belongs in that step's design, which points to the workstream for what it shares rather than copying it.
- **Derived (placement)**: one line, selected by `shapes one step only`.
- **Derived (wording)**: `that step's design`; `points to the workstream for what it shares`; `rather than copying it`.

### `workstreams-seeded-holds-not-progress`

- **Specified**: Context and Decisions say what is known and decided about the goal, never how far the work has come. A finding states what is true of the problem, not that a step found or did it, and neither names a step as done, in flight or merged.
- **Derived (placement)**: one line, selected by `context and decisions say`.
- **Derived (wording)**: `what is known and decided about the goal`; `never how far the work has come`; `what is true of the problem`; `not that a step found or did it`; `neither (section )?names a step` (the requirement says "neither names", the design "neither section names"); `done, in flight or merged`.

### `workstreams-seeded-overturned-revised-in-place`

- **Specified**: Context and Decisions state what is held now. Where a change in the workstream overturns something they hold, it is revised in place, naming that change, in its plan commit or at the latest at its archive.
- **Derived (placement)**: one line, selected by `state what is held now`.
- **Derived (wording)**: `a change in the workstream overturns`; `in place`; `nam(e|ing) that change`; `plan commit`; `at the latest at its archive`.
- **Deliberately untested**: "The file's history keeps what was held before." It appears in design.md decision 7 and in the requirement's rationale, but it is not among the statements the created file must carry.

### `workstreams-seeded-shape-sections-no-status`

- **Specified**: the shape names Goal, Done when, Steps, Not in scope, Open questions and Opened, and the Context and Decisions sections, and names no field or section recording a step's status.
- **Derived (placement)**: the shape is the fenced example. Each field is a fenced line carrying `**<label>**`. Each section is a fenced line that is exactly `## Context` or `## Decisions`.
- **Derived (operationalisation of "no field or section")**: no fenced line, headings included, carries `status`, `progress`, `in flight`, a checkbox, or `done:`. This is the same scan as `workstreams-seeded-no-status-field`, applied to every fenced line. A status field or section worded some other way is not caught.
- **Discriminator**: a conforming specimen must pass. A missing `## Context`, a `- **Decisions**` item standing in for the section, a `## Step status` section, and a `- **Progress**` item must each be rejected.

### `workstreams-seeded-fields-list-then-sections`

- **Specified**:
  - Not in scope, Open questions and Opened are consecutive list items after the steps, in that order.
  - Not in scope and Open questions give `none` as the absent value.
  - There is no Decisions list item.
  - `## Context` and then `## Decisions` come after the list.
  - Goal and Done when are paragraphs.
  - Open questions' answer is "recorded under Decisions" (shape bullet).
  - Each section is optional and omitted where empty (shape bullet).
- **Derived (placement)**: list items are fenced lines beginning `- **<label>**`, three adjacent lines. Sections are fenced lines that are exactly the heading.
- **Derived (operationalisation)**: Opened always has a value, so `none` binds only the other two items, and neither may offer `nothing`. Each section's placeholder, up to the next heading or the end of the fence, contains `omit` (design.md decision 7: "omit the section where there are none").
- **Discriminator**: a conforming specimen must pass. Seven specimens must each be rejected: the retired Decisions item, a Decisions item elsewhere in the fence, the sections in reverse order, a missing section, the old answer wording, a section not marked as omittable, and a blank line inside the list.

### Deliberately untested

- **This repository's own `docs/workstreams/README.md` matching the seed, and the migration of the two open workstreams and the backlog entry** (tasks 1.2–1.4). None of these is a scenario of the delta. Task 1.2's own verification is a diff against the heredoc.
- **The requirement's rationale paragraphs** ("A workstream holds what its steps share because ...", the archive rationale's "plan, context and decisions"). These are rationale, not statements the created file must carry.
- **"Keep this file when there is no workstream" as a sentence of its own** (design.md decision 6). The existing `workstreams-seeded-statements` line 71 still asserts the phrase, and that assertion is not superseded.
- **An optional distinctive phrase added to `backlog-skill-workstream-rules-not-restated`'s forbid list** (design.md decision 9 says "may be added"). That is an edit to an existing case, so it is outside this pass. It is left to the implementer as optional.

## Obsolete tests

The delta is `MODIFIED`. I compared the current requirement under `specsRoot` with the delta and searched `tests/cases/**` only, for `plan changes`, `keep a workstream short`, `short`, `points to`, `decisions`, `separate document` and `context`, then read every hit. No earlier `test-plan.md` was supplied for this change. Every entry below is a **candidate for human confirmation**, not a conclusion. None was edited.

- **`workstreams-seeded-statements`**, assertion at line 56 (`Edit the file only when the plan changes`).
  - Superseded by: the edit-statement bullet, now "only when the plan or what it holds changes".
  - Evidence: the asserted phrase is the old sentence. It fails against decision 7's text in the simulation above.
  - Candidate for confirmation.
- **`workstreams-seeded-statements`**, assertions at lines 69 (`Keep a workstream short`) and 70 (`that the file points to`).
  - Superseded by: the removal of the "kept short, its lasting decisions recorded in a document or a change's design it points to" bullet, now the four Context/Decisions bullets and "the README is kept".
  - Evidence: both phrases come from the removed paragraph. The new text contains neither, and scenario 11 now requires the file not to keep the workstream short.
  - Candidate for confirmation.
- **`workstreams-seeded-statements`**, header comment at lines 14 ("edited only when the plan changes") and 19 ("kept short, decisions pointed to").
  - Superseded by: the same two bullets.
  - Evidence: these lines describe the assertions above. They are comments, not assertions, so they are obsolete as a description only.
  - Candidate for confirmation.
- **`workstreams-seeded-fields-are-a-list`**: `ITEMS` and `NONE_ITEMS` include `Decisions`, and the four-item adjacency check and the `- **Decisions**` requirement (lines 9–11, 27–28, 72–73; specimen at line 108).
  - Superseded by: scenario 8 as revised ("gives no Decisions list item") and the shape bullet.
  - Evidence: the case fails against decision 7's text with "carries no list item `- **Decisions**`". Its revised replacement is `workstreams-seeded-fields-list-then-sections`.
  - Candidate for confirmation.
- **`workstreams-seeded-no-status-field`**: `Decisions` in the label loop (line 37; header lines 6–8).
  - Superseded by: scenario 3 as revised, where Decisions is now a section, not a field.
  - Evidence: the case fails against decision 7's text with "does not name **Decisions**". The rest of the case (the status scan) is not superseded. Its revised replacement is `workstreams-seeded-shape-sections-no-status`.
  - Candidate for confirmation.

Searched and found **not** superseded:
- `backlog-skill-workstream-rules-not-restated` line 35 forbids "keep a workstream short" in the backlog skill. The skill does not change, so the case stays green.
- `workflow-fragment-workstream-rules-not-restated` has no such scan.
- `backlog-dir-seeded-new-project`'s "short" assertion is about the backlog README, not the workstream README.

This agrees with design.md decision 9. The search covered `tests/cases/**` only. It shows that nothing else was found there, not that no other bearing test exists anywhere.

Task 2.1 directs revising the obsolete assertions "changing only what the delta replaced". That is a decision about existing tests for the human or the implementer. This pass did not make it.

## Unresolved project questions

- **Q1. No runner-specific skill.** The harness is plain bash, and the library's `bash` skill was loaded. `tests/README.md` records the runner, so nothing is unresolved here.
- **Q2. Where the shared arrangement is recorded.**
  - AGENTS.md and `tests/README.md` describe `tests/lib.sh`'s helpers. Neither names `tests/cases/lib/` as shared arrangement, and neither says the project has none beyond `lib.sh`.
  - The dispatch named both `tests/lib.sh` and `tests/cases/lib/` as shared, and I took that as the assumption. Under it, `line-scan.sh` and `static-scan.sh` are shared arrangement and may be sourced.
  - Dependent cases: the five prose cases above, which use `line-scan.sh`, and `workstreams-seeded-shared-research-placed`, which also uses `static-scan.sh`.
  - Recording this in `tests/README.md` (or AGENTS.md) would settle the question. The analog plan for `observe-what-finishes-a-workstream` took the opposite assumption.
- **Q3. Where the scenario-to-case mapping is recorded.** `tests/coverage.md` is outside this pass's read and write set. Task 2.2 carries the new cases there.

## Missing shared arrangement

The dispatch named `tests/lib.sh` and `tests/cases/lib/` as shared arrangement. Five cases need nothing beyond them. Two cases declare helpers locally:

- **`fenced_text <file>`**, declared in `tests/cases/workstreams-seeded-shape-sections-no-status.sh`.
  - What it stands in for: every line inside fenced code, with the fence markers dropped.
  - Used by: `workstreams-seeded-shape-sections-no-status`.
  - Near-miss: `tests/lib.sh`'s `fenced_line`. It returns one line number for a `**<label>**` line, not the fenced text.
  - Found in another test module: as an inline `awk` in `workstreams-seeded-no-status-field`, not as a helper.
  - Proposed home: `tests/lib.sh`, beside `fenced_line`.
- **`fenced_prefixed_line <file> <prefix> <label>`**, declared in `tests/cases/workstreams-seeded-fields-list-then-sections.sh`.
  - What it stands in for: the line number of the first fenced line beginning `<prefix>**<label>**`.
  - Used by: `workstreams-seeded-fields-list-then-sections`.
  - Near-miss: `tests/lib.sh`'s `fenced_line`. It strips an optional `- ` before matching, so it cannot require the list marker or require that it be absent.
  - Found in another test module: yes, `workstreams-seeded-fields-are-a-list`. It was redeclared here, not imported.
  - Proposed home: `tests/lib.sh`.
- **`fenced_exact_line <file> <text>`**, declared in `tests/cases/workstreams-seeded-fields-list-then-sections.sh`.
  - What it stands in for: the line number of the first fenced line that is exactly `<text>`, here a section heading.
  - Used by: `workstreams-seeded-fields-list-then-sections`.
  - Near-miss: `fenced_line`. It matches a `**<label>**` prefix, not a whole line.
  - Found in another test module: no.
  - Proposed home: `tests/lib.sh`.
- **`section_omits <file> <line>`**, declared in `tests/cases/workstreams-seeded-fields-list-then-sections.sh`.
  - What it stands in for: whether the lines after a heading, up to the next heading or fence marker, say "omit".
  - Used by: `workstreams-seeded-fields-list-then-sections`.
  - Near-miss: `static-scan.sh`'s `scan_heading_section`. It reads a section under a heading, but it skips fenced code, and these sections are inside a fence.
  - Found in another test module: no.
  - Proposed home: none proposed. It is specific to this shape.

**Dispositions at `apply`:**
- `fenced_text`, `fenced_prefixed_line`, `fenced_exact_line`, `section_omits`: **kept local.** `AGENTS.md` records no shared test arrangement, so nothing can be promoted into one; creating or recording one is a testing-strategy decision, not a step of this change. The backlog's `record-this-repositorys-shared-test-arrangement` is where they would move.
- Obsolete assertions (above): **confirmed and revised** in task 2.1. `workstreams-seeded-statements` asserts the new edit sentence and drops "Keep a workstream short" and "that the file points to"; `workstreams-seeded-fields-are-a-list` drops the Decisions item from its lists and specimen; `workstreams-seeded-no-status-field` drops Decisions from its label loop. Only what the delta replaced was changed; the revised scenarios' new halves are asserted by the derived cases.
