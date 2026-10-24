# backlog-maintenance Specification

## Purpose
Defines the `backlog` skill: the on-demand operations a session performs over a project's `docs/backlog.md` — recording, picking, closing, sweeping at archive, and auditing entries — and the seam that keeps those operations from becoming a second statement of the entry rules or of the workflow's obligations.

## Requirements

### Requirement: The skill operates on the project it is invoked in

The library SHALL carry a skill at `skills/backlog/SKILL.md` whose directory name and `name` are `backlog`. It SHALL operate on `docs/backlog.md` of the project it is invoked in, not on this repository unless this repository is that project.

Where `docs/workstreams/README.md` is absent, an operation step that reads workstreams SHALL say so, name `project-init` as what seeds it, and be skipped, and the skill SHALL NOT create the file.

Its description SHALL state the six operations and the phrasings that reach them, and SHALL distinguish it from `project-init`, which seeds the file, and from the OpenSpec skills, which open and carry the change an entry names.

#### Scenario: Invoked from a consuming project

- **WHEN** the skill is invoked in a project that installed this library as a plugin
- **THEN** it reads and writes that project's `docs/backlog.md`, and touches nothing in this library

#### Scenario: No backlog exists

- **WHEN** the skill is invoked in a project with no `docs/backlog.md`
- **THEN** it says so and names `project-init` as what seeds the file, and does not create the file with text of its own

#### Scenario: No workstream register exists

- **WHEN** an operation that reads workstreams is invoked in a project with no `docs/workstreams/README.md`
- **THEN** it says so, names `project-init` as what seeds the file, skips the workstream steps, and creates nothing

### Requirement: The skill restates neither the entry rules nor the workflow's obligations

The skill SHALL read how an entry is shaped, named, kept and deleted from the backlog file's own preamble, and SHALL NOT restate those rules. It SHALL NOT place an obligation on a session that the workflow fragment does not state, and SHALL NOT be required for any obligation the fragment states to be met. The checks an operation performs and the gates on its own edits are procedure: they bind a session only while it runs that operation, and an entry or an archive done without the skill is not deficient for lacking them. This is the seam `session-workflow` states for an operational skill.

It SHALL likewise read how a workstream is named, shaped, kept and archived, and how a step's status is derived, from `docs/workstreams/README.md`, and SHALL NOT restate those rules.

The entry rules and the workstream rules are owned by `project-bootstrap` and stated in their files; the obligations to record, and to re-read at archive, are owned by `session-workflow` and stated in the fragment. A third statement of either is a wording that drifts from both, and a skill is loaded only when something judges it relevant, so it cannot be where an obligation lives.

#### Scenario: A project's preamble differs from the seeded one

- **WHEN** a project's `docs/backlog.md` states an entry shape that differs from the one `project-init` seeds
- **THEN** the skill records and checks entries against the shape that file states, not against a shape of its own

#### Scenario: The skill does not mandate an audit cadence

- **WHEN** a session reads the skill
- **THEN** it finds no rule obliging an audit at any interval, since the fragment states none

#### Scenario: A project's workstream README differs from the seeded one

- **WHEN** a project's `docs/workstreams/README.md` states a status derivation or a workstream shape that differs from the one `project-init` seeds
- **THEN** the skill reads workstreams and derives status by what that file states, not by rules of its own

### Requirement: Record writes an entry the file can be relied on for

The **record** operation SHALL write one entry in the shape the file states. Where the session invoking it is in a change, record SHALL first test the work against the fold-in rule the project's workflow states, where it states one, taking the test from the workflow rather than stating it; where the work meets it, record SHALL say so and write no entry. It SHALL offer no override the workflow does not state. Before writing, it SHALL check the entry's name against the backlog's headings, the project's open and archived change directories, and its branches, and SHALL not write a name already used by any of them. It SHALL set Kind by the file's own definition and state the reason. It SHALL search the existing entries for ones touching the same files, specifications or capabilities and present each as a Design with candidate, writing into Design with only the candidates the session or operator confirms share a design, or `nothing`. A shared pointer is evidence of a shared design, not the same thing. Where the file's shape names Priority, it SHALL set Priority to the file's default — `normal` in the seeded file — unless the session or the operator states the evidence or the condition the file requires for another value, and SHALL write `high` or `parked` only once the operator confirms it. Where the file's shape names Workstream, it SHALL set Workstream to the workstream of the change the session is in, where it is in one, unless the session or the operator states that the entry serves another goal or none, and otherwise to `nothing`; it SHALL write only a name an open workstream in `docs/workstreams/` carries, or `nothing`. Where `docs/workstreams/README.md` exists, its name check SHALL also cover the names of workstreams, open and archived. It SHALL set Re-checked to the day the entry is written.

Urgency and deferral are the operator's judgements about the project's work, not facts a session can verify alone, which is why record proposes them and does not set them on its own.

The fold-in test, the name check and the overlap search are the operation's procedure, not entry rules or obligations: the workflow states when work is folded in, the file states that an entry is named and may name entries to design with, and record is how the skill makes those statements hold for the entry it writes.

#### Scenario: A name already used by an archived change

- **WHEN** record is asked to write an entry whose name matches an archived change's directory
- **THEN** it does not write the entry under that name and asks for another

#### Scenario: An overlapping entry exists

- **WHEN** record writes an entry naming a file another entry also names
- **THEN** record presents that other entry as a Design with candidate, and names it in Design with only once it is confirmed to share a design

#### Scenario: Work the change can fold in

- **WHEN** record is invoked during a change for a small correction in a file that change edits, owing no delta and no decision, in a project whose workflow states a fold-in rule
- **THEN** record says the work can be folded in and writes no entry

#### Scenario: Record defaults Priority

- **WHEN** record writes an entry and neither the session nor the operator states evidence of current harm or a condition to park it under
- **THEN** the entry's Priority is `normal`

#### Scenario: Record parks an entry only on the operator's word

- **WHEN** a session judges an entry not worth taking until a stated condition holds
- **THEN** record proposes `parked until` that condition and writes it only once the operator confirms

#### Scenario: Record carries the change's workstream

- **WHEN** record writes an entry from a change whose proposal names an open workstream, and nothing states the entry serves another goal
- **THEN** the entry's Workstream names that workstream

#### Scenario: Record refuses a workstream that is not open

- **WHEN** record is asked to set Workstream to a name no open workstream carries
- **THEN** it does not write that name, and asks for an open workstream or `nothing`

### Requirement: Pick lists what can be taken now

The **pick** operation SHALL list the entries whose Waits on is `nothing`, split into `fix` and `change`, with entries that name each other in Design with listed together. Where the file's shape names Priority, `high` entries SHALL be listed first, a Design with group placed by its highest-priority member. Waits on governs first: an entry whose Waits on is not `nothing` is not takeable whatever its Priority. An entry whose Priority is `parked` SHALL NOT be listed as takeable; where its Waits on is `nothing` or already satisfied it SHALL be listed apart, under Parked, with its condition and any satisfied wait named beside it, and where it is still waiting it is not offered at all, as any blocked entry is not. A parked entry whose condition already holds and whose wait is `nothing` or satisfied SHALL be listed as takeable once updated, naming what fulfilled it. Where the file's shape names Workstream, it SHALL group without changing what is takeable, which Waits on alone decides: within each of the takeable `fix` and `change` lists, entries naming one workstream SHALL be listed together as one group, placed by its highest-priority member as a Design with group is; inside the group, `high` entries come first, then the others in the workstream's step order, then entries naming it without being a step, listed as unplaced; a Design with group whose members name different workstreams sits in the group of its highest-priority member, then of its earliest step, at its earliest member's step position; entries naming `nothing` are grouped as before. Where given paths, it SHALL narrow the list to entries naming any of them. An entry whose Waits on names something already satisfied — a change that is archived, say — SHALL be listed apart, as takeable once updated, rather than hidden as blocked. It SHALL write nothing, and SHALL NOT open a change or begin an entry's work.

#### Scenario: A blocked entry is not offered

- **WHEN** an entry waits on a change that is not archived
- **THEN** pick does not list it as takeable

#### Scenario: A wait already satisfied but not updated

- **WHEN** an entry waits on a change that has since been archived and the entry was never updated
- **THEN** pick lists it apart as takeable once updated, naming the archived change

#### Scenario: Pick narrowed to files

- **WHEN** pick is given a set of paths
- **THEN** it lists only takeable entries naming one of those paths

#### Scenario: A parked entry is not offered as takeable

- **WHEN** an entry waits on `nothing` and its Priority is `parked until` a condition that does not hold
- **THEN** pick lists it apart as parked, with its condition, and not as takeable

#### Scenario: A parked entry whose condition holds

- **WHEN** a parked entry's condition already holds and the entry was never updated
- **THEN** pick lists it as takeable once updated, naming what fulfilled the condition

#### Scenario: A parked entry still waiting

- **WHEN** a parked entry's condition holds but it waits on a change that is not archived
- **THEN** pick does not list it as takeable, as takeable once updated, or under Parked

#### Scenario: High entries come first

- **WHEN** pick lists takeable entries and some carry Priority `high`
- **THEN** those entries are listed before the others in their list

#### Scenario: Pick lists a workstream's entries in step order

- **WHEN** pick lists takeable entries of which two, of one Kind and one Priority, name one workstream and are its third and first steps
- **THEN** they are listed in that workstream's group, the first step before the third

#### Scenario: A high step leads its workstream's group

- **WHEN** a workstream's group holds its first step at `normal` and its third at `high`
- **THEN** the third is listed first, and the group is placed as a group with a `high` member

#### Scenario: An unplaced entry is shown under its workstream

- **WHEN** a takeable entry names a workstream whose steps do not name it
- **THEN** pick lists it in that workstream's group, as unplaced, and not apart from it

### Requirement: Close removes an entry and every reference to it

The **close** operation SHALL delete the entry it is given and, in the same edit, update every other entry that names it in Waits on or Design with, so no entry is left pointing at a name the file no longer carries. Where an open workstream's steps name the closed entry, close SHALL name that workstream and the step, so its plan can be revised; it SHALL NOT edit the workstream file.

#### Scenario: A closed entry was another's only wait

- **WHEN** close deletes an entry another entry names as its only Waits on
- **THEN** that other entry's Waits on no longer names it, and the entry is takeable

#### Scenario: A closed entry was a workstream's step

- **WHEN** close deletes an entry an open workstream names among its steps
- **THEN** close names that workstream and step, and leaves the workstream file unchanged

### Requirement: Sweep performs the archive step's re-read

The **sweep** operation, given a change, SHALL find the entries it completed, made obsolete, unblocked, unparked or made stale. It SHALL search for entries naming the change, entries whose Waits on it satisfies, entries whose parked condition it fulfils, entries whose `high` evidence it removes, entries naming files or specifications the change touched, and, where the change's archive archives a workstream, entries naming that workstream.

It SHALL take what the change touched from the change's merged pull requests on the forge — every one of them, since a change takes at least two — and, where the forge cannot be reached, from the change's specification deltas and the files its design and tasks name, saying that the fallback was used. It SHALL NOT take them from the branch's diff against the trunk: by the archive step the branch has been brought back to the trunk, and a squash merge leaves no ancestry, so that diff holds the record alone.

Run before the archive commit, it SHALL update each entry as the file directs and leave the edit for that commit. Run after the change's record is on the trunk, it SHALL make the same edit and say that it is to be delivered as the workflow delivers work too small to be a change.

Searching by what the change touched, and not only by name, is required because a change that finishes an entry's work seldom names the entry.

#### Scenario: An entry finished without being named

- **WHEN** sweep runs for a change whose diff completes an entry that the change never mentions
- **THEN** sweep finds the entry through the files the change's merged pull requests touched, and presents it for deletion

#### Scenario: Sweep after a squash merge

- **WHEN** sweep runs at the archive step for a change whose work was squash-merged
- **THEN** it still finds what the change touched, from the forge's record of its merged pull requests, not from the branch's diff

#### Scenario: Sweep after the record has landed

- **WHEN** sweep is run for a change whose record is already on the trunk
- **THEN** it makes the edit and says it is to be delivered as work too small to be a change, not left for an archive commit that no longer exists

#### Scenario: A change fulfils a parked entry's condition

- **WHEN** sweep runs for a change that fulfils the condition a parked entry names
- **THEN** sweep presents that entry with its Priority proposed as the file directs, `normal` or `high` with evidence

#### Scenario: A change removes a high entry's evidence

- **WHEN** sweep runs for a change that removes the harm a `high` entry's evidence names, in a file directing that such an entry becomes `normal`
- **THEN** sweep presents that entry with its Priority proposed as the file directs, `normal`

#### Scenario: Entries naming a workstream being archived

- **WHEN** sweep runs for a change whose archive makes its workstream's Done when hold
- **THEN** sweep presents every entry naming that workstream, to be re-pointed or set to `nothing` as `docs/workstreams/README.md` directs

### Requirement: Audit verifies every entry independently and changes nothing without the operator

The **audit** operation SHALL divide the backlog into ranges and give each range to a separate read-only agent run in parallel. Each agent SHALL verify every entry in its range against the code, the specifications, the open and the archived changes, the commit history and the forge's merged pull requests, and SHALL return for each entry a relevance verdict — `live`, `stale`, `partly-done`, `obsolete` or `waiting` — and a kind verdict — `fix`, `change` or `fix?` — each with its evidence. Where the file's shape names Priority, for an entry whose Priority is `high` it SHALL say whether the evidence still holds, and for one whose Priority is `parked`, whether its condition now holds. Where the file's shape names Workstream, it SHALL say whether the workstream an entry names is open in `docs/workstreams/`.

The archived changes and merged pull requests are named because an entry is most often completed by a change that never mentions it, and an agent checking the code alone reads such an entry as live.

The skill SHALL merge the agents' results into one report naming: the entries done or obsolete, the entries that are one change recorded twice, the entries whose facts are stale — among them each `high` entry whose evidence no longer holds, with its Priority corrected as the file directs, and each entry naming a workstream that is archived or absent —, the groups that share a design, the entries now unblocked or unparked, and the entries that can be taken as fixes. It SHALL apply none of it until the operator says so, and SHALL then apply it as one edit to `docs/backlog.md`, delivered as the workflow delivers work too small to be a change.

The agents SHALL write nothing. Each is given the entries, the paths to check and the verdict vocabulary, and returns its verdicts; only the skill edits the file, and only after the operator's word.

#### Scenario: An entry done by an unmentioning change

- **WHEN** an entry's work was completed by an archived change that never names the entry
- **THEN** the agent checking it finds the change among the archived changes or merged pull requests and returns `obsolete` or `partly-done` with that change as evidence

#### Scenario: The report is not applied unasked

- **WHEN** the audit's report is ready
- **THEN** `docs/backlog.md` is unchanged until the operator approves the cleanup

#### Scenario: Two entries recorded for one change

- **WHEN** two entries describe the same change under different names
- **THEN** the report names them as one change recorded twice

#### Scenario: A parked entry whose condition has fired

- **WHEN** an entry is parked until a condition that now holds
- **THEN** the report names it among the entries now unparked, with the evidence that the condition holds

#### Scenario: An entry names an archived workstream

- **WHEN** an entry's Workstream names a workstream whose file is under `docs/workstreams/archive/`
- **THEN** the report names it among the stale facts

### Requirement: Entries in an older shape are reported, not rewritten

Where an entry lacks a field the file's shape names, the skill SHALL report it as unclassified wherever that field decides the outcome, and SHALL NOT invent the field's value. Where the file itself states what an entry without the field means — as the seeded file does for Priority, an absent one being `normal` — the skill SHALL read the entry as the file states, and SHALL NOT report it as unclassified for that field: the value is the file's, not invented. It SHALL rewrite an entry into the current shape only on the operator's word.

Backlogs written before the shape gained its fields are left byte-for-byte unchanged by `project-init`, so the skill meets them as they are.

#### Scenario: Pick meets an entry with no Kind

- **WHEN** pick lists takeable entries and one carries Depends on but no Kind or Waits on
- **THEN** it lists that entry as unclassified rather than as a fix or a change, and rather than omitting it

#### Scenario: Pick meets an entry with no Priority

- **WHEN** pick lists takeable entries in a file whose shape names Priority and states an absent one is `normal`, and one entry carries no Priority
- **THEN** it lists that entry as `normal`, not as unclassified

### Requirement: Workstreams reports where each workstream stands

The **workstreams** operation SHALL, for each open workstream in `docs/workstreams/`, list its steps in order with each step's status derived by the step's name as the README states, taking its precedence and its sources from the README: in the seeded file, `done`, then `in flight`, then `recorded`, then `planned`, the first that holds winning, with change directories and the backlog read from the freshly fetched trunk and branches and pull requests from the local repository, the remote and the forge. It SHALL name as **next** the first step in list order whose status is `planned`, or `recorded` with an entry that **pick** would list as takeable — its Waits on `nothing` or satisfied, and its Priority not `parked`; it SHALL NOT name a step `in flight` or `done`, and SHALL NOT read list order as a wait. It SHALL list as unplaced the backlog entries, and the open changes whose proposals name the workstream, that name it without being one of its steps, and SHALL show each unplaced open change beside the `planned` steps, as possibly one of them opened under another name. Where every step is done, it SHALL say that the workstream's Done when is to be checked. Given a name, it SHALL report that workstream alone.

It SHALL write nothing, and SHALL NOT open a change, edit a workstream or archive one.

The status is derived rather than read because the workstream file holds none, by `project-bootstrap`'s rule; this operation is how a session reads it without the lookups by hand, and the README states the lookups so that the plan is readable without the skill. Where the forge cannot be reached, it SHALL say so and derive from what it can reach.

#### Scenario: A step's status comes from the repository

- **WHEN** a workstream lists three steps of which one is an archived change, one has a remote branch and one is a backlog heading
- **THEN** workstreams reports them as `done`, `in flight` and `recorded`, with the workstream file unchanged

#### Scenario: A step in two sources

- **WHEN** a step's change is archived on the trunk and its branch has not yet been removed
- **THEN** workstreams reports it as `done`

#### Scenario: The next step is named

- **WHEN** the first step of a workstream is done and the second is recorded with an entry waiting on `nothing`
- **THEN** workstreams names the second as next

#### Scenario: A waiting step is not next

- **WHEN** the first step not done is recorded with an entry that waits on an unarchived change, and a later step is planned
- **THEN** workstreams names the later step as next, not the waiting one

#### Scenario: Every step done

- **WHEN** every step of an open workstream is done
- **THEN** workstreams says its Done when is to be checked, and does not archive it

#### Scenario: Unplaced entries are shown

- **WHEN** a backlog entry names a workstream whose steps do not name it
- **THEN** workstreams lists it under that workstream as unplaced

#### Scenario: A change opened under another name is surfaced

- **WHEN** an open change's proposal names a workstream whose steps do not name the change, and one of the workstream's steps is `planned`
- **THEN** workstreams lists the change as unplaced beside the planned steps
