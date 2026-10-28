## MODIFIED Requirements

### Requirement: The skill operates on the project it is invoked in

*Modified by `list-what-a-project-receives`: a directory's rules are its `AGENTS.md` block, or a `README.md` where it holds no block. *A project on the rules' earlier README* is added; every other scenario keeps its title.*


*Modified by `one-file-per-backlog-entry`: the skill operates on the directory `docs/backlog/`, and refuses a project still on the single file, naming the migration tool. Every scenario keeps its title.*

The library SHALL carry a skill at `skills/backlog/SKILL.md` whose directory name and `name` are `backlog`. It SHALL operate on `docs/backlog/` of the project it is invoked in — its rules file and one file per entry — not on this repository unless this repository is that project.

A directory's **rules file** is its `AGENTS.md` where that file holds a managed block of the directory's rules, and its `README.md` where it holds none, the shape before `1.0.0`, which a project keeps until an update converts it. Where a requirement of this capability says a directory's README, it means that directory's rules file. The skill SHALL NOT write a rules file, convert one shape into the other, or count `AGENTS.md`, `CLAUDE.md` or `README.md` as an entry.

Where the project has `docs/backlog.md` and no rules file in `docs/backlog/`, the skill SHALL say that the backlog is in the single-file shape, name `scripts/backlog-migrate` as what converts it, and perform no operation. It SHALL NOT convert the file itself, and SHALL NOT read or write the single file as if it were the directory. A conversion written by a session's own judgement is the variance a deterministic tool exists to remove, and an operation run against two shapes is a second set of rules to keep true.

Where `docs/workstreams/` holds no rules file, an operation step that reads workstreams SHALL say so, name `project-init` as what seeds it, and be skipped, and the skill SHALL NOT create the file.

Its description SHALL state the six operations and the phrasings that reach them, and SHALL distinguish it from `project-init`, which writes the backlog's rules, from `scripts/backlog-migrate`, which converts a single-file backlog, and from the OpenSpec skills, which open and carry the change an entry names.

#### Scenario: Invoked from a consuming project

- **WHEN** the skill is invoked in a project that installed this library as a plugin
- **THEN** it reads and writes that project's `docs/backlog/`, and touches nothing in this library

#### Scenario: No backlog exists

- **WHEN** the skill is invoked in a project with neither a rules file in `docs/backlog/` nor `docs/backlog.md`
- **THEN** it says so and names `project-init` as what seeds the backlog, and creates nothing with text of its own

#### Scenario: No workstream register exists

- **WHEN** an operation that reads workstreams is invoked in a project with no rules file in `docs/workstreams/`
- **THEN** it says so, names `project-init` as what seeds the file, skips the workstream steps, and creates nothing

#### Scenario: A project on the single file

- **WHEN** the skill is invoked in a project with `docs/backlog.md` and no rules file in `docs/backlog/`
- **THEN** it says the backlog is in the single-file shape, names `scripts/backlog-migrate`, performs no operation, and leaves `docs/backlog.md` unchanged

#### Scenario: A project on the rules' earlier README

- **WHEN** the skill is invoked in a project whose `docs/backlog/` holds `README.md` and no `AGENTS.md`
- **THEN** it reads the entry rules from that README and performs the operation, and writes no `AGENTS.md`

### Requirement: The skill restates neither the entry rules nor the workflow's obligations

*Modified by `list-what-a-project-receives`: the rules are read from each directory's rules file, its `AGENTS.md` block or an earlier `README.md`. Every scenario keeps its title.*


*Modified by `one-file-per-backlog-entry`: the entry rules are read from `docs/backlog/README.md`. Every scenario keeps its title.*

The skill SHALL read how an entry is shaped, named, kept and deleted from the rules file of `docs/backlog/`, and SHALL NOT restate those rules. It SHALL NOT place an obligation on a session that the workflow fragment does not state, and SHALL NOT be required for any obligation the fragment states to be met. The checks an operation performs and the gates on its own edits are procedure: they bind a session only while it runs that operation, and an entry or an archive done without the skill is not deficient for lacking them. This is the seam `session-workflow` states for an operational skill.

It SHALL likewise read how a workstream is named, shaped, kept and archived, and how a step's status is derived, from the rules file of `docs/workstreams/`, and SHALL NOT restate those rules.

The entry rules and the workstream rules are owned by `project-bootstrap` and stated in each directory's rules file; the obligations to record, and to re-read at archive, are owned by `session-workflow` and stated in the fragment. A third statement of either is a wording that drifts from both, and a skill is loaded only when something judges it relevant, so it cannot be where an obligation lives.

#### Scenario: A project's preamble differs from the seeded one

- **WHEN** a project's backlog rules file states an entry shape that differs from the one `project-init` writes
- **THEN** the skill records and checks entries against the shape that file states, not against a shape of its own

#### Scenario: The skill does not mandate an audit cadence

- **WHEN** a session reads the skill
- **THEN** it finds no rule obliging an audit at any interval, since the fragment states none

#### Scenario: A project's workstream README differs from the seeded one

- **WHEN** a project's workstreams rules file states a status derivation or a workstream shape that differs from the one `project-init` writes
- **THEN** the skill reads workstreams and derives status by what that file states, not by rules of its own

### Requirement: Record writes an entry the file can be relied on for

*Modified by `list-what-a-project-receives`: record refuses `agents` and `claude` as it refuses `readme`. *Record refuses a name colliding with the rules' files* is added; every other scenario keeps its title.*


*Modified by `one-file-per-backlog-entry`: record writes one entry file, its values as frontmatter in the README's form and its reasons in the body, and keeps names and conditions apart. Every scenario keeps its title.*

The **record** operation SHALL write one entry as its own file, `docs/backlog/<name>.md`, in the shape the README states: its values as frontmatter in the README's form, and its prose and reasons as the body. Where the session invoking it is in a change, record SHALL first test the work against the fold-in rule the project's workflow states, where it states one, taking the test from the workflow rather than stating it; where the work meets it, record SHALL say so and write no entry. It SHALL offer no override the workflow does not state. Before writing, it SHALL check the entry's name against the entry files in `docs/backlog/`, the project's open and archived change directories, and its branches, and SHALL not write a name already used by any of them, nor `readme`, `agents` or `claude` in any case, which would collide with `README.md`, `AGENTS.md` or `CLAUDE.md` on a filesystem that ignores case, overwriting the directory's rules or their import. It SHALL set `kind` by the README's own definition and state the reason in the body. It SHALL write into `waits_on` only names of entries or changes, and SHALL write a wait on anything else — an answer, an access grant, an event — as a condition in `waits_for`. It SHALL search the existing entries for ones touching the same files, specifications or capabilities and present each as a Design with candidate, writing into `design_with` only the candidates the session or operator confirms share a design, or the README's empty value — `[]` in the seeded README. A shared pointer is evidence of a shared design, not the same thing. Where the README's shape names `priority`, it SHALL set it to the README's default — `normal` in the seeded README — unless the session or the operator states the evidence or the condition the README requires for another value, and SHALL write `high`, or `parked` with its `parked_until`, only once the operator confirms it. Where the README's shape names `workstream`, it SHALL set it to the workstream of the change the session is in, where it is in one, unless the session or the operator states that the entry serves another goal or none, and otherwise to the README's absent value — `none` in the seeded README; it SHALL write only a name an open workstream in `docs/workstreams/` carries, or that absent value. Where `docs/workstreams/README.md` exists, its name check SHALL also cover the names of workstreams, open and archived. It SHALL set `re_checked` to the day the entry is written. It SHALL write the frontmatter in the form the README states — bare names, set values and dates, double-quoted free text with `"` and `\` escaped, inline lists — and SHALL write no key the README does not define.

Urgency and deferral are the operator's judgements about the project's work, not facts a session can verify alone, which is why record proposes them and does not set them on its own.

The fold-in test, the name check and the overlap search are the operation's procedure, not entry rules or obligations: the workflow states when work is folded in, the README states that an entry is named and may name entries to design with, and record is how the skill makes those statements hold for the entry it writes.

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

- **WHEN** record writes an entry from a change whose proposal names an open workstream, and nothing states the entry serves another goal
- **THEN** the entry's `workstream` names that workstream

#### Scenario: Record refuses a workstream that is not open

- **WHEN** record is asked to set `workstream` to a name no open workstream carries
- **THEN** it does not write that name, and asks for an open workstream or the README's absent value

#### Scenario: Record keeps a condition out of waits_on

- **WHEN** record writes an entry that waits on a named change and on a person's answer
- **THEN** the change's name is in `waits_on`, the answer is a double-quoted condition in `waits_for`, and `waits_on` holds no other text

#### Scenario: Record writes one file

- **WHEN** record writes an entry
- **THEN** exactly one file, `docs/backlog/<name>.md`, is created, and no other entry file and no README is changed
