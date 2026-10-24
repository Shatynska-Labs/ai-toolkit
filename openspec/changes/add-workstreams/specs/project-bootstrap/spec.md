## MODIFIED Requirements

### Requirement: Each concern is checked independently and is safe to repeat

The tool SHALL evaluate each concern on its own — repository initialized, specification tooling initialized, ignore file present, backlog present, workstream register present, conventions file present, managed block present — completing what is absent and skipping what is satisfied.

The tool SHALL NOT refuse to run because some concerns are already satisfied. Repeated execution SHALL be safe: a second run against an unchanged directory SHALL make no destructive change and SHALL alter no file the first run already brought to its target state.

#### Scenario: Repeated execution is not destructive

- **WHEN** the tool is run twice in succession against the same directory
- **THEN** the second run completes reporting every concern as already satisfied, and no file written by the first run is modified, truncated, or duplicated

#### Scenario: A partially initialized directory is completed, not refused

- **WHEN** the tool runs where a repository exists but specification tooling does not
- **THEN** it skips repository initialization, completes specification tooling, and reports each concern's outcome separately

#### Scenario: Existing specification tooling is skipped, not reinitialized

- **WHEN** the tool runs where both a repository and specification tooling are already present
- **THEN** both are reported as already satisfied, neither is reinitialized, and no file either of them owns is modified


### Requirement: A backlog is seeded where none exists

Where `docs/backlog.md` does not exist in the target, the tool SHALL create it, in both the new-project and the adoption mode, creating `docs/` if absent. Where the file exists, the tool SHALL leave it byte-for-byte unchanged and report it present.

The workflow fragment routes out-of-scope work to that path and defers to the file for how an entry is written. A file each project's first session invents carries a different header, entry shape and deletion rule in every project, so the rules the fragment defers to would not be the same rules anywhere.

The created file SHALL state, as prose a session reads before adding an entry:

- that it lists changes the project has identified and not yet archived, each recorded instead of being folded into the change that found it;
- that an entry's heading is the change's kebab-case name — the name its branch and change directory are expected to take, which the session that opens the change may revise if the work turns out different — and that an entry is referred to only by that name, a fix taking it as its branch's name only;
- that the order of entries carries no meaning, and that an entry states in its own fields what it waits on, how urgent it is, and which entries share a design with it;
- that an entry is kept short: what is needed and why, with files, specifications and changes named as pointers, and without line numbers, census tables or step-by-step plans;
- that an entry is deleted when its change is archived, when the operator takes it as a fix rather than a change, when a change makes it obsolete, or when the operator decides the change will not be made;
- that when a change is archived, the entries it unblocked, unparked or made stale are updated and their re-checked date set;
- that the file is kept when it has no entries;
- the shape of an entry: its heading; what the change is and why, written for a session that has not seen the work that found it; its **Priority**, `high`, `normal` or `parked until` a condition that can be checked, with the reason, that a parked entry is not folded into another change before its condition holds, that a parked entry whose condition holds becomes `normal`, or `high` with evidence, that a `high` entry whose evidence no longer holds becomes `normal`, and that an entry without the field is `normal`; its **Kind**, `fix` or `change`, with the reason; what it **Waits on**, as `nothing` or as something that can be checked — a change by name, a person's answer, an event; which entries it is to be **designed with**, or nothing; which **workstream** it is a step of or serves, by name, or `nothing`, that an entry recorded by a change in a workstream takes that workstream unless it serves another goal, and that an entry without the field is `nothing`; what **recorded** it and why it was not done there; and the date it was last **re-checked** against the repository.

**Kind is `fix` only where the entry owes no specification delta, needs no decision from the operator, and is small enough to review in one sitting**; otherwise it is `change`. The size condition is the workflow's own: a fix is work too small to be a change, which skips `plan`, so an entry too large for one sitting is not one whatever it owes. The reason is stated because the label alone cannot be checked, and an entry's kind is the first thing a session picking work reads.

**Waits on replaces a list of changes that must land first.** An entry that should precede another says so from the waiting side: the later entry names it in Waits on. The earlier shape also let an entry state what it should precede; that direction is dropped, because a constraint stated on both sides is two statements that drift, and Waits on is the side the pick and the archive re-read read.

**Priority is `high` only with evidence of harm happening now** — an incident, a measurement, an observation — and **`parked` only with a condition that can be checked**, under which the entry becomes worth taking. Both are stated so that a later reading can tell whether they still hold, which a bare label cannot show. There is no `low`: an entry not worth taking with no condition under which it would be is one the operator has decided will not be made, which is already a deletion ground. Parked is not a wait: a waiting entry cannot be taken, a parked one can and is deliberately deferred, and an entry may be both. An entry without the field is `normal`, stated in the file so that a backlog written before the field existed needs no edit.

**Workstream is not Design with.** Design with groups entries that share a design, a property of the work; Workstream places an entry in a goal's sequence of changes, a property of the plan. Two entries may share either without the other, so neither field stands in for the other. The default is the recording change's workstream because work a change identifies usually serves the goal that change serves, and an entry recorded without it is detached from the plan it belongs to. An entry without the field is `nothing`, stated in the file so that a backlog written before the field existed needs no edit.

A blocked entry waits on more than changes — an answer, an access grant, a production event — and a trigger stated as something checkable is the one that can be noticed when it fires.

Entry brevity is stated because the details it excludes are the ones that go stale first, and the session that takes the entry up redoes them anyway. A census worth keeping belongs in the change's own artifacts once the change is opened.

**This requirement owns the backlog's entry rules**; `session-workflow` owns only routing work to the file and when it is re-read, and its fragment defers to the file for these rules rather than restating them. `backlog-maintenance` performs operations over the file and likewise reads these rules from it.

The file is present where a path exists at `docs/backlog.md` of any type, including a symbolic link whether or not it resolves. A link counted as absent would be written through, to wherever it points.

The created file SHALL contain no entry, and SHALL NOT number entries or mention entry numbers. An entry carrying a number invites citing and ordering by it; a name is the identifier that survives other entries being deleted.

The file is kept when empty because the tool created it: deleting it would leave the next session to recreate it from no text at all, which is the variance this requirement removes.

#### Scenario: A project without a backlog receives the seeded file

- **WHEN** the tool runs in a target with no `docs/backlog.md`
- **THEN** the file is created with every statement listed above and no entry, and the report states the backlog was created

#### Scenario: An existing backlog is preserved exactly

- **WHEN** the target already contains `docs/backlog.md`
- **THEN** its contents are left byte-for-byte unchanged and the report states the backlog is already present

#### Scenario: The seeded file carries no numbering

- **WHEN** the seeded file is created
- **THEN** no heading in it begins with a number and no sentence in it refers to an entry's number

#### Scenario: The seeded entry shape carries the structured fields

- **WHEN** the seeded file is created
- **THEN** its entry shape names Priority, Kind, Waits on, Design with, Workstream, Recorded by and Re-checked, and does not name Depends on

#### Scenario: A fix is distinguished from a change by what it owes

- **WHEN** a session reads the seeded file to record an entry that owes a specification delta
- **THEN** the file's definition of Kind leaves only `change` available to it, because `fix` is stated as owing no delta, needing no decision and fitting one review sitting

#### Scenario: Priority's values and default are stated

- **WHEN** the seeded file is created
- **THEN** its entry shape states Priority's three values `high`, `normal` and `parked until`, that `high` needs evidence of harm happening now, that `parked` needs a condition that can be checked, and that an entry without the field is `normal`

#### Scenario: The seeded file offers no low priority

- **WHEN** a session reads the seeded file to record an entry it judges not worth taking
- **THEN** the file offers no `low` value, so the entry is either parked with a condition or not recorded

#### Scenario: The seeded file states how an entry leaves parked and high

- **WHEN** a session reads the seeded file at the archive of a change that fulfilled a parked entry's condition, or removed a `high` entry's evidence
- **THEN** the file directs that entry to `normal`, or to `high` with evidence for the parked one, and names unparked entries among those the archive updates

#### Scenario: Workstream's default is stated

- **WHEN** the seeded file is created
- **THEN** its entry shape states that an entry recorded by a change in a workstream takes that workstream unless it serves another goal, and that an entry without the field is `nothing`

## ADDED Requirements

### Requirement: A workstream register is seeded where none exists

Where `docs/workstreams/README.md` does not exist in the target, the tool SHALL create it, in both the new-project and the adoption mode, creating `docs/workstreams/` if absent. Where the file exists, the tool SHALL leave it byte-for-byte unchanged and report it present. The file is present where a path exists at `docs/workstreams/README.md` of any type, including a symbolic link whether or not it resolves. The tool SHALL NOT create `docs/workstreams/archive/`.

A workstream is a goal that takes more than one change. The workflow fragment sends a session to this directory at a change's proposal and at its archive, and defers to the README for how a workstream is written, as it defers to the backlog for an entry. Unseeded, each project's first session would invent those rules, and the fragment's references would mean something different in every project.

The created file SHALL state, as prose a session reads before opening, editing or archiving a workstream:

- that a workstream is a goal that takes more than one change, each open one a file in this directory named `<name>.md` for its kebab-case name, unique among workstreams open and archived and not also a change's name, and referred to only by that name;
- that a workstream file holds the plan and never its progress, and that a step's status is read from the repository by the step's name, the first that holds winning: done where the freshly fetched trunk holds an archived change of that name; in flight where it holds an open change of that name, or a local or remote branch or an open pull request of that name exists; recorded where its `docs/backlog.md` has an entry of that name; and planned otherwise;
- that the order of the steps is the intended order of work and gates nothing, a step that cannot start before another saying so in its backlog entry's Waits on;
- that the file is edited only when the plan changes — a step added, removed, reordered or renamed, what finishes it or what is out of scope revised, an open question added or answered, or the workstream archived;
- that a workstream is opened when the operator decides a goal needs more than one change, and committed with the plan of the first change that advances it or as work too small to be a change;
- that a change or a backlog entry may name the workstream it serves before any step names it, and that each such change or entry is placed among the steps or detached at the next edit of the workstream, and at the latest at the archive of a change in it;
- that when what finishes a workstream holds, its file moves to `archive/<YYYY-MM-DD>-<name>.md`, dated the day it is archived, in the commit that carries the record of the change that completed it, after each step not done, other than the change whose record that commit carries, is removed from the steps, first recorded as a backlog entry naming no workstream where it is still wanted and not yet in flight, an in-flight one continuing as its own change, and every backlog entry still naming it is re-pointed or cleared;
- that the operator may abandon a workstream whose goal will not be met, which gains an **Abandoned** line with the date and the reason, has its steps and entries dealt with as on completion, and is moved to `archive/` the same way, as work too small to be a change;
- that a workstream is kept short, its lasting decisions recorded in a document or a change's design it points to, and that the README is kept when there is no workstream;
- the shape of a workstream: its heading, the name; its **Goal**; its **Done when**, a condition that can be checked against the repository, the forge or production; its **Steps**, an ordered list each naming a change in kebab-case with what it does; what is **Not in scope**, or `nothing`; its **Open questions**, each deleted once answered with the answer recorded where its decisions are, or `nothing`; its **Decisions**, where they are recorded, or `nothing`; and when and by what it was **Opened**.

**The file holds no status because status written by hand goes stale.** Progress happens in every session, and a status field is edited by none of them at the moment it changes; a status read from the repository by name is current whenever it is read. That is why a step is named by the change it is expected to be: the name is the key the lookups use. **The precedence and the trunk are stated because the sources overlap**: a backlog entry survives until its change is archived, and a branch until the record's pull request merges, so a step matches more than one source in the ordinary course of its life; and a session's own working tree may predate a step's archive, so reading it would give each session a different answer.

**Order gates nothing because precedence already has one authority.** Waits on is the side the pick and the archive re-read read, and the backlog dropped a second side because two statements of one constraint drift; a step's "comes after" in the workstream file would reintroduce it.

**A finished or abandoned workstream is archived, not deleted** (operator, 2026-10-24), so its plan and the decisions it points to stay readable after its goal is met, as an archived change's record does.

**This requirement owns the workstream rules**; `session-workflow` owns only when the fragment sends a session to the directory, and its fragment defers to the README rather than restating them. `backlog-maintenance` reads them from the README.

The created file SHALL contain no workstream.

#### Scenario: A project without a workstream register receives the seeded file

- **WHEN** the tool runs in a target with no `docs/workstreams/README.md`
- **THEN** the file is created with every statement listed above and no workstream, no `archive/` directory is created, and the report states the workstream register was created

#### Scenario: An existing workstream register is preserved exactly

- **WHEN** the target already contains `docs/workstreams/README.md`, or a symbolic link at that path
- **THEN** it is left byte-for-byte unchanged and not written through, and the report states the workstream register is already present

#### Scenario: The seeded register carries no status field

- **WHEN** the seeded file is created
- **THEN** its workstream shape names Goal, Done when, Steps, Not in scope, Open questions, Decisions and Opened, and names no field recording a step's status

#### Scenario: An abandoned workstream is archived, not deleted

- **WHEN** a session reads the seeded file after the operator decides a workstream's goal will not be met
- **THEN** the file directs adding an Abandoned line with the date and reason and moving the workstream to a dated file under `archive/`, after its unfinished steps and the entries naming it are dealt with

#### Scenario: A finished workstream is archived

- **WHEN** a session reads the seeded file at the archive of the change that made a workstream's Done when hold
- **THEN** the file directs moving the workstream to a dated file under `archive/` in the record's commit, after its unfinished steps and the entries naming it are dealt with

#### Scenario: A step matching two sources takes the first status

- **WHEN** a step's change is open on the trunk and its backlog entry has not yet been deleted
- **THEN** the seeded file's precedence makes the step in flight, not recorded

#### Scenario: Step order is not a dependency

- **WHEN** a session reads the seeded file to learn whether a step may start before the step listed above it
- **THEN** the file directs it to that step's backlog entry's Waits on, and states that list order gates nothing

