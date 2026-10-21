## MODIFIED Requirements

### Requirement: Record writes an entry the file can be relied on for

The **record** operation SHALL write one entry in the shape the file states. Where the session invoking it is in a change, record SHALL first test the work against the fold-in rule the project's workflow states, where it states one, taking the test from the workflow rather than stating it; where the work meets it, record SHALL say so and write no entry. It SHALL offer no override the workflow does not state. Before writing, it SHALL check the entry's name against the backlog's headings, the project's open and archived change directories, and its branches, and SHALL not write a name already used by any of them. It SHALL set Kind by the file's own definition and state the reason. It SHALL search the existing entries for ones touching the same files, specifications or capabilities and present each as a Design with candidate, writing into Design with only the candidates the session or operator confirms share a design, or `nothing`. A shared pointer is evidence of a shared design, not the same thing. Where the file's shape names Priority, it SHALL set Priority to the file's default — `normal` in the seeded file — unless the session or the operator states the evidence or the condition the file requires for another value, and SHALL write `high` or `parked` only once the operator confirms it. It SHALL set Re-checked to the day the entry is written.

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

### Requirement: Pick lists what can be taken now

The **pick** operation SHALL list the entries whose Waits on is `nothing`, split into `fix` and `change`, with entries that name each other in Design with listed together. Where the file's shape names Priority, `high` entries SHALL be listed first, a Design with group placed by its highest-priority member. Waits on governs first: an entry whose Waits on is not `nothing` is not takeable whatever its Priority. An entry whose Priority is `parked` SHALL NOT be listed as takeable; where its Waits on is `nothing` or already satisfied it SHALL be listed apart, under Parked, with its condition and any satisfied wait named beside it, and where it is still waiting it is not offered at all, as any blocked entry is not. A parked entry whose condition already holds and whose wait is `nothing` or satisfied SHALL be listed as takeable once updated, naming what fulfilled it. Where given paths, it SHALL narrow the list to entries naming any of them. An entry whose Waits on names something already satisfied — a change that is archived, say — SHALL be listed apart, as takeable once updated, rather than hidden as blocked. It SHALL write nothing, and SHALL NOT open a change or begin an entry's work.

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

### Requirement: Sweep performs the archive step's re-read

The **sweep** operation, given a change, SHALL find the entries it completed, made obsolete, unblocked, unparked or made stale. It SHALL search for entries naming the change, entries whose Waits on it satisfies, entries whose parked condition it fulfils, entries whose `high` evidence it removes, and entries naming files or specifications the change touched.

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

### Requirement: Audit verifies every entry independently and changes nothing without the operator

The **audit** operation SHALL divide the backlog into ranges and give each range to a separate read-only agent run in parallel. Each agent SHALL verify every entry in its range against the code, the specifications, the open and the archived changes, the commit history and the forge's merged pull requests, and SHALL return for each entry a relevance verdict — `live`, `stale`, `partly-done`, `obsolete` or `waiting` — and a kind verdict — `fix`, `change` or `fix?` — each with its evidence. Where the file's shape names Priority, for an entry whose Priority is `high` it SHALL say whether the evidence still holds, and for one whose Priority is `parked`, whether its condition now holds.

The archived changes and merged pull requests are named because an entry is most often completed by a change that never mentions it, and an agent checking the code alone reads such an entry as live.

The skill SHALL merge the agents' results into one report naming: the entries done or obsolete, the entries that are one change recorded twice, the entries whose facts are stale — among them each `high` entry whose evidence no longer holds, with its Priority corrected as the file directs —, the groups that share a design, the entries now unblocked or unparked, and the entries that can be taken as fixes. It SHALL apply none of it until the operator says so, and SHALL then apply it as one edit to `docs/backlog.md`, delivered as the workflow delivers work too small to be a change.

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

### Requirement: Entries in an older shape are reported, not rewritten

Where an entry lacks a field the file's shape names, the skill SHALL report it as unclassified wherever that field decides the outcome, and SHALL NOT invent the field's value. Where the file itself states what an entry without the field means — as the seeded file does for Priority, an absent one being `normal` — the skill SHALL read the entry as the file states, and SHALL NOT report it as unclassified for that field: the value is the file's, not invented. It SHALL rewrite an entry into the current shape only on the operator's word.

Backlogs written before the shape gained its fields are left byte-for-byte unchanged by `project-init`, so the skill meets them as they are.

#### Scenario: Pick meets an entry with no Kind

- **WHEN** pick lists takeable entries and one carries Depends on but no Kind or Waits on
- **THEN** it lists that entry as unclassified rather than as a fix or a change, and rather than omitting it

#### Scenario: Pick meets an entry with no Priority

- **WHEN** pick lists takeable entries in a file whose shape names Priority and states an absent one is `normal`, and one entry carries no Priority
- **THEN** it lists that entry as `normal`, not as unclassified
