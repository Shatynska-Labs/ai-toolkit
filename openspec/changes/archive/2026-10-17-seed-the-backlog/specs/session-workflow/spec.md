## MODIFIED Requirements

### Requirement: A second change surfacing in a session is recorded in the backlog

The workflow fragment SHALL state that a session works on one change, and SHALL state what happens when a second change is identified while the first is in progress.

Where the change in progress depends on the identified change, the fragment SHALL require that the dependency and the wait it implies are recorded in the artifacts of the change in progress, before anything else is done about it. It MAY then permit opening the identified change on a branch of its own and nothing further, and recommending that the work continue in a separate session.

**An identified change SHALL be opened with a `handoff.md` and no proposal.** A proposal is the artifact the workflow reviews before anything is built. Written in passing by a session that will not do the work, it draws that review before it has earned it — and a review round spent on a proposal nobody has thought through is a round spent, not a round passed.

`handoff.md` SHALL carry what the originating session knows and the next will not: why the change was identified, what the originating work established that bears on it, and what it must not undo. The session that takes the change up writes its proposal.

`handoff.md` SHALL sit at the identified change's root, where the change's own artifacts sit.

The name SHALL NOT be reserved to this use. A change that already has a proposal MAY carry a `handoff.md` for something else — a survey handed from one session to another, say — so what marks an *identified* change is the handoff standing where a proposal is not, rather than the filename alone.

**The fragment SHALL direct proposing a commit on that branch as soon as it is opened**, and SHALL state what happens where that commit is declined: report that the handoff is unsaved and stop, as the plan-commit rule does, rather than continuing and leaving it to be lost. The session that opened it is by definition not returning to it, so no later commit will carry the handoff and an uncommitted one is lost with the session. It is proposed rather than made, per the fragment's commit rule.

The path SHALL be fixed here, at the identified change's root, for the reason `docs/backlog.md` and `.worktrees/` are fixed: a location stated only in a change's own artifacts is archived with them.

Where the change in progress does not depend on the identified change, the fragment SHALL require that it is either opened on a branch of its own, carrying the handoff the clauses above state, or recorded as an entry in the project's **backlog**.

Where such a branch is created by either path, the fragment SHALL state that it is created and left: it does not become the session's working branch and gets no working tree of its own here. The branch carries the identified change's handoff and no proposal, so it is not named for a proposal — the term this requirement's predecessor used, and the one this change replaces.

**The fragment SHALL name the backlog's path as `docs/backlog.md`.** A backlog entry names an identified change.

**This capability governs routing work to the backlog, not the backlog's entry rules.** How an entry is headed, referred to, ordered and deleted is owned by `project-bootstrap`, which seeds `docs/backlog.md` with those rules. The fragment SHALL state that the file carries them, and SHALL NOT restate them: stated in both places, they are two wordings that drift.

The seeded file is therefore not a further publication of this capability's obligations, and the rule that the fragment remain sufficient on its own does not reach it. That rule guards against a document loaded only when something judges it relevant; the entry rules sit in the file a session must open to record or cite an entry, so they are read at the moment they apply.

**The fragment SHALL NOT mention entry numbers.** An entry is named, not numbered, and its name is the only identifier a reference outside the file can carry. A rule explaining that a number is unstable presumes the number exists; stating it invites the numbering it warns against.

The fragment SHALL NOT direct creating the backlog where it is absent. `project-bootstrap` creates it; a project that took the rules without the tool owns that gap, and a clause repeated to every session for a one-time setup step is the kind of setup obligation this capability keeps out of the fragment.

The path is fixed here rather than left to the fragment's author for the reason `.worktrees/` is fixed above: a path stated only in a change's own artifacts is archived with them, and a requirement whose subject is then unnameable cannot be checked against the fragment afterwards.

The fragment SHALL reconcile the second route against its own scope rule, which obliges out-of-scope work noticed during a change to become a separate proposed change rather than being folded in. The reconciliation SHALL be stated against that obligation rather than against a quoted string, since both now live in one document that will be reworded. The seam is that a backlog entry *is* that separate proposed change, recorded rather than opened, and the obligation both rules share is that the work leaves the change in progress.

The fragment SHALL state that recording is the obligation and branching is the option. It SHALL give the reason the backlog exists outside the change: a deferral recorded only inside a change becomes unfindable when that change is archived, so it is the change succeeding, not the session ending, that loses it.

#### Scenario: A blocking dependency survives the session ending

- **WHEN** a session identifies that its change cannot complete until another change is merged, and the session then ends
- **THEN** the dependency and the wait are readable in the change's own artifacts, and the next session can distinguish a blocked change from a merely unfinished one

#### Scenario: An unrelated improvement is recorded rather than implemented

- **WHEN** a session identifies work outside its change's scope that nothing in the current change depends on
- **THEN** it is opened on a branch of its own carrying a handoff, or recorded as an entry in the backlog, and is not implemented in the session that found it

#### Scenario: A backlog entry is cited by name

- **WHEN** a session refers to a `docs/backlog.md` entry from anywhere outside that file — a waiver, a handoff, another entry
- **THEN** it refers to the entry by its heading, the change's name — the only identifier the seeded file gives an entry, and the one that file directs referring to it by — so deleting or reordering other entries does not make the reference point elsewhere

#### Scenario: The scope rule and the backlog are one obligation

- **WHEN** a session records out-of-scope work as a backlog entry
- **THEN** it has satisfied the fragment's scope rule too, because the fragment states that such an entry is that rule's separate proposed change recorded rather than opened

#### Scenario: The backlog does not yet exist

- **WHEN** a project carrying these rules has no file at the named path
- **THEN** the fragment does not direct creating it: the file is `project-bootstrap`'s to create, and running the tool creates it with the entry rules the fragment defers to

#### Scenario: Entry rules are read from the backlog, not the fragment

- **WHEN** a session records an entry in `docs/backlog.md`
- **THEN** the fragment has told it where the entry goes and why, and the file itself tells it how the entry is headed, shaped and deleted, with no rule about entry numbers stated in either

#### Scenario: An identified change is opened without a proposal

- **WHEN** a session opens a change it has identified but will not work on
- **THEN** the change carries a `handoff.md` naming why it was identified, what bears on it and what it must not undo, and no `proposal.md` — which the session that takes it up writes

#### Scenario: A handoff is not left uncommitted on a branch the session leaves

- **WHEN** a session opens an identified change on a branch of its own and then continues with its own change
- **THEN** it has proposed a commit on that branch already, because no later commit of its own will carry the handoff

#### Scenario: An opened-and-left branch does not become the session's working branch

- **WHEN** a session opens a branch for work it identified but will not do here
- **THEN** the branch is created and left, taking no working tree and not becoming the branch this session works on

#### Scenario: A deferral outlives the change that recorded it

- **WHEN** a change that recorded a deferral inside its own artifacts is archived
- **THEN** the fragment has already directed the deferral into the project's backlog, so archiving the change does not remove it from view
