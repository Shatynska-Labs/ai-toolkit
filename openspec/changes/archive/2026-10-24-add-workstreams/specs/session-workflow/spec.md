## MODIFIED Requirements

### Requirement: A session reports where its change stands before acting

The workflow fragment SHALL require a session, on entering a working tree, to report the state of the change it finds there before taking any other action on the change: which change it is, what stage it has reached, how far through its task list it is, what has been committed, and whether its verification currently passes.

**It SHALL require the same report as the last thing said before the session stops.** Orientation and hand-off are one obligation seen from two ends; a session that reports on arrival and not on departure leaves the next one to reconstruct what it already knew.

**The report SHALL be a single row of fixed cells, in a fixed order, and SHALL NOT be a paragraph.** The cells are the workstream the change advances, by the source order stated below, or `none`; the change's name; its stage named from the vocabulary below, its task progress, and its committed state. The entering report SHALL carry one further cell, the verification result, because that is the half a session arriving does not know and a session leaving does.

The fixed row is required rather than recommended because the report's whole purpose is to be read by a session that was not present. Prose is re-interpreted at every hand-off; a row in a known shape is read at a glance, and a missing cell shows as a gap rather than passing as an omission nobody notices.

That report SHALL be derived from the repository where the repository holds the fact — the change's own artifacts, the commit log, the forge, and an actual run of the verification. Where a fact is in none of them, the fragment SHALL direct asking rather than assuming.

**The obligation SHALL NOT be stated as a prohibition on recalled conversation.** An earlier form did, and it was true only while a ledger recorded every gate. With that removed, an operator's confirmation of a merge or a deploy is in no artifact, so a session that may not recall and has nothing to read is left with no route at all. Asking is the route, and it is stated.

The fragment SHALL state how this composes with provisioning, because the two do not compose on their own. The stage and the committed state are readable from the repository immediately. A verification result is not: a working tree that has not been provisioned produces a run that skips and reports success, so an orientation report assembled before provisioning states that verification passes on exactly the evidence the provisioning requirement below says is worthless. The fragment SHALL therefore require, at the provisioning rule and not at the report, that verification be reported as *not run, and why* until provisioning is complete. Stating it in both places puts a sentence about provisioning inside the description of a table cell, where the reason cannot fit and the rule is already stated a page earlier.

Nothing here licenses skipping the report. Orientation still precedes the work; what it may not do is present an unprovisioned tree's green as a result.

**The workstream cell comes first** because an operator running several sessions reads the row to tell which line of work each belongs to, and a change's name alone does not say which goal it serves. The fragment SHALL state, beside the row, the source of that cell in order: the open workstream whose steps name the change; else the workstream its proposal names; else the workstream its backlog entry names; else `none`. The workstream file comes first because its steps are the authoritative side of membership; the proposal and the entry are how a change is attached before a step names it.

#### Scenario: A session resumes a working tree left by another session

- **WHEN** a session begins in a working tree holding a change it did not start
- **THEN** it reports the change's name, its stage, its task progress, its committed state and its verification result before continuing the work

#### Scenario: The report is a row, not a paragraph

- **WHEN** a session reports where its change stands
- **THEN** the report is a single row of fixed cells in the fixed order, so a session reading it later takes the stage from a known position rather than from a sentence

#### Scenario: A session reports on the way out as well as the way in

- **WHEN** a session stops
- **THEN** the last thing it says is that row, so the next session's arrival report has something to be checked against rather than reconstructed from nothing

#### Scenario: An unprovisioned working tree's green is not reported as a result

- **WHEN** a session enters a newly created working tree that has not been provisioned, and the project's verification would skip rather than fail
- **THEN** the orientation report gives the change's stage and committed state, and reports verification as not run and why, or reports the result of a run made after provisioning — never the skipped run's success

#### Scenario: The report is derived rather than recalled

- **WHEN** the session has earlier conversation describing the change's state
- **THEN** the report is still derived from the repository and a run of the verification, because the conversation records what was true when it was written and the repository records what is true now

#### Scenario: The row names the workstream first

- **WHEN** a session reports on a change whose proposal names a workstream, and no open workstream's steps name the change
- **THEN** the row's first cell is that workstream's name, and for a change advancing none it is `none`

#### Scenario: A change with no proposal takes its workstream from the plan

- **WHEN** a session reports on a change in `plan:explore` that an open workstream names among its steps
- **THEN** the row's first cell is that workstream, read from its file

## ADDED Requirements

### Requirement: A change states the workstream it advances, and archiving re-reads it

The workflow fragment SHALL direct, at **draft**, that a change's proposal names the workstream in `docs/workstreams/` that names the change among its steps or whose goal the change serves, and otherwise states that the change advances none. Where the change is one of several a goal needs and no workstream holds them, the fragment SHALL direct proposing that one be opened, and SHALL NOT direct opening one without the operator: which goals are worth tracking as one line of work is the operator's judgement about their work.

The fragment SHALL NOT state, where it routes an identified change to `docs/backlog.md`, which workstream the entry takes. That an entry recorded during a change in a workstream takes that workstream is an entry rule, owned by `project-bootstrap` and stated in the backlog file, and the fragment already directs recording as that file directs.

The fragment's **archive** step SHALL direct, where the change advanced a workstream, re-reading that workstream before the record's pull request is opened: placing the entries attached to it, revising the steps the change made obsolete, and archiving the workstream once what finishes it holds, as `docs/workstreams/README.md` directs, in the commit that carries the record.

A change is usually smaller than the goal it serves, and an operator running several sessions across several goals otherwise holds in their head which change belongs to which goal and what follows it. The proposal is where a change first states what it is for, so it is where the link is made; the archive is the one moment every change passes through after it lands, so it is where the goal's plan is brought up to date, as it already is for the backlog.

**The fragment SHALL name the directory as `docs/workstreams/`**, for the reason it names `docs/backlog.md`: a path stated only in a change's own artifacts is archived with them.

**This capability governs when a session is sent to a workstream, not the workstream rules.** How a workstream is named, shaped, opened, kept, and archived is owned by `project-bootstrap`, which seeds the README with those rules. The fragment SHALL defer to the README for them and SHALL NOT restate them, SHALL name no entry field, and SHALL NOT direct creating the README where it is absent. The status row's source order refers to the workstream a backlog entry names as one place the answer may be read; it names no field label and states no entry rule, so it is not naming an entry field, as the archive re-read's "entries that name the change" is not.

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

- **WHEN** a session in a change that advances a workstream records an identified change in `docs/backlog.md`
- **THEN** the fragment routes it to the file and states nothing about its workstream, and the file's entry shape is what gives the entry that workstream

#### Scenario: Archiving the last step archives the workstream

- **WHEN** a change is archived whose landing makes its workstream's Done when hold
- **THEN** the archive step's re-read archives the workstream as the README directs, in the commit that carries the record

#### Scenario: The fragment defers the workstream rules to the README

- **WHEN** a session reads the fragment to learn how a workstream is shaped or archived
- **THEN** the fragment directs it to `docs/workstreams/README.md`, and states no workstream field, file shape or archive path itself
