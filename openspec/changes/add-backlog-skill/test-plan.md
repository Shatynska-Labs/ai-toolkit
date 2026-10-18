# Test plan: add-backlog-skill

Written by `change-test-writer` against the plan committed at `08000d1`, before implementation. This file is not an artifact the OpenSpec schema knows about: it does not appear among `openspec instructions apply`'s context files and must be read on purpose.

## Running a single case

`tests/run.sh` has no per-case filter (see Q4). Run one case from the working-tree root with:

```
TOOLKIT_ROOT=$PWD TESTLIB=$PWD/tests/lib.sh PROJECT_INIT=$PWD/scripts/project-init TESTDIR=$(mktemp -d) bash tests/cases/<name>.sh
```

Every identifier below is a file under `tests/cases/`, and that same name with `.sh` removed is what `tests/run.sh` prints.

## Baseline

Full suite, `bash tests/run.sh`, on a clean tree at `08000d1`, before any test was written: **90 passed, 0 failed.**

After this pass: **91 passed, 15 failed.** The extra pass is `backlog-seeded-no-entry-numbering`, which asserts behaviour the current seeded file already has (see its row). All 15 failures are new cases, and each fails because its target is absent: no `skills/backlog/`, no archive-step re-read in the fragment, and the seeded heredoc not yet changed. No pre-existing case changed state.

## Scenario accounting

There are 30 `#### Scenario:` blocks across the three delta specs (17 + 5 + 8), and all 30 are accounted for below. "In part" means a case asserts the mechanical half and the row names the half it does not reach. Every case marked *new* was red when written, and each discriminator below was green.

### specs/backlog-maintenance/spec.md (17, all ADDED)

| # | Scenario | Status | Case(s) | Not reached |
|---|---|---|---|---|
| 1 | Invoked from a consuming project | In part | `backlog-skill-identity` | that it reads and writes only the invoking project's file (run-time conduct) |
| 2 | No backlog exists | In part | `backlog-skill-absent-backlog` | "does not create the file": deliberately untested, because a lexical scan cannot tell a direction to create the file from a sentence forbidding it |
| 3 | A project's preamble differs from the seeded one | In part | `backlog-skill-restates-no-entry-rule` | checking entries against the file's shape (conduct) |
| 4 | The skill does not mandate an audit cadence | Covered | `backlog-skill-no-audit-cadence` | an interval worded outside the scanned forms |
| 5 | A name already used by an archived change | In part | `backlog-skill-record` | the refusal and the request for another name (conduct) |
| 6 | An overlapping entry exists | In part | `backlog-skill-record` | leaving out unconfirmed candidates (conduct) |
| 7 | A blocked entry is not offered | In part | `backlog-skill-pick` | the omission itself (conduct) |
| 8 | A wait already satisfied but not updated | In part | `backlog-skill-pick` | listing it apart, with the change named (conduct) |
| 9 | Pick narrowed to files | In part | `backlog-skill-pick` | the narrowing itself (conduct) |
| 10 | A closed entry was another's only wait | In part | `backlog-skill-close` | that it is one edit and that the other entry becomes takeable (conduct) |
| 11 | An entry finished without being named | In part | `backlog-skill-sweep` | finding the entry (conduct) |
| 12 | Sweep after a squash merge | In part | `backlog-skill-sweep` | "not from the branch's diff": deliberately untested, because a scan forbidding `git diff …` would also fail a SKILL.md that names the command to rule it out |
| 13 | Sweep after the record has landed | In part | `backlog-skill-sweep` | the edit being made (conduct) |
| 14 | An entry done by an unmentioning change | In part | `backlog-skill-audit` | an agent actually finding it (conduct) |
| 15 | The report is not applied unasked | In part | `backlog-skill-audit` | the file staying unchanged before approval (conduct) |
| 16 | Two entries recorded for one change | In part | `backlog-skill-audit` | the merge actually identifying them (conduct) |
| 17 | Pick meets an entry with no Kind | In part | `backlog-skill-older-shape-unclassified` | listing it rather than omitting it, inventing no value, migrating only on the operator's word (conduct) |

### specs/project-bootstrap/spec.md (5, MODIFIED "A backlog is seeded where none exists")

| # | Scenario | Status | Case(s) |
|---|---|---|---|
| 18 | A project without a backlog receives the seeded file | Covered | new `backlog-seeded-structured-statements` (the statements the delta adds or revises); existing `backlog-seeded-new-project` (carried statements; its `Depends on` assertion is obsolete, see below) and `backlog-seeded-adoption` (same text in both modes) |
| 19 | An existing backlog is preserved exactly | Covered (existing, unchanged by the delta) | `backlog-existing-preserved`, `backlog-dangling-symlink-not-written-through` |
| 20 | The seeded file carries no numbering | Covered | new `backlog-seeded-no-entry-numbering`; existing `backlog-seeded-no-numbering` is obsolete, see below |
| 21 | The seeded entry shape carries the structured fields | Covered | new `backlog-seeded-structured-fields` |
| 22 | A fix is distinguished from a change by what it owes | Covered | new `backlog-seeded-kind-definition` |

### specs/session-workflow/spec.md (8)

| # | Scenario | Delta | Status | Case(s) / reason |
|---|---|---|---|---|
| 23 | A rule outlives the defect that motivated it | MODIFIED, carried verbatim | Uncovered | This change leaves the behaviour unchanged, and it is a property of prose; `tests/coverage.md`'s existing accounting stands |
| 24 | The fragment carries no argument written for the library | MODIFIED, carried verbatim | Uncovered | same as 23 |
| 25 | An incident does not become a standing entry | MODIFIED, carried verbatim | Uncovered | same as 23 |
| 26 | An operational skill carries procedure, not obligation | MODIFIED, new | In part | `workflow-fragment-archive-backlog-reread` checks that the fragment states the obligation and its differing edge case and names no skill. `backlog-skill-no-audit-cadence` checks that the skill carries one obligation the fragment does not. Not reached: the full set of obligations a skill might add |
| 27 | An entry completed by an archived change is removed with its record | ADDED | In part | `workflow-fragment-archive-backlog-reread`. Not reached: a session's conduct |
| 28 | An entry waiting on the archived change is marked takeable | ADDED | In part | `workflow-fragment-archive-backlog-reread` (`unblocked`). Not reached: conduct |
| 29 | The fragment defers the update's form to the file | ADDED | Covered | `workflow-fragment-archive-reread-names-no-field`; `as the file directs` is in `workflow-fragment-archive-backlog-reread` |
| 30 | The obligation holds where the skill is absent | ADDED | In part | `workflow-fragment-archive-backlog-reread` (`[names-skill]`). Not reached: a session following the fragment alone |

Count: 30 scenarios, 30 accounted for. 3 are uncovered, 9 covered and 18 covered in part.

## Assertion classification

**Specified** assertions trace to the delta's requirement or scenario text. **Derived** assertions were inferred, and each one is stated in its case's header as well as here.

- `backlog-seeded-structured-statements`
  - Specified: each statement the MODIFIED requirement adds: the fix name, "in its own fields", brevity with its three exclusions, obsolescence as a deletion ground, the archive-time update with Re-checked, Waits on as checkable, Design with, Re-checked.
  - Derived (wording): each statement is matched by one phrase from `design.md` decision 2, the same method `backlog-seeded-new-project` uses. All 13 phrases were confirmed present in that text.
  - Derived (placement): the archive-time update and `Re-checked` are on one line.
- `backlog-seeded-structured-fields`
  - Specified: the five labels are named and `Depends on` is not.
  - Specified from requirement text: `precede` appears nowhere, because that direction is dropped.
  - Derived: the labels are read from inside the fenced shape.
- `backlog-seeded-kind-definition`
  - Specified: `fix` / `change`, with the three conditions.
  - Derived: the definition is on the fenced `**Kind**` line, matched by the phrases `no specification delta`, `no decision` and `one review sitting`.
- `backlog-seeded-no-entry-numbering`
  - Specified: no heading begins with a number.
  - Derived: every `number` must belong to `line number(s)`. That is the narrowest reading consistent with the revised requirement, which obliges "without line numbers". It passes now because the current seeded file carries no `number` at all. This is the second situation (the behaviour already exists), not an alarm.
- `backlog-skill-identity`
  - Specified: the path, `name: backlog`, `docs/backlog.md`, the five operations, and `project-init` in the description.
  - Derived: "distinguishes from the OpenSpec skills" is read as the description naming `openspec`. The `project-lifecycle` tag comes from `design.md` decision 5, not the spec.
- `backlog-skill-absent-backlog`
  - Specified: `project-init` is named where the file is absent.
  - Derived: both are on one line, with absence matched by `absent|missing|not exist|no docs/backlog.md`.
- `backlog-skill-restates-no-entry-rule`
  - Specified: no restatement.
  - Derived: a restatement is recognised by six phrases from the seeded preamble, in SKILL.md and `references/audit.md`. Field names are deliberately not scanned, because the operations act on fields.
- `backlog-skill-no-audit-cadence`
  - Specified: there is no interval rule.
  - Derived: the forms recognised as an interval.
- `backlog-skill-record`, `-pick`, `-close`, `-sweep`
  - Specified: each term traces to the operation's requirement text.
  - Derived: the terms are read from the section under a heading naming the operation (Q1), plus the term lists stated in each header.
- `backlog-skill-audit`
  - Specified: the five relevance verdicts, `fix?`, archived changes, merged PRs, agents writing nothing, "recorded twice", the operator, parallel.
  - Derived: `references/audit.md` as the brief's location and SKILL.md referencing it (from `design.md` decision 4).
- `backlog-skill-older-shape-unclassified`
  - Specified: `unclassified`.
  - Derived: searched across the whole file, not only the pick section.
- `workflow-fragment-archive-backlog-reread`
  - Specified: each element of the ADDED requirement's first paragraph.
  - Derived: the sentence sits on the archive step's own line (Q3), with the wording tokens listed in the header. Naming no backlog skill is the operationalisation of scenario 30.
- `workflow-fragment-archive-reread-names-no-field`
  - Specified: no field, date rule or deletion ground.
  - Derived: the label forms are case-sensitive, and the re-read line is checked for `date` as a word and for `delet`.

### Discriminators (static checks)

Every `backlog-skill-*` case and both `workflow-fragment-archive-*` cases read files statically. Each one runs its check before it reads the real file:

- **Over a conforming fixture**, which must pass.
- **Over one mutant per scan.** A require scan gets its matches blanked; a forbid scan gets a specimen inserted. Each mutant must be rejected with status 1 *and* with that scan's own `[tag]`.

So each scan is shown to be able to fail on the property it names, not just the case as a whole. This was run and green for all 12 static cases during this pass. The `backlog-seeded-*` cases execute `scripts/project-init` and read what it writes, so no fixture is owed for them.

## Obsolete tests: candidates for human confirmation

The search covered `tests/cases/**` only, using the terms `Depends on`, `precede`, `number`, `publication`, `reasoning only`, `none exists today`, version literals (`v6`, `version: 6`) and `backlog`. No earlier `test-plan.md` was supplied. Every entry below is a **candidate for human confirmation**, not a conclusion. Nothing was edited or deleted.

1. **`backlog-seeded-new-project`**: the assertion `assert_contains "$backlog" "Depends on" "statement 6: the shape — what it depends on"`.
   - Superseded by: project-bootstrap MODIFIED *A backlog is seeded where none exists*. "Waits on replaces a list of changes that must land first", and scenario 21 says the shape "does not name Depends on".
   - Evidence: the assertion's literal and its message. It will fail against a compliant file. The header's "six statements" count is superseded too.
   - The rest of the case still holds.
2. **`backlog-seeded-no-numbering`**: the derived scan `mentions="$(grep -n -i -E 'number' "$backlog")"`, meaning `number` nowhere in the file.
   - Superseded by: the same MODIFIED requirement, which now obliges the file to state that an entry is kept "without line numbers". The scan therefore fails every compliant file.
   - Evidence: the scan, and its own header recording it as "stricter than the scenario".
   - Its heading scan still holds. The new case `backlog-seeded-no-entry-numbering` carries both halves as revised, so this case may be retired rather than rewritten.

Cases that bear on the change and were assessed as **not** superseded:

- `workflow-fragment-backlog-rules-not-restated` still scans for `depends on:`. That stays valid because the fragment must still not restate field labels. The new labels are covered by `workflow-fragment-archive-reread-names-no-field`.
- `inlined-body-matches-fragment` and `managed-block-*` read the fragment's version dynamically, so the bump from 6 to 7 needs no test change.

There was nothing to find for two superseded statements:

- **"should precede"**: no case in the glob asserts it.
- **`none exists today`**: the delta keeps it, so it is not superseded.

## Unresolved project questions

- **Q1. Structure of `skills/backlog/SKILL.md`.**
  - Assumption: each operation sits under its own markdown heading naming it (`record`, `pick`, `close`, `sweep`, `audit`), at any level, and the scans read that section.
  - Neither the spec nor the design fixes this. A SKILL.md that puts the operations under one heading as bullets would fail compliant content.
  - Depends on it: `backlog-skill-record`, `-pick`, `-close`, `-sweep`, `-audit`.
- **Q2. Shared helper location.**
  - `tests/README.md` names `tests/lib.sh` as the harness's helpers, but that file is outside this pass's write glob. The shared scan machinery was therefore written to `tests/cases/lib/static-scan.sh`. It is never run as a case, because `run.sh` runs `tests/cases/*.sh` only.
  - Task 5.2's `shellcheck … tests/cases/*.sh` does not reach it, and the cases disable SC1091 for the dynamic `source`. It was checked clean with an explicit path: `shellcheck tests/cases/*.sh tests/cases/lib/static-scan.sh` passes.
  - Moving it into `tests/lib.sh` is the maintainer's call.
  - Depends on it: all ten `backlog-skill-*` cases.
- **Q3. Placement of the fragment sentence.**
  - Assumption: per `design.md` decision 3 ("appended to **archive**") and one-paragraph-per-line, the re-read sentence shares a line with the archive step, so that line contains `archive`.
  - Depends on it: `workflow-fragment-archive-backlog-reread`, `workflow-fragment-archive-reread-names-no-field`.
- **Q4. No per-case runner selection.** `tests/run.sh` runs every case and has no filter, so the single-case invocation above is the selection form. Assumption: that form is acceptable to the project.
- **Q5. Script preamble.** The `bash` skill asks for `set -euo pipefail`, but no existing case uses it. The new cases follow the project's convention and do not use it either. This conflict is reported, not resolved.
- **Q6. Stack skill.** The library carries `bash`, which was loaded for the cases. It has no skill specific to static checks over markdown assets, so those cases rest on the `testing` floor plus repository precedent (`testing-skill-*.sh`, `workflow-fragment-*.sh`).

## Notes for the implementation step

- **Changes required to make the 15 new cases pass:**
  - Replace the heredoc with `design.md` decision 2's text. That satisfies the four `backlog-seeded-*` cases (all phrases verified present).
  - Append decision 3's sentence to the archive step, on the archive step's own line.
  - Write `skills/backlog/SKILL.md` with one heading per operation, and `references/audit.md`.
- **Writing the forbidden sources and phrases in SKILL.md:**
  - Phrasing that rules out the branch diff stays free, because it is not scanned.
  - Phrasing an audit interval in any scanned form fails `backlog-skill-no-audit-cadence`, even when the interval is offered only as a suggestion.
- **Task 1.2's edit of obsolete tests:** it should act only on the confirmed entries above.
