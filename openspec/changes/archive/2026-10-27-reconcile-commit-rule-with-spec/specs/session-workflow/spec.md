## MODIFIED Requirements

### Requirement: The session obligations are published in the workflow fragment and one binding fragment

The obligations this capability governs SHALL be published in the two places named below, and in no further place a session must read alongside them to act correctly:

- `rules/development-workflow.md` — the workflow fragment, which states every obligation service-neutrally alongside the spec-driven gates it already carries, and which `scripts/project-init` inlines into a consuming project's conventions file;
- `rules/development-workflow-database.md` — the binding fragment, which binds the workflow fragment's provisioning and namespace obligations to a containerized relational database.

The workflow fragment SHALL state a role and name its binding beneath it, as it already does for the agents and the working-tree location it binds to Claude Code. The binding fragment SHALL NOT restate an obligation the workflow fragment states; it names the service, the naming form and the operations that reach the stated end state.

**The fragment SHALL name its unit of work before stating any rule about it.** The unit is a change, and every rule below is a rule about a change's life; a document that never says so leaves a reader to infer it from the rules themselves.

**It SHALL state what falls outside that unit and what happens to it.** Work too small to be a change skips `plan` — there is nothing to specify — and does not skip `ship`, since nothing reaches production except by merging. Unstated, the reader has two readings and neither is written down: that trivial work carries the whole process, or that it escapes the delivery rules too.

The qualifier SHALL sit in the opening rather than inside a rule. It governs whether the document applies at all, and a scope condition met halfway through has already been read as unconditional by anyone who stopped earlier.

**The workflow fragment SHALL assume a remote, pull requests, continuous integration, and that merging to the trunk deploys, and SHALL state no conditional for their absence.** Pull requests imply the forge whose merged-state report the teardown gate reads; naming it separately in the assumptions states twice what the gate states once. Every project these rules are written for has all of them. A conditional for a shape no consumer has is paid for by every reader of every project that does have one, and it is the class of text that made the previous publication expensive.

A project of a shape these assumptions do not fit is served by a publication of its own rather than by a conditional here. A second publication is written when there is something to write it for; a conditional is carried forever whether or not anything needs it.

Where such a publication is written, **this capability owns it alongside the others**, and states each shared obligation once while naming which publications it binds — the arrangement it already holds for the workflow fragment and the binding fragment. Stated, because the argument against keeping two publications of one rule set is that both must be maintained, and that argument applies to this pair the moment it exists rather than being answered by the pair having been anticipated.

Neither fragment SHALL name a `rules/` path, a sibling fragment, or an import. In a consuming project the conventions file is a copy and no `rules/` directory is read, so a sentence naming a fragment file names something the reader cannot open.

Where a binding is itself a fragment rather than a tool name written inline, the workflow fragment SHALL refer to it by where the reader will find it — an adjacent section of the same conventions file, where the project carries one — and not by a path. The reference SHALL be conditioned on the project carrying that binding, since until the installing tool writes a second block the section exists only where someone pasted it, and an unconditional reference points at nothing in every project initialised in the interval. Otherwise the two clauses above cannot both be satisfied for the case this requirement exists to introduce, and a project holding the workflow fragment alone would carry a service-neutral obligation with no stated way to learn that a binding exists at all.

Neither fragment SHALL name an `ai-toolkit:` agent or skill that this library does not ship. A consuming project reaches the library's agents and skills only through the installed plugin, so a name with no `agents/<name>.md` or `skills/<name>/SKILL.md` behind it is a dispatch that finds nothing — the same dangling reference as a path the reader cannot open, met at the gate that needs it.

`project-bootstrap` owns how the workflow fragment reaches a project and what shape it takes there — the managed block, the version and its increment condition, that a role is named before a tool, that the gates form an ordered sequence with checkable preconditions, and that an automatic dispatch loop is bounded, what happens on reaching the bound, and which outcomes exit the loop rather than consume a round. `change-code-review` owns one sentence of the workflow fragment: the content of `build`'s Claude Code binding, what the session does on each of the reviewer's four verdicts. This capability owns what the rest of the session-derived rules say, and MAY fix the numeric value of a bound for a loop it states — `project-bootstrap` requires that a bound exist and fixes no number.

Where this capability states a loop, it SHALL state the value, what happens on reaching the bound, **and** the outcomes that exit it — all three of what `project-bootstrap` requires of every loop the rules state, since a loop introduced here would otherwise arrive carrying only the part this capability remembered. The seams are stated because all three capabilities bear on one file, and an unstated seam is resolved by whoever amends it first — an editor starting from this capability would otherwise not learn that the binding's content is governed elsewhere.

#### Scenario: A session obligation is stated once

- **WHEN** an obligation this capability governs is amended
- **THEN** it is amended in the workflow fragment, and the binding fragment changes only where the amendment touches the service, the naming form or the operations

#### Scenario: A reader of a project's conventions finds no dangling reference

- **WHEN** a session reads the workflow fragment's body as inlined in a project's conventions file
- **THEN** every reference resolves within that document, and no sentence names a file that exists only in this library

#### Scenario: A fragment names only agents and skills the library ships

- **WHEN** either fragment's body names an agent or skill as `ai-toolkit:<name>`
- **THEN** the library ships an agent or a skill of that name, and a name it does not ship is reported rather than passing unnoticed

#### Scenario: A project without a deploy is not served by a conditional

- **WHEN** a project that does not deploy on merge needs these rules
- **THEN** it is served by a publication of its own, and the workflow fragment states its assumptions plainly rather than branching on them

#### Scenario: A second publication does not arrive unowned

- **WHEN** a publication for another project shape is written
- **THEN** this capability owns it alongside the workflow fragment and the binding fragment, and states each shared obligation once naming which publications it binds

#### Scenario: An editor learns every owner of the fragment's content from this capability

- **WHEN** an editor reads this capability before amending the workflow fragment
- **THEN** it names `project-bootstrap` as owning how the fragment reaches a project and its shape, `change-code-review` as owning the content of `build`'s Claude Code binding, and this capability as owning what the rest of the rules say

### Requirement: A second change surfacing in a session is recorded in the backlog

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

**This capability governs routing work to the backlog, not the backlog's entry rules.** How an entry is named, referred to, ordered and deleted is owned by `project-bootstrap`, which seeds `docs/backlog/README.md` with those rules. The fragment SHALL state that the README carries them, and SHALL NOT restate them: stated in both places, they are two wordings that drift.

The seeded README is therefore not a further publication of this capability's obligations, and the rule that the fragment remain sufficient on its own does not reach it. That rule guards against a document loaded only when something judges it relevant; the entry rules sit in the README a session must open to record or cite an entry, so they are read at the moment they apply.

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
- **THEN** it refers to the entry by its file's name, the change's name — the only identifier the seeded README gives an entry, and the one that README directs referring to it by — so deleting or reordering other entries does not make the reference point elsewhere

#### Scenario: The scope rule and the backlog are one obligation

- **WHEN** a session records out-of-scope work as a backlog entry
- **THEN** it has satisfied the fragment's scope rule too, because the fragment states that such an entry is that rule's separate proposed change recorded rather than opened

#### Scenario: The backlog does not yet exist

- **WHEN** a project carrying these rules has no backlog at the named path
- **THEN** the fragment does not direct creating it: the README is `project-bootstrap`'s to create, and running the tool creates it with the entry rules the fragment defers to

#### Scenario: Entry rules are read from the backlog, not the fragment

- **WHEN** a session records an entry in `docs/backlog/`
- **THEN** the fragment has told it where the entry goes and why, and the README tells it how the entry is named, shaped and deleted, with no rule about entry numbers stated in either

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

## ADDED Requirements

### Requirement: Fragment prose is not hard-wrapped

The workflow fragment SHALL direct that Markdown prose is not hard-wrapped: each paragraph is kept on a single line whatever its length, and a line break is used only where Markdown's own structure requires one.

The reason is the diff. A paragraph wrapped at a column makes every later edit reflow the lines around it, so an edit and a reflow cannot be told apart in review, and a reviewer reading a diff of prose reads the reflow as change.

The direction SHALL be stated as an imperative, and SHALL NOT enumerate the structures it leaves alone beyond Markdown's own line structure: the fragment states it in those terms, and a requirement listing more would govern text the fragment does not carry.

#### Scenario: A session writing prose keeps a paragraph on one line

- **WHEN** a session following the fragment writes or edits a paragraph of Markdown prose
- **THEN** the paragraph stays on a single line, and the fragment has told it so

#### Scenario: Markdown structure still takes its own line breaks

- **WHEN** a session following the fragment writes a list, a heading, a table or a fenced block
- **THEN** it breaks lines where that structure requires, and the prose rule does not forbid it
