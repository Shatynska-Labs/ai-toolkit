# Test plan: match-backlog-entries-to-a-workstream

Run a case with `bash tests/run.sh <case>`, from the working tree root. Every name below is such a case, without its `.sh`.

## Baseline

Full, taken before any test was written, at `bd3929c`: `bash tests/run.sh` gave 645 passed, 0 failed, in 4m49s. All 14 cases below are new, so any other failure after implementation comes from the change or from a test listed as obsolete.

`shellcheck tests/*.sh tests/cases/*.sh tests/cases/lib/*.sh` exits 1 on findings already in `tests/task-board-lib.sh` and nine `task-board-*` cases, none written here. The 14 new cases are clean. Task 4.2 cannot pass as written until those are dealt with.

## New cases and what each must see

All 14 fail today. For each, the discriminators ran and passed, so the run reached the real target and failed there. A forbid scan that already holds is marked as passing; each has a mutant that fails it.

| Case | Task | Red at authoring on | Passing today |
|---|---|---|---|
| `backlog-block-none-ends-a-search` | 1.1 | `read-every-open`, `takes-served`, `none-after`, `not-in-scope` | none |
| `workstreams-block-placing-settled` | 1.2 | every scan but the one passing | `latest-at-archive` |
| `workstreams-block-archive-detaches` | 1.2 | `step-entry-detached`, `entries-by-detaching`, `no-unexamined-none` | none |
| `workflow-fragments-archive-names-unplaced` | 1.3 | `names-unplaced`, `not-attached`, in both fragments | `no-field` |
| `workflow-fragments-record-binding` | 1.3 | paragraph absent (state 2) and `placement`, in both fragments | none |
| `workflow-fragments-sweep-binding` | 1.3 | paragraph absent (state 2) and `placement`, in both fragments | none |
| `workflow-fragments-binding-restates-no-rule` | 1.3 | paragraph absent (state 2), in both fragments | none |
| `rules-changelog-placement-records` | 1.4 | `record` | none |
| `backlog-skill-record-reads-goals` | 2.1 | all six scans | none |
| `backlog-skill-record-places-entry` | 2.1 | the four require scans | `not-the-others` |
| `backlog-skill-sweep-unplaced` | 2.1 | all seven scans | none |
| `backlog-skill-sweep-detaches-by-read` | 2.1 | all three scans | none |
| `backlog-skill-workstreams-names-a-step` | 2.1 | `by-the-rule` | `not-restated` |
| `backlog-skill-description-follow-ups` | 2.2 | the three phrases, `follow-ups-fixture`, `too-long` (1,062 characters) | angle-bracket check |

The red runs above are the record that each check discriminates on real content. The fixtures stay in the suite as the lasting discriminators. The three state-2 cases have never exercised their scans on real content: only their fixtures have.

## Scenarios

79 scenarios in the delta specs, all accounted for here: 32 in `backlog-maintenance`, 38 in `project-bootstrap`, 9 in `session-workflow`. None is uncovered. 20 are added or revised and take new cases; 59 are unchanged and stay with the existing cases named.

A scan shows that a text directs an act, never that a session does it. "Mechanical half" below means the rest is conduct, recorded under *Deliberately untested*.

### backlog-maintenance

| Scenario | State | Cases |
|---|---|---|
| A name already used by an archived change | unchanged | `backlog-skill-record`, `backlog-skill-dir-record-file` |
| Record refuses a name colliding with the rules' files | unchanged | `backlog-skill-record-refuses-agents-claude` |
| An overlapping entry exists | unchanged | `backlog-skill-record`, `backlog-skill-record-absent-value`, `backlog-skill-dir-record-names-and-conditions` |
| Work the change can fold in | unchanged | `backlog-skill-record-fold-in` |
| Record defaults Priority | unchanged | `backlog-skill-record-priority` |
| Record parks an entry only on the operator's word | unchanged | `backlog-skill-record-priority`, `backlog-skill-dir-record-names-and-conditions` |
| Record carries the change's workstream | revised | `backlog-skill-record-reads-goals` (mechanical half), `backlog-skill-record-absent-value` |
| Record refuses a workstream that is not open | unchanged | `backlog-skill-record-absent-value` |
| Record keeps a condition out of waits_on | unchanged | `backlog-skill-dir-record-names-and-conditions` |
| Record writes one file | revised | `backlog-skill-record-places-entry` (`one-other-file`), `backlog-skill-dir-record-file` |
| An entry the change's workstream rules out finds another | added | `backlog-skill-record-reads-goals` (mechanical half) |
| The absent value follows the read | added | `backlog-skill-record-reads-goals` (mechanical half) |
| A recorded entry is placed or left with a reason | added | `backlog-skill-record-places-entry` (mechanical half) |
| Placing one entry owes nothing for the others | added | `backlog-skill-record-places-entry` (`not-the-others`), `workstreams-block-placing-settled` (`others-not-due`) |
| An entry finished without being named | unchanged | `backlog-skill-sweep` |
| Sweep after a squash merge | unchanged | `backlog-skill-sweep` |
| Sweep after the record has landed | unchanged | `backlog-skill-sweep` |
| A change fulfils a parked entry's condition | unchanged | `backlog-skill-sweep-priority`, `backlog-skill-dir-sweep-keys` |
| A change removes a high entry's evidence | unchanged | `backlog-skill-sweep-priority` |
| Entries naming a workstream being archived | revised | `backlog-skill-sweep-detaches-by-read` (mechanical half), `backlog-skill-sweep-workstream`, `backlog-skill-sweep-absent-value` |
| An entry waiting on the swept change | unchanged | `backlog-skill-dir-sweep-keys` |
| An entry naming the open workstream that no step names | added | `backlog-skill-sweep-unplaced` (mechanical half) |
| An entry falling outside its workstream is re-pointed | added | `backlog-skill-sweep-detaches-by-read` (mechanical half), `workstreams-block-placing-settled` (`detach-repoints`, `clears-last`) |
| An entry the change recorded is not yet on the trunk | added | `backlog-skill-sweep-unplaced` (`working-tree`, `own-entries`; mechanical half) |
| A step's status comes from the repository | unchanged | `backlog-skill-workstreams-operation`, `backlog-skill-dir-workstreams-entry-files` |
| A step in two sources | unchanged | `backlog-skill-workstreams-operation` |
| The next step is named | unchanged | `backlog-skill-workstreams-operation` |
| A waiting step is not next | unchanged | `backlog-skill-dir-workstreams-entry-files` |
| Every step done | unchanged | `backlog-skill-workstreams-operation` |
| Unplaced entries are shown | unchanged | `backlog-skill-workstreams-operation` |
| A change opened under another name is surfaced | unchanged | `backlog-skill-workstreams-operation` |
| A mention in a step's description is not a step | added | `backlog-skill-workstreams-names-a-step` (mechanical half), `workstreams-block-placing-settled` (`mention-places-nothing`) |

### project-bootstrap

| Scenario | State | Cases |
|---|---|---|
| A project without a workstream register receives the seeded file | revised statements | `workstreams-block-placing-settled`, `workstreams-block-archive-detaches`, `workstreams-seeded-statements`, `workstreams-seeded-new-project` |
| An existing workstream register is preserved exactly | unchanged | `workstreams-block-existing-preserved` |
| The seeded register carries no status field | unchanged | `workstreams-seeded-shape-sections-no-status`, `workstreams-seeded-no-status-field` |
| An abandoned workstream is archived, not deleted | revised statement | `workstreams-seeded-abandoned`, `workstreams-block-archive-detaches` |
| A finished workstream is archived | revised statement | `workstreams-seeded-archive-on-done`, `workstreams-block-archive-detaches` |
| A step matching two sources takes the first status | unchanged | `workstreams-seeded-precedence` |
| Step order is not a dependency | unchanged | `workstreams-dir-order-names-waits-on` |
| The seeded workstream's fields are a list | unchanged | `workstreams-seeded-fields-list-then-sections`, `workstreams-seeded-fields-are-a-list` |
| A step is recorded by its entry file | unchanged | `workstreams-dir-step-recorded-by-entry-file` |
| Done when asks for an observable effect of the Goal | unchanged | `workstreams-seeded-done-when-step-done-shape`, `workstreams-seeded-done-when-step-done-statement`, `workstreams-seeded-done-when-shape`, `workstreams-seeded-done-when-statement` |
| Research shared by several steps has a place in the workstream | unchanged | `workstreams-seeded-shared-research-placed` |
| A decision for one step stays in that step's design | unchanged | `workstreams-seeded-one-step-decision-in-design` |
| What a workstream holds is not progress | unchanged | `workstreams-seeded-holds-not-progress` |
| Overturned content is revised in place | unchanged | `workstreams-seeded-overturned-revised-in-place` |
| A step taken as a fix reads as done | unchanged | `workstreams-seeded-fix-step-done` |
| A change whose work has merged is still in flight | unchanged | `workstreams-seeded-merged-change-in-flight` |
| A fix step without the forge | unchanged | `workstreams-seeded-forge-unreachable` |
| A change needed by two workstreams is listed in one | unchanged | `workstreams-seeded-one-workstream-per-change` |
| The seeded block settles what placing means | added | `workstreams-block-placing-settled` |
| A project without a backlog receives the seeded file | revised statement | `backlog-block-none-ends-a-search`, `backlog-dir-seeded-new-project`, `backlog-block-new-project` |
| An existing backlog is preserved exactly | unchanged | `backlog-block-existing-preserved` |
| The seeded file carries no numbering | unchanged | `backlog-dir-seeded-no-entry-numbering` |
| The seeded entry shape carries the structured fields | unchanged | `backlog-dir-seeded-structured-keys` |
| A fix is distinguished from a change by what it owes | unchanged | `backlog-dir-seeded-kind-definition` |
| Priority's values and default are stated | unchanged | `backlog-dir-seeded-priority-values` |
| The seeded file offers no low priority | unchanged | `backlog-dir-seeded-priority-no-low` |
| The seeded file states how an entry leaves parked and high | unchanged | `backlog-dir-seeded-priority-transitions` |
| Workstream's default is stated | unchanged | `backlog-dir-seeded-workstream-default` |
| The seeded entry's fields are a list | unchanged | `backlog-dir-seeded-fields-are-a-list` |
| An absent value reads as its field | unchanged | `backlog-dir-seeded-absent-values` |
| A single-file backlog is pointed to the migration tool | unchanged | `backlog-dir-single-file-pointed-to-migrate` |
| A missing backlog fragment blocks every run | unchanged | `backlog-fragment-absent-blocks-every-run` |
| The rules are added beside existing entries | unchanged | `backlog-block-beside-existing-entries` |
| Project text beside the block survives | unchanged | `backlog-block-project-text-survives` |
| A backlog path that is not a directory is not written through | unchanged | `backlog-dir-not-a-directory-not-written-through` |
| Waits on holds only names | unchanged | `backlog-dir-seeded-waits-on-names-only` |
| The frontmatter is flat | unchanged | `backlog-dir-seeded-frontmatter-flat` |
| The seeded block makes `none` the end of a search | added | `backlog-block-none-ends-a-search` |

### session-workflow

| Scenario | State | Cases |
|---|---|---|
| A proposal in a workstream names it | unchanged | `workflow-fragment-draft-names-workstream` |
| A proposal in no workstream says so | unchanged | `workflow-fragment-draft-names-workstream` |
| A workstream is proposed, not opened | unchanged | `workflow-fragment-draft-names-workstream` |
| Derived work is attached by the backlog's rule, not the fragment's | unchanged | `workflow-fragment-backlog-dir-routing-names-no-workstream`, `workflow-fragment-defers-to-directory-agents-md` |
| Archiving the last step archives the workstream | unchanged | `workflow-fragment-archive-workstream-reread`, `workflow-fragment-defers-to-directory-agents-md` |
| The fragment defers the workstream rules to the README | unchanged | `workflow-fragment-defers-to-directory-agents-md`, `workflow-fragment-workstream-rules-not-restated` |
| The archive re-read names the entries no step names | added | `workflow-fragments-archive-names-unplaced` |
| Both bindings name a shipped skill | added | `workflow-fragments-record-binding`, `workflow-fragments-sweep-binding` |
| A binding restates no entry rule | added | `workflow-fragments-binding-restates-no-rule` |

The operations under the delta are all `MODIFIED` or `ADDED`. There is no `REMOVED` or `RENAMED` delta, so no scenario is uncovered by operation.

## Assertion classification

**Specified**, tracing to a delta requirement's statement or scenario:

- `backlog-block-none-ends-a-search`: the sense of all four scans.
- `workstreams-block-placing-settled`: the sense of all nine scans.
- `workstreams-block-archive-detaches`: `step-entry-detached`, `entries-by-detaching`.
- `backlog-skill-record-reads-goals`: the sense of the five require scans.
- `backlog-skill-record-places-entry`: the sense of the four require scans.
- `backlog-skill-sweep-unplaced`: the sense of all seven scans.
- `backlog-skill-sweep-detaches-by-read`: the sense of all three scans.
- `backlog-skill-workstreams-names-a-step`: `by-the-rule`.
- `workflow-fragments-archive-names-unplaced`: `names-unplaced`, `no-field`, and both forms.
- `workflow-fragments-record-binding`, `workflow-fragments-sweep-binding`: the binding, its operation, both forms, and `skills/backlog/SKILL.md` being shipped.
- `workflow-fragments-binding-restates-no-rule`: `names-operation`, `no-entry-field`.

**Specified by proposal or design, with no delta scenario:**

- `backlog-skill-description-follow-ups`: the description is at most 1,024 characters and holds no angle bracket (proposal, tasks 2.2), and carries the phrases and the fixture (decision 6).
- `rules-changelog-placement-records`: one record per fragment, none with an `ask` (decision 8).

**Derived**, reviewable as such:

- The wording of every scan above. The specs fix what is stated, and each scan pins one phrase of `design.md`'s text. A rewording that keeps the sense fails here, so a change to the wording is a change to a derived assertion.
- `workstreams-block-archive-detaches`: `no-unexamined-none`, that the superseded phrase is gone.
- `backlog-skill-record-reads-goals`: `no-session-word`, that the superseded trigger is gone (decision 1).
- `backlog-skill-record-places-entry`: `not-the-others`, reading "for that entry alone" as the section directing nothing about other unplaced entries.
- `backlog-skill-workstreams-names-a-step`: `not-restated`, by the phrase `backticked name` (decision 4 says the skill does not restate the rule).
- `workflow-fragments-archive-names-unplaced`: `not-attached`, and selecting the paragraph by `docs/workstreams/AGENTS.md` and `advanced`, as `workflow-fragment-archive-workstream-reread` does.
- `workflow-fragments-record-binding`, `workflow-fragments-sweep-binding`: `placement`, reading "under" and "at" as after the anchor paragraph with no bold-led paragraph or heading between. The sweep binding's `entries-part` and `of-the-reread` are also derived wording.
- `backlog-skill-description-follow-ups`: a character is a code point, and the section under a heading naming `trigger`.
- Structure: the skill's operations sit under headings naming `record`, `sweep` and `workstreams`, as the existing `backlog-skill-*` cases assume.

**Deliberately untested:**

- **Whether a session really reads the Goals before writing `none`.** This is the change's first goal, and it is conduct. A scan shows the rule and the skill direct the read, never that a session made it, or judged rightly which Goal an entry serves. The same holds for a session writing by hand. The test of it is what happens in a project, as the operator noticed in commerce-ops.
- Whether record places an entry, asks for the position, and says its reason; whether it edits only the files it may; whether it asks where more than one Goal is served. Conduct.
- Whether sweep finds and presents unplaced entries, reads the working tree, or proposes the right workstream. Conduct.
- Whether workstreams lists a mentioned entry as unplaced on a real repository. The skill has no code to run; `scripts/task-board` has its own reading, which this change does not touch.
- Whether sessions use the bindings, and that revising steps and archiving a workstream stay the session's, which the sweep binding's "the entries' part" only implies.
- The trigger behaviour of the description: task 2.2's `create-skill` trigger check holds it.
- Tasks 3.1, 3.2 and the `docs/workstreams/complete-the-workstream-loop.md` step. The plugin's rise is held by `plugin-version-rise-checks-this-repository`, a fragment's rise having a record by `rules-changelog-version-rise-recorded`, and this repository's blocks by running `scripts/project-update`.
- The goal "an entry naming an open workstream is a step, or is shown as not yet one": the design makes a deterministic check a non-goal.

## Obsolete tests

Both are candidates for human confirmation, not conclusions. Neither was edited. Task 3.3 retires them. Both will fail once tasks 1.2 and 1.3 land.

| Test | Superseding delta | Evidence | Status |
|---|---|---|---|
| `workstreams-seeded-statements`, line 67: `assert_contains "$r" "backlog entry naming no workstream"` | `project-bootstrap`, *A workstream register is seeded where none exists*: the step "first recorded as a backlog entry detached from it" (design decision 2) | The asserted phrase is the one the delta replaces. Only this case pins it. | candidate for human confirmation |
| `manifest-alternative-and-versions`: `check`'s `[direct-version]` (line 85) and `[full-version]` (line 86), with `mkroot`'s fixture versions and mutants `h` and `i` (lines 117, 118) | `session-workflow`, both fragments changed (design decision 8): `development-workflow` to `2.1.0`, `development-workflow-direct` to `1.1.0` | The case compares the shipped versions with `2.0.0` and `1.0.0`. Mutant `h` sets `1.1.0`, the version the change ships. | candidate for human confirmation |

Keep `[since]` in the second: `alternative_since` stays `2.0.0`, so that assertion still holds.

The search covered `tests/cases/*.sh`, by the phrases the deltas replace and by what the design text drops or changes. It found no other test whose assertion the change breaks, which means none was found by this search, not that none exists. It was made without reading the implementation, so a test failing after task 1 or 2 should be read against this list first.

These bear on the change and need no action on their assertions:

- `backlog-skill-record-absent-value`: its header and fixture describe the old default, and its scans still hold on decision 3's text.
- `workflow-fragment-archive-workstream-reread`: its header and fixture say "attached to it", and its scans still hold.
- `backlog-dir-seeded-workstream-default`, `backlog-skill-sweep-workstream`, `backlog-skill-sweep-absent-value`: the phrases they pin are kept by decisions 1 and 4.
- `workflow-fragment-backlog-dir-archive-reread`: it forbids naming the skill on the re-read paragraph. The binding must stay its own paragraph, as decision 5 has it.

No earlier `test-plan.md` was dispatched, so none was used as a mapping.

## Unresolved project questions

1. **One case per scenario, or several scenarios in one case.** The suite does both. Assumption: scenarios sharing one passage share a case, and a scan's tag names which scenario half it holds. Depends on it: the three `backlog-skill-record-*` and `backlog-skill-sweep-*` multi-scenario cases.
2. **What ends the paragraph an anchor governs in a fragment.** I did not read the fragments. Assumption: the next line opening with `**` or `#`. If the workstream re-read paragraph opens in bold, the sweep binding must stand before it for `workflow-fragments-sweep-binding` to pass. Depends on it: `workflow-fragments-record-binding`, `workflow-fragments-sweep-binding`.
3. **How `create-skill` counts its 1,024 characters.** Assumption: code points, which reproduces the design's figures of 1,062 for the current description and 1,016 for the new one. Depends on it: `backlog-skill-description-follow-ups`.

The dispatch named the shared arrangement, and no stack skill was missing: `testing` and `bash` both loaded.

## Missing shared arrangement

The dispatch named `tests/lib.sh`, `tests/cases/lib/static-scan.sh` and `tests/cases/lib/line-scan.sh`. None was edited. Five local declarations:

### `seed_and_check`

- **Declared in:** `backlog-block-none-ends-a-search.sh`, `workstreams-block-placing-settled.sh`, `workstreams-block-archive-detaches.sh`.
- **Stands in for:** running static scans over the tree `project-init` writes.
- **Tests:** those three cases.
- **Near-miss:** `scan_run` in `static-scan.sh`, which checks `$TOOLKIT_ROOT` only, not a seeded tree.
- **Found in test module:** `backlog-dir-seeded-workstream-default.sh` and its neighbours.
- **Proposed home:** `tests/cases/lib/static-scan.sh`, as `scan_run_seeded`.

### `check_both_forms`

- **Declared in:** `workflow-fragments-archive-names-unplaced.sh`, `workflow-fragments-record-binding.sh`, `workflow-fragments-sweep-binding.sh`, `workflow-fragments-binding-restates-no-rule.sh`.
- **Stands in for:** holding one set of line scans over both workflow fragments.
- **Tests:** those four cases.
- **Near-miss:** `line_run` in `line-scan.sh`, which reads one file and exits the case.
- **Found in test module:** no.
- **Proposed home:** `tests/cases/lib/line-scan.sh`, as a `line_run` taking several files.

### `binding_under`

- **Declared in:** `workflow-fragments-record-binding.sh`, `workflow-fragments-sweep-binding.sh`.
- **Stands in for:** reading where a paragraph sits relative to an anchor paragraph.
- **Tests:** those two cases.
- **Near-miss:** `prose_line` in `tests/lib.sh`, which finds a line and says nothing of what lies between two.
- **Found in test module:** no.
- **Proposed home:** `tests/lib.sh`.

### `description_value`, `description_check`, `specimen_with`, `expect_rejected`

- **Declared in:** `backlog-skill-description-follow-ups.sh`.
- **Stands in for:** measuring a skill's description and rejecting an angle bracket in it.
- **Tests:** `backlog-skill-description-follow-ups`.
- **Near-miss:** a forbid scan on `@description` in `static-scan.sh`: `scan_mutate` appends its specimen after the frontmatter, so its mutant cannot trip it. `scan_description` itself is reused.
- **Found in test module:** no.
- **Proposed home:** `tests/cases/lib/static-scan.sh`, for `description_value` and `description_check`; the other two stay local.

### `changelog_records`, `check`, `record`, `expect`

- **Declared in:** `rules-changelog-placement-records.sh`.
- **Stands in for:** reading `rules/changelog`'s records, with the count of each one's `ask` lines.
- **Tests:** `rules-changelog-placement-records`.
- **Near-miss:** none in the shared arrangement.
- **Found in test module:** `rules-changelog-version-rise-recorded.sh` holds a `changelog_records` without the `ask` count, and the same `record` and `expect` shape.
- **Proposed home:** `tests/lib.sh`, for `changelog_records`; the rest stay local.

## Disposition of the local declarations

All five are **kept** local, for one reason: this repository's conventions record no location for a shared arrangement, and the entry `record-this-repositorys-shared-test-arrangement` is where that decision belongs, not this change.

## Retired

Both obsolete assertions were dealt with in task 3.3. `manifest-alternative-and-versions` loses `[direct-version]`, `[full-version]` and mutants `h` and `i`, keeping `[since]`. `workstreams-seeded-statements` asserts "backlog entry detached from it" in place of "backlog entry naming no workstream".
