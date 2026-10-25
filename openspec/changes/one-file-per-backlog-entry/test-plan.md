# Test plan: one-file-per-backlog-entry

Derived by `ai-toolkit:change-test-writer` from the delta specs of plan commit 5f540a0, before implementation. This file is not an artifact the OpenSpec schema knows about: `openspec instructions apply` will not list it, so read it on purpose before implementing.

## How to run a single case

`tests/run.sh` runs every case and has no selector. One case runs on its own, from the worktree root, as:

```
TOOLKIT_ROOT=$PWD TESTLIB=$PWD/tests/lib.sh PROJECT_INIT=$PWD/scripts/project-init TESTDIR=$(mktemp -d) bash tests/cases/<case>.sh
```

Every test below is named by its file under `tests/cases/`, which is the unit the runner selects.

## Baseline

Full suite, `bash tests/run.sh`, at 5f540a0 with a clean tree, before any case was written: **192 passed, 0 failed**.

After this pass: **192 passed, 65 failed**. All 65 failures are the new cases, and every one fails on its own check. None fails on its discriminator. Each fails for one of these reasons:

- the target is absent (state 2): `scripts/backlog-migrate`, `scripts/seed/backlog-README.md` or `docs/backlog/README.md` does not exist yet, or no paragraph names `docs/backlog/` or `scripts/seed/`;
- the current text or behaviour asserts the superseded shape (state 1): for example, the fragment version is 11, and project-init reports `backlog: already present` for a single file.

The obsolete cases listed below still pass. They will fail as the implementation lands.

## What the implementation must make pass, by task

| Task | Cases that must go from failing to passing |
|---|---|
| 1.0 | `toolkit-structure-seed-has-one-home.sh` |
| 1.1, 1.2 | `backlog-dir-seeded-new-project.sh`, `backlog-dir-seeded-adoption.sh`, `backlog-dir-seed-is-the-shared-file.sh`, `backlog-dir-existing-preserved.sh`, `backlog-dir-seeded-no-entry-numbering.sh`, `backlog-dir-seeded-structured-keys.sh`, `backlog-dir-seeded-kind-definition.sh`, `backlog-dir-seeded-priority-values.sh`, `backlog-dir-seeded-priority-no-low.sh`, `backlog-dir-seeded-priority-transitions.sh`, `backlog-dir-seeded-workstream-default.sh`, `backlog-dir-seeded-fields-are-a-list.sh`, `backlog-dir-seeded-absent-values.sh`, `backlog-dir-seeded-waits-on-names-only.sh`, `backlog-dir-seeded-frontmatter-flat.sh`, `backlog-dir-single-file-pointed-to-migrate.sh`, `backlog-dir-missing-seed-blocks-outstanding.sh`, `backlog-dir-readme-beside-entries.sh`, `backlog-dir-not-a-directory-not-written-through.sh` |
| 1.3 | `workstreams-dir-step-recorded-by-entry-file.sh`, `workstreams-dir-order-names-waits-on.sh` |
| 2.1 | `backlog-migrate-converts.sh`, `backlog-migrate-readme-is-seeded.sh` (also needs 1.1, 1.2), `backlog-migrate-commits-nothing.sh`, `backlog-migrate-blocks-uncommitted-edit.sh`, `backlog-migrate-blocks-existing-directory.sh`, `backlog-migrate-blocks-heading-not-name.sh`, `backlog-migrate-blocks-readme-entry.sh`, `backlog-migrate-blocks-preconditions.sh`, `backlog-migrate-fenced-example-not-entry.sh`, `backlog-migrate-preamble-sections.sh`, `backlog-migrate-write-failure.sh`, `backlog-migrate-readme-from-own-copy.sh`, `backlog-migrate-older-bash.sh` |
| 2.2 | `backlog-migrate-list-and-paragraph-alike.sh`, `backlog-migrate-parked.sh`, `backlog-migrate-wait-on-change-and-answer.sh`, `backlog-migrate-spec-name-not-a-wait.sh`, `backlog-migrate-waits-on-nothing-note.sh`, `backlog-migrate-unknown-field-kept.sh`, `backlog-migrate-no-kind.sh`, `backlog-migrate-absent-values-normalised.sh`, `backlog-migrate-report-condition.sh` |
| 3.1 | `workflow-fragment-backlog-dir-path.sh`, `workflow-fragment-backlog-dir-routing-owed.sh`, `workflow-fragment-backlog-dir-readme-states-rules.sh`, `workflow-fragment-backlog-dir-defers.sh`, `workflow-fragment-backlog-dir-handoff.sh`, `workflow-fragment-backlog-dir-archive-reread.sh`, `workflow-fragment-backlog-dir-apply-pickup.sh`, `workflow-fragment-backlog-dir-routing-names-no-workstream.sh`, `workflow-fragment-version-after-backlog-dir.sh`. The existing `inlined-body-matches-fragment.sh` must stay green. |
| 3.2, 3.3 | `backlog-skill-dir-identity.sh`, `backlog-skill-dir-single-file-refused.sh`, `backlog-skill-dir-absent-backlog.sh`, `backlog-skill-dir-reads-readme.sh`, `backlog-skill-dir-record-file.sh`, `backlog-skill-dir-record-names-and-conditions.sh`, `backlog-skill-dir-pick-wait.sh`, `backlog-skill-dir-close-file.sh`, `backlog-skill-dir-sweep-keys.sh`, `backlog-skill-dir-audit-names.sh` (3.3 for its audit.md half), `backlog-skill-dir-older-shape-missing-key.sh`, `backlog-skill-dir-workstreams-entry-files.sh` |

Tasks 2.3, 3.4 and 4.x–6.x are verified by reading or by commands the tasks name. This pass derives no case for them.

## Scenario accounting

The delta specs have 133 scenarios: backlog-migration 22, toolkit-structure 8, project-bootstrap 26, session-workflow 24 and backlog-maintenance 53. **124 are covered** and **9 are uncovered**, each with its reason.

"In part" marks a scenario whose case reads the stated text, not a session's conduct. That is the limit the suite already records for the skill and the fragment in `tests/coverage.md`.

Each case's own header states which of its assertions are **specified** and which are **derived**, with the reason. The labels in the tables below summarise those headers.

### backlog-migration (ADDED, 22)

| Scenario | Covered by | Classification |
|---|---|---|
| A backlog is converted | `backlog-migrate-converts.sh` | Specified: files, deletion, nothing else written, SUCCESS and exit 0. Derived: the run comes from another working directory, which tests the explicit target. |
| The README is the seeded one | `backlog-migrate-readme-is-seeded.sh` | Specified: byte-equal to project-init's README and to the seed. Derived: the report names `preamble`. |
| The tool commits nothing | `backlog-migrate-commits-nothing.sh` | Specified. Derived: HEAD, commit count and `git diff --cached` are the operationalisation. |
| An uncommitted edit blocks | `backlog-migrate-blocks-uncommitted-edit.sh` | Specified: both the working-tree edit and the index edit, exit 2 and nothing written. |
| A converted backlog is not converted twice | `backlog-migrate-blocks-existing-directory.sh` | Specified: covers a directory and a symbolic link. Derived: the report carries `docs/backlog`. |
| A heading that is not a name blocks | `backlog-migrate-blocks-heading-not-name.sh` | Specified. |
| The seeded preamble's example is not an entry | `backlog-migrate-fenced-example-not-entry.sh` | Specified. Derived fixture: the old preamble shape is written here, because this pass cannot read the old file. |
| A preamble with sections of its own | `backlog-migrate-preamble-sections.sh` | Specified. Derived: no file is written for the preamble heading. |
| An entry named readme blocks | `backlog-migrate-blocks-readme-entry.sh` | Specified. Derived: the lowercase word `readme` appears in the report. |
| A failed write leaves the old file | `backlog-migrate-write-failure.sh` (in part) | Specified: ERROR, exit 1, nothing left behind. Derived mechanism: making `docs/` unwritable fails the *first* write, not a write partway through (Q6). |
| A listed and a paragraph entry convert alike | `backlog-migrate-list-and-paragraph-alike.sh` | Specified. Derived: compares identical frontmatter blocks. |
| A parked entry | `backlog-migrate-parked.sh` | Specified: exact values. |
| A wait on a change and on an answer | `backlog-migrate-wait-on-change-and-answer.sh` | Specified: `waits_on`, and `waits_for` double-quoted. Derived tolerance: backticks inside `waits_for` are not asserted. |
| A specification's name is not a wait | `backlog-migrate-spec-name-not-a-wait.sh` | Specified. Derived: the spec directory exists, and `waits_on` may be absent or `[]`. |
| Waits on nothing with a note | `backlog-migrate-waits-on-nothing-note.sh` | Specified. Derived: the note is a body item beginning `- **Waits on**:` (design.md decision 4). |
| An unknown field is kept | `backlog-migrate-unknown-field-kept.sh` | Specified. Derived: an exact body line, and no key is made from the field. |
| An entry with no Kind | `backlog-migrate-no-kind.sh` | Specified: no `kind`, `priority` or `workstream` key, and `waits_on` holds the known name. Derived: the report names the entry and `kind` on one line (Q3). |
| Earlier absent values are normalised | `backlog-migrate-absent-values-normalised.sh` | Specified. |
| A written condition is reported | `backlog-migrate-report-condition.sh` | Specified. Derived: one line (Q3). |
| A kept note is reported | `backlog-migrate-waits-on-nothing-note.sh` | Specified. Derived: one line (Q3). |
| The README comes from the tool's own copy | `backlog-migrate-readme-from-own-copy.sh` | Specified. Derived: the decoy variables are `AI_TOOLKIT_ROOT`, `CLAUDE_PLUGIN_ROOT` and `TOOLKIT_ROOT`. |
| An older bash | `backlog-migrate-older-bash.sh` (in part) | Specified: the shebang. Derived proxy: a static scan for constructs bash 3.2 lacks, discriminated on specimens. The run half executes only where a bash 3.2 exists. **None exists here, so that half has not been executed** (Q7). |

`backlog-migrate-blocks-preconditions.sh` covers no scenario of its own. It covers requirement text under *Every run ends in one of three outcomes*, all specified: BLOCKED when there is no git repository, no file, an untracked file, a symbolic-link file, a duplicate name, or a missing seed.

### toolkit-structure (MODIFIED, 8)

| Scenario | Covered by |
|---|---|
| A text two tools write has one home | `toolkit-structure-seed-has-one-home.sh`. Specified: `scripts/seed/` is named, and the reason it is not `rules/` is given. Derived: the reason is found by the words `rules/`, `frontmatter` and verbatim or byte-for-byte on one paragraph. |
| Claude Code picks up conventions | Uncovered, carried over unchanged: repository layout and documentation content, not exercised by `tests/cases/` (`tests/coverage.md`, toolkit-structure). |
| Layout constraint is explained, not just stated | Uncovered, carried over (same reason). |
| Library assets are distinguished from repository tooling | Uncovered, carried over (same reason). |
| Authoring guidance is not duplicated into conventions | Uncovered, carried over (same reason). |
| A deterministic operation is placed in shipped tooling | Uncovered, carried over (same reason). |
| Shipped tooling is distinguished from repository helpers | Uncovered, carried over (same reason). |
| Shipped tooling is not mistaken for an asset | Uncovered, carried over (same reason). The seed carries no frontmatter of its own, which `backlog-dir-seed-is-the-shared-file.sh` reaches only indirectly. |

### project-bootstrap (MODIFIED, 26)

*A backlog is seeded where none exists* (17):

| Scenario | Covered by |
|---|---|
| A project without a backlog receives the seeded file | `backlog-dir-seeded-new-project.sh`, `backlog-dir-seeded-adoption.sh`, `backlog-dir-seed-is-the-shared-file.sh` |
| An existing backlog is preserved exactly | `backlog-dir-existing-preserved.sh`. It also carries the repeat half of the superseded `repeated-execution-backlog.sh`. |
| The seeded file carries no numbering | `backlog-dir-seeded-no-entry-numbering.sh` |
| The seeded entry shape carries the structured fields | `backlog-dir-seeded-structured-keys.sh` |
| A fix is distinguished from a change by what it owes | `backlog-dir-seeded-kind-definition.sh` |
| Priority's values and default are stated | `backlog-dir-seeded-priority-values.sh` |
| The seeded file offers no low priority | `backlog-dir-seeded-priority-no-low.sh` |
| The seeded file states how an entry leaves parked and high | `backlog-dir-seeded-priority-transitions.sh` |
| Workstream's default is stated | `backlog-dir-seeded-workstream-default.sh` |
| The seeded entry's fields are a list | `backlog-dir-seeded-fields-are-a-list.sh` |
| An absent value reads as its field | `backlog-dir-seeded-absent-values.sh` |
| A single-file backlog is pointed to the migration tool | `backlog-dir-single-file-pointed-to-migrate.sh` |
| A missing seed blocks only an outstanding backlog | `backlog-dir-missing-seed-blocks-outstanding.sh` |
| A README is added beside existing entries | `backlog-dir-readme-beside-entries.sh` |
| A backlog path that is not a directory is not written through | `backlog-dir-not-a-directory-not-written-through.sh` |
| Waits on holds only names | `backlog-dir-seeded-waits-on-names-only.sh` |
| The frontmatter is flat | `backlog-dir-seeded-frontmatter-flat.sh` |

Classification:

- **Specified** — file presence and absence, byte-for-byte checks, and exit codes.
- **Derived**:
  - every README text pattern, which reads a statement by one tolerant pattern, as earlier passes did with phrases;
  - the fenced-example shape (Q1);
  - the report tokens beyond the contract's `created` and `already present` (Q2).
- **Deliberately untested** — "the README SHALL NOT number entries" beyond headings and the word `number`, as before.

*A workstream register is seeded where none exists* (9):

| Scenario | Covered by |
|---|---|
| A project without a workstream register receives the seeded file | Existing `workstreams-seeded-new-project.sh`, `workstreams-seeded-adoption.sh` and `workstreams-seeded-statements.sh`. The last is an obsolete candidate for one phrase, below. `workstreams-dir-step-recorded-by-entry-file.sh` covers the revised statement. |
| An existing workstream register is preserved exactly | Existing `workstreams-existing-preserved.sh`, `workstreams-dangling-symlink-not-written-through.sh` (unchanged) |
| The seeded register carries no status field | Existing `workstreams-seeded-no-status-field.sh` (unchanged) |
| An abandoned workstream is archived, not deleted | Existing `workstreams-seeded-abandoned.sh`, `workstreams-seeded-abandoned-item.sh` (unchanged) |
| A finished workstream is archived | Existing `workstreams-seeded-archive-on-done.sh` (unchanged) |
| A step matching two sources takes the first status | Existing `workstreams-seeded-precedence.sh` (unchanged) |
| Step order is not a dependency | `workstreams-dir-order-names-waits-on.sh`. Specified: `waits_on`. Derived: on the "gates nothing" line. |
| The seeded workstream's fields are a list | Existing `workstreams-seeded-fields-are-a-list.sh` (unchanged) |
| A step is recorded by its entry file | `workstreams-dir-step-recorded-by-entry-file.sh`. Specified: `docs/backlog/` is named and `docs/backlog.md` is not. Derived: on a sentence naming `recorded`. |

### session-workflow (MODIFIED, 24)

All 24 are covered in part at most, as the suite already records for this capability.

| Scenario | Covered by |
|---|---|
| A blocking dependency survives the session ending | **Uncovered**, carried over unchanged: conduct across a session's end, with no program to run it against (`tests/coverage.md`, fold-small-work-in). |
| An unrelated improvement is recorded rather than implemented | `workflow-fragment-backlog-dir-routing-owed.sh`, `workflow-fragment-backlog-dir-path.sh`; existing `workflow-fragment-second-change-excludes-folded.sh` |
| A backlog entry is cited by name | `workflow-fragment-backlog-dir-defers.sh` (no entry numbers), `workflow-fragment-backlog-dir-readme-states-rules.sh`; on the README side `backlog-dir-seeded-new-project.sh` (`by-name-only`) |
| The scope rule and the backlog are one obligation | Existing `workflow-fragment-second-change-excludes-folded.sh` (unchanged) |
| The backlog does not yet exist | `workflow-fragment-backlog-dir-defers.sh` (no creation direction) |
| Entry rules are read from the backlog, not the fragment | `workflow-fragment-backlog-dir-readme-states-rules.sh`, `workflow-fragment-backlog-dir-defers.sh` |
| An identified change is opened without a proposal | `workflow-fragment-backlog-dir-handoff.sh` |
| A handoff is not left uncommitted on a branch the session leaves | **Uncovered**, carried over unchanged: conduct (`tests/coverage.md`, fold-small-work-in). |
| An opened-and-left branch does not become the session's working branch | `workflow-fragment-backlog-dir-handoff.sh` |
| A deferral outlives the change that recorded it | `workflow-fragment-backlog-dir-readme-states-rules.sh` (`outside-any-change`, the stated reason). This was uncovered before and is now covered in part. |
| Recording is stated as what is owed | `workflow-fragment-backlog-dir-routing-owed.sh` |
| An entry completed by an archived change is removed with its record | `workflow-fragment-backlog-dir-archive-reread.sh` |
| An entry waiting on the archived change is marked takeable | `workflow-fragment-backlog-dir-archive-reread.sh` |
| The fragment defers the update's form to the file | `workflow-fragment-backlog-dir-archive-reread.sh` (`as-readme-directs`, `field-label`, `date-rule`, `deletion-ground`) |
| The obligation holds where the skill is absent | `workflow-fragment-backlog-dir-archive-reread.sh` (`names-skill`) |
| An entry the change can fold in | `workflow-fragment-backlog-dir-apply-pickup.sh` |
| An entry outside the change's files | `workflow-fragment-backlog-dir-apply-pickup.sh` (`by-fold-in`) |
| Selection names no field | `workflow-fragment-backlog-dir-apply-pickup.sh` |
| A proposal in a workstream names it | Existing `workflow-fragment-draft-names-workstream.sh` (unchanged) |
| A proposal in no workstream says so | Existing `workflow-fragment-draft-names-workstream.sh` (unchanged) |
| A workstream is proposed, not opened | Existing `workflow-fragment-draft-names-workstream.sh` (unchanged) |
| Derived work is attached by the backlog's rule, not the fragment's | `workflow-fragment-backlog-dir-routing-names-no-workstream.sh` |
| Archiving the last step archives the workstream | Existing `workflow-fragment-archive-workstream-reread.sh` (unchanged) |
| The fragment defers the workstream rules to the README | Existing `workflow-fragment-workstream-rules-not-restated.sh` (unchanged) |

Classification:

- **Specified** — the path `docs/backlog/`, and the README carrying the rules.
- **Derived**:
  - every pattern the cases carried over from the superseded cases, with their anchor revised;
  - the absence of `docs/backlog.md` anywhere in the fragment (`workflow-fragment-backlog-dir-path.sh`, from design.md decision 9 and task 3.1, "wherever");
  - `workflow-fragment-version-after-backlog-dir.sh`, which covers no scenario. It traces to design.md decision 9 and asserts "at least 12" so that a later increment does not break it.

### backlog-maintenance (MODIFIED, 53)

All 53 are covered in part: each case reads the skill's text, not a session's conduct.

| Scenario | Covered by |
|---|---|
| Invoked from a consuming project | `backlog-skill-dir-identity.sh`; existing `backlog-skill-identity-workstreams.sh` (six operations) |
| No backlog exists | `backlog-skill-dir-absent-backlog.sh`. "Creates nothing" is deliberately untested, because a scan cannot tell a direction from a prohibition. |
| No workstream register exists | Existing `backlog-skill-absent-workstream-register.sh` (unchanged) |
| A project on the single file | `backlog-skill-dir-single-file-refused.sh`, `backlog-skill-dir-identity.sh` (description). Leaving `docs/backlog.md` unchanged is deliberately untested, for the same reason. |
| A project's preamble differs from the seeded one | `backlog-skill-dir-reads-readme.sh`; existing `backlog-skill-restates-no-entry-rule.sh`, `backlog-skill-priority-not-restated.sh` |
| The skill does not mandate an audit cadence | Existing `backlog-skill-no-audit-cadence.sh` (unchanged) |
| A project's workstream README differs from the seeded one | Existing `backlog-skill-workstream-rules-not-restated.sh` (unchanged) |
| A name already used by an archived change | `backlog-skill-dir-record-file.sh` |
| An overlapping entry exists | `backlog-skill-dir-record-names-and-conditions.sh` (`design-with-confirmed`) |
| Work the change can fold in | Existing `backlog-skill-record-fold-in.sh` (unchanged) |
| Record defaults Priority | Existing `backlog-skill-record-priority.sh` (unchanged) |
| Record parks an entry only on the operator's word | Existing `backlog-skill-record-priority.sh`; `backlog-skill-dir-record-names-and-conditions.sh` (`parked-until`) |
| Record carries the change's workstream | Existing `backlog-skill-record-absent-value.sh`, whose workstream scans hold; its `dw-absent-value` scan is an obsolete candidate |
| Record refuses a workstream that is not open | Existing `backlog-skill-record-absent-value.sh` (`ws-open-only`) |
| Record keeps a condition out of waits_on | `backlog-skill-dir-record-names-and-conditions.sh` |
| Record writes one file | `backlog-skill-dir-record-file.sh` |
| A blocked entry is not offered | `backlog-skill-dir-pick-wait.sh` |
| A wait already satisfied but not updated | `backlog-skill-dir-pick-wait.sh` |
| Pick narrowed to files | `backlog-skill-dir-pick-wait.sh` (`narrowed-to-paths`, carried from the superseded `backlog-skill-pick.sh`) |
| A parked entry is not offered as takeable | Existing `backlog-skill-pick-priority.sh`; `backlog-skill-dir-pick-wait.sh` (`parked-until`) |
| A parked entry whose condition holds | Existing `backlog-skill-pick-priority.sh` (unchanged) |
| A parked entry still waiting | Existing `backlog-skill-pick-priority.sh` (unchanged) |
| High entries come first | Existing `backlog-skill-pick-priority.sh` (unchanged) |
| Pick lists a workstream's entries in step order | Existing `backlog-skill-pick-workstream.sh` (unchanged) |
| A high step leads its workstream's group | Existing `backlog-skill-pick-workstream.sh` (unchanged) |
| An unplaced entry is shown under its workstream | Existing `backlog-skill-pick-workstream.sh` (unchanged) |
| An entry naming no workstream is grouped apart | Existing `backlog-skill-pick-no-workstream.sh` (unchanged) |
| A condition not shown to hold blocks | `backlog-skill-dir-pick-wait.sh` (`shown-to-hold`) |
| A closed entry was another's only wait | `backlog-skill-dir-close-file.sh` |
| A closed entry was a workstream's step | Existing `backlog-skill-close-workstream.sh` (unchanged) |
| An entry finished without being named | Existing `backlog-skill-sweep.sh` (unchanged) |
| Sweep after a squash merge | Existing `backlog-skill-sweep.sh` (unchanged) |
| Sweep after the record has landed | Existing `backlog-skill-sweep.sh` (unchanged) |
| A change fulfils a parked entry's condition | Existing `backlog-skill-sweep-priority.sh` (its `parked-condition` and `condition-fulfilled` scans); `backlog-skill-dir-sweep-keys.sh` (`parked-until`, `readme-directs`) |
| A change removes a high entry's evidence | Existing `backlog-skill-sweep-priority.sh` (`high-evidence`, `evidence-removed`); `backlog-skill-dir-sweep-keys.sh` (`readme-directs`) |
| Entries naming a workstream being archived | Existing `backlog-skill-sweep-workstream.sh`, `backlog-skill-sweep-absent-value.sh` (unchanged) |
| An entry waiting on the swept change | `backlog-skill-dir-sweep-keys.sh` |
| An entry done by an unmentioning change | Existing `backlog-skill-audit.sh` (unchanged) |
| The report is not applied unasked | Existing `backlog-skill-audit.sh`; `backlog-skill-dir-audit-names.sh` (`entry-files`) |
| Two entries recorded for one change | Existing `backlog-skill-audit.sh` (unchanged) |
| A parked entry whose condition has fired | Existing `backlog-skill-audit-priority.sh` (unchanged) |
| An entry names an archived workstream | Existing `backlog-skill-audit-workstream.sh` (unchanged) |
| An entry names an unknown name | `backlog-skill-dir-audit-names.sh` |
| Pick meets an entry with no Kind | Existing `backlog-skill-older-shape-unclassified.sh`; `backlog-skill-dir-older-shape-missing-key.sh` |
| Pick meets an entry with no Priority | Existing `backlog-skill-older-shape-priority-default.sh` (unchanged) |
| An earlier absent value is read as the current one | Existing `backlog-skill-older-shape-earlier-nothing.sh` (unchanged) |
| A step's status comes from the repository | Existing `backlog-skill-workstreams-operation.sh`; `backlog-skill-dir-workstreams-entry-files.sh` |
| A step in two sources | Existing `backlog-skill-workstreams-operation.sh` (unchanged) |
| The next step is named | Existing `backlog-skill-workstreams-operation.sh`; `backlog-skill-dir-workstreams-entry-files.sh` (`wait-read`) |
| A waiting step is not next | Existing `backlog-skill-workstreams-operation.sh`; `backlog-skill-dir-workstreams-entry-files.sh` |
| Every step done | Existing `backlog-skill-workstreams-operation.sh` (unchanged) |
| Unplaced entries are shown | Existing `backlog-skill-workstreams-operation.sh` (unchanged) |
| A change opened under another name is surfaced | Existing `backlog-skill-workstreams-operation.sh` (unchanged) |

Classification:

- **Specified** — that the skill names `docs/backlog/`, its README, `scripts/backlog-migrate`, and the keys `waits_on`, `waits_for`, `parked_until`, `design_with` and `re_checked` where the requirement names them.
- **Derived** — the reading of each by section and by pattern. The sections are the headings the existing `backlog-skill-*` cases already rely on.
- **Derived, flagged** — `backlog-skill-dir-older-shape-missing-key.sh` reads the requirement's word "key" on the `unclassified` paragraph. Wording that keeps "field" would fail it. The change applies to that paragraph a rename the requirement makes, but it is still a derived constraint for review.

## Obsolete tests: candidates for human confirmation

Each entry below is a **candidate for human confirmation**, not a conclusion. Nothing here was edited or deleted. All 40 pass on the baseline.

**How the search was done:**

- It covered only `tests/cases/**`.
- It matched cases that name `docs/backlog.md` or a field label of the old shape (`Waits on`, `Design with`, `Re-checked`, `Recorded by`, `Depends on`, `**Kind**`, `**Priority**`).
- It also matched scans whose wording the deltas revise: "as the file directs" became "as the README directs", and "absent value" became "empty value" for `design_with`.

No earlier `test-plan.md` was supplied, and none was sought. A bearing case outside these patterns would not have been found: the list is "none other found by this search", not "no other exists".

Each entry gives the case, its superseding delta, and the evidence:

- `backlog-seeded-new-project.sh`
  - Superseded by: project-bootstrap MODIFIED *A backlog is seeded where none exists*.
  - Evidence: asserts `docs/backlog.md` is created and reads phrases from it, including "may rename it if the work turns out different" and the entry-heading statement.
- `backlog-seeded-adoption.sh`
  - Superseded by: the same delta.
  - Evidence: asserts `docs/backlog.md` is created in adoption mode and compares it with the new-project file.
- `backlog-seeded-absent-values.sh`
  - Superseded by: the same delta.
  - Evidence: reads `docs/backlog.md` (line 38). `fenced_field "Waits on"` expects the old shape, whose absent value was `nothing`, not `[]`.
- `backlog-seeded-fields-are-a-list.sh`
  - Superseded by: the same delta (*The seeded entry's fields are a list*, revised).
  - Evidence: requires the seven list items `- **Priority**` to `- **Re-checked**` in `docs/backlog.md`. The values are now frontmatter keys.
- `backlog-seeded-item-kind-definition.sh`, `backlog-seeded-item-priority-no-low.sh`, `backlog-seeded-item-priority-statements.sh`, `backlog-seeded-item-priority-transitions.sh`, `backlog-seeded-item-priority-values.sh`
  - Superseded by: the same delta.
  - Evidence: each sets `backlog="$work/docs/backlog.md"` (lines 50–54) and reads its `**Kind**` or `**Priority**` item.
- `backlog-seeded-no-entry-numbering.sh`
  - Superseded by: the same delta.
  - Evidence: reads `docs/backlog.md`, and requires a heading in it.
- `backlog-seeded-structured-fields.sh`
  - Superseded by: the same delta (*The seeded entry shape carries the structured fields*, revised to keys).
  - Evidence: reads `docs/backlog.md` (line 23) and its fenced field labels.
- `backlog-seeded-structured-statements.sh`
  - Superseded by: the same delta.
  - Evidence: reads `docs/backlog.md` (line 36).
- `backlog-seeded-workstream-default-none.sh`, `backlog-seeded-workstream-field.sh`
  - Superseded by: the same delta.
  - Evidence: each reads `docs/backlog.md`. The second reads `fenced_line ... Workstream` and `"Design with"` labels.
- `backlog-existing-preserved.sh`
  - Superseded by: the same delta. A file at `docs/backlog.md` is now "present in the single-file shape", with a pointer to the migration tool.
  - Evidence: asserts `backlog: already present` for a pre-existing `docs/backlog.md`. Its byte-for-byte assertion still holds.
- `backlog-dangling-symlink-not-written-through.sh`
  - Superseded by: the same delta. Any path at `docs/backlog.md` gets the single-file report.
  - Evidence: asserts `backlog: already present` for a dangling link at `docs/backlog.md`. Its "nothing written through" assertions still hold.
- `repeated-execution-backlog.sh`
  - Superseded by: the same delta's path. Its own requirement, *Each concern is checked independently*, is not modified.
  - Evidence: `assert_file "$work/docs/backlog.md"` after the first run (line 20). `backlog-dir-existing-preserved.sh` carries its repeat half.
- `partial-init-reports-backlog.sh`
  - Superseded by: the same delta's path.
  - Evidence: `assert_file "$work/docs/backlog.md" "backlog completed"` (line 29).
- `workstreams-seeded-order-gates-nothing.sh`
  - Superseded by: project-bootstrap MODIFIED *A workstream register is seeded where none exists* ("its backlog entry's `waits_on`").
  - Evidence: requires the phrase `Waits on` on the "gates nothing" line.
- `workstreams-seeded-statements.sh` (**low confidence**)
  - Superseded by: the same delta ("recorded where its `docs/backlog/` holds an entry of that name").
  - Evidence: asserts the phrase "has an entry of that name". An implementation that keeps "has" with the new path still satisfies it. Only that one assertion bears on the delta.
- `backlog-skill-identity.sh`
  - Superseded by: backlog-maintenance MODIFIED *The skill operates on the project it is invoked in*.
  - Evidence: scan `target-file 'docs/backlog[.]md'` asserts the skill operates on the single file. It may still pass, because the refusal text names `docs/backlog.md`, but what it asserts is superseded.
- `backlog-skill-absent-backlog.sh` (**low confidence**)
  - Superseded by: the same delta ("neither `docs/backlog/README.md` nor `docs/backlog.md`").
  - Evidence: scan `absent-names-seeder` keys absence on `no docs/backlog.md`. It also accepts "absent", so it may survive.
- `backlog-skill-record.sh`
  - Superseded by: backlog-maintenance MODIFIED *Record writes an entry the file can be relied on for*.
  - Evidence: scan `name-vs-headings 'heading'`, because the name is now checked against entry files, and scan `rechecked 're-checked'`, because the key is now `re_checked`.
- `backlog-skill-record-absent-value.sh` (**one scan only**)
  - Superseded by: the same delta. `design_with` takes "the README's empty value — `[]`".
  - Evidence: scan `dw-absent-value 'design with[^.]*absent value'`. Its workstream scans still hold and cover two scenarios above.
- `backlog-skill-pick.sh`
  - Superseded by: backlog-maintenance MODIFIED *Pick lists what can be taken now* (unwaited = `waits_on` empty and no `waits_for`).
  - Evidence: scan `takeable-is-waits-on-nothing 'waits on[^.]*nothing'`. Its other scans are carried into `backlog-skill-dir-pick-wait.sh`.
- `backlog-skill-close.sh`
  - Superseded by: backlog-maintenance MODIFIED *Close removes an entry and every reference to it*.
  - Evidence: scans `'waits on'` and `'design with'` (labels). The delta names `waits_on` and `design_with`.
- `backlog-skill-sweep-priority.sh` (**one scan only**)
  - Superseded by: backlog-maintenance MODIFIED *Sweep performs the archive step's re-read* ("as the README directs").
  - Evidence: scan `priority-as-file-directs 'priority[^.]*(file directs|as the file)…'`. Its other four scans still hold.
- `backlog-skill-older-shape-paragraph-fields.sh`
  - Superseded by: backlog-maintenance MODIFIED *Entries in an older shape are reported, not rewritten*. The sentence "Fields written as paragraphs rather than as a list are read the same as listed ones" is removed. specsRoot line 247 holds it; the delta does not.
  - Evidence: it requires that sentence.
- `workflow-fragment-fixed-paths.sh` (**its `docs/backlog.md` assertion only**)
  - Superseded by: session-workflow MODIFIED *A second change surfacing…* ("SHALL name the backlog's path as `docs/backlog/`").
  - Evidence: `assert_contains "$fragment" "docs/backlog.md"`. Its `.worktrees/` assertion still holds.
- `workflow-fragment-names-handoff.sh`, `workflow-fragment-no-proposal-only-branch.sh`
  - Superseded by: the same delta.
  - Evidence: each runs `assert_contains "$fragment" "docs/backlog.md"`. `workflow-fragment-backlog-dir-handoff.sh` carries the rest.
- `workflow-fragment-backlog-no-entry-numbers.sh`, `workflow-fragment-backlog-not-created-by-fragment.sh`, `workflow-fragment-backlog-rules-not-restated.sh`
  - Superseded by: the same delta.
  - Evidence: each anchors on `assert_contains "$fragment" "docs/backlog.md"`. `workflow-fragment-backlog-dir-defers.sh` carries their scans.
- `workflow-fragment-routing-recording-owed.sh`
  - Superseded by: the same delta.
  - Evidence: scan `record-in-backlog 'record (it|them) in .?docs/backlog[.]md'`.
- `workflow-fragment-backlog-routing-names-no-workstream.sh`
  - Superseded by: session-workflow MODIFIED *A change states the workstream it advances…*.
  - Evidence: it selects lines by `grep -F 'docs/backlog.md'`. Absent the path, it returns 2 and fails.
- `workflow-fragment-apply-backlog-pickup.sh`, `workflow-fragment-apply-pickup-names-no-field.sh`
  - Superseded by: session-workflow MODIFIED *A change takes the backlog entries it can fold in*.
  - Evidence: `line_select 'docs/backlog[.]md'`.
- `workflow-fragment-archive-backlog-reread.sh`
  - Superseded by: session-workflow MODIFIED *Archiving a change re-reads the backlog against it*.
  - Evidence: it selects the line by `docs/backlog\.md`, and its scan `as-the-file-directs` is superseded by "as the backlog's README directs".
- `workflow-fragment-archive-reread-names-no-field.sh`
  - Superseded by: the same delta.
  - Evidence: it selects the archive line by `docs/backlog\.md`.

**Checked and judged not obsolete:**

- `workstreams-seeded-adoption.sh`: a pre-existing `docs/backlog.md` is still left unchanged under the delta.
- `backlog-write-failure-errors.sh`: a regular file `docs` still fails the write.
- `backlog-report-line-after-ignore-file.sh`: the line position is unchanged.
- `initial-branch-corrupted-head-not-rewritten.sh`, `initial-branch-missing-head-not-rewritten.sh`: they name the path in a comment only.
- `backlog-skill-older-shape-earlier-nothing.sh`: the `nothing` clause survives the delta.
- `workflow-fragment-second-change-excludes-folded.sh` and `workflow-fragment-archive-workstream-reread.sh`: they name the path only in fixtures.

## Obsolete tests: dispositions at apply

Every candidate above was judged, and five cases the search did not find were added after they failed against the implementation.

- **Retired, 28 cases**, each with a successor among the derived cases: `backlog-seeded-new-project`, `-adoption`, `-absent-values`, `-fields-are-a-list`, `-item-kind-definition`, `-item-priority-no-low`, `-item-priority-statements`, `-item-priority-transitions`, `-item-priority-values`, `-no-entry-numbering`, `-structured-fields`, `-structured-statements`, `-workstream-default-none`, `-workstream-field`; `backlog-existing-preserved`; `workstreams-seeded-order-gates-nothing`; `backlog-skill-older-shape-paragraph-fields` (its requirement clause is removed by the delta); `workflow-fragment-backlog-no-entry-numbers`, `-backlog-not-created-by-fragment`, `-backlog-rules-not-restated`, `-routing-recording-owed`, `-backlog-routing-names-no-workstream`, `-archive-backlog-reread`, `-archive-reread-names-no-field`, `-apply-backlog-pickup`, `-apply-pickup-names-no-field`, `-names-handoff`, `-no-proposal-only-branch`.
- **Re-anchored, kept**: where only the old path, label or report token was stale and the rest of the case still tests a live requirement, that anchor, and the case's own conforming fixture where it carried the old wording, moved to the new one; no scan was dropped or loosened. `backlog-dangling-symlink-not-written-through` (the single-file report), `repeated-execution-backlog` and `partial-init-reports-backlog` (`docs/backlog/README.md`), `workflow-fragment-fixed-paths` (`docs/backlog/`), `workstreams-seeded-statements` ("holds an entry of that name"), `backlog-skill-record` (name checked against entry files), `backlog-skill-record-absent-value` (`design_with`'s empty value), `backlog-skill-pick` (unwaited), `backlog-skill-close` (`waits_on`, `design_with`), `backlog-skill-sweep-priority` ("as the README directs").
- **Found by running, not by the search**: `executable-bit-not-relied-upon` copies `project-init` alone into a fixture library, which now blocks for want of the seed; its fixture copies `scripts/seed/` too. `backlog-skill-record-fold-in` anchored the name check on "heading"; it and its fixtures now anchor on "entry files". `backlog-skill-close-workstream`, `backlog-skill-older-shape-priority-default` and `backlog-skill-pick-priority` failed on the skill's first rewrite, not on a stale anchor: their requirements are unchanged, so the skill's wording was restored to meet them.
- **Kept unchanged**: `backlog-skill-identity` and `backlog-skill-absent-backlog` still pass against the skill's refusal text, which names `docs/backlog.md` as the single-file shape, and assert nothing the deltas contradict.

## Unresolved project questions

- **Q1 — The seeded README's entry shape is a fenced example.**
  - Assumption: the README shows its entry shape as a fenced example, with frontmatter between `---` lines and the reasons list after it, as the single-file seed did.
  - Why: the requirement says "its keys in this order, one per line" and gives the list items, but does not say an example carries them.
  - Depends on it: `backlog-dir-seeded-structured-keys.sh`, `backlog-dir-seeded-fields-are-a-list.sh`. Both tolerate an example that leaves `parked_until` and `waits_for` to prose.
- **Q2 — project-init's report wording for the new backlog states.**
  - Assumption: `tests/README.md`'s report contract fixes only `backlog: created | already present`. It is assumed that:
    - the single-file report is a `backlog:` line carrying `single` and `scripts/backlog-migrate`;
    - the README-beside-entries report is a `backlog:` line carrying `created`;
    - the not-a-directory report is a `backlog:` line carrying `not a directory`.
  - Task 5.3 should record the chosen wording in the contract.
  - Depends on it: `backlog-dir-single-file-pointed-to-migrate.sh`, `backlog-dir-readme-beside-entries.sh`, `backlog-dir-not-a-directory-not-written-through.sh`.
- **Q3 — `scripts/backlog-migrate`'s report format.** No contract exists yet. Assumptions:
  - the outcome appears as the word `SUCCESS`, `BLOCKED` or `ERROR`, as project-init's `Outcome:` line does;
  - an entry's report names its entry and the field or key on one line;
  - the preamble statement carries the word `preamble`.
  - Depends on it: `backlog-migrate-waits-on-nothing-note.sh`, `backlog-migrate-no-kind.sh`, `backlog-migrate-report-condition.sh`, `backlog-migrate-readme-is-seeded.sh`, and every BLOCKED and ERROR case.
- **Q4 — An entry file's frontmatter is delimited by `---` lines from the file's first line.**
  - Assumption: it is, in the usual YAML form.
  - Depends on it: every `backlog-migrate-*` case that reads values through `fm_value` or `fm_keys`.
- **Q5 — Exit codes.**
  - Assumption: the spec makes `backlog-migrate`'s codes "`scripts/project-init`'s outcomes and codes", taken from `tests/README.md`: 0 SUCCESS, 1 ERROR, 2 BLOCKED.
  - Depends on it: every BLOCKED and ERROR case.
- **Q6 — Inducing a write failure.**
  - Assumption: `backlog-migrate-write-failure.sh` makes `docs/` unwritable after the fixture is committed. That fails the first write, not a later one, so the "partway" in the scenario is reached only at its start.
  - Limits: as root, permissions do not bind, so the case fails rather than pass vacuously. Someone with the implementation in hand may find a later failure point worth a further case.
- **Q7 — No bash 3.2 here.**
  - Assumption: none is needed for the static half. `backlog-migrate-older-bash.sh` runs its run half only where `$BASH32`, `bash3.2`, `bash-3.2` or a 3.2 `/bin/bash` exists. None does on this machine, so that half has never been executed. Its static half is a derived proxy.
  - Depends on it: `backlog-migrate-older-bash.sh`.
- **Q8 — Stack skill.** `bash` was loaded and supplied the idiom. No question is outstanding.

## Missing shared arrangement

The dispatch named `tests/lib.sh` and `tests/cases/lib/` (`static-scan.sh`, `line-scan.sh`) as the shared arrangement. They were read and not written. Each declaration below sits inside the case that uses it.

- **Migrate fixture helpers**
  - What: `require_migrate`, `new_repo`, `fm_value`, `fm_keys`, `fm_body`, `check_reader`, `assert_untouched`.
  - Declared in: each of the 22 `backlog-migrate-*.sh` cases.
  - Stands in for: a git repository whose `docs/backlog.md` is committed, a reader for an entry file's frontmatter and body, the target-absent guard for the tool, and the "nothing written" check over `docs/`.
  - Used by: every `backlog-migrate-*.sh`. `fm_*` and `check_reader` are used by the mapping cases.
  - Near-miss: `tests/lib.sh`'s `assert_unchanged` checks one file, not a directory's contents. Nothing in the arrangement makes a git fixture or reads frontmatter.
  - Found in a test module: no.
  - Proposed home: `tests/lib.sh` for `fm_value`, `fm_keys`, `fm_body` and `assert_untouched`; a new `tests/cases/lib/migrate-fixture.sh` for `new_repo` and `require_migrate`.
  - Disposition: **kept**: `AGENTS.md` records no shared test arrangement, so the workflow keeps every entry local, and where shared arrangement should live is `record-this-repositorys-shared-test-arrangement`'s decision, not this change's. The 22 copies are byte-identical, so that entry can move them as one block; `backlog-migrate-rechecked-note-kept.sh`, written at apply, declares the same block.
- **Seeded-output scan wrappers**
  - What: `fixture_readme`, `seed_and_check` and `R`.
  - Declared in: `backlog-dir-seeded-new-project.sh`, `-kind-definition.sh`, `-priority-values.sh`, `-priority-no-low.sh`, `-priority-transitions.sh`, `-workstream-default.sh`, `-absent-values.sh`, `-waits-on-names-only.sh`, `-frontmatter-flat.sh`. They are also declared but unused in `-structured-keys.sh` and `-fields-are-a-list.sh`, which source the same block.
  - Stands in for: running static-scan's discriminator and check against a tree project-init writes, rather than against `$TOOLKIT_ROOT`.
  - Used by: the nine cases first listed. `workstreams-dir-step-recorded-by-entry-file.sh` and `workstreams-dir-order-names-waits-on.sh` inline the same pattern for `static-scan.sh` and `line-scan.sh`.
  - Near-miss: `static-scan.sh`'s `scan_run` and `line-scan.sh`'s `line_run` run the check over `$TOOLKIT_ROOT` only, and their root is not a parameter. Extending them is editing shared arrangement, which this pass does not do.
  - Found in a test module: no.
  - Proposed home: `scan_run_at ROOT` in `tests/cases/lib/static-scan.sh`, and `line_run_at FILE` in `line-scan.sh`.
  - Disposition: **kept**: `AGENTS.md` records no shared test arrangement, so the workflow keeps every entry local, and where shared arrangement should live is `record-this-repositorys-shared-test-arrangement`'s decision, not this change's. The eleven copies are byte-identical.
- **`fenced_fm_keys`**
  - Declared in: `backlog-dir-seeded-structured-keys.sh`, `backlog-dir-seeded-fields-are-a-list.sh`.
  - Stands in for: a reader for the frontmatter keys of a fenced example.
  - Used by: those two cases.
  - Near-miss: `tests/lib.sh`'s `fenced_line` finds `**<label>**` lines in a fence, not `key:` lines between `---` delimiters.
  - Found in a test module: no.
  - Proposed home: `tests/lib.sh`.
  - Disposition: **kept**: `AGENTS.md` records no shared test arrangement, so the workflow keeps every entry local, and where shared arrangement should live is `record-this-repositorys-shared-test-arrangement`'s decision, not this change's.
- **`fenced_item_line`**
  - Declared in: `backlog-dir-seeded-fields-are-a-list.sh`.
  - Stands in for: the line of a fenced `- **<label>**` list item.
  - Used by: that case.
  - Near-miss: `tests/lib.sh`'s `fenced_line` accepts the label with or without the list marker, so it cannot require the marker.
  - Found in a test module: yes, the superseded `backlog-seeded-fields-are-a-list.sh` (list-the-entry-fields' local declaration), copied rather than imported.
  - Proposed home: `tests/lib.sh`, beside `fenced_line`.
  - Disposition: **kept**: `AGENTS.md` records no shared test arrangement, so the workflow keeps every entry local, and where shared arrangement should live is `record-this-repositorys-shared-test-arrangement`'s decision, not this change's.
- **Check logic carried from superseded test modules**
  - What: `restated_rules`, `number_mentions` and `create_directions` in `workflow-fragment-backlog-dir-defers.sh`; `check` and `mutate_and_expect` in `workflow-fragment-backlog-dir-archive-reread.sh`; `check` and `expect` in `workflow-fragment-backlog-dir-routing-names-no-workstream.sh`; `numbered_headings` and `number_mentions` in `backlog-dir-seeded-no-entry-numbering.sh`.
  - Stands in for: these are assertion logic rather than builders or fakes, so arguably not arrangement at all. They are recorded because each was found in a test module and copied rather than imported.
  - Used by: those cases.
  - Near-miss: none.
  - Found in: `workflow-fragment-backlog-rules-not-restated.sh`, `-backlog-no-entry-numbers.sh`, `-backlog-not-created-by-fragment.sh`, `-archive-backlog-reread.sh`, `-archive-reread-names-no-field.sh`, `-backlog-routing-names-no-workstream.sh` and `backlog-seeded-no-entry-numbering.sh`.
  - Proposed home: none. They are specific to each case.
  - Disposition: **kept**: `AGENTS.md` records no shared test arrangement, so the workflow keeps every entry local, and where shared arrangement should live is `record-this-repositorys-shared-test-arrangement`'s decision, not this change's. They are also assertion logic, one use each.

## Findings in the artifacts

No artifact carried an instruction addressed to the test author. One gap was noted, not acted on: `toolkit-structure`'s delta changes the requirement but leaves `tests/coverage.md`'s accounting of the 7 carried-over scenarios as "uncovered". That accounting still holds.
