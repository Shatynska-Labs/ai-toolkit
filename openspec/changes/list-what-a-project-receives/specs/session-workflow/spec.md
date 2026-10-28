## MODIFIED Requirements

### Requirement: A second change surfacing in a session is recorded in the backlog

*Modified by `list-what-a-project-receives`: a directory's rules are the managed block in its `AGENTS.md`, and the fragment defers to that file rather than to a README. Every scenario keeps its title; a title naming the README reads it as that file.*


*Modified by `one-file-per-backlog-entry`: the backlog is the directory `docs/backlog/`, its entry rules stated in `docs/backlog/README.md`. Modified by `reconcile-commit-rule-with-spec`: the handoff branch is committed, not proposed for a commit. Every scenario keeps its title.*

The workflow fragment SHALL state that a session works on one change, and SHALL state what happens when a second change is identified while the first is in progress and the fragment's scope rule does not fold it in. Work that rule folds in is not a second change, and nothing below reaches it.

Where the change in progress depends on the identified change, the fragment SHALL require that the dependency and the wait it implies are recorded in the artifacts of the change in progress, before anything else is done about it. It MAY then permit opening the identified change on a branch of its own and nothing further, and recommending that the work continue in a separate session.

**An identified change SHALL be opened with a `handoff.md` and no proposal.** A proposal is the artifact the workflow reviews before anything is built. Written in passing by a session that will not do the work, it draws that review before it has earned it — and a review round spent on a proposal nobody has thought through is a round spent, not a round passed.

`handoff.md` SHALL carry what the originating session knows and the next will not: why the change was identified, what the originating work established that bears on it, and what it must not undo. The session that takes the change up writes its proposal.

`handoff.md` SHALL sit at the identified change's root, where the change's own artifacts sit.

The name SHALL NOT be reserved to this use. A change that already has a proposal MAY carry a `handoff.md` for something else — a survey handed from one session to another, say — so what marks an *identified* change is the handoff standing where a proposal is not, rather than the filename alone.

**The fragment SHALL direct committing that branch as soon as it is opened.** The session that opened it is by definition not returning to it, so no later commit will carry the handoff and an uncommitted one is lost with the session. The commit is made, not proposed, so the fragment states no path for a declined one.

The path SHALL be fixed here, at the identified change's root, for the reason `docs/backlog/` and `.worktrees/` are fixed: a location stated only in a change's own artifacts is archived with them.

Where the change in progress does not depend on the identified change, the fragment SHALL require that it is recorded as an entry in the project's **backlog**, and MAY permit opening it on a branch of its own instead, carrying the handoff the clauses above state.

Where such a branch is created by either path, the fragment SHALL state that it is created and left: it does not become the session's working branch and gets no working tree of its own here. The branch carries the identified change's handoff and no proposal, so it is not named for a proposal — the term this requirement's predecessor used, and the one this change replaces.

**The fragment SHALL name the backlog's path as `docs/backlog/`.** A backlog entry names an identified change, one file per entry.

**This capability governs routing work to the backlog, not the backlog's entry rules.** How an entry is named, referred to, ordered and deleted is owned by `project-bootstrap`, which writes those rules as a managed block into `docs/backlog/AGENTS.md`. The fragment SHALL state that this file carries them, and SHALL NOT restate them: stated in both places, they are two wordings that drift.

The seeded block is therefore not a further publication of this capability's obligations, and the rule that the fragment remain sufficient on its own does not reach it. That rule guards against a document loaded only when something judges it relevant; the entry rules sit in the directory's `AGENTS.md`, which its `CLAUDE.md` loads once a session reads or writes a file in the directory to record or cite an entry, so they are read at the moment they apply.

**The fragment SHALL NOT mention entry numbers.** An entry is named, not numbered, and its name is the only identifier a reference outside the backlog can carry. A rule explaining that a number is unstable presumes the number exists; stating it invites the numbering it warns against.

The fragment SHALL NOT direct creating the backlog where it is absent. `project-bootstrap` creates it; a project that took the rules without the tool owns that gap, and a clause repeated to every session for a one-time setup step is the kind of setup obligation this capability keeps out of the fragment.

The path is fixed here rather than left to the fragment's author for the reason `.worktrees/` is fixed above: a path stated only in a change's own artifacts is archived with them, and a requirement whose subject is then unnameable cannot be checked against the fragment afterwards.

The fragment SHALL reconcile the second route against its own scope rule, which folds small adjacent work into the change and obliges the rest of the out-of-scope work noticed during a change to become a separate proposed change. The reconciliation SHALL be stated against that obligation rather than against a quoted string, since both now live in one document that will be reworded. The seam is that a backlog entry *is* that separate proposed change, recorded rather than opened, and the obligation both rules share is that work the scope rule does not fold in leaves the change in progress.

The fragment SHALL state that recording is the obligation and branching is the option, and SHALL state it where it routes an independent change, rather than offering the two there as equals. It SHALL give the reason the backlog exists outside the change: a deferral recorded only inside a change becomes unfindable when that change is archived, so it is the change succeeding, not the session ending, that loses it.

#### Scenario: A blocking dependency survives the session ending

- **WHEN** a session identifies that its change cannot complete until another change is merged, and the session then ends
- **THEN** the dependency and the wait are readable in the change's own artifacts, and the next session can distinguish a blocked change from a merely unfinished one

#### Scenario: An unrelated improvement is recorded rather than implemented

- **WHEN** a session identifies work outside its change's scope that nothing in the current change depends on, and the scope rule does not fold it in
- **THEN** it is recorded as an entry in the backlog, or opened instead on a branch of its own carrying a handoff, and is not implemented in the session that found it

#### Scenario: A backlog entry is cited by name

- **WHEN** a session refers to a `docs/backlog/` entry from anywhere outside that entry — a waiver, a handoff, another entry
- **THEN** it refers to the entry by its file's name, the change's name — the only identifier the seeded rules give an entry, and the one they direct referring to it by — so deleting or reordering other entries does not make the reference point elsewhere

#### Scenario: The scope rule and the backlog are one obligation

- **WHEN** a session records out-of-scope work as a backlog entry
- **THEN** it has satisfied the fragment's scope rule too, because the fragment states that such an entry is that rule's separate proposed change recorded rather than opened

#### Scenario: The backlog does not yet exist

- **WHEN** a project carrying these rules has no backlog at the named path
- **THEN** the fragment does not direct creating it: the rules file is `project-bootstrap`'s to write, and running the tool creates it with the entry rules the fragment defers to

#### Scenario: Entry rules are read from the backlog, not the fragment

- **WHEN** a session records an entry in `docs/backlog/`
- **THEN** the fragment has told it where the entry goes and why, and the directory's `AGENTS.md` tells it how the entry is named, shaped and deleted, with no rule about entry numbers stated in either

#### Scenario: An identified change is opened without a proposal

- **WHEN** a session opens a change it has identified but will not work on
- **THEN** the change carries a `handoff.md` naming why it was identified, what bears on it and what it must not undo, and no `proposal.md` — which the session that takes it up writes

#### Scenario: A handoff is not left uncommitted on a branch the session leaves

- **WHEN** a session opens an identified change on a branch of its own and then continues with its own change
- **THEN** it has committed that branch already, because no later commit of its own will carry the handoff

#### Scenario: An opened-and-left branch does not become the session's working branch

- **WHEN** a session opens a branch for work it identified but will not do here
- **THEN** the branch is created and left, taking no working tree and not becoming the branch this session works on

#### Scenario: A deferral outlives the change that recorded it

- **WHEN** a change that recorded a deferral inside its own artifacts is archived
- **THEN** the fragment has already directed the deferral into the project's backlog, so archiving the change does not remove it from view

#### Scenario: Recording is stated as what is owed

- **WHEN** a session reads the fragment's routing for an identified change the change in progress does not depend on
- **THEN** it reads recording in `docs/backlog/` as what is owed and opening the change as the option it may take instead, not the two as equals

### Requirement: Archiving a change re-reads the backlog against it

*Modified by `list-what-a-project-receives`: a directory's rules are the managed block in its `AGENTS.md`, and the fragment defers to that file rather than to a README. Every scenario keeps its title; a title naming the README reads it as that file.*


*Modified by `one-file-per-backlog-entry`: the backlog is the directory `docs/backlog/`, its entry rules stated in `docs/backlog/README.md`. Every scenario keeps its title.*

The workflow fragment's **archive** step SHALL direct, before the record's pull request is opened, that `docs/backlog/` is re-read for the entries the archived change completed, made obsolete, unblocked or made stale — **including entries that name the files or specifications the change touched, not only entries that name the change** — and that each is updated as the backlog's `AGENTS.md` directs, in the commit that carries the record.

The search by what the change touched SHALL be stated in the fragment, not left to a skill: it is the edge case whose answer differs from a search by name, and it is the one the motivating audit found most often.

An entry is recorded against the state of the repository when it is written, and the change that falsifies it seldom names it: a change that finishes an entry's work, supersedes it, or delivers what it waits on usually does so without mentioning it. Without a step that re-reads the backlog at the moment a change lands, the backlog accumulates entries that are done, obsolete or silently unblocked, and every session picking work reads them as live.

The archive step is the point at which to re-read, because it is the one moment every change passes through after its effect is confirmed and before its branch is removed, and its commit already carries only the record of the change and its consequences.

The fragment SHALL state which entries to look for and that they are updated in the archive commit. It SHALL NOT state how an entry is updated — which field changes, what the date records, when an entry is deleted. Those are entry rules, owned by `project-bootstrap` and stated in the backlog's `AGENTS.md`, and this capability defers to that file for them as its backlog requirement already provides.

The obligation SHALL be stated in the fragment itself. Where a skill offers a procedure for performing it, the fragment remains sufficient without that skill, per the rule that a separately published document is loaded only when something judges it relevant.

#### Scenario: An entry completed by an archived change is removed with its record

- **WHEN** a change is archived that finishes the work a backlog entry describes, without naming the entry
- **THEN** the archive step's re-read finds the entry, and the commit carrying the record also removes it as the backlog's `AGENTS.md` directs

#### Scenario: An entry waiting on the archived change is marked takeable

- **WHEN** a change is archived and a backlog entry names it in what it waits on
- **THEN** the entry is updated in the archive commit, so a session picking work afterwards reads it as no longer blocked

#### Scenario: The fragment defers the update's form to the file

- **WHEN** a session reads the archive step to learn how to update an entry it found
- **THEN** the fragment directs it to update the entry as `docs/backlog/AGENTS.md` directs, and names no entry field, date rule or deletion ground itself

#### Scenario: The obligation holds where the skill is absent

- **WHEN** a project carries the workflow fragment and no `backlog` skill is installed
- **THEN** the archive step still directs the re-read, and a session following the fragment alone performs it

### Requirement: A change states the workstream it advances, and archiving re-reads it

*Modified by `list-what-a-project-receives`: a directory's rules are the managed block in its `AGENTS.md`, and the fragment defers to that file rather than to a README. Every scenario keeps its title; a title naming the README reads it as that file.*


*Modified by `one-file-per-backlog-entry`: the backlog is the directory `docs/backlog/`, its entry rules stated in `docs/backlog/README.md`. Every scenario keeps its title.*

The workflow fragment SHALL direct, at **draft**, that a change's proposal names the workstream in `docs/workstreams/` that names the change among its steps or whose goal the change serves, and otherwise states that the change advances none. Where the change is one of several a goal needs and no workstream holds them, the fragment SHALL direct proposing that one be opened, and SHALL NOT direct opening one without the operator: which goals are worth tracking as one line of work is the operator's judgement about their work.

The fragment SHALL NOT state, where it routes an identified change to `docs/backlog/`, which workstream the entry takes. That an entry recorded during a change in a workstream takes that workstream is an entry rule, owned by `project-bootstrap` and stated in the backlog's `AGENTS.md`, and the fragment already directs recording as that file directs.

The fragment's **archive** step SHALL direct, where the change advanced a workstream, re-reading that workstream before the record's pull request is opened: placing the entries attached to it, revising the steps the change made obsolete, and archiving the workstream once what finishes it holds, as `docs/workstreams/AGENTS.md` directs, in the commit that carries the record.

A change is usually smaller than the goal it serves, and an operator running several sessions across several goals otherwise holds in their head which change belongs to which goal and what follows it. The proposal is where a change first states what it is for, so it is where the link is made; the archive is the one moment every change passes through after it lands, so it is where the goal's plan is brought up to date, as it already is for the backlog.

**The fragment SHALL name the directory as `docs/workstreams/`**, for the reason it names `docs/backlog/`: a path stated only in a change's own artifacts is archived with them.

**This capability governs when a session is sent to a workstream, not the workstream rules.** How a workstream is named, shaped, opened, kept, and archived is owned by `project-bootstrap`, which writes those rules as a managed block into `docs/workstreams/AGENTS.md`. The fragment SHALL defer to that file for them and SHALL NOT restate them, SHALL name no entry field, and SHALL NOT direct creating that file where it is absent. The status row's source order refers to the workstream a backlog entry names as one place the answer may be read; it names no field label and states no entry rule, so it is not naming an entry field, as the archive re-read's "entries that name the change" is not.

#### Scenario: A proposal in a workstream names it

- **WHEN** a session drafts a proposal for a change that a workstream names among its steps
- **THEN** the fragment has directed that the proposal names that workstream

#### Scenario: A proposal in no workstream says so

- **WHEN** a session drafts a proposal for a change that serves no workstream's goal
- **THEN** the fragment has directed that the proposal states the change advances none, so its absence is a statement rather than an omission

#### Scenario: A workstream is proposed, not opened

- **WHEN** a session sees that its change is one of several a goal needs and no workstream holds them
- **THEN** the fragment directs proposing a workstream to the operator, and does not direct opening one without them

#### Scenario: Derived work is attached by the backlog's rule, not the fragment's

- **WHEN** a session in a change that advances a workstream records an identified change in `docs/backlog/`
- **THEN** the fragment routes it to the backlog and states nothing about its workstream, and the backlog's `AGENTS.md` entry shape is what gives the entry that workstream

#### Scenario: Archiving the last step archives the workstream

- **WHEN** a change is archived whose landing makes its workstream's Done when hold
- **THEN** the archive step's re-read archives the workstream as `docs/workstreams/AGENTS.md` directs, in the commit that carries the record

#### Scenario: The fragment defers the workstream rules to the README

- **WHEN** a session reads the fragment to learn how a workstream is shaped or archived
- **THEN** the fragment directs it to `docs/workstreams/AGENTS.md`, and states no workstream field, file shape or archive path itself
