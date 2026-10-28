# Test plan: list-what-a-project-receives

Written by `ai-toolkit:change-test-writer` from the delta specs at plan commit `eae70d7`, before any implementation. This file is not an artifact the OpenSpec schema knows about: `openspec instructions apply` does not list it, so read it on purpose before implementing.

Every test named here is runner-selectable as `bash tests/run.sh <case>` from the worktree root (`tests/cases/<case>.sh`). Several can be named in one run.

This pass added 44 files under `tests/cases/` and wrote this file. It edited, deleted and disabled nothing, and wrote no implementation. It adds tests and never subtracts. The existing cases this change makes obsolete are listed below for a person to confirm. None of them was touched.

## Baseline

A full baseline was taken before any test was written: `bash tests/run.sh` at `eae70d7`, a clean tree, gave **257 passed, 0 failed**. Every failure below is therefore attributable to this change's tests or to the implementation that follows.

After writing, the 44 new cases were run by name: **0 passed, 44 failed**. Every one is red at authoring, as tests written before implementation should be. No case passed on its first run, so none raises the alarm a first-run pass would.

What each failure establishes:

- **State 2: target absent. The assertions have not executed yet.** 25 cases stop on an absent `rules/manifest`, `rules/backlog.md` or `rules/workstreams.md`, or on a `docs/<dir>/AGENTS.md` that a run did not write:
  - `manifest-*` (all except `manifest-target-link-not-written-through` and `manifest-read-from-own-copy`)
  - `block-marker-hash-matches-contents`, `block-marker-version-and-body`, `block-marker-edit-changes-hash`
  - `backlog-block-*`, `workstreams-block-*`, `dir-claude-md-*`
  - `rules-manifest-only-non-fragment`, `help-names-manifest-blocks`, `backlog-fragment-absent-blocks-every-run`
- **State 1: the code ran and produced the wrong value.** The other 19 cases:
  - **The current tool's behaviour is the one the delta replaces.** `block-marker-legacy-v12-read` (the version `12` is not semantic). `legacy-readme-*` (no shape statement). `manifest-target-link-not-written-through` (no refusal reported). `manifest-read-from-own-copy` (no marker in the new form). `hash-command-absent-blocks-outstanding` (exit 0 rather than 2).
  - **The migrate cases.** A README is still written; an `agents` entry converts; the seed is still a precondition.
  - **The static scans.** `plugin-version-semantic` (`0.2.0`). `rules-fragment-versions-semantic` (counter versions). `toolkit-structure-rule-text-has-one-home` (AGENTS.md names `scripts/seed/`). `backlog-skill-*` and `workflow-fragment-defers-to-directory-agents-md` (README paths).
- **Static checks red at authoring.** The static checks are recorded here as red at authoring, on the property each one names. They are `manifest-lists-three-blocks`, `manifest-fragments-kind-semver`, `rules-fragment-versions-semantic`, `rules-manifest-only-non-fragment`, `plugin-version-semantic`, `toolkit-structure-rule-text-has-one-home`, `backlog-skill-rules-file-agents-md`, `backlog-skill-record-refuses-agents-claude`, `workflow-fragment-defers-to-directory-agents-md`, `backlog-block-reserved-names` and `workstreams-block-reserved-names`. When they go green as the change lands, read that against this record.
  - **Each also carries a fixture-driven discriminator, and every discriminator ran and rejected its mutants.** One discriminator failed on first run: `manifest-lists-three-blocks`' `version:` mutant was caught by another check first. That was a state-3 defect in the test, and it was repaired in this pass by reordering the checks. No assertion changed.
- **One state-2 case is waiting on code, not on files.** `manifest-lists-three-blocks` fails today only because `rules/manifest` is absent. Its discriminator passes.

All 44 new files pass `shellcheck -x` with no finding.

## Unresolved project questions

1. **Shared test arrangement.**
   - **The gap.** The dispatch named no shared arrangement. `AGENTS.md` and `tests/README.md` neither name one nor state that the project has none. `tests/coverage.md` records the same gap as `record-this-repositorys-shared-test-arrangement`.
   - **Assumption taken.** `tests/lib.sh` is the runner's harness, not arrangement. `run.sh` exports it as `$TESTLIB` and `tests/README.md` documents it as what every case sources. So every new case sources it.
   - **Assumption taken.** `tests/cases/lib/static-scan.sh` and `line-scan.sh` are test modules. They sit inside the test-path glob and were not dispatched as shared arrangement. No new case imports them, and their function is declared locally instead.
   - **Depending on it:** every new case. All 44 source `$TESTLIB`, and the 11 static cases declare their scans locally.
2. **Report wording.**
   - **The gap.** The specs state what the report must say about four new things, but not the wording:
     - a refused target
     - a directory's `CLAUDE.md` created or needing the import
     - a README in the shape before `1.0.0`
     - the run's outcome when a record is refused
   - **The report contract is not updated.** The contract in `tests/README.md` is the project's normative form for report tokens, and this change does not yet update it.
   - **Assumption taken.** Tokens are matched tolerantly, as listed under *Derived assertions*, and the existing tokens are kept:
     - `backlog: created`, `backlog: … already present`, `backlog: … beside …`
     - `workstreams: created`, `workstreams: … already present`
     - `conventions file:`, `Outcome: BLOCKED`
     - exit codes 0, 1 and 2
   - **Depending on it:**
     - `legacy-readme-backlog-left-alone`, `legacy-readme-workstreams-left-alone`
     - `dir-claude-md-*`, `manifest-target-link-not-written-through`
     - `backlog-block-*`, `workstreams-block-*`
     - `block-marker-legacy-v12-read`, `backlog-migrate-then-project-init-writes-block`
   - **Recommendation.** Record the new lines in `tests/README.md`'s contract when task 2.4 settles them.
3. **Stack skill.** The library carries a `bash` skill, but it was not loaded for this pass. The idiom was taken from the existing cases and checked with ShellCheck. No test depends on anything the skill alone would have supplied.

## Scenario accounting

The delta specs hold 159 scenarios: `project-bootstrap` 70, `toolkit-structure` 24, `backlog-migration` 26, `backlog-maintenance` 18 and `session-workflow` 21. The four `REMOVED` requirements carry no scenarios in the delta. Each scenario is accounted for once below, as one of these:

- **N**: covered by a new case.
- **E**: covered by an existing case that still holds unchanged.
- **R**: covered by an existing case only once the assertion the obsolete list names is revised. Until then that case is red for a path or token reason, not a behavioural one.
- **U**: uncovered, with the reason.

Where a scenario has a mechanical half and a conduct half, only the mechanical half is covered, and the case header says so.

**Why the carried-over content scenarios are R and not N.** The backlog's entry rules and the workstream rules move unchanged from a README into a block. The spec says "the entry rules are carried over unchanged", and the workstreams requirement says "every scenario keeps its title". So the scenarios about what those texts *say* are covered by the existing `backlog-dir-seeded-*`, `workstreams-seeded-*` and `workstreams-dir-*` cases once their path is re-anchored, as task 5.1 owes.

Writing duplicates of those cases at the new path would leave two copies after 5.1. This pass covers instead:

- **what changed about the texts:** reserved names and "this file", in `backlog-block-reserved-names` and `workstreams-block-reserved-names`
- **where they are delivered:** the `*-block-*` cases
- **that the block is the fragment byte for byte:** `block-marker-version-and-body`

**Totals:** a new case among its tests 51 (N 32, N+R 14, N+E 1, E+N 2, N+E+R 2), E alone 51, E+R 1, R alone 30, U 26; 159 in all.

### project-bootstrap (70)

| Scenario | Op | Status | Tests |
|---|---|---|---|
| The manifest lists the three blocks | ADDED | N | `manifest-lists-three-blocks` |
| Every listed fragment exists with a kind and a semantic version | ADDED | N | `manifest-fragments-kind-semver` |
| A new project receives exactly the listed blocks | ADDED | N | `manifest-new-project-exactly-listed-blocks` |
| A record added to the manifest is written without a change to the tool | ADDED | N | `manifest-added-record-written` |
| A link at a target is not written through | ADDED | N | `manifest-target-link-not-written-through` |
| The marker's hash is the hash of what lies between the markers | ADDED | N | `block-marker-hash-matches-contents` |
| The marker's version is the fragment's | ADDED | N | `block-marker-version-and-body` |
| An edit inside a block changes what its hash describes | ADDED | N | `block-marker-edit-changes-hash` |
| An earlier marker is read | ADDED | N | `block-marker-legacy-v12-read` |
| A seeded directory gets its import | ADDED | N | `dir-claude-md-seeded` |
| A directory CLAUDE.md of the project's own is not written | ADDED | N | `dir-claude-md-project-own-unchanged` |
| A CLAUDE.md created beside a present block is reported | ADDED | N | `dir-claude-md-created-beside-present-block` |
| The root CLAUDE.md is never created | ADDED | N | `root-claude-md-never-created` |
| A backlog README is left alone | ADDED | N | `legacy-readme-backlog-left-alone` |
| A root README does not hold back the workflow block | ADDED | N | `legacy-readme-root-does-not-hold-back` |
| A workstreams README is left alone | ADDED | N | `legacy-readme-workstreams-left-alone` |
| A project without a backlog receives the seeded file | ADDED | N+R | delivery, modes and new statements: `backlog-block-new-project`, `backlog-block-reserved-names`; the listed statements: `backlog-dir-seeded-new-project` (R) |
| An existing backlog is preserved exactly | ADDED | N | `backlog-block-existing-preserved` |
| The seeded file carries no numbering | ADDED | R | `backlog-dir-seeded-no-entry-numbering` |
| The seeded entry shape carries the structured fields | ADDED | R | `backlog-dir-seeded-structured-keys` |
| A fix is distinguished from a change by what it owes | ADDED | R | `backlog-dir-seeded-kind-definition` |
| Priority's values and default are stated | ADDED | R | `backlog-dir-seeded-priority-values` |
| The seeded file offers no low priority | ADDED | R | `backlog-dir-seeded-priority-no-low` |
| The seeded file states how an entry leaves parked and high | ADDED | R | `backlog-dir-seeded-priority-transitions` |
| Workstream's default is stated | ADDED | R | `backlog-dir-seeded-workstream-default` |
| The seeded entry's fields are a list | ADDED | R | `backlog-dir-seeded-fields-are-a-list` |
| An absent value reads as its field | ADDED | R | `backlog-dir-seeded-absent-values` |
| A single-file backlog is pointed to the migration tool | ADDED | E | `backlog-dir-single-file-pointed-to-migrate`, `backlog-dangling-symlink-not-written-through` |
| A missing backlog fragment blocks every run | ADDED | N | `backlog-fragment-absent-blocks-every-run` |
| The rules are added beside existing entries | ADDED | N | `backlog-block-beside-existing-entries` |
| Project text beside the block survives | ADDED | N | `backlog-block-project-text-survives` |
| A backlog path that is not a directory is not written through | ADDED | R | `backlog-dir-not-a-directory-not-written-through` |
| Waits on holds only names | ADDED | R | `backlog-dir-seeded-waits-on-names-only` |
| The frontmatter is flat | ADDED | R | `backlog-dir-seeded-frontmatter-flat` |
| Fragments come from the copy the script belongs to | MODIFIED | N+R | `manifest-read-from-own-copy`; `self-location-conflicting-env` (R) |
| Explicit root reaches the working tree through the caller | MODIFIED | U | Caller-side resolution in the skill, not the script. The text is unchanged, and the accounting is the same as in `tests/coverage.md`. |
| A machine consumer can branch on the result | MODIFIED | E | every case's `assert_exit` against the documented codes |
| A command missing for an already-satisfied concern does not block | MODIFIED | E | `command-absent-satisfied-proceeds` |
| The fragment is read even when nothing will be written | MODIFIED | N | `manifest-fragment-absent-blocks` (the present-block run) |
| Missing fragment blocks rather than degrades | MODIFIED | N | `manifest-fragment-absent-blocks`, `backlog-fragment-absent-blocks-every-run` |
| A missing manifest blocks | MODIFIED | N | `manifest-absent-blocks` |
| A delegated command's writes are attributed, not concealed | MODIFIED | E | `adoption-agents-md-diff-only` |
| An existing ignore file is preserved exactly | MODIFIED | E | `existing-gitignore-preserved` |
| An existing conventions file receives only the managed block | MODIFIED | E+N | `existing-agents-md-appended`; the widened exception: `backlog-block-project-text-survives` |
| A project's adopted version is readable | MODIFIED | N+R | `block-marker-version-and-body`; `inlined-body-matches-fragment`, `managed-block-current-version` (R) |
| Project content below the block survives | MODIFIED | E | `existing-agents-md-appended` |
| A project with only a CLAUDE.md | MODIFIED | E | `claude-md-only` |
| Rules written but not yet loadable are reported as such | MODIFIED | E | `import-line-reported`, `import-line-names-own-claude-md` |
| A shadowing file above the target is reported like one in it | MODIFIED | E | `shadowing-claude-md-above-target`, `shadowing-claude-md-in-enclosing-repo` |
| The user's own instructions file does not shadow | MODIFIED | E | `home-dot-claude-does-not-shadow` |
| No CLAUDE.md yields a version note, not an instruction | MODIFIED | E | `no-shadowing-file-version-note`, `empty-directory-new-project` |
| An existing block at a different version is reported, not rewritten | MODIFIED | N+R | `block-marker-legacy-v12-read`; `managed-block-older-version` (R) |
| An edited fragment is distinguishable from the copy already adopted | MODIFIED | R | `managed-block-older-version` |
| A frontmatter-only edit does not consume a version | MODIFIED | U | An obligation on a future author, not behaviour a tool exhibits. The text is unchanged, and the accounting is the same as in `tests/coverage.md`. |
| Which part rises is decided by what the project must do | MODIFIED | U | Deliberately untested. Which part rises is an author's judgement of what an edit asks of a project. No program in this change chooses or checks it, and no scan can tell a minor edit from a patch. That the versions are semantic and at least `1.0.0` is checked by `rules-fragment-versions-semantic`, from the requirement text. |
| A legacy version reads as older | MODIFIED | U | Deliberately untested. Nothing in this change orders two versions: `project-init` reports both and compares neither, and ordering them is `update-managed-block`'s. That the tool *reads* a `v12` marker is covered by `block-marker-legacy-v12-read`. |
| A project without a workstream register receives the seeded file | MODIFIED | N+R | delivery, no workstream, no `archive/` and new statements: `workstreams-block-new-project`, `workstreams-block-reserved-names`; the listed statements: `workstreams-seeded-statements` (R) |
| An existing workstream register is preserved exactly | MODIFIED | N | `workstreams-block-existing-preserved` |
| The seeded register carries no status field | MODIFIED | R | `workstreams-seeded-no-status-field`, `workstreams-seeded-shape-sections-no-status` |
| An abandoned workstream is archived, not deleted | MODIFIED | R | `workstreams-seeded-abandoned`, `workstreams-seeded-abandoned-item` |
| A finished workstream is archived | MODIFIED | R | `workstreams-seeded-archive-on-done` |
| A step matching two sources takes the first status | MODIFIED | R | `workstreams-seeded-precedence` |
| Step order is not a dependency | MODIFIED | R | `workstreams-dir-order-names-waits-on` |
| The seeded workstream's fields are a list | MODIFIED | R | `workstreams-seeded-fields-are-a-list`, `workstreams-seeded-fields-list-then-sections` |
| A step is recorded by its entry file | MODIFIED | R | `workstreams-dir-step-recorded-by-entry-file` |
| Done when asks for an observable effect of the Goal | MODIFIED | R | `workstreams-seeded-done-when-shape`, `workstreams-seeded-done-when-statement` |
| Research shared by several steps has a place in the workstream | MODIFIED | R | `workstreams-seeded-shared-research-placed` |
| A decision for one step stays in that step's design | MODIFIED | R | `workstreams-seeded-one-step-decision-in-design` |
| What a workstream holds is not progress | MODIFIED | R | `workstreams-seeded-holds-not-progress` |
| Overturned content is revised in place | MODIFIED | R | `workstreams-seeded-overturned-revised-in-place` |

### toolkit-structure (24)

| Scenario | Op | Status | Tests |
|---|---|---|---|
| The plugin carries a semantic version | MODIFIED | N | `plugin-version-semantic` |
| Repository is installed as a plugin; Manifest placement; Development without installing; Packaging is verified, not assumed; Verification observes a component, not just the plugin | MODIFIED (unchanged) | U (5) | Installation and layout behaviour this harness does not exercise. The accounting is the same as in `tests/coverage.md`. |
| The manifest is the one file in rules/ that is not a fragment | MODIFIED | N | `rules-manifest-only-non-fragment` |
| The increment rule has exactly one owner | MODIFIED (unchanged) | U | A property of two specification files. The accounting is the same as in `tests/coverage.md`. |
| Placing a new skill; Skill placed too deep is undiscoverable; Agent invocation name carries no grouping; Names are unique per directory; Placeholders for unpopulated directories; A placeholder is not mistaken for an asset; A non-`.md` file beside an agent is not an asset; A procedural fragment is not inlined into a project | MODIFIED (unchanged) | U (8) | Layout and discovery behaviour. The accounting is unchanged. |
| A text two tools write has one home | MODIFIED | N | `toolkit-structure-rule-text-has-one-home` |
| Claude Code picks up conventions; Layout constraint is explained, not just stated; Library assets are distinguished from repository tooling; Authoring guidance is not duplicated into conventions; A deterministic operation is placed in shipped tooling; Shipped tooling is distinguished from repository helpers; Shipped tooling is not mistaken for an asset | MODIFIED (unchanged) | U (7) | Documentation this suite does not exercise. The accounting is unchanged. |

### backlog-migration (26)

| Scenario | Op | Status | Tests |
|---|---|---|---|
| A backlog is converted | ADDED | N+R | `backlog-migrate-entries-only-converts`; `backlog-migrate-converts` (R) |
| The rules are left to project-init | ADDED | N | `backlog-migrate-writes-no-rules` |
| A converted backlog receives the seeded rules | ADDED | N | `backlog-migrate-then-project-init-writes-block` |
| The tool commits nothing | ADDED | E | `backlog-migrate-commits-nothing` |
| The named project-init is the tool's own copy's | ADDED | N | `backlog-migrate-names-own-project-init` |
| An older bash | ADDED | E | `backlog-migrate-older-bash` |
| An uncommitted edit blocks | MODIFIED | E | `backlog-migrate-blocks-uncommitted-edit` |
| A converted backlog is not converted twice | MODIFIED | E | `backlog-migrate-blocks-existing-directory` |
| A heading that is not a name blocks | MODIFIED | E | `backlog-migrate-blocks-heading-not-name` |
| The seeded preamble's example is not an entry | MODIFIED | N+R | `backlog-migrate-fenced-example-entries-only`; `backlog-migrate-fenced-example-not-entry` (R) |
| A preamble with sections of its own | MODIFIED | R | `backlog-migrate-preamble-sections` |
| An entry named readme blocks | MODIFIED | E | `backlog-migrate-blocks-readme-entry` |
| An entry named agents or claude blocks | MODIFIED | N | `backlog-migrate-blocks-agents-claude-entry` |
| A malformed first entry blocks | MODIFIED | E | `backlog-migrate-blocks-malformed-first-heading` |
| Windows line endings | MODIFIED | E | `backlog-migrate-crlf-converts` |
| A failed write leaves the old file | MODIFIED | E | `backlog-migrate-write-failure` |
| A listed and a paragraph entry convert alike | MODIFIED | E | `backlog-migrate-list-and-paragraph-alike` |
| A parked entry | MODIFIED | E | `backlog-migrate-parked` |
| A wait on a change and on an answer | MODIFIED | E | `backlog-migrate-wait-on-change-and-answer` |
| A specification's name is not a wait | MODIFIED | E | `backlog-migrate-spec-name-not-a-wait` |
| Waits on nothing with a note | MODIFIED | E | `backlog-migrate-waits-on-nothing-note` |
| A fence after a field stays out of the value | MODIFIED | E | `backlog-migrate-fence-after-field` |
| A fence of the other marker does not close | MODIFIED | E | `backlog-migrate-mixed-fence-markers` |
| An unknown field is kept | MODIFIED | E | `backlog-migrate-unknown-field-kept` |
| An entry with no Kind | MODIFIED | E | `backlog-migrate-no-kind` |
| Earlier absent values are normalised | MODIFIED | E | `backlog-migrate-absent-values-normalised` |

### backlog-maintenance (18)

All covered in their mechanical half only. What a session does when it runs an operation is not reachable by a scan.

| Scenario | Op | Status | Tests |
|---|---|---|---|
| Invoked from a consuming project | MODIFIED | N+R | `backlog-skill-rules-file-agents-md`; `backlog-skill-dir-identity` (R) |
| No backlog exists | MODIFIED | N+R | `backlog-skill-rules-file-agents-md` (absent-names-project-init); `backlog-skill-dir-absent-backlog` (R) |
| No workstream register exists | MODIFIED | N+R | `backlog-skill-rules-file-agents-md` (workstreams-agents, absent-names-project-init); `backlog-skill-absent-workstream-register` (R) |
| A project on the single file | MODIFIED | E | `backlog-skill-dir-single-file-refused` |
| A project on the rules' earlier README | MODIFIED | N | `backlog-skill-rules-file-agents-md` (readme-fallback, not-entries) |
| A project's preamble differs from the seeded one | MODIFIED | N+E+R | `backlog-skill-rules-file-agents-md` (backlog-agents); `backlog-skill-restates-no-entry-rule` (E); `backlog-skill-dir-reads-readme` (R) |
| The skill does not mandate an audit cadence | MODIFIED | E | `backlog-skill-no-audit-cadence` |
| A project's workstream README differs from the seeded one | MODIFIED | N+R | `backlog-skill-rules-file-agents-md` (workstreams-agents); `backlog-skill-workstream-rules-not-restated` (R) |
| A name already used by an archived change | MODIFIED | E | `backlog-skill-record`, `backlog-skill-dir-record-file` |
| Record refuses a name colliding with the rules' files | MODIFIED | N+E | `backlog-skill-record-refuses-agents-claude`; `backlog-skill-dir-record-file` (readme) |
| An overlapping entry exists | MODIFIED | E | `backlog-skill-record`, `backlog-skill-dir-record-names-and-conditions`, `backlog-skill-record-absent-value` |
| Work the change can fold in | MODIFIED | E | `backlog-skill-record-fold-in` |
| Record defaults Priority | MODIFIED | E | `backlog-skill-record-priority` |
| Record parks an entry only on the operator's word | MODIFIED | E | `backlog-skill-record-priority`, `backlog-skill-dir-record-names-and-conditions` |
| Record carries the change's workstream | MODIFIED | E | `backlog-skill-record-absent-value` |
| Record refuses a workstream that is not open | MODIFIED | E | `backlog-skill-record-absent-value` |
| Record keeps a condition out of waits_on | MODIFIED | E | `backlog-skill-dir-record-names-and-conditions` |
| Record writes one file | MODIFIED | E | `backlog-skill-dir-record-file` |

### session-workflow (21)

All covered in their mechanical half only, since each case reads the fragment's text.

| Scenario | Op | Status | Tests |
|---|---|---|---|
| A blocking dependency survives the session ending | MODIFIED (unchanged) | U | What a session does. The accounting is unchanged. |
| An unrelated improvement is recorded rather than implemented | MODIFIED | E | `workflow-fragment-backlog-dir-routing-owed`, `workflow-fragment-second-change-excludes-folded` |
| A backlog entry is cited by name | MODIFIED | E+R | `workflow-fragment-backlog-dir-defers`; `workflow-fragment-backlog-dir-readme-states-rules` (R) |
| The scope rule and the backlog are one obligation | MODIFIED | E | `workflow-fragment-second-change-excludes-folded` |
| The backlog does not yet exist | MODIFIED | E | `workflow-fragment-backlog-dir-defers` |
| Entry rules are read from the backlog, not the fragment | MODIFIED | N+E+R | `workflow-fragment-defers-to-directory-agents-md`; `workflow-fragment-backlog-dir-defers` (E); `workflow-fragment-backlog-dir-readme-states-rules` (R) |
| An identified change is opened without a proposal | MODIFIED | E | `workflow-fragment-backlog-dir-handoff` |
| A handoff is not left uncommitted on a branch the session leaves | MODIFIED | E | `workflow-fragment-handoff-branch-committed` |
| An opened-and-left branch does not become the session's working branch | MODIFIED | E | `workflow-fragment-backlog-dir-handoff` |
| A deferral outlives the change that recorded it | MODIFIED | R | `workflow-fragment-backlog-dir-readme-states-rules` (outside-any-change) |
| Recording is stated as what is owed | MODIFIED | E | `workflow-fragment-backlog-dir-routing-owed` |
| An entry completed by an archived change is removed with its record | MODIFIED | R | `workflow-fragment-backlog-dir-archive-reread` |
| An entry waiting on the archived change is marked takeable | MODIFIED | R | `workflow-fragment-backlog-dir-archive-reread` |
| The fragment defers the update's form to the file | MODIFIED | N+R | `workflow-fragment-defers-to-directory-agents-md`; `workflow-fragment-backlog-dir-archive-reread` (R) |
| The obligation holds where the skill is absent | MODIFIED | R | `workflow-fragment-backlog-dir-archive-reread` |
| A proposal in a workstream names it | MODIFIED | E | `workflow-fragment-draft-names-workstream` |
| A proposal in no workstream says so | MODIFIED | E | `workflow-fragment-draft-names-workstream` |
| A workstream is proposed, not opened | MODIFIED | E | `workflow-fragment-draft-names-workstream` |
| Derived work is attached by the backlog's rule, not the fragment's | MODIFIED | E+N | `workflow-fragment-backlog-dir-routing-names-no-workstream`; `workflow-fragment-defers-to-directory-agents-md` (backlog-agents) |
| Archiving the last step archives the workstream | MODIFIED | N+R | `workflow-fragment-defers-to-directory-agents-md`; `workflow-fragment-archive-workstream-reread` (R) |
| The fragment defers the workstream rules to the README | MODIFIED | N+R | `workflow-fragment-defers-to-directory-agents-md`; `workflow-fragment-workstream-rules-not-restated` (R) |

## Assertion classification

Every new case's header records the classification of each of its assertions, marked SPECIFIED, DERIVED or DELIBERATELY UNTESTED, with its reason. What follows collects them, so that a derived assertion is visible for review without opening each file.

**Specified**, traced to delta-spec text. This is everything the tables above cite as a scenario, plus these requirement-text clauses that carry no scenario of their own:

- `manifest-fragment-invalid-blocks`: a listed fragment without a `kind`, or with a non-semantic `version`, blocks.
- `hash-command-absent-blocks-outstanding`: no hash command while a block is outstanding blocks, and the same with nothing outstanding does not.
- `rules-fragment-versions-semantic`: every versioned fragment is `MAJOR.MINOR.PATCH` and at least `1.0.0`.
- `dir-claude-md-seeded`' second run: an importing `CLAUDE.md` is left, and nothing is said of it.
- `backlog-migrate-names-own-project-init`: no seed precondition.
- `manifest-added-record-written`: a `CLAUDE.md` beside the added target.
- `manifest-target-link-not-written-through`: no `CLAUDE.md` for a refused record. "Write nothing for that record" is read to cover the record's `CLAUDE.md`. That reading is the case author's.

**Derived**, inferred and not fixed by any spec. Review these:

- **Report tokens** (question 2):
  - the `backlog:` and `workstreams:` lines naming `1.0.0` for a legacy README
  - a line naming `docs/workstreams/CLAUDE.md` and `@AGENTS.md`
  - a line naming `docs/backlog/CLAUDE.md` and `created`, other than the `backlog:` line
  - a line naming `docs/workstreams` and `not` for a refused link
  - `beside` on the `backlog:` line
  - `v12` and the carried version on the `conventions file:` line
  - `already present` with the carried version
  - `manifest` in the reason
  - `preamble`, `project-init` and `docs/backlog/AGENTS.md` in the migrate report
  - the invoked copy's absolute `scripts/project-init` path in the migrate report
- **The notice's words** `generated`, `replaced` and `outside the markers` (design.md decision 2).
- **Locating the body** as the block's last lines, as many as the fragment body's.
- **Two operationalisations:**
  - "no entry file" is read as the directory holding `AGENTS.md` and `CLAUDE.md` alone
  - "no workstream" is read as at most one heading outside fences, carried from `workstreams-seeded-new-project`
- **Reading the manifest:** "two keys" means every line is `name:`, `target:` or a separator.
- **Fixture and reading choices:**
  - `rules/manifest` is read as a regular file whose first line is not `---`
  - the plugin version is read with `sed`
  - a copy is probed for by a ≥40-character body line under `scripts/`
- **Wording patterns:**
  - the reserved-names statement (`readme`, `agents`, `claude` and `entry name` or `workstream name` on one line; `in any case`; `ignores case`)
  - the skill's rules-file patterns
  - the fragment's "its AGENTS.md" alternative
- **Ownership of the five fragments.** design.md decision 3 names five fragments as carrying a version.
- **From tasks.md:**
  - task 2.4: `--help` names every target, in `help-names-manifest-blocks`
  - task 3.2: the description no longer saying "seeding either README"
  - task 1.3: no README reference left in the fragment

**Deliberately untested:**

- the outcome and exit code of a run with a refused record, which the spec does not state
- that the skill writes no rules file and acts on a README project, which is conduct
- that record asks for another name, which is conduct
- the three U scenarios stated above as deliberately untested

## Obsolete tests

Each entry below is a **candidate for human confirmation, not a conclusion**. The search covered `tests/cases/**` only. No earlier `test-plan.md` was supplied, so none was used. Matches were found by `grep` for:

- `docs/backlog/README`, `docs/workstreams/README` and `README.md`
- `scripts/seed`
- `ai-toolkit:development-workflow`, `v$version`, `fragment_version` and numeric `version:`
- the report tokens these produce

Each hit was then read against the delta. "Revise" means changing only what the delta replaced, as task 5.1 states. "Retire" means the case's scenario was removed and a new case covers its successor.

**Pass or fail is not the test for an entry.** Ten entries say they may stay green. They still state what the delta superseded, and a person should decide whether to keep or rewrite them.

### Path of the backlog's rules: `docs/backlog/README.md` → the `backlog` block in `docs/backlog/AGENTS.md`

**Superseded by:** `project-bootstrap` REMOVED *A backlog is seeded where none exists*, ADDED *The backlog's rules are written where none exist*.

**Each case's assertion that must change:**

1. `backlog-dir-seeded-new-project`
   - `R=docs/backlog/README.md` must become `R=docs/backlog/AGENTS.md`.
   - The listing assertion `!= "README.md"` must become `AGENTS.md CLAUDE.md`.
   - Evidence: lines `R=…` and `listing … README.md`.
2. These ten cases share the same fix: `R=docs/backlog/README.md` (or `assert_file "$work/$R"`, or `r=…/README.md`) must point at `docs/backlog/AGENTS.md`. Their scans are unchanged.
   - `backlog-dir-seeded-absent-values`
   - `backlog-dir-seeded-priority-no-low`
   - `backlog-dir-seeded-kind-definition`
   - `backlog-dir-seeded-waits-on-names-only`
   - `backlog-dir-seeded-frontmatter-flat`
   - `backlog-dir-seeded-priority-transitions`
   - `backlog-dir-seeded-structured-keys`
   - `backlog-dir-seeded-priority-values`
   - `backlog-dir-seeded-workstream-default`
   - `backlog-dir-seeded-fields-are-a-list`
3. `backlog-dir-seeded-no-entry-numbering`
   - `r="$work/docs/backlog/README.md"` must become `…/AGENTS.md`.
4. `backlog-dir-seeded-adoption`
   - It asserts `docs/backlog/README.md` is created, `ls -A` equals `README.md`, and the README is compared with a fresh run's.
   - Revise all three to `AGENTS.md` (listing `AGENTS.md CLAUDE.md`), or retire it: `backlog-block-new-project` now covers adoption.
5. `backlog-dir-existing-preserved`
   - Its fixture is a project's own `docs/backlog/README.md`. Under *A directory holding its rules in a README is reported, not converted*, that is reported as the shape before `1.0.0`, not `backlog: already present`.
   - Its second half asserts `docs/backlog/README.md` is seeded.
   - Superseded by `legacy-readme-backlog-left-alone` and `backlog-block-existing-preserved`. Retire it, or revise it to those assertions.
6. `backlog-dir-readme-beside-entries` (**retire**)
   - It asserts `README.md` is created beside the entries and equals `scripts/seed/backlog-README.md`.
   - The REMOVED scenario *A README is added beside existing entries* is replaced by *The rules are added beside existing entries*, covered by `backlog-block-beside-existing-entries`.
7. `backlog-dir-seed-is-the-shared-file` (**retire**)
   - It asserts `scripts/seed/backlog-README.md` exists and equals the written README.
   - `scripts/seed/` is removed (toolkit-structure MODIFIED *Documentation separation of concerns*). The one-text property is now `block-marker-version-and-body`: the block equals `rules/backlog.md`'s body.
8. `backlog-dir-missing-seed-blocks-outstanding` (**retire**)
   - It asserts that a missing seed blocks only an outstanding backlog, and that a present backlog proceeds (exit 0).
   - The REMOVED scenario *A missing seed blocks only an outstanding backlog* is reversed by *A missing backlog fragment blocks every run*, covered by `backlog-fragment-absent-blocks-every-run`.
9. `backlog-dir-not-a-directory-not-written-through`
   - `assert_file "$work/docs/workstreams/README.md" "the remaining concerns proceed"`, twice, must become `docs/workstreams/AGENTS.md`.
10. `partial-init-reports-backlog`
    - `assert_file "$work/docs/backlog/README.md"` must become `…/AGENTS.md`.
11. `repeated-execution-backlog`
    - `assert_file` and `md5sum docs/backlog/README.md` must become `…/AGENTS.md`.
    - Watch `backlog: already present`: the line must now also carry versions.

### Path of the workstream rules: `docs/workstreams/README.md` → the `workstreams` block in `docs/workstreams/AGENTS.md`

**Superseded by:** `project-bootstrap` MODIFIED *A workstream register is seeded where none exists*.

12. `workstreams-seeded-new-project`
    - `readme=…/README.md` must become `…/AGENTS.md`.
    - "holds more than its README" (`find … ! -name README.md`) must allow `AGENTS.md` and `CLAUDE.md`.
13. These eighteen cases share the same fix: the `r=`, `R=` or `W=` path and `assert_file` of `docs/workstreams/README.md` must become `docs/workstreams/AGENTS.md`. Their scans are unchanged.
    - `workstreams-seeded-abandoned`
    - `workstreams-seeded-abandoned-item`
    - `workstreams-seeded-archive-on-done`
    - `workstreams-seeded-done-when-shape`
    - `workstreams-seeded-done-when-statement`
    - `workstreams-seeded-edit-rule-what-it-holds`
    - `workstreams-seeded-fields-are-a-list`
    - `workstreams-seeded-fields-list-then-sections`
    - `workstreams-seeded-holds-not-progress`
    - `workstreams-seeded-no-status-field`
    - `workstreams-seeded-one-step-decision-in-design`
    - `workstreams-seeded-overturned-revised-in-place`
    - `workstreams-seeded-precedence`
    - `workstreams-seeded-shape-sections-no-status`
    - `workstreams-seeded-shared-research-placed`
    - `workstreams-seeded-statements`
    - `workstreams-dir-order-names-waits-on`
    - `workstreams-dir-step-recorded-by-entry-file`
14. `workstreams-seeded-adoption`
    - The three `docs/workstreams/README.md` references must become `AGENTS.md`.
15. `repeated-execution-workstreams`
    - The `docs/workstreams/README.md` assertions must become `AGENTS.md`.
16. `partial-init-reports-workstreams`
    - `assert_file "$work/docs/workstreams/README.md"` must become `AGENTS.md`.
17. `workstreams-existing-preserved`
    - Its fixture is a project's own `docs/workstreams/README.md`. That is now reported as the shape before `1.0.0`, not `workstreams: already present`.
    - Superseded by `legacy-readme-workstreams-left-alone` and `workstreams-block-existing-preserved`.
18. `workstreams-dangling-symlink-not-written-through`
    - It asserts `workstreams: already present` for a dangling `docs/workstreams/README.md` link. A README present of any type now takes the legacy report (*A directory holding its rules in a README…*, with "a path is present where it exists of any type").
    - The token must change. The link and no-write-through assertions still hold.
19. `workstreams-write-failure-errors` (behaviour changed)
    - It asserts `ERROR` (exit 1) where `docs/workstreams` is a regular file.
    - ADDED *A project receives exactly the blocks the manifest lists* states that where a non-root target's directory "exists as something other than what the tool would write there", the tool writes nothing for that record, reports it, and the other records proceed. That reads as a refused record, not an `ERROR`.
    - Confirm the reading. If it holds, revise the exit and `Reason:` assertions.
20. `workstreams-report-line-after-backlog` (derived, may break)
    - It asserts the `workstreams:` line directly follows the `backlog:` line. The new obligation to report a created directory `CLAUDE.md` "on its own line" may fall between them.
    - Its assertion traces to an earlier change's design, not to this delta. Revise it only if the new line is placed there. `backlog-report-line-after-ignore-file` is in the same position, if lines are added before `backlog:`.

### Seed and conversion in `scripts/backlog-migrate`

**Superseded by:** `backlog-migration` REMOVED *The tool converts a single-file backlog into the directory* and REMOVED *The tool locates its resources itself…*, MODIFIED outcomes.

21. `backlog-migrate-converts`
    - Drop `assert_file "$work/docs/backlog/README.md" "the README is written"`.
    - The expected listing `README.md alpha-change.md beta-fix.md gamma-change.md` must lose `README.md`.
    - Superseded in substance by `backlog-migrate-entries-only-converts`.
22. `backlog-migrate-readme-is-seeded` (**retire**)
    - The REMOVED scenario *The README is the seeded one*. It asserts the written README equals `scripts/seed/backlog-README.md` and project-init's.
    - Successor: `backlog-migrate-writes-no-rules`.
23. `backlog-migrate-readme-from-own-copy` (**retire**)
    - The REMOVED scenario *The README comes from the tool's own copy*. It writes `scripts/seed/backlog-README.md` into two copies and compares the README.
    - Successor: `backlog-migrate-names-own-project-init`.
24. `backlog-migrate-blocks-preconditions`
    - The `missing-seed` block (`rm -f "$copy/scripts/seed/backlog-README.md"` … `expect_blocked missing-seed`) asserts a precondition the MODIFIED outcomes requirement drops. Remove that block only.
25. `backlog-migrate-fenced-example-not-entry`
    - The expected listing `README.md first-entry.md second-entry.md` must become `first-entry.md second-entry.md`. The scenario is revised to "exactly two entry files".
    - Superseded by `backlog-migrate-fenced-example-entries-only`.
26. `backlog-migrate-preamble-sections`
    - The expected listing `README.md first-entry.md second-entry.md` must lose `README.md`.

### Marker form and semantic versions

**Superseded by:** `project-bootstrap` ADDED *A block's opening marker records its version and a hash…*, MODIFIED *Workflow rules reach a project as a versioned managed block*, *The fragment's version increments…*, *Every run ends in one of three outcomes…*.

27. `inlined-body-matches-fragment`
    - `assert_contains … "<!-- ai-toolkit:development-workflow v$version -->"` must become the `<version> sha256:<hash>` form.
    - The awk start pattern `Project-specific conventions belong below the closing marker\. -->$` must follow the notice's new last line ("outside the markers").
    - Superseded by `block-marker-version-and-body`.
28. `managed-block-current-version`
    - Its fixture marker `printf '<!-- ai-toolkit:development-workflow v%s -->' "$version"` produces `v1.0.0`, which is neither marker form.
    - To stay "at the current version" it must be written in the new form, with a hash of its lines.
29. `managed-block-older-version`
    - `assert_contains "$report" "existing version 0"`: per *An earlier marker is read*, an earlier marker is reported as `v<N>`, e.g. `v0`, so the token must change.
    - `tool carries version $version` still holds.
30. `self-location-conflicting-env`
    - `assert_contains "$work/AGENTS.md" "v$version"` fails once the marker carries `1.0.0` with no `v`. It must read the marker's version field.
    - Its decoy also carries no manifest, which is harmless because it is never read. `manifest-read-from-own-copy` covers the revised scenario.
31. `fragment-absent-blocks` (passes for a different reason)
    - Its decoy copies `scripts/project-init` and no `rules/`. After the change it blocks on the absent manifest, not the absent fragment, so its exit-2 assertion no longer discriminates the scenario.
    - The fixture should copy `rules/` whole and remove `development-workflow.md` alone, as `manifest-fragment-absent-blocks` does. May stay green.
32. `fragment-absent-block-present-blocks` (passes for a different reason)
    - Same as 31.
33. `executable-bit-not-relied-upon`
    - `cp -R "$TOOLKIT_ROOT/scripts/seed" …` fails once `scripts/seed/` is removed.
    - It copies only `rules/development-workflow.md`, so the copy lacks the manifest and the other fragments and blocks.
    - It must copy `rules/` whole and drop the seed copy.
34. `workflow-fragment-version-after-backlog-dir`
    - `case "$version" in *[!0-9]*` fails "not a number" against `1.0.0`, and `-lt 12` cannot compare it.
    - It traces to an archived change's design (11 → 12). The reset to `1.0.0` (design.md decision 3) supersedes it. Retire it, or revise it to a semantic check.
35. `database-fragment-frontmatter`
    - `grep -q '^version:[[:space:]]*[0-9][0-9]*[[:space:]]*$'` ("declare a numeric version") rejects `1.0.0` (decision 3).
    - It must accept `MAJOR.MINOR.PATCH`.

### The skill reads each directory's rules file

**Superseded by:** `backlog-maintenance` MODIFIED *The skill operates on the project it is invoked in*, *The skill restates neither…*. The skill must read `AGENTS.md`, with `README.md` as its fallback. These scans require the README path, which the fallback may still name. All five may stay green, but their basis ("reads the rules from the README") is superseded.

36. `backlog-skill-dir-reads-readme`
    - `scan require … reads-readme 'docs/backlog/readme[.]md'` must become `docs/backlog/agents[.]md`.
37. `backlog-skill-dir-identity`
    - `scan require … names-readme 'docs/backlog/readme[.]md'` must become `docs/backlog/agents[.]md`.
38. `backlog-skill-dir-absent-backlog`
    - `line_scan require names-readme 'docs/backlog/readme[.]md'`, on the line naming `project-init` and absence, must name the rules file or `AGENTS.md`.
39. `backlog-skill-absent-workstream-register`
    - `register-absent` and `register-seeder` both match `docs/workstreams/readme[.]md`. They must match `docs/workstreams/agents[.]md`.
40. `backlog-skill-workstream-rules-not-restated`
    - `scan require … reads-readme 'docs/workstreams/readme[.]md'` must become `docs/workstreams/agents[.]md`.

### The fragment defers to the directories' `AGENTS.md`

**Superseded by:** `session-workflow` MODIFIED, all three requirements. Task 1.3 replaces every README reference, so each of these fails once the fragment is revised.

41. `workflow-fragment-archive-workstream-reread`
    - `line_select 'docs/workstreams/readme[.]md'` must become `docs/workstreams/agents[.]md`.
42. `workflow-fragment-backlog-dir-archive-reread`
    - `need as-readme-directs 'readme[^.]*directs'` and its mutant `s/as its README directs/…/` must name `AGENTS.md`.
43. `workflow-fragment-backlog-dir-readme-states-rules`
    - `line_scan require readme-states-rules 'readme[^.]*(states|carries)[^.]*entr'` must name `AGENTS.md`.
44. `workflow-fragment-workstream-rules-not-restated`
    - `scan require … defers-to-readme 'docs/workstreams/readme[.]md'` must become `docs/workstreams/agents[.]md`.

### `scripts/seed/` in AGENTS.md

**Superseded by:** `toolkit-structure` MODIFIED *Documentation separation of concerns*.

45. `toolkit-structure-seed-has-one-home` (**retire**)
    - `line_select 'scripts/seed/'` requires AGENTS.md's paragraph on `scripts/seed/`, which this change removes.
    - Superseded by `toolkit-structure-rule-text-has-one-home`.

**Searched and judged not obsolete.** Each of these names README, seed or the marker incidentally, or asserts behaviour the delta keeps:

- `backlog-dangling-symlink-not-written-through`, `backlog-dir-single-file-pointed-to-migrate`
- `backlog-write-failure-errors`: `docs` as a file, so the backlog is outstanding and `ERROR` stands.
- `backlog-skill-dir-single-file-refused`, `backlog-skill-dir-record-file`, `backlog-skill-absent-backlog`, `backlog-skill-identity`
- the other `backlog-migrate-*` cases (their listings are of `docs/`, not of `docs/backlog/`)
- `workflow-fragment-backlog-dir-defers`, `workflow-fragment-backlog-dir-routing-names-no-workstream`
- `existing-agents-md-appended`, `claude-md-only`, `adoption-agents-md-diff-only`, `empty-directory-new-project`
- `command-absent-*` (their reduced PATH keeps `/usr/bin`, so the hash commands stay reachable)
- `database-fragment-migrate-is-not-seed`: database seeding, unrelated.
- the `version: N` fixtures in `workflow-fragment-first-commit-*`, `workflow-fragment-arrangement-promotion` and `test-plan-fragment-missing-arrangement`: fixture texts for scans, never run through `project-init`.

`tests/coverage.md` is task 5.2's and is not a test.

## Missing shared arrangement

No shared arrangement was dispatched, and the convention files record none (question 1). So every new case declares its arrangement locally, and nothing is proposed into a home because none is named. A future shared arrangement could hold each entry below, in `tests/lib.sh` or a dispatched `tests/cases/lib/`.

| Declared | Stands in for | Declared in and used by | Near-miss in the shared arrangement | Found in a test module |
|---|---|---|---|---|
| `block_body`, `marker_line` | A reader of a managed block: its lines between the markers, and its opening line in the version-and-hash form | `block-marker-hash-matches-contents`, `block-marker-version-and-body`, `block-marker-edit-changes-hash`, `manifest-added-record-written`, `manifest-target-link-not-written-through`, `manifest-read-from-own-copy`, `dir-claude-md-project-own-unchanged`, `legacy-readme-root-does-not-hold-back`, `backlog-block-new-project`, `backlog-block-beside-existing-entries`, `backlog-block-project-text-survives`, `backlog-block-reserved-names`, `workstreams-block-new-project`, `workstreams-block-reserved-names`, `backlog-migrate-then-project-init-writes-block` | None | `inlined-body-matches-fragment` extracts a body with an inline awk keyed to the old notice. It is not reusable. |
| `sha256_of` | The hash command the marker names (`sha256sum`, or `shasum -a 256`) | `block-marker-hash-matches-contents`, `block-marker-edit-changes-hash` | None | None |
| `frag_key`, `frag_body` | A reader of any fragment's frontmatter key and body | `manifest-fragments-kind-semver`, `block-marker-version-and-body`, `block-marker-legacy-v12-read`, `backlog-block-existing-preserved`, `workstreams-block-existing-preserved`, `manifest-read-from-own-copy`, `rules-fragment-versions-semantic`, `rules-manifest-only-non-fragment`, `toolkit-structure-rule-text-has-one-home` | **`tests/lib.sh`'s `fragment_version`.** It reads `rules/development-workflow.md` only, under a root rather than a file, so it cannot read `backlog.md`, `workstreams.md` or a fixture fragment. It was not edited. | `fm_value` in the `backlog-migrate-*` cases reads entry frontmatter. It is not reused. |
| `manifest_records` | A reader of `rules/manifest`'s records | `manifest-lists-three-blocks`, `manifest-fragments-kind-semver`, `manifest-new-project-exactly-listed-blocks`, `block-marker-hash-matches-contents`, `block-marker-version-and-body`, `help-names-manifest-blocks` | None | None |
| `toolkit_copy` | A toolkit copy (`rules/` and `scripts/`) a case may alter | `manifest-added-record-written`, `manifest-absent-blocks`, `manifest-fragment-absent-blocks`, `manifest-fragment-invalid-blocks`, `backlog-fragment-absent-blocks-every-run` | None | The same `cp -R rules scripts` inline in `backlog-dir-missing-seed-blocks-outstanding` |
| `holds_import` | The check that a `CLAUDE.md` holds exactly `@AGENTS.md` | `dir-claude-md-seeded`, `dir-claude-md-created-beside-present-block`, `root-claude-md-never-created`, `manifest-added-record-written`, `backlog-block-new-project`, `backlog-block-beside-existing-entries`, `workstreams-block-new-project` | None | None |
| `scan_add`, `scan_hits`, `scan_text`, `scan_discriminate`, `scan_target` | Tagged require and forbid scans over a text, with a mutant per scan (a fixture-driven discriminator) | `backlog-block-reserved-names`, `workstreams-block-reserved-names`, `toolkit-structure-rule-text-has-one-home`, `backlog-skill-rules-file-agents-md`, `backlog-skill-record-refuses-agents-claude`, `workflow-fragment-defers-to-directory-agents-md` | None in the dispatched set | **`tests/cases/lib/static-scan.sh` and `line-scan.sh`.** They are test modules, and they scan files under a root rather than one text, with no `&&` conjunction, so they were not imported. |
| `md_section` | The section of a markdown file under a heading | `backlog-skill-record-refuses-agents-claude` | None | `scan_heading_section` in `tests/cases/lib/static-scan.sh` |
| `require_migrate`, `new_repo` | The `backlog-migrate` target-absent guard, and a git repository holding a committed `docs/backlog.md` | `backlog-migrate-entries-only-converts`, `backlog-migrate-writes-no-rules`, `backlog-migrate-then-project-init-writes-block`, `backlog-migrate-names-own-project-init`, `backlog-migrate-fenced-example-entries-only`, `backlog-migrate-blocks-agents-claude-entry` | None | The same helpers, declared locally in every `backlog-migrate-*` case (e.g. `backlog-migrate-converts`) |
| `three_entries` | A three-entry single-file backlog with a preamble | `backlog-migrate-entries-only-converts`, `backlog-migrate-writes-no-rules`, `backlog-migrate-then-project-init-writes-block` | None | The same shape, inline in `backlog-migrate-converts` |
| Per-case `check_*` and `expect` functions | The case's own check, and its discriminator runner | `manifest-lists-three-blocks`, `manifest-fragments-kind-semver`, `rules-fragment-versions-semantic`, `plugin-version-semantic`, `rules-manifest-only-non-fragment`, plus `hash_ok`, `rewrite_fm` and `run_blocked` in `block-marker-hash-matches-contents` and `manifest-fragment-invalid-blocks` | None | The `expect` shape appears in `workflow-fragment-backlog-dir-routing-names-no-workstream` |

## Findings for the dispatcher

- **No instruction addressed to a test writer was found in the artifacts.** Nothing like "skip", "no tests needed" or "already covered" appears.
- **`workstreams-write-failure-errors`.** The ADDED manifest requirement appears to turn a `docs/workstreams` that is a regular file from `ERROR` into a refused-and-reported record. If that is not intended, the requirement needs a clarification; that would be `openspec-update-change`'s work, not this pass's.
- **Report wording is not specified** for the new report statements (question 2). Neither is the outcome of a run that refuses a record. Six new cases assert tolerant tokens for these, labelled derived.

## Dispositions at implementation

- **Revised to the new path or token**: entries 1–4, 9–16, 18, 21, 24–30, 33, 35–44, as listed. `backlog-dir-seeded-adoption` was revised rather than retired.
- **Retired**: entries 5, 6, 7, 8, 17, 22, 23, 34 and 45. Each one's scenario is removed or superseded, and its successor case is named above.
- **Entry 19 confirmed**: the reading holds. `workstreams-write-failure-errors` is renamed `workstreams-dir-not-a-directory-not-written-through` and asserts a refused, reported record and a successful run. `backlog-write-failure-errors` stays an `ERROR`: the refusal covers only the target's own directory, and there `docs` itself is the file.
- **Entries 31 and 32** now copy `rules/` whole and remove only the workflow fragment, so they block on that fragment again.
- **Entry 20**: the `directory import:` lines follow the conventions file's line, so the backlog and workstreams lines stay adjacent and both ordering cases hold unchanged. The new lines are recorded in `tests/README.md`'s report contract.
- **A defect in a derived case**: `manifest-fragment-invalid-blocks`'s fixture check, `grep '^kind:'`, also matched the `kind: change` line in the backlog rules' entry shape. It is narrowed to the frontmatter; the assertion is unchanged.
- **Merged from the trunk**: `describe-commits-and-pull-requests` raised the workflow fragment to `13` and added `workflow-fragment-version-after-pr-binding`, requiring a whole-number version of at least 13. The fragment keeps `1.0.0`, which now names that body too, and the case is retired as entry 34's twin.
