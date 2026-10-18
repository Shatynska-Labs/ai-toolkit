# backlog-maintenance Specification

## Purpose
Defines the `backlog` skill: the on-demand operations a session performs over a project's `docs/backlog.md` — recording, picking, closing, sweeping at archive, and auditing entries — and the seam that keeps those operations from becoming a second statement of the entry rules or of the workflow's obligations.

## Requirements

### Requirement: The skill operates on the project it is invoked in

The library SHALL carry a skill at `skills/backlog/SKILL.md` whose directory name and `name` are `backlog`. It SHALL operate on `docs/backlog.md` of the project it is invoked in, not on this repository unless this repository is that project.

Its description SHALL state the five operations and the phrasings that reach them, and SHALL distinguish it from `project-init`, which seeds the file, and from the OpenSpec skills, which open and carry the change an entry names.

#### Scenario: Invoked from a consuming project

- **WHEN** the skill is invoked in a project that installed this library as a plugin
- **THEN** it reads and writes that project's `docs/backlog.md`, and touches nothing in this library

#### Scenario: No backlog exists

- **WHEN** the skill is invoked in a project with no `docs/backlog.md`
- **THEN** it says so and names `project-init` as what seeds the file, and does not create the file with text of its own

### Requirement: The skill restates neither the entry rules nor the workflow's obligations

The skill SHALL read how an entry is shaped, named, kept and deleted from the backlog file's own preamble, and SHALL NOT restate those rules. It SHALL NOT place an obligation on a session that the workflow fragment does not state, and SHALL NOT be required for any obligation the fragment states to be met. The checks an operation performs and the gates on its own edits are procedure: they bind a session only while it runs that operation, and an entry or an archive done without the skill is not deficient for lacking them. This is the seam `session-workflow` states for an operational skill.

The entry rules are owned by `project-bootstrap` and stated in the file; the obligations to record, and to re-read at archive, are owned by `session-workflow` and stated in the fragment. A third statement of either is a wording that drifts from both, and a skill is loaded only when something judges it relevant, so it cannot be where an obligation lives.

#### Scenario: A project's preamble differs from the seeded one

- **WHEN** a project's `docs/backlog.md` states an entry shape that differs from the one `project-init` seeds
- **THEN** the skill records and checks entries against the shape that file states, not against a shape of its own

#### Scenario: The skill does not mandate an audit cadence

- **WHEN** a session reads the skill
- **THEN** it finds no rule obliging an audit at any interval, since the fragment states none

### Requirement: Record writes an entry the file can be relied on for

The **record** operation SHALL write one entry in the shape the file states. Before writing, it SHALL check the entry's name against the backlog's headings, the project's open and archived change directories, and its branches, and SHALL not write a name already used by any of them. It SHALL set Kind by the file's own definition and state the reason. It SHALL search the existing entries for ones touching the same files, specifications or capabilities and present each as a Design with candidate, writing into Design with only the candidates the session or operator confirms share a design, or `nothing`. A shared pointer is evidence of a shared design, not the same thing. It SHALL set Re-checked to the day the entry is written.

The name check and the overlap search are the operation's procedure, not entry rules: the file states that an entry is named and may name entries to design with, and record is how the skill makes those statements hold for the entry it writes.

#### Scenario: A name already used by an archived change

- **WHEN** record is asked to write an entry whose name matches an archived change's directory
- **THEN** it does not write the entry under that name and asks for another

#### Scenario: An overlapping entry exists

- **WHEN** record writes an entry naming a file another entry also names
- **THEN** record presents that other entry as a Design with candidate, and names it in Design with only once it is confirmed to share a design

### Requirement: Pick lists what can be taken now

The **pick** operation SHALL list the entries whose Waits on is `nothing`, split into `fix` and `change`, with entries that name each other in Design with listed together. Where given paths, it SHALL narrow the list to entries naming any of them. An entry whose Waits on names something already satisfied — a change that is archived, say — SHALL be listed apart, as takeable once updated, rather than hidden as blocked. It SHALL write nothing, and SHALL NOT open a change or begin an entry's work.

#### Scenario: A blocked entry is not offered

- **WHEN** an entry waits on a change that is not archived
- **THEN** pick does not list it as takeable

#### Scenario: A wait already satisfied but not updated

- **WHEN** an entry waits on a change that has since been archived and the entry was never updated
- **THEN** pick lists it apart as takeable once updated, naming the archived change

#### Scenario: Pick narrowed to files

- **WHEN** pick is given a set of paths
- **THEN** it lists only takeable entries naming one of those paths

### Requirement: Close removes an entry and every reference to it

The **close** operation SHALL delete the entry it is given and, in the same edit, update every other entry that names it in Waits on or Design with, so no entry is left pointing at a name the file no longer carries.

#### Scenario: A closed entry was another's only wait

- **WHEN** close deletes an entry another entry names as its only Waits on
- **THEN** that other entry's Waits on no longer names it, and the entry is takeable

### Requirement: Sweep performs the archive step's re-read

The **sweep** operation, given a change, SHALL find the entries it completed, made obsolete, unblocked or made stale. It SHALL search for entries naming the change, entries whose Waits on it satisfies, and entries naming files or specifications the change touched.

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

### Requirement: Audit verifies every entry independently and changes nothing without the operator

The **audit** operation SHALL divide the backlog into ranges and give each range to a separate read-only agent run in parallel. Each agent SHALL verify every entry in its range against the code, the specifications, the open and the archived changes, the commit history and the forge's merged pull requests, and SHALL return for each entry a relevance verdict — `live`, `stale`, `partly-done`, `obsolete` or `waiting` — and a kind verdict — `fix`, `change` or `fix?` — each with its evidence.

The archived changes and merged pull requests are named because an entry is most often completed by a change that never mentions it, and an agent checking the code alone reads such an entry as live.

The skill SHALL merge the agents' results into one report naming: the entries done or obsolete, the entries that are one change recorded twice, the entries whose facts are stale, the groups that share a design, the entries now unblocked, and the entries that can be taken as fixes. It SHALL apply none of it until the operator says so, and SHALL then apply it as one edit to `docs/backlog.md`, delivered as the workflow delivers work too small to be a change.

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

### Requirement: Entries in an older shape are reported, not rewritten

Where an entry lacks a field the file's shape names, the skill SHALL report it as unclassified wherever that field decides the outcome, and SHALL NOT invent the field's value. It SHALL rewrite an entry into the current shape only on the operator's word.

Backlogs written before the shape gained its fields are left byte-for-byte unchanged by `project-init`, so the skill meets them as they are.

#### Scenario: Pick meets an entry with no Kind

- **WHEN** pick lists takeable entries and one carries Depends on but no Kind or Waits on
- **THEN** it lists that entry as unclassified rather than as a fix or a change, and rather than omitting it
