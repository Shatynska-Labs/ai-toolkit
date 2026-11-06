## MODIFIED Requirements

### Requirement: Record writes an entry the file can be relied on for

*Modified by `report-a-tasks-kind-and-wait`: record writes `need` at the README's default unless the operator confirms `must` or `could` with its reason, and writes beside each `waits_for` the types it states. Every scenario keeps its title; three are added.*

*Modified by `match-backlog-entries-to-a-workstream`: before setting `workstream`, record reads every open workstream's Goal and Not in scope, writes the absent value only once that read finds none, says what it chose and why, and places the entry among the steps or says why not. *Record carries the change's workstream* and *Record writes one file* keep their titles; four scenarios are added.*

*Modified by `list-what-a-project-receives`: record refuses `agents` and `claude` as it refuses `readme`. *Record refuses a name colliding with the rules' files* is added; every other scenario keeps its title.*

*Modified by `one-file-per-backlog-entry`: record writes one entry file, its values as frontmatter in the README's form and its reasons in the body, and keeps names and conditions apart. Every scenario keeps its title.*

The **record** operation SHALL write one entry as its own file, `docs/backlog/<name>.md`, in the shape the README states: its values as frontmatter in the README's form, and its prose and reasons as the body. Where the session invoking it is in a change, record SHALL first test the work against the fold-in rule the project's workflow states, where it states one, taking the test from the workflow rather than stating it; where the work meets it, record SHALL say so and write no entry. It SHALL offer no override the workflow does not state. Before writing, it SHALL check the entry's name against the entry files in `docs/backlog/`, the project's open and archived change directories, and its branches, and SHALL not write a name already used by any of them, nor `readme`, `agents` or `claude` in any case, which would collide with `README.md`, `AGENTS.md` or `CLAUDE.md` on a filesystem that ignores case, overwriting the directory's rules or their import. It SHALL set `kind` by the README's own definition and state the reason in the body. Where the README's shape names `need`, it SHALL set it to the README's default — `should` in the seeded README — unless the session or the operator states why the entry is `must` or `could`, SHALL propose either with that reason, read from the Goal of the entry's workstream or, for an entry naming no workstream, from the harm its absence does to the project, and SHALL write it only once the operator confirms it. It SHALL write into `waits_on` only names of entries or changes, and SHALL write a wait on anything else — an answer, an access grant, an event — as a condition in `waits_for`. Where the README's shape names `waits_for_type`, it SHALL write beside each `waits_for` the types the condition states, from the README's set. It SHALL search the existing entries for ones touching the same files, specifications or capabilities and present each as a Design with candidate, writing into `design_with` only the candidates the session or operator confirms share a design, or the README's empty value — `[]` in the seeded README. A shared pointer is evidence of a shared design, not the same thing. Where the README's shape names `priority`, it SHALL set it to the README's default — `normal` in the seeded README — unless the session or the operator states the evidence or the condition the README requires for another value, and SHALL write `high`, or `parked` with its `parked_until`, only once the operator confirms it. Where the README's shape names `workstream`, it SHALL read the Goal and Not in scope of every open workstream in `docs/workstreams/` before setting it. It SHALL set it to the workstream of the change the session is in where the entry serves that workstream's Goal and falls inside its scope; otherwise to the open workstream whose Goal the entry serves, asking the operator where more than one is served; and to the README's absent value — `none` in the seeded README — only once that read finds none. What the operator states the entry serves SHALL be taken over that reading. It SHALL write only a name an open workstream in `docs/workstreams/` carries, or that absent value, and SHALL say in its answer the workstream chosen for each entry and why, so the operator need not ask where an entry belongs. Where it writes an open workstream's name, it SHALL add the entry to that workstream's steps in the same edit, asking the operator where in the order, or SHALL say that the entry is left for the archive and why. Where `docs/workstreams/README.md` exists, its name check SHALL also cover the names of workstreams, open and archived. It SHALL set `re_checked` to the day the entry is written. It SHALL write the frontmatter in the form the README states — bare names, set values and dates, double-quoted free text with `"` and `\` escaped, inline lists — and SHALL write no key the README does not define.

Urgency, deferral and need are the operator's judgements about the project's work, not facts a session can verify alone, which is why record proposes them and does not set them on its own. A condition's type is a fact of its wording, which the operator already gave, so record sets it.

The fold-in test, the name check, the overlap search and the way the open workstreams' Goals are read are the operation's procedure, not entry rules or obligations: the workflow states when work is folded in, the README states that an entry is named, may name entries to design with and takes the workstream whose Goal it serves, which is the obligation to make that read, and record is how the skill makes those statements hold for the entry it writes.

#### Scenario: A name already used by an archived change

- **WHEN** record is asked to write an entry whose name matches an archived change's directory
- **THEN** it does not write the entry under that name and asks for another

#### Scenario: Record refuses a name colliding with the rules' files

- **WHEN** record is asked to write an entry named `agents`, `Claude` or `readme`
- **THEN** it writes no file and asks for another name

#### Scenario: An overlapping entry exists

- **WHEN** record writes an entry naming a file another entry also names
- **THEN** record presents that other entry as a Design with candidate, and names it in `design_with` only once it is confirmed to share a design

#### Scenario: Work the change can fold in

- **WHEN** record is invoked during a change for a small correction in a file that change edits, owing no delta and no decision, in a project whose workflow states a fold-in rule
- **THEN** record says the work can be folded in and writes no entry

#### Scenario: Record defaults Priority

- **WHEN** record writes an entry and neither the session nor the operator states evidence of current harm or a condition to park it under
- **THEN** the entry's `priority` is `normal`

#### Scenario: Record parks an entry only on the operator's word

- **WHEN** a session judges an entry not worth taking until a stated condition holds
- **THEN** record proposes `priority: parked` with that condition as `parked_until`, and writes it only once the operator confirms

#### Scenario: Record carries the change's workstream

- **WHEN** record writes an entry from a change whose proposal names an open workstream, the entry serves that workstream's Goal and falls inside its scope, and nothing states the entry serves another goal
- **THEN** the entry's `workstream` names that workstream

#### Scenario: Record refuses a workstream that is not open

- **WHEN** record is asked to set `workstream` to a name no open workstream carries
- **THEN** it does not write that name, and asks for an open workstream or the README's absent value

#### Scenario: Record keeps a condition out of waits_on

- **WHEN** record writes an entry that waits on a named change and on a person's answer
- **THEN** the change's name is in `waits_on`, the answer is a double-quoted condition in `waits_for`, and `waits_on` holds no other text

#### Scenario: Record writes one file

- **WHEN** record writes an entry
- **THEN** exactly one file, `docs/backlog/<name>.md`, is created, and no other entry file and no README is changed; the one other file it may edit is the workstream file whose steps take the entry

#### Scenario: An entry the change's workstream rules out finds another

- **WHEN** record writes an entry from a change whose workstream's Not in scope leaves the entry out, and another open workstream's Goal is served by it
- **THEN** the entry's `workstream` names that other workstream, and the answer says why

#### Scenario: The absent value follows the read

- **WHEN** record writes an entry from outside any change, and nothing states what it serves
- **THEN** it reads the Goal and Not in scope of every open workstream, writes the absent value only where none is served, and says so in its answer

#### Scenario: A recorded entry is placed or left with a reason

- **WHEN** record writes an open workstream's name on an entry
- **THEN** it adds the entry to that workstream's steps, the position asked of the operator, or says that the entry is left for the archive and why

#### Scenario: Placing one entry owes nothing for the others

- **WHEN** record adds an entry to the steps of a workstream that other entries name while no step names them
- **THEN** it edits the steps for that entry alone

#### Scenario: Record defaults Need

- **WHEN** record writes an entry and neither the session nor the operator states why it is `must` or `could`
- **THEN** the entry's `need` is `should`

#### Scenario: Record writes must only on the operator's word

- **WHEN** a session judges that a workstream's Goal does not hold without the entry it records
- **THEN** record proposes `need: must` with that reason, and writes it, with **Need** in the body, only once the operator confirms

#### Scenario: Record types a condition

- **WHEN** record writes an entry waiting for the operator's choice and for a team's answer
- **THEN** the entry carries both as its `waits_for` condition and `waits_for_type: [decision, answer]`

### Requirement: Pick lists what can be taken now

*Modified by `report-a-tasks-kind-and-wait`: within one priority, entries are listed by need, `must` before `should` before `could`, and need never decides what is takeable. Every scenario keeps its title; two are added.*

*Modified by `one-file-per-backlog-entry`: an entry is unwaited when its `waits_on` is empty and it has no `waits_for`; a name in `waits_on` is satisfied when its change is archived, and a `waits_for` only when the condition is shown to hold. Every scenario keeps its title.*

An entry is **unwaited** where its `waits_on` is empty and it carries no `waits_for`. Its wait is **satisfied** where every name in `waits_on` is an archived change and, where it carries `waits_for`, the condition is shown to hold.

The **pick** operation SHALL list the unwaited entries, split into `fix` and `change`, with entries that name each other in `design_with` listed together. Where the README's shape names `priority`, `high` entries SHALL be listed first, a Design with group placed by its highest-priority member. Where it names `need`, entries of one priority SHALL be listed `must`, then `should`, then `could`, a Design with group placed by its highest-need member after its highest-priority one; need SHALL NOT make an entry takeable or not. The wait governs first: an entry that is neither unwaited nor satisfied is not takeable whatever its priority. An entry whose `priority` is `parked` SHALL NOT be listed as takeable; where it is unwaited or its wait is satisfied it SHALL be listed apart, under Parked, with its `parked_until` and any satisfied wait named beside it, and where it is still waiting it is not offered at all, as any blocked entry is not. A parked entry whose condition already holds and which is unwaited or satisfied SHALL be listed as takeable once updated, naming what fulfilled it. Where the README's shape names `workstream`, it SHALL group without changing what is takeable, which the wait alone decides: within each of the takeable `fix` and `change` lists, entries naming one workstream SHALL be listed together as one group, placed by its highest-priority member as a Design with group is; inside the group, `high` entries come first, then the others in the workstream's step order, step order holding within one need, `must` steps before `should` and `should` before `could`, then entries naming it without being a step, listed as unplaced; a Design with group whose members name different workstreams sits in the group of its highest-priority member, then of its earliest step, at its earliest member's step position; entries naming no workstream — the README's absent value, or an earlier `nothing` — are grouped as before. Where given paths, it SHALL narrow the list to entries naming any of them. An entry whose wait is satisfied but which was never updated SHALL be listed apart, as takeable once updated, naming the archived change or the evidence the condition holds, rather than hidden as blocked. An entry carrying `waits_for` whose condition the session cannot show to hold SHALL be treated as waiting. It SHALL write nothing, and SHALL NOT open a change or begin an entry's work.

#### Scenario: A blocked entry is not offered

- **WHEN** an entry's `waits_on` names a change that is not archived
- **THEN** pick does not list it as takeable

#### Scenario: A wait already satisfied but not updated

- **WHEN** an entry's `waits_on` names a change that has since been archived and the entry was never updated
- **THEN** pick lists it apart as takeable once updated, naming the archived change

#### Scenario: Pick narrowed to files

- **WHEN** pick is given a set of paths
- **THEN** it lists only takeable entries naming one of those paths

#### Scenario: A parked entry is not offered as takeable

- **WHEN** an entry is unwaited and its `priority` is `parked` with a `parked_until` that does not hold
- **THEN** pick lists it apart as parked, with its condition, and not as takeable

#### Scenario: A parked entry whose condition holds

- **WHEN** a parked entry's `parked_until` already holds and the entry was never updated
- **THEN** pick lists it as takeable once updated, naming what fulfilled the condition

#### Scenario: A parked entry still waiting

- **WHEN** a parked entry's condition holds but its `waits_on` names a change that is not archived
- **THEN** pick does not list it as takeable, as takeable once updated, or under Parked

#### Scenario: High entries come first

- **WHEN** pick lists takeable entries and some carry `priority: high`
- **THEN** those entries are listed before the others in their list

#### Scenario: Pick lists a workstream's entries in step order

- **WHEN** pick lists takeable entries of which two, of one kind and one priority, name one workstream and are its third and first steps
- **THEN** they are listed in that workstream's group, the first step before the third

#### Scenario: A high step leads its workstream's group

- **WHEN** a workstream's group holds its first step at `normal` and its third at `high`
- **THEN** the third is listed first, and the group is placed as a group with a `high` member

#### Scenario: An unplaced entry is shown under its workstream

- **WHEN** a takeable entry names a workstream whose steps do not name it
- **THEN** pick lists it in that workstream's group, as unplaced, and not apart from it

#### Scenario: An entry naming no workstream is grouped apart

- **WHEN** pick lists takeable entries in a backlog whose README gives `workstream`'s absent value as `none`, and one entry's `workstream` is `none`
- **THEN** it lists that entry with the entries naming no workstream, not as a workstream named `none` and not as unplaced

#### Scenario: A condition not shown to hold blocks

- **WHEN** an entry's `waits_on` is empty and it carries a `waits_for` the session cannot show holds
- **THEN** pick does not list it as takeable

#### Scenario: Must comes before could

- **WHEN** pick lists two takeable entries of one kind and priority naming no workstream, one `could` and one `must`
- **THEN** the `must` entry is listed first

#### Scenario: Need does not make an entry takeable

- **WHEN** an entry is `must` and its `waits_on` names a change that is not archived
- **THEN** pick does not list it as takeable

### Requirement: Audit verifies every entry independently and changes nothing without the operator

*Modified by `report-a-tasks-kind-and-wait`: for an entry carrying `waits_for`, an agent also says whether its `waits_for_type` states the kinds the condition holds, and proposes them where it has none; the report lists a wrong or missing type, and a type without a condition, among the stale facts. Audit proposes no `need`. Every scenario keeps its title; three are added.*

*Modified by `one-file-per-backlog-entry`: the ranges are sets of entry files, an agent is given each file verbatim, and the approved cleanup is one edit across the entry files. Every scenario keeps its title.*

The **audit** operation SHALL divide the entry files into ranges and give each range to a separate read-only agent run in parallel. Each agent SHALL verify every entry in its range against the code, the specifications, the open and the archived changes, the commit history and the forge's merged pull requests, and SHALL return for each entry a relevance verdict — `live`, `stale`, `partly-done`, `obsolete` or `waiting` — and a kind verdict — `fix`, `change` or `fix?` — each with its evidence. Where the README's shape names `priority`, for an entry whose `priority` is `high` it SHALL say whether the evidence still holds, and for one that is `parked`, whether its `parked_until` now holds. For an entry carrying `waits_for`, it SHALL say whether the condition now holds, and, where the README's shape names `waits_for_type`, whether the entry's types state the kinds of wait the condition holds, proposing them where it has none, and SHALL report a `waits_for_type` carried without `waits_for`. It SHALL propose no `need`, which is the operator's judgement. Where the README's shape names `workstream`, it SHALL say whether the workstream an entry names is open in `docs/workstreams/`. It SHALL say where a name in an entry's `waits_on` or `design_with` is neither an entry nor a change, open or archived.

The archived changes and merged pull requests are named because an entry is most often completed by a change that never mentions it, and an agent checking the code alone reads such an entry as live.

The skill SHALL merge the agents' results into one report naming: the entries done or obsolete, the entries that are one change recorded twice, the entries whose facts are stale — among them each `high` entry whose evidence no longer holds, with its `priority` corrected as the README directs, each entry naming a workstream that is archived or absent, each entry naming an unknown name, each condition whose type is wrong or missing, with the types proposed, and each `waits_for_type` carried without `waits_for` —, the groups that share a design, the entries now unblocked or unparked, and the entries that can be taken as fixes. It SHALL apply none of it until the operator says so, and SHALL then apply it as one edit across the entry files, delivered as the workflow delivers work too small to be a change.

The agents SHALL write nothing. Each is given the entries, the paths to check and the verdict vocabulary, and returns its verdicts; only the skill edits the entry files, and only after the operator's word.

#### Scenario: An entry done by an unmentioning change

- **WHEN** an entry's work was completed by an archived change that never names the entry
- **THEN** the agent checking it finds the change among the archived changes or merged pull requests and returns `obsolete` or `partly-done` with that change as evidence

#### Scenario: The report is not applied unasked

- **WHEN** the audit's report is ready
- **THEN** every file in `docs/backlog/` is unchanged until the operator approves the cleanup

#### Scenario: Two entries recorded for one change

- **WHEN** two entries describe the same change under different names
- **THEN** the report names them as one change recorded twice

#### Scenario: A parked entry whose condition has fired

- **WHEN** an entry is parked until a condition that now holds
- **THEN** the report names it among the entries now unparked, with the evidence that the condition holds

#### Scenario: An entry names an archived workstream

- **WHEN** an entry's `workstream` names a workstream whose file is under `docs/workstreams/archive/`
- **THEN** the report names it among the stale facts

#### Scenario: An entry names an unknown name

- **WHEN** an entry's `waits_on` names something that is neither an entry nor a change, open or archived
- **THEN** the report names it among the stale facts

#### Scenario: A condition without a type

- **WHEN** an entry's `waits_for` reads "the operator's choice of model" and it carries no `waits_for_type`
- **THEN** the report names it among the stale facts, proposing `waits_for_type: [decision]`

#### Scenario: A type without a condition

- **WHEN** an entry carries `waits_for_type: [answer]` and no `waits_for`
- **THEN** the report names it among the stale facts

#### Scenario: Audit leaves need alone

- **WHEN** audit checks an entry without `need`
- **THEN** the report proposes no `need` for it

### Requirement: Entries in an older shape are reported, not rewritten

*Modified by `report-a-tasks-kind-and-wait`: an entry without `need` reads as the README's default, and one with `waits_for` and no `waits_for_type` as an untyped wait, neither reported as unclassified. Every scenario keeps its title; one is added.*

*Modified by `one-file-per-backlog-entry`: layout and the earlier absent values are normalised by `scripts/backlog-migrate`, so this requirement keeps to entries missing a value, and to an earlier `nothing` written by hand. Every scenario keeps its title.*

Where an entry lacks a key the README's shape names, the skill SHALL report it as unclassified wherever that key decides the outcome, and SHALL NOT invent the value. Where the README itself states what an entry without the key means — as the seeded README does for `priority`, an absent one being `normal`, and for `need`, an absent one being `should` — the skill SHALL read the entry as the README states, and SHALL NOT report it as unclassified for that key: the value is the README's, not invented. Where an entry gives `nothing` as the value of `design_with` or `workstream`, the absent value an earlier shape used, the skill SHALL read it as the README's absent value, and SHALL NOT report it as a name or as unclassified. An entry carrying `waits_for` without `waits_for_type` SHALL be read as waiting, its type unknown, and SHALL NOT be reported as unclassified, since the type decides no operation's outcome. It SHALL rewrite an entry into the current shape only on the operator's word.

`scripts/backlog-migrate` carries an older entry's values into the frontmatter where it can find them and omits a key where the entry never had the field, so a migrated backlog may hold entries with no `kind`, and the skill meets them as they are.

#### Scenario: Pick meets an entry with no Kind

- **WHEN** pick lists takeable entries and one has no `kind` key
- **THEN** it lists that entry as unclassified rather than as a fix or a change, and rather than omitting it

#### Scenario: Pick meets an entry with no Priority

- **WHEN** pick lists takeable entries in a backlog whose README names `priority` and states an absent one is `normal`, and one entry has no `priority` key
- **THEN** it lists that entry as `normal`, not as unclassified

#### Scenario: An earlier absent value is read as the current one

- **WHEN** pick or the workstreams operation reads an entry whose `workstream` is `nothing`, in a backlog whose README gives the key's absent value as `none`
- **THEN** it reads the entry as naming no workstream, and does not report it as unplaced or unclassified

#### Scenario: Pick meets an untyped condition

- **WHEN** pick lists entries and one carries `waits_for` and no `waits_for_type`
- **THEN** it treats that entry as waiting, and does not list it as unclassified
