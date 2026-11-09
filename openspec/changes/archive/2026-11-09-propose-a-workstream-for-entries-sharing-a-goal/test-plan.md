# Test plan: propose-a-workstream-for-entries-sharing-a-goal

Written by `ai-toolkit:change-test-writer` from the committed plan (a16ae08). This file is not an artifact the OpenSpec schema knows about: `openspec instructions apply` does not list it, so read it on purpose before implementing.

Every case named below runs alone as `bash tests/run.sh <case-name>` from the worktree root. Every case this pass wrote is red at authoring (state 1 on real content, see *Red at authoring*), and every scan in each is shown able to fail by `scan_discriminate` over a fixture the case writes.

## Inputs and their state

- Delta specs: `specs/backlog-maintenance/spec.md` and `specs/project-bootstrap/spec.md`, both `## MODIFIED Requirements` only (five requirements, 86 scenarios).
- `.openspec.yaml`: the dispatched path `<changeRoot>/.openspec.yaml` does not exist (finding F1). Delta specs are present, so the specs-exempt route does not arise whatever the file would say; the pass proceeded on the ordinary route.
- Read set: the change's artifacts, the five requirements under `openspec/specs/`, `AGENTS.md`, `tests/README.md`, `tests/cases/lib/static-scan.sh`, `tests/cases/lib/line-scan.sh` and cases under `tests/cases/`. Not read: `rules/*.md`, `skills/backlog/**`, `scripts/**`, `tests/coverage.md`.

## Scenario accounting

86 scenarios in the delta specs; 86 accounted for below: 8 covered by a case this pass wrote, 78 uncovered by this pass for reason U1.

**U1.** The scenario's text is identical to the same scenario under `openspec/specs/` (compared block by block: no line of any of the five requirements' scenarios is removed or altered, only the 8 below are added). The change does not revise it, so no new behaviour is stated for it to derive. Its coverage predates this change and is ledgered in `tests/coverage.md`, which this pass did not read (outside its read set) and does not own (task 3.3 does). The changed requirement bodies are held through the 8 added scenarios, each of which also carries the revised body statement it restates (named in each case's header).

| # | Capability | Requirement | Scenario | Delta | Accounted |
|---|---|---|---|---|---|
| 1 | backlog-maintenance | Record writes an entry the file can be relied on for | A name already used by an archived change | Unchanged | Uncovered by this pass: U1 |
| 2 | backlog-maintenance | Record writes an entry the file can be relied on for | Record refuses a name colliding with the rules' files | Unchanged | Uncovered by this pass: U1 |
| 3 | backlog-maintenance | Record writes an entry the file can be relied on for | An overlapping entry exists | Unchanged | Uncovered by this pass: U1 |
| 4 | backlog-maintenance | Record writes an entry the file can be relied on for | Work the change can fold in | Unchanged | Uncovered by this pass: U1 |
| 5 | backlog-maintenance | Record writes an entry the file can be relied on for | Record defaults Priority | Unchanged | Uncovered by this pass: U1 |
| 6 | backlog-maintenance | Record writes an entry the file can be relied on for | Record parks an entry only on the operator's word | Unchanged | Uncovered by this pass: U1 |
| 7 | backlog-maintenance | Record writes an entry the file can be relied on for | Record carries the change's workstream | Unchanged | Uncovered by this pass: U1 |
| 8 | backlog-maintenance | Record writes an entry the file can be relied on for | Record refuses a workstream that is not open | Unchanged | Uncovered by this pass: U1 |
| 9 | backlog-maintenance | Record writes an entry the file can be relied on for | Record keeps a condition out of waits_on | Unchanged | Uncovered by this pass: U1 |
| 10 | backlog-maintenance | Record writes an entry the file can be relied on for | Record writes one file | Unchanged | Uncovered by this pass: U1 |
| 11 | backlog-maintenance | Record writes an entry the file can be relied on for | An entry the change's workstream rules out finds another | Unchanged | Uncovered by this pass: U1 |
| 12 | backlog-maintenance | Record writes an entry the file can be relied on for | The absent value follows the read | Unchanged | Uncovered by this pass: U1 |
| 13 | backlog-maintenance | Record writes an entry the file can be relied on for | A recorded entry is placed or left with a reason | Unchanged | Uncovered by this pass: U1 |
| 14 | backlog-maintenance | Record writes an entry the file can be relied on for | Placing one entry owes nothing for the others | Unchanged | Uncovered by this pass: U1 |
| 15 | backlog-maintenance | Record writes an entry the file can be relied on for | Record defaults Need | Unchanged | Uncovered by this pass: U1 |
| 16 | backlog-maintenance | Record writes an entry the file can be relied on for | Record writes must only on the operator's word | Unchanged | Uncovered by this pass: U1 |
| 17 | backlog-maintenance | Record writes an entry the file can be relied on for | Record types a condition | Unchanged | Uncovered by this pass: U1 |
| 18 | backlog-maintenance | Record writes an entry the file can be relied on for | Entries sharing a goal are proposed a workstream | Added | Covered (mechanical half): `bash tests/run.sh backlog-skill-record-shared-goal-proposed`; conduct half conduct-only |
| 19 | backlog-maintenance | Record writes an entry the file can be relied on for | No shared goal is said | Added | Covered (mechanical half): `bash tests/run.sh backlog-skill-record-no-shared-goal-said`; conduct half conduct-only |
| 20 | backlog-maintenance | Record writes an entry the file can be relied on for | A goal one change meets earns no proposal | Added | Covered (mechanical half): `bash tests/run.sh backlog-skill-record-one-change-goal-not-proposed`; conduct half conduct-only |
| 21 | backlog-maintenance | Sweep performs the archive step's re-read | An entry finished without being named | Unchanged | Uncovered by this pass: U1 |
| 22 | backlog-maintenance | Sweep performs the archive step's re-read | Sweep after a squash merge | Unchanged | Uncovered by this pass: U1 |
| 23 | backlog-maintenance | Sweep performs the archive step's re-read | Sweep after the record has landed | Unchanged | Uncovered by this pass: U1 |
| 24 | backlog-maintenance | Sweep performs the archive step's re-read | A change fulfils a parked entry's condition | Unchanged | Uncovered by this pass: U1 |
| 25 | backlog-maintenance | Sweep performs the archive step's re-read | A change removes a high entry's evidence | Unchanged | Uncovered by this pass: U1 |
| 26 | backlog-maintenance | Sweep performs the archive step's re-read | Entries naming a workstream being archived | Unchanged | Uncovered by this pass: U1 |
| 27 | backlog-maintenance | Sweep performs the archive step's re-read | An entry waiting on the swept change | Unchanged | Uncovered by this pass: U1 |
| 28 | backlog-maintenance | Sweep performs the archive step's re-read | An entry naming the open workstream that no step names | Unchanged | Uncovered by this pass: U1 |
| 29 | backlog-maintenance | Sweep performs the archive step's re-read | An entry falling outside its workstream is re-pointed | Unchanged | Uncovered by this pass: U1 |
| 30 | backlog-maintenance | Sweep performs the archive step's re-read | An entry the change recorded is not yet on the trunk | Unchanged | Uncovered by this pass: U1 |
| 31 | backlog-maintenance | Sweep performs the archive step's re-read | Entries detached together share a goal | Added | Covered (mechanical half): `bash tests/run.sh backlog-skill-sweep-detached-share-a-goal`; conduct half conduct-only |
| 32 | backlog-maintenance | Audit verifies every entry independently and changes nothing without the operator | An entry done by an unmentioning change | Unchanged | Uncovered by this pass: U1 |
| 33 | backlog-maintenance | Audit verifies every entry independently and changes nothing without the operator | The report is not applied unasked | Unchanged | Uncovered by this pass: U1 |
| 34 | backlog-maintenance | Audit verifies every entry independently and changes nothing without the operator | Two entries recorded for one change | Unchanged | Uncovered by this pass: U1 |
| 35 | backlog-maintenance | Audit verifies every entry independently and changes nothing without the operator | A parked entry whose condition has fired | Unchanged | Uncovered by this pass: U1 |
| 36 | backlog-maintenance | Audit verifies every entry independently and changes nothing without the operator | An entry names an archived workstream | Unchanged | Uncovered by this pass: U1 |
| 37 | backlog-maintenance | Audit verifies every entry independently and changes nothing without the operator | An entry names an unknown name | Unchanged | Uncovered by this pass: U1 |
| 38 | backlog-maintenance | Audit verifies every entry independently and changes nothing without the operator | A condition without a type | Unchanged | Uncovered by this pass: U1 |
| 39 | backlog-maintenance | Audit verifies every entry independently and changes nothing without the operator | A type without a condition | Unchanged | Uncovered by this pass: U1 |
| 40 | backlog-maintenance | Audit verifies every entry independently and changes nothing without the operator | Audit leaves need alone | Unchanged | Uncovered by this pass: U1 |
| 41 | backlog-maintenance | Audit verifies every entry independently and changes nothing without the operator | Entries in two ranges share a goal | Added | Covered (mechanical half): `bash tests/run.sh backlog-skill-audit-shared-goals`; conduct half conduct-only |
| 42 | project-bootstrap | A workstream register is seeded where none exists | A project without a workstream register receives the seeded file | Unchanged | Uncovered by this pass: U1 |
| 43 | project-bootstrap | A workstream register is seeded where none exists | An existing workstream register is preserved exactly | Unchanged | Uncovered by this pass: U1 |
| 44 | project-bootstrap | A workstream register is seeded where none exists | The seeded register carries no status field | Unchanged | Uncovered by this pass: U1 |
| 45 | project-bootstrap | A workstream register is seeded where none exists | An abandoned workstream is archived, not deleted | Unchanged | Uncovered by this pass: U1 |
| 46 | project-bootstrap | A workstream register is seeded where none exists | A finished workstream is archived | Unchanged | Uncovered by this pass: U1 |
| 47 | project-bootstrap | A workstream register is seeded where none exists | A step matching two sources takes the first status | Unchanged | Uncovered by this pass: U1 |
| 48 | project-bootstrap | A workstream register is seeded where none exists | Step order is not a dependency | Unchanged | Uncovered by this pass: U1 |
| 49 | project-bootstrap | A workstream register is seeded where none exists | The seeded workstream's fields are a list | Unchanged | Uncovered by this pass: U1 |
| 50 | project-bootstrap | A workstream register is seeded where none exists | A step is recorded by its entry file | Unchanged | Uncovered by this pass: U1 |
| 51 | project-bootstrap | A workstream register is seeded where none exists | Done when asks for an observable effect of the Goal | Unchanged | Uncovered by this pass: U1 |
| 52 | project-bootstrap | A workstream register is seeded where none exists | Research shared by several steps has a place in the workstream | Unchanged | Uncovered by this pass: U1 |
| 53 | project-bootstrap | A workstream register is seeded where none exists | A decision for one step stays in that step's design | Unchanged | Uncovered by this pass: U1 |
| 54 | project-bootstrap | A workstream register is seeded where none exists | What a workstream holds is not progress | Unchanged | Uncovered by this pass: U1 |
| 55 | project-bootstrap | A workstream register is seeded where none exists | Overturned content is revised in place | Unchanged | Uncovered by this pass: U1 |
| 56 | project-bootstrap | A workstream register is seeded where none exists | A step taken as a fix reads as done | Unchanged | Uncovered by this pass: U1 |
| 57 | project-bootstrap | A workstream register is seeded where none exists | A change whose work has merged is still in flight | Unchanged | Uncovered by this pass: U1 |
| 58 | project-bootstrap | A workstream register is seeded where none exists | A fix step without the forge | Unchanged | Uncovered by this pass: U1 |
| 59 | project-bootstrap | A workstream register is seeded where none exists | A change needed by two workstreams is listed in one | Unchanged | Uncovered by this pass: U1 |
| 60 | project-bootstrap | A workstream register is seeded where none exists | The seeded block settles what placing means | Unchanged | Uncovered by this pass: U1 |
| 61 | project-bootstrap | A workstream register is seeded where none exists | The seeded block directs proposing a workstream | Added | Covered (mechanical half): `bash tests/run.sh workstreams-block-proposes-a-workstream`; conduct half conduct-only |
| 62 | project-bootstrap | A workstream register is seeded where none exists | A detach is not a deferral | Added | Covered (mechanical half): `bash tests/run.sh workstreams-block-detach-not-deferral`; conduct half conduct-only |
| 63 | project-bootstrap | The backlog's rules are written where none exist | A project without a backlog receives the seeded file | Unchanged | Uncovered by this pass: U1 |
| 64 | project-bootstrap | The backlog's rules are written where none exist | An existing backlog is preserved exactly | Unchanged | Uncovered by this pass: U1 |
| 65 | project-bootstrap | The backlog's rules are written where none exist | The seeded file carries no numbering | Unchanged | Uncovered by this pass: U1 |
| 66 | project-bootstrap | The backlog's rules are written where none exist | The seeded entry shape carries the structured fields | Unchanged | Uncovered by this pass: U1 |
| 67 | project-bootstrap | The backlog's rules are written where none exist | A fix is distinguished from a change by what it owes | Unchanged | Uncovered by this pass: U1 |
| 68 | project-bootstrap | The backlog's rules are written where none exist | Priority's values and default are stated | Unchanged | Uncovered by this pass: U1 |
| 69 | project-bootstrap | The backlog's rules are written where none exist | The seeded file offers no low priority | Unchanged | Uncovered by this pass: U1 |
| 70 | project-bootstrap | The backlog's rules are written where none exist | The seeded file states how an entry leaves parked and high | Unchanged | Uncovered by this pass: U1 |
| 71 | project-bootstrap | The backlog's rules are written where none exist | Workstream's default is stated | Unchanged | Uncovered by this pass: U1 |
| 72 | project-bootstrap | The backlog's rules are written where none exist | The seeded entry's fields are a list | Unchanged | Uncovered by this pass: U1 |
| 73 | project-bootstrap | The backlog's rules are written where none exist | An absent value reads as its field | Unchanged | Uncovered by this pass: U1 |
| 74 | project-bootstrap | The backlog's rules are written where none exist | A single-file backlog is pointed to the migration tool | Unchanged | Uncovered by this pass: U1 |
| 75 | project-bootstrap | The backlog's rules are written where none exist | A missing backlog fragment blocks every run | Unchanged | Uncovered by this pass: U1 |
| 76 | project-bootstrap | The backlog's rules are written where none exist | The rules are added beside existing entries | Unchanged | Uncovered by this pass: U1 |
| 77 | project-bootstrap | The backlog's rules are written where none exist | Project text beside the block survives | Unchanged | Uncovered by this pass: U1 |
| 78 | project-bootstrap | The backlog's rules are written where none exist | A backlog path that is not a directory is not written through | Unchanged | Uncovered by this pass: U1 |
| 79 | project-bootstrap | The backlog's rules are written where none exist | Waits on holds only names | Unchanged | Uncovered by this pass: U1 |
| 80 | project-bootstrap | The backlog's rules are written where none exist | The frontmatter is flat | Unchanged | Uncovered by this pass: U1 |
| 81 | project-bootstrap | The backlog's rules are written where none exist | The seeded block makes `none` the end of a search | Unchanged | Uncovered by this pass: U1 |
| 82 | project-bootstrap | The backlog's rules are written where none exist | Need's values and default are stated | Unchanged | Uncovered by this pass: U1 |
| 83 | project-bootstrap | The backlog's rules are written where none exist | A condition's types are stated | Unchanged | Uncovered by this pass: U1 |
| 84 | project-bootstrap | The backlog's rules are written where none exist | A condition without a type stays valid | Unchanged | Uncovered by this pass: U1 |
| 85 | project-bootstrap | The backlog's rules are written where none exist | A step is not must for being a step | Unchanged | Uncovered by this pass: U1 |
| 86 | project-bootstrap | The backlog's rules are written where none exist | The seeded block reads the none entries before writing none | Added | Covered (mechanical half): `bash tests/run.sh backlog-block-reads-none-entries`; conduct half conduct-only |

## Cases written and assertion classification

Every case is a static read (the third situation) except that the three `*-block-*` cases run `scripts/project-init` and read the file it seeds. Every scenario's "THEN" about a session's behaviour (reading entries, judging a shared goal, proposing, creating no workstream file) is **conduct-only** per design.md decision 10: deliberately untested, since no scan can hold it.

### backlog-skill-record-shared-goal-proposed

Scenario: *Entries sharing a goal are proposed a workstream*. Reads `skills/backlog/SKILL.md`, section under the heading naming `record`.

- Specified (requirement body, restated by the scenario): reads bodies, not the repository; proposes a workstream as the workstreams rules direct, naming entries and a draft Goal; writes the absent value meanwhile.
- Derived (wording, design.md decision 4): `[reads-bodies]`, `[shared-goal]`, `[proposes]`, `[names-draft]`, `[meanwhile]`, each one phrase of decision 4's text.
- Derived (decision 4, "the skill does not restate"): `[no-unasked]` forbids `opens? none unasked|never open it unasked` in the record section.
- Deliberately untested: the session proposing, and no workstream file created (conduct).

### backlog-skill-record-no-shared-goal-said

Scenario: *No shared goal is said*. Record section.

- Specified: the answer says what was proposed or that no shared goal was found.
- Derived (wording, decision 4): `[says-none-found]`.
- Deliberately untested: the answer itself (conduct).

### backlog-skill-record-one-change-goal-not-proposed

Scenario: *A goal one change meets earns no proposal*. Reads the record section and `rules/workstreams.md`.

- Specified: a proposal only where the goal takes more than one change; a goal one change meets is not proposed.
- Derived (decisions 1 and 4: the skill defers, the rule states it): `[defers]` in the record section; `[one-change-not-proposed]`, `[more-than-one]` in `rules/workstreams.md` (the fragment itself, so the case is a pure static read; the seeded copy is held by `workstreams-block-proposes-a-workstream`).
- Deliberately untested: the session's judgement that a goal is one change's (conduct).

### backlog-skill-sweep-detached-share-a-goal

Scenario: *Entries detached together share a goal*. Section under the heading naming `sweep`.

- Specified: an entry to be set to the absent value is read with those already carrying it, and with the others detached, as record reads them.
- Derived (wording, decision 5): `[read-together]`, `[as-record]`. Derived (decision 5 "the words ... pin stay"): `[kept-words]`, already green at authoring and held because the revised sentence must keep it.
- Deliberately untested: three entries found and named under a draft Goal (conduct). That the read covers "the others the same sweep detaches" is held only through decision 5's "those to be set to it read together", which is how the plan words it; there is no separate phrase to scan.

### backlog-skill-audit-shared-goals

Scenario: *Entries in two ranges share a goal*. Reads the audit section of `skills/backlog/SKILL.md` and `skills/backlog/references/audit.md`.

- Specified: the skill reads every absent-value entry together after the agents return because no agent sees two ranges; the report names groups with a draft Goal, proposed as workstreams; an approved workstream is opened as the rules and workflow direct, entries re-pointed; the edit spans entry files and the workstream files it opens.
- Derived (wording, decision 6): `[reads-across-ranges]`, `[opens-approved]`, `[repoints]`, `[workstream-files]`, `[draft-goal]`, `[proposed-to-open]`, `[no-agent-two-ranges]`.
- Derived (numbering, decision 6): `[shared-goals-seventh]` (`7. **Shared goals**`), `[fixes-eighth]` (`8. **Fixes**`), `[unverified-ninth]` (`9. **Unverified**`). These assume the report's sections are a numbered list written `N. **Name**`, which decision 6 implies but this pass could not confirm without reading `audit.md` (Q2).
- Deliberately untested: a group found across two ranges, and no workstream file before approval (conduct; "applies none of it until the operator says so" is already held by `backlog-skill-audit` `[operator-approves]`).

### workstreams-block-proposes-a-workstream

Scenario: *The seeded block directs proposing a workstream*; also the revised list item of *A project without a workstream register receives the seeded file*. Runs `project-init`, reads `docs/workstreams/AGENTS.md`.

- Specified: opening is the operator's decision; a session finding a goal no open workstream holds, shared by changes or `none` entries, proposes one with changes, entries and a draft Goal and opens none unasked; a goal one change meets is not proposed.
- Derived (wording, decision 1): `[operator-decides]` (already green; kept verbatim per decision 1), `[no-open-holds]`, `[shared-by]`, `[proposes-to-operator]`, `[names-draft]`, `[none-unasked]`, `[one-change-not-proposed]`.

### workstreams-block-detach-not-deferral

Scenario: *A detach is not a deferral*; also the revised detaching list item of *A project without a workstream register receives the seeded file*. Runs `project-init`, reads `docs/workstreams/AGENTS.md`.

- Specified: read with the entries already naming `none` and the others detached in the same edit; re-point, clear after the read, or delete on a backlog ground; a deferring note does not detach.
- Derived (wording, decision 2): `[clears-last]` (already green; decision 2 adds after it), `[read-with-none]`, `[read-with-batch]`, `[proposes-as-above]`, `[three-ends]`, `[no-deferral]`.
- Deliberately untested: a session's detach of an abandoned workstream (conduct).

### backlog-block-reads-none-entries

Scenario: *The seeded block reads the none entries before writing none*; also the revised `workstream` rule of *A project without a backlog receives the seeded file*. Runs `project-init`, reads `docs/backlog/AGENTS.md`.

- Specified: the other `none` entries are read for a shared goal before `none` is written; a workstream is proposed as the workstreams rules direct; `none` is written meanwhile.
- Derived (wording, decision 3): `[read-before-none]`, `[more-than-one]`, `[directs]` (names `docs/workstreams/AGENTS.md`, as decision 3 does), `[meanwhile]`.

### Not derived from a scenario

The version rises (`backlog` 1.3.0, `workstreams` 2.2.0, plugin 2.4.0), the two `rules/changelog` records and this repository's own blocks (tasks 1.3, 3.1, 3.2) state no scenario. They are held by existing cases the tasks name (`project-update-changelog-*`, `plugin-version-rise-checks-this-repository`, the `inlined-body-matches-fragment` family); this pass wrote nothing for them.

## Red at authoring

Recorded per `testing`: each check below was observed red on real content at authoring, with every discriminator passing first (no `UNREADABLE`, no discriminator failure). Each goes green as the named task lands; no second record is owed.

- `backlog-skill-record-shared-goal-proposed`: red on all five require scans (task 2.1). `[no-unasked]` passes (forbid; discriminated by its specimen).
- `backlog-skill-record-no-shared-goal-said`: red on `[says-none-found]` (task 2.1).
- `backlog-skill-record-one-change-goal-not-proposed`: red on all three (tasks 1.1, 2.1).
- `backlog-skill-sweep-detached-share-a-goal`: red on `[read-together]`, `[as-record]`; `[kept-words]` green (task 2.1).
- `backlog-skill-audit-shared-goals`: red on all ten (tasks 2.1, 2.2).
- `workstreams-block-proposes-a-workstream`: red on all but `[operator-decides]` (task 1.1).
- `workstreams-block-detach-not-deferral`: red on all but `[clears-last]` (task 1.1).
- `backlog-block-reads-none-entries`: red on all four (task 1.2).

## Obsolete tests

The change carries only `MODIFIED` deltas. What each supersedes, by comparing the requirement under `openspec/specs/` with the delta: every removed body line is a prefix the delta extends, not a statement it contradicts, save one: audit's "apply it as one edit across the entry files", now "across the entry files and the workstream files it opens".

Search: `tests/cases/*.sh` (no earlier `test-plan.md` was supplied), for the phrases of every removed line and for audit report numbering (`6.`/`7.`/`8.`, `Fixes`, `Unverified`).

No bearing test was found by this search; this is not a finding that none exists. Reviewed and judged not obsolete, recorded so the judgement can be checked:

- `backlog-skill-dir-audit-names` `[entry-files]` (requires `entry files` in the audit section): the superseded statement is extended, and the phrase survives decision 6's text. Not obsolete. Candidate for human confirmation.
- `workstreams-seeded-statements` (pins "Open a workstream when the operator decides" and "with the plan of the first change that advances it"): decision 1 keeps both. Not obsolete. Candidate for human confirmation.
- `workstreams-block-placing-settled` `[clears-last]`, `backlog-block-none-ends-a-search` `[none-after]`, `backlog-skill-sweep-detaches-by-read` `[archived-by-read]`: each pins a phrase decisions 2, 3 and 5 extend after, not replace. Not obsolete, provided the implementation keeps the phrase on one line as the plan's text does. Candidate for human confirmation.
- `backlog-skill-workstream-rules-not-restated` and `backlog-skill-restates-no-entry-rule` forbid restating rule phrases in the skill; none of their forbidden phrases is one decision 4, 5 or 6 adds to the skill. Not obsolete.

## Missing shared arrangement

The dispatch named `tests/lib.sh` and `tests/cases/lib/` as the shared arrangement. One local declaration:

- **`seed_and_check`**, declared in `tests/cases/workstreams-block-proposes-a-workstream.sh`, `tests/cases/workstreams-block-detach-not-deferral.sh` and `tests/cases/backlog-block-reads-none-entries.sh` (once per file). Stands in for: "discriminate the scans on a fixture, run `scripts/project-init` in a fresh directory, hold the seeded file to the scans". Used by: `bash tests/run.sh workstreams-block-proposes-a-workstream`, `bash tests/run.sh workstreams-block-detach-not-deferral`, `bash tests/run.sh backlog-block-reads-none-entries`. Near-miss: `scan_run` in `tests/cases/lib/static-scan.sh` checks `$TOOLKIT_ROOT`, not a seeded project, so it would read the fragment, not what `project-init` writes. Found in test modules `tests/cases/workstreams-block-placing-settled.sh` and `tests/cases/backlog-block-none-ends-a-search.sh` (identical), copied, not imported. Proposed home: `tests/cases/lib/static-scan.sh`, as a `scan_run_seeded REL` beside `scan_run`.

**Disposition: keep.** This repository's conventions record no shared arrangement's location (`record-this-repositorys-shared-test-arrangement` holds that decision), so `seed_and_check` stays local, as the identical copies it was taken from do; that entry names it.

The five `backlog-skill-*` cases declare nothing locally: they take `scan`, `scan_run` from `tests/cases/lib/static-scan.sh` and `$TESTLIB` from `tests/lib.sh`.

## Unresolved project questions

- **Q1. Coverage ledger.** `tests/coverage.md` is outside the test-path glob; this pass did not write or read it. Assumption: task 3.3 adds the rows. The 8 rows to add are the *Added* rows of the table above, each with its case. Depends: none of the cases.
- **Q2. Shape of `audit.md`'s report sections.** Assumption: the merged report's sections are a numbered list written `N. **Name**`, per decision 6. Depends: `backlog-skill-audit-shared-goals` `[shared-goals-seventh]`, `[fixes-eighth]`, `[unverified-ninth]`. If the file writes them otherwise, those three derived scans are the ones to reconsider (recorded as a change to a derived assertion, not a repair).
- **Q3. "The workstreams README".** Decisions 4 and 6 have the skill say "the workstreams README" for `docs/workstreams/AGENTS.md`. Assumption: the skill uses that phrase, as the plan's text does. Depends: `backlog-skill-record-shared-goal-proposed` `[proposes]`, `backlog-skill-record-one-change-goal-not-proposed` `[defers]`, `backlog-skill-audit-shared-goals` `[opens-approved]`.
- **Q4. Stack skill.** `bash` was loaded; the scans follow the `backlog-skill-*` style the dispatch named. No question outstanding.

## Findings

- **F1.** `<changeRoot>/.openspec.yaml` does not exist, though the dispatch names it. It did not change the route here, since delta specs are present.

## Baseline

Full suite, `bash tests/run.sh` from the worktree root, before any case was written: **698 passed, 1 failed** (`command-absent-outstanding-blocks`, unrelated to this change, as the dispatch said). After writing, the 8 new cases run alone: 0 passed, 8 failed, all for the reasons recorded under *Red at authoring*. `shellcheck -x` is clean on all 8.
