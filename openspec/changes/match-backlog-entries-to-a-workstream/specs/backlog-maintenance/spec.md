## MODIFIED Requirements

### Requirement: Record writes an entry the file can be relied on for

*Modified by `match-backlog-entries-to-a-workstream`: before setting `workstream`, record reads every open workstream's Goal and Not in scope, writes the absent value only once that read finds none, says what it chose and why, and places the entry among the steps or says why not. *Record carries the change's workstream* and *Record writes one file* keep their titles; four scenarios are added.*

*Modified by `list-what-a-project-receives`: record refuses `agents` and `claude` as it refuses `readme`. *Record refuses a name colliding with the rules' files* is added; every other scenario keeps its title.*

*Modified by `one-file-per-backlog-entry`: record writes one entry file, its values as frontmatter in the README's form and its reasons in the body, and keeps names and conditions apart. Every scenario keeps its title.*

The **record** operation SHALL write one entry as its own file, `docs/backlog/<name>.md`, in the shape the README states: its values as frontmatter in the README's form, and its prose and reasons as the body. Where the session invoking it is in a change, record SHALL first test the work against the fold-in rule the project's workflow states, where it states one, taking the test from the workflow rather than stating it; where the work meets it, record SHALL say so and write no entry. It SHALL offer no override the workflow does not state. Before writing, it SHALL check the entry's name against the entry files in `docs/backlog/`, the project's open and archived change directories, and its branches, and SHALL not write a name already used by any of them, nor `readme`, `agents` or `claude` in any case, which would collide with `README.md`, `AGENTS.md` or `CLAUDE.md` on a filesystem that ignores case, overwriting the directory's rules or their import. It SHALL set `kind` by the README's own definition and state the reason in the body. It SHALL write into `waits_on` only names of entries or changes, and SHALL write a wait on anything else — an answer, an access grant, an event — as a condition in `waits_for`. It SHALL search the existing entries for ones touching the same files, specifications or capabilities and present each as a Design with candidate, writing into `design_with` only the candidates the session or operator confirms share a design, or the README's empty value — `[]` in the seeded README. A shared pointer is evidence of a shared design, not the same thing. Where the README's shape names `priority`, it SHALL set it to the README's default — `normal` in the seeded README — unless the session or the operator states the evidence or the condition the README requires for another value, and SHALL write `high`, or `parked` with its `parked_until`, only once the operator confirms it. Where the README's shape names `workstream`, it SHALL read the Goal and Not in scope of every open workstream in `docs/workstreams/` before setting it. It SHALL set it to the workstream of the change the session is in where the entry serves that workstream's Goal and falls inside its scope; otherwise to the open workstream whose Goal the entry serves, asking the operator where more than one is served; and to the README's absent value — `none` in the seeded README — only once that read finds none. What the operator states the entry serves SHALL be taken over that reading. It SHALL write only a name an open workstream in `docs/workstreams/` carries, or that absent value, and SHALL say in its answer the workstream chosen for each entry and why, so the operator need not ask where an entry belongs. Where it writes an open workstream's name, it SHALL add the entry to that workstream's steps in the same edit, asking the operator where in the order, or SHALL say that the entry is left for the archive and why. Where `docs/workstreams/README.md` exists, its name check SHALL also cover the names of workstreams, open and archived. It SHALL set `re_checked` to the day the entry is written. It SHALL write the frontmatter in the form the README states — bare names, set values and dates, double-quoted free text with `"` and `\` escaped, inline lists — and SHALL write no key the README does not define.

Urgency and deferral are the operator's judgements about the project's work, not facts a session can verify alone, which is why record proposes them and does not set them on its own.

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

### Requirement: Sweep performs the archive step's re-read

*Modified by `match-backlog-entries-to-a-workstream`: sweep also gathers the entries unplaced in the change's open workstream, the change's own among them, and detaches an entry, here and where a workstream is archived, by reading the open workstreams' Goals. Every scenario keeps its title; three are added.*

*Modified by `one-file-per-backlog-entry`: sweep reads the entry files and their `waits_on`, `parked_until` and `workstream`, and edits entry files as the README directs. Every scenario keeps its title.*

The **sweep** operation, given a change, SHALL find the entries it completed, made obsolete, unblocked, unparked or made stale. It SHALL search for entries naming the change, entries whose `waits_on` names it, entries whose `waits_for` or `parked_until` it fulfils, entries whose `high` evidence it removes, entries naming files or specifications the change touched, where the change's archive archives a workstream, entries naming that workstream, and, where the change advanced an open workstream its archive does not archive, the entries the **workstreams** operation's unplaced read finds in it, that read being made over the change's working tree as well as the trunk, so that the entries the change recorded are among them, rather than by a second definition.

It SHALL take what the change touched from the change's merged pull requests on the forge — every one of them, since a change takes at least two — and, where the forge cannot be reached, from the change's specification deltas and the files its design and tasks name, saying that the fallback was used. It SHALL NOT take them from the branch's diff against the trunk: by the archive step the branch has been brought back to the trunk, and a squash merge leaves no ancestry, so that diff holds the record alone.

Run before the archive commit, it SHALL update each entry's file as the README directs and leave the edit for that commit. Run after the change's record is on the trunk, it SHALL make the same edit and say that it is to be delivered as the workflow delivers work too small to be a change.

It SHALL present each unplaced entry to be placed among the steps, the position asked of the operator, or detached. An entry that does not serve its workstream's Goal, or that its workstream's Not in scope leaves out, is detached by the same read of the open workstreams' Goals record makes, not set to the README's absent value without it. Editing the workstream's steps is the one edit sweep makes outside the entry files, and it SHALL go in the same commit as the entry edits.

Searching by what the change touched, and not only by name, is required because a change that finishes an entry's work seldom names the entry.

#### Scenario: An entry finished without being named

- **WHEN** sweep runs for a change whose diff completes an entry that the change never mentions
- **THEN** sweep finds the entry through the files the change's merged pull requests touched, and presents its file for deletion

#### Scenario: Sweep after a squash merge

- **WHEN** sweep runs at the archive step for a change whose work was squash-merged
- **THEN** it still finds what the change touched, from the forge's record of its merged pull requests, not from the branch's diff

#### Scenario: Sweep after the record has landed

- **WHEN** sweep is run for a change whose record is already on the trunk
- **THEN** it makes the edit and says it is to be delivered as work too small to be a change, not left for an archive commit that no longer exists

#### Scenario: A change fulfils a parked entry's condition

- **WHEN** sweep runs for a change that fulfils the `parked_until` of a parked entry
- **THEN** sweep presents that entry with its `priority` proposed as the README directs, `normal` or `high` with evidence

#### Scenario: A change removes a high entry's evidence

- **WHEN** sweep runs for a change that removes the harm a `high` entry's evidence names, in a backlog whose README directs that such an entry becomes `normal`
- **THEN** sweep presents that entry with its `priority` proposed as the README directs, `normal`

#### Scenario: Entries naming a workstream being archived

- **WHEN** sweep runs for a change whose archive makes its workstream's Done when hold
- **THEN** sweep presents every entry naming that workstream, to be detached as `docs/workstreams/README.md` directs: re-pointed to the open workstream whose Goal it serves, and set to the README's absent value only where that read finds none

#### Scenario: An entry waiting on the swept change

- **WHEN** sweep runs for a change an entry's `waits_on` names
- **THEN** sweep presents that entry with the change's name proposed removed from its `waits_on`

#### Scenario: An entry naming the open workstream that no step names

- **WHEN** sweep runs for a change in an open workstream that the archive does not archive, and an entry names that workstream while no step names it
- **THEN** sweep presents that entry to be placed among the steps, the position asked of the operator, or detached

#### Scenario: An entry falling outside its workstream is re-pointed

- **WHEN** sweep presents an unplaced entry that its workstream's Not in scope leaves out, and another open workstream's Goal is served by it
- **THEN** sweep proposes that other workstream, and proposes the README's absent value only where the read finds no Goal served

#### Scenario: An entry the change recorded is not yet on the trunk

- **WHEN** sweep runs for a change whose branch holds an entry naming the change's open workstream, no step names it, and the entry has not reached the trunk
- **THEN** sweep presents it as it presents any unplaced entry

### Requirement: Workstreams reports where each workstream stands

*Modified by `match-backlog-entries-to-a-workstream`: unplaced is read by what the README states names a step, so a mention in a step's description places nothing. Every scenario keeps its title; one is added.*

*Modified by `one-file-per-backlog-entry`: a step is recorded where `docs/backlog/` holds an entry of its name, and next is decided by the entry's wait and priority as pick reads them. Every scenario keeps its title.*

The **workstreams** operation SHALL, for each open workstream in `docs/workstreams/`, list its steps in order with each step's status derived by the step's name as the README states, taking its precedence and its sources from the README: in the seeded file, `done`, then `in flight`, then `recorded`, then `planned`, the first that holds winning, with change directories and the backlog's entry files read from the freshly fetched trunk and branches and pull requests from the local repository, the remote and the forge. It SHALL name as **next** the first step in list order whose status is `planned`, or `recorded` with an entry that **pick** would list as takeable — unwaited or its wait satisfied, and its `priority` not `parked`; it SHALL NOT name a step `in flight` or `done`, and SHALL NOT read list order as a wait. It SHALL list as unplaced the backlog entries, and the open changes whose proposals name the workstream, that name it without being one of its steps, by what the README states names a step, and SHALL show each unplaced open change beside the `planned` steps, as possibly one of them opened under another name. Where every step is done, it SHALL say that the workstream's Done when is to be checked. Given a name, it SHALL report that workstream alone.

It SHALL write nothing, and SHALL NOT open a change, edit a workstream or archive one.

The status is derived rather than read because the workstream file holds none, by `project-bootstrap`'s rule; this operation is how a session reads it without the lookups by hand, and the README states the lookups so that the plan is readable without the skill. Where the forge cannot be reached, it SHALL say so and derive from what it can reach.

#### Scenario: A step's status comes from the repository

- **WHEN** a workstream lists three steps of which one is an archived change, one has a remote branch and one is an entry file in `docs/backlog/`
- **THEN** workstreams reports them as `done`, `in flight` and `recorded`, with the workstream file unchanged

#### Scenario: A step in two sources

- **WHEN** a step's change is archived on the trunk and its branch has not yet been removed
- **THEN** workstreams reports it as `done`

#### Scenario: The next step is named

- **WHEN** the first step of a workstream is done and the second is recorded with an unwaited entry
- **THEN** workstreams names the second as next

#### Scenario: A waiting step is not next

- **WHEN** the first step not done is recorded with an entry whose `waits_on` names an unarchived change, and a later step is planned
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

#### Scenario: A mention in a step's description is not a step

- **WHEN** a backlog entry names a workstream, and its name appears only inside a step's description
- **THEN** workstreams lists it under that workstream as unplaced
