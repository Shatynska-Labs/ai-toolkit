## MODIFIED Requirements

### Requirement: A workstream register is seeded where none exists

*Modified by `one-file-per-backlog-entry`: a step is recorded where `docs/backlog/` holds an entry of its name, and a step's ordering wait is its entry's `waits_on`.*

*Modified by `observe-what-finishes-a-workstream`: a workstream's Done when names an observable effect of its Goal, and every step being archived may stand beside it but never in its place.*

*Modified by `hold-shared-research-in-a-workstream`: a workstream holds, besides its plan, the context and decisions its steps share, which are never progress and are revised in place when overturned.*

Where `docs/workstreams/README.md` does not exist in the target, the tool SHALL create it, in both the new-project and the adoption mode, creating `docs/workstreams/` if absent. Where the file exists, the tool SHALL leave it byte-for-byte unchanged and report it present. The file is present where a path exists at `docs/workstreams/README.md` of any type, including a symbolic link whether or not it resolves. The tool SHALL NOT create `docs/workstreams/archive/`.

A workstream is a goal that takes more than one change. The workflow fragment sends a session to this directory at a change's proposal and at its archive, and defers to the README for how a workstream is written, as it defers to the backlog's README for an entry. Unseeded, each project's first session would invent those rules, and the fragment's references would mean something different in every project.

The created file SHALL state, as prose a session reads before opening, editing or archiving a workstream:

- that a workstream is a goal that takes more than one change, each open one a file in this directory named `<name>.md` for its kebab-case name, unique among workstreams open and archived and not also a change's name, and referred to only by that name;
- that a workstream file holds the plan and never its progress, and that a step's status is read from the repository by the step's name, the first that holds winning: done where the freshly fetched trunk holds an archived change of that name; in flight where it holds an open change of that name, or a local or remote branch or an open pull request of that name exists; recorded where its `docs/backlog/` holds an entry of that name; and planned otherwise;
- that the order of the steps is the intended order of work and gates nothing, a step that cannot start before another saying so in its backlog entry's `waits_on`;
- that the file is edited only when the plan or what it holds changes — a step added, removed, reordered or renamed, what finishes it or what is out of scope revised, an open question added or answered, context or a decision added or revised, or the workstream archived;
- that a workstream is opened when the operator decides a goal needs more than one change, and committed with the plan of the first change that advances it or as work too small to be a change;
- that a change or a backlog entry may name the workstream it serves before any step names it, and that each such change or entry is placed among the steps or detached at the next edit of the workstream, and at the latest at the archive of a change in it;
- that what finishes a workstream, its Done when, is an observable effect of its Goal — what to look at in the repository, the forge or production, what provokes it where something must, and the result that means the Goal holds — and that every step being archived may stand beside that effect where it is wanted but never in its place, since it shows only that the step list was worked through, which a list missing a step satisfies as well;
- that when what finishes a workstream holds, its file moves to `archive/<YYYY-MM-DD>-<name>.md`, dated the day it is archived, in the commit that carries the record of the change that completed it, after each step not done, other than the change whose record that commit carries, is removed from the steps, first recorded as a backlog entry naming no workstream where it is still wanted and not yet in flight, an in-flight one continuing as its own change, and every backlog entry still naming it is re-pointed or cleared;
- that the operator may abandon a workstream whose goal will not be met, which gains an **Abandoned** item after Opened, with the date and the reason, has its steps and entries dealt with as on completion, and is moved to `archive/` the same way, as work too small to be a change;
- that besides its plan a workstream holds what its steps share: under `## Context`, the research, findings and options considered that the goal was planned from, with why one option was chosen; and under `## Decisions`, the decisions that shape more than one step or were taken before any step's proposal existed, each with who took it, when and why, a decision already recorded in a change's design pointed to rather than copied;
- that a decision shaping one step only belongs in that step's design, which points to the workstream for what it shares rather than copying it;
- that Context and Decisions say what is known and decided about the goal and never how far the work has come: a finding states what is true of the problem, not that a step found or did it, and neither names a step as done, in flight or merged;
- that Context and Decisions state what is held now: where a change in the workstream overturns something they hold, it is revised in place, naming that change, in its plan commit or at the latest at its archive;
- that the README is kept when there is no workstream;
- the shape of a workstream: its heading, the name; its **Goal**; its **Done when**, an observable effect of the Goal that can be checked against the repository, the forge or production, with every step being archived beside it where that is wanted; its **Steps**, an ordered list each naming a change in kebab-case with what it does; what is **Not in scope**, or `none`; its **Open questions**, each deleted once answered with the answer recorded under Decisions, or `none`; and when and by what it was **Opened** — Goal and Done when as paragraphs, and the fields after the steps as one list, one item per field, with no blank line between them; then an optional `## Context` section and an optional `## Decisions` section, in that order, each omitted where it would be empty.

**The file holds no status because status written by hand goes stale.** Progress happens in every session, and a status field is edited by none of them at the moment it changes; a status read from the repository by name is current whenever it is read. That is why a step is named by the change it is expected to be: the name is the key the lookups use. **The precedence and the trunk are stated because the sources overlap**: a backlog entry survives until its change is archived, and a branch until the record's pull request merges, so a step matches more than one source in the ordinary course of its life; and a session's own working tree may predate a step's archive, so reading it would give each session a different answer.

**Done when names an effect of the Goal because the steps are the plan's guess at reaching it.** "Every step is archived" is checked against the repository, so it meets the old wording, yet it holds for a step list that missed a step as surely as for one that did not: it confirms the plan was carried out, not that the Goal was reached. A change's `confirm` already asks for its effect to be observed rather than inferred from a merge; a workstream's Done when asks the same of its Goal. Archiving every step stays available beside the effect, for a workstream whose steps are each wanted whatever the effect shows.

**A workstream holds what its steps share because nowhere else ties it to the goal.** A change's design belongs to one step and is archived with it, so research shared by several steps is copied into each or leaves with the first to finish; a separate document under `docs/` is tied to no goal and retired by nothing. The workstream file is the one place every step points to, and it is archived whole. The two reasons the file was once kept short still hold, and are answered rather than dropped. Status written by hand goes stale because progress happens in every session; what Context and Decisions hold changes only when understanding of the goal changes, and never records progress. Edits were kept rare so parallel sessions seldom meet in one file; they stay tied to events — research done, a decision taken or overturned — not to sessions. **Overturned content is revised in place** (operator, 2026-10-27) because a record a reader must reconcile entry by entry is the stale table in another form; the file's history keeps what was held before.

**Order gates nothing because precedence already has one authority.** `waits_on` is the side the pick and the archive re-read read, and the backlog dropped a second side because two statements of one constraint drift; a step's "comes after" in the workstream file would reintroduce it.

**A finished or abandoned workstream is archived, not deleted** (operator, 2026-10-24), so its plan, context and decisions stay readable after its goal is met, as an archived change's record does.

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
- **THEN** its workstream shape names Goal, Done when, Steps, Not in scope, Open questions and Opened, and the Context and Decisions sections, and names no field or section recording a step's status

#### Scenario: An abandoned workstream is archived, not deleted

- **WHEN** a session reads the seeded file after the operator decides a workstream's goal will not be met
- **THEN** the file directs adding an Abandoned line with the date and reason and moving the workstream to a dated file under `archive/`, after its unfinished steps and the entries naming it are dealt with

#### Scenario: A finished workstream is archived

- **WHEN** a session reads the seeded file at the archive of the change that made a workstream's Done when hold
- **THEN** the file directs moving the workstream to a dated file under `archive/` in the record's commit, after its unfinished steps and the entries naming it are dealt with

#### Scenario: A step matching two sources takes the first status

- **WHEN** a step's change is open on the trunk and its backlog entry file has not yet been deleted
- **THEN** the seeded file's precedence makes the step in flight, not recorded

#### Scenario: Step order is not a dependency

- **WHEN** a session reads the seeded file to learn whether a step may start before the step listed above it
- **THEN** the file directs it to that step's backlog entry's `waits_on`, and states that list order gates nothing

#### Scenario: The seeded workstream's fields are a list

- **WHEN** the seeded file is created
- **THEN** its workstream shape gives Not in scope, Open questions and Opened as consecutive list items after the steps, each absent value as `none`, gives no Decisions list item, and places `## Context` and then `## Decisions` after the list

#### Scenario: A step is recorded by its entry file

- **WHEN** the seeded file is created
- **THEN** it states that a step is recorded where `docs/backlog/` holds an entry of the step's name, and does not name `docs/backlog.md`

#### Scenario: Done when asks for an observable effect of the Goal

- **WHEN** the seeded file is created
- **THEN** its workstream shape gives Done when as an observable effect of the Goal, and its prose states that every step being archived may stand beside that effect but never in its place

#### Scenario: Research shared by several steps has a place in the workstream

- **WHEN** a session reads the seeded file holding research, findings or a decision that shapes more than one step of a workstream
- **THEN** the file directs it to the workstream's `## Context` or `## Decisions` section, and does not direct it to a separate document or keep the workstream short

#### Scenario: A decision for one step stays in that step's design

- **WHEN** a session reads the seeded file holding a decision that shapes one step only
- **THEN** the file directs it to that step's design, which points to the workstream for what it shares rather than copying it

#### Scenario: What a workstream holds is not progress

- **WHEN** a session reads the seeded file to learn what Context and Decisions may say
- **THEN** the file states that they say what is known and decided about the goal, never how far the work has come, and that neither names a step as done, in flight or merged

#### Scenario: Overturned content is revised in place

- **WHEN** a session reads the seeded file in a change in a workstream that overturns something the workstream's Context or Decisions holds
- **THEN** the file directs revising it in place, naming that change, in the change's plan commit or at the latest at its archive
