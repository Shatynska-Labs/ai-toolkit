## MODIFIED Requirements

### Requirement: Record writes an entry the file can be relied on for

*Modified by `propose-a-workstream-for-entries-sharing-a-goal`: before writing the absent value, record reads the other entries carrying it for a goal they share with the new one, proposes a workstream where they share one that takes more than one change, and says what it proposed or that none was found. Every scenario keeps its title; three are added.*

*Modified by `report-a-tasks-kind-and-wait`: record writes `need` at the README's default unless the operator confirms `must` or `could` with its reason, and writes beside each `waits_for` the types it states. Every scenario keeps its title; three are added.*

*Modified by `match-backlog-entries-to-a-workstream`: before setting `workstream`, record reads every open workstream's Goal and Not in scope, writes the absent value only once that read finds none, says what it chose and why, and places the entry among the steps or says why not. *Record carries the change's workstream* and *Record writes one file* keep their titles; four scenarios are added.*

*Modified by `list-what-a-project-receives`: record refuses `agents` and `claude` as it refuses `readme`. *Record refuses a name colliding with the rules' files* is added; every other scenario keeps its title.*

*Modified by `one-file-per-backlog-entry`: record writes one entry file, its values as frontmatter in the README's form and its reasons in the body, and keeps names and conditions apart. Every scenario keeps its title.*

The **record** operation SHALL write one entry as its own file, `docs/backlog/<name>.md`, in the shape the README states: its values as frontmatter in the README's form, and its prose and reasons as the body. Where the session invoking it is in a change, record SHALL first test the work against the fold-in rule the project's workflow states, where it states one, taking the test from the workflow rather than stating it; where the work meets it, record SHALL say so and write no entry. It SHALL offer no override the workflow does not state. Before writing, it SHALL check the entry's name against the entry files in `docs/backlog/`, the project's open and archived change directories, and its branches, and SHALL not write a name already used by any of them, nor `readme`, `agents` or `claude` in any case, which would collide with `README.md`, `AGENTS.md` or `CLAUDE.md` on a filesystem that ignores case, overwriting the directory's rules or their import. It SHALL set `kind` by the README's own definition and state the reason in the body. Where the README's shape names `need`, it SHALL set it to the README's default — `should` in the seeded README — unless the session or the operator states why the entry is `must` or `could`, SHALL propose either with that reason, read from the Goal of the entry's workstream or, for an entry naming no workstream, from the harm its absence does to the project, and SHALL write it only once the operator confirms it. It SHALL write into `waits_on` only names of entries or changes, and SHALL write a wait on anything else — an answer, an access grant, an event — as a condition in `waits_for`. Where the README's shape names `waits_for_type`, it SHALL write beside each `waits_for` the types the condition states, from the README's set. It SHALL search the existing entries for ones touching the same files, specifications or capabilities and present each as a Design with candidate, writing into `design_with` only the candidates the session or operator confirms share a design, or the README's empty value — `[]` in the seeded README. A shared pointer is evidence of a shared design, not the same thing. Where the README's shape names `priority`, it SHALL set it to the README's default — `normal` in the seeded README — unless the session or the operator states the evidence or the condition the README requires for another value, and SHALL write `high`, or `parked` with its `parked_until`, only once the operator confirms it. Where the README's shape names `workstream`, it SHALL read the Goal and Not in scope of every open workstream in `docs/workstreams/` before setting it. It SHALL set it to the workstream of the change the session is in where the entry serves that workstream's Goal and falls inside its scope; otherwise to the open workstream whose Goal the entry serves, asking the operator where more than one is served; and to the README's absent value — `none` in the seeded README — only once that read finds none. What the operator states the entry serves SHALL be taken over that reading. It SHALL write only a name an open workstream in `docs/workstreams/` carries, or that absent value, and SHALL say in its answer the workstream chosen for each entry and why, so the operator need not ask where an entry belongs. Before writing that absent value, it SHALL read the bodies of the other entries carrying it, not the repository, for a goal they share with the entry; where they share one that takes more than one change, it SHALL propose to the operator opening a workstream for it, naming the entries and a draft Goal, as `docs/workstreams/AGENTS.md` directs, SHALL write the absent value meanwhile, and SHALL say in its answer what it proposed or that no shared goal was found. Where it writes an open workstream's name, it SHALL add the entry to that workstream's steps in the same edit, asking the operator where in the order, or SHALL say that the entry is left for the archive and why. Where `docs/workstreams/README.md` exists, its name check SHALL also cover the names of workstreams, open and archived. It SHALL set `re_checked` to the day the entry is written. It SHALL write the frontmatter in the form the README states — bare names, set values and dates, double-quoted free text with `"` and `\` escaped, inline lists — and SHALL write no key the README does not define.

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

#### Scenario: Entries sharing a goal are proposed a workstream

- **WHEN** record is about to write the absent value on an entry, and two entries already carrying it share with it a goal that takes more than one change
- **THEN** it writes the absent value, and its answer proposes opening a workstream for that goal, naming the three entries and a draft Goal, and no workstream file is created

#### Scenario: No shared goal is said

- **WHEN** record writes the absent value on an entry that shares no goal with the other entries carrying it
- **THEN** its answer says that no shared goal was found

#### Scenario: A goal one change meets earns no proposal

- **WHEN** record writes the absent value on an entry that shares with one other entry carrying it a goal one change would meet
- **THEN** it proposes no workstream for that goal

### Requirement: Sweep performs the archive step's re-read

*Modified by `propose-a-workstream-for-entries-sharing-a-goal`: an entry sweep sets to the absent value is first read with the entries already carrying it, and with the others it detaches, for a shared goal, as record reads them. Every scenario keeps its title; one is added.*

*Modified by `match-backlog-entries-to-a-workstream`: sweep also gathers the entries unplaced in the change's open workstream, the change's own among them, and detaches an entry, here and where a workstream is archived, by reading the open workstreams' Goals. Every scenario keeps its title; three are added.*

*Modified by `one-file-per-backlog-entry`: sweep reads the entry files and their `waits_on`, `parked_until` and `workstream`, and edits entry files as the README directs. Every scenario keeps its title.*

The **sweep** operation, given a change, SHALL find the entries it completed, made obsolete, unblocked, unparked or made stale. It SHALL search for entries naming the change, entries whose `waits_on` names it, entries whose `waits_for` or `parked_until` it fulfils, entries whose `high` evidence it removes, entries naming files or specifications the change touched, where the change's archive archives a workstream, entries naming that workstream, and, where the change advanced an open workstream its archive does not archive, the entries the **workstreams** operation's unplaced read finds in it, that read being made over the change's working tree as well as the trunk, so that the entries the change recorded are among them, rather than by a second definition.

It SHALL take what the change touched from the change's merged pull requests on the forge — every one of them, since a change takes at least two — and, where the forge cannot be reached, from the change's specification deltas and the files its design and tasks name, saying that the fallback was used. It SHALL NOT take them from the branch's diff against the trunk: by the archive step the branch has been brought back to the trunk, and a squash merge leaves no ancestry, so that diff holds the record alone.

Run before the archive commit, it SHALL update each entry's file as the README directs and leave the edit for that commit. Run after the change's record is on the trunk, it SHALL make the same edit and say that it is to be delivered as the workflow delivers work too small to be a change.

It SHALL present each unplaced entry to be placed among the steps, the position asked of the operator, or detached. An entry that does not serve its workstream's Goal, or that its workstream's Not in scope leaves out, is detached by the same read of the open workstreams' Goals record makes, not set to the README's absent value without it. An entry to be set to that absent value SHALL first be read with the entries already carrying it, and with the others the same sweep detaches, for a goal they share, as record reads them, and a workstream SHALL be proposed where they share one that takes more than one change. Editing the workstream's steps is the one edit sweep makes outside the entry files, and it SHALL go in the same commit as the entry edits.

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

#### Scenario: Entries detached together share a goal

- **WHEN** sweep detaches the entries of a workstream being archived, the read of the open workstreams finds none for three of them, and those three share a goal that takes more than one change
- **THEN** sweep proposes them with the README's absent value and proposes a workstream for that goal, naming the three and a draft Goal

### Requirement: Audit verifies every entry independently and changes nothing without the operator

*Modified by `propose-a-workstream-for-entries-sharing-a-goal`: after merging the agents' verdicts, the skill reads every entry carrying the absent value together, across ranges, and the report gains the groups that share a goal, proposed as workstreams. Every scenario keeps its title; one is added.*

*Modified by `report-a-tasks-kind-and-wait`: for an entry carrying `waits_for`, an agent also says whether its `waits_for_type` states the kinds the condition holds, and proposes them where it has none; the report lists a wrong or missing type, and a type without a condition, among the stale facts. Audit proposes no `need`. Every scenario keeps its title; three are added.*

*Modified by `one-file-per-backlog-entry`: the ranges are sets of entry files, an agent is given each file verbatim, and the approved cleanup is one edit across the entry files. Every scenario keeps its title.*

The **audit** operation SHALL divide the entry files into ranges and give each range to a separate read-only agent run in parallel. Each agent SHALL verify every entry in its range against the code, the specifications, the open and the archived changes, the commit history and the forge's merged pull requests, and SHALL return for each entry a relevance verdict — `live`, `stale`, `partly-done`, `obsolete` or `waiting` — and a kind verdict — `fix`, `change` or `fix?` — each with its evidence. Where the README's shape names `priority`, for an entry whose `priority` is `high` it SHALL say whether the evidence still holds, and for one that is `parked`, whether its `parked_until` now holds. For an entry carrying `waits_for`, it SHALL say whether the condition now holds, and, where the README's shape names `waits_for_type`, whether the entry's types state the kinds of wait the condition holds, proposing them where it has none, and SHALL report a `waits_for_type` carried without `waits_for`. It SHALL propose no `need`, which is the operator's judgement. Where the README's shape names `workstream`, it SHALL say whether the workstream an entry names is open in `docs/workstreams/`. It SHALL say where a name in an entry's `waits_on` or `design_with` is neither an entry nor a change, open or archived.

The archived changes and merged pull requests are named because an entry is most often completed by a change that never mentions it, and an agent checking the code alone reads such an entry as live.

The skill SHALL merge the agents' results into one report naming: the entries done or obsolete, the entries that are one change recorded twice, the entries whose facts are stale — among them each `high` entry whose evidence no longer holds, with its `priority` corrected as the README directs, each entry naming a workstream that is archived or absent, each entry naming an unknown name, each condition whose type is wrong or missing, with the types proposed, and each `waits_for_type` carried without `waits_for` —, the groups that share a design, the groups of entries carrying the README's absent value that share a goal taking more than one change, each with a draft Goal, proposed as workstreams, the entries now unblocked or unparked, and the entries that can be taken as fixes. The skill SHALL find those groups itself, reading the bodies of every entry carrying the absent value together after the agents return, because no agent sees two ranges. It SHALL apply none of it until the operator says so, SHALL open a workstream the operator approves as `docs/workstreams/AGENTS.md` and the workflow direct, its entries re-pointed to it, and SHALL then apply it as one edit across the entry files and the workstream files it opens, delivered as the workflow delivers work too small to be a change.

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

#### Scenario: Entries in two ranges share a goal

- **WHEN** two entries carrying the absent value, given to different agents, share a goal that takes more than one change
- **THEN** the report names them as one group under a draft Goal, proposed as a workstream, and no workstream file is created until the operator approves
