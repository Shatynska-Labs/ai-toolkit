## MODIFIED Requirements

### Requirement: A change states the workstream it advances, and archiving re-reads it

*Modified by `match-backlog-entries-to-a-workstream`: the archive re-read names the entries it places by a set that can be checked, the entries naming the workstream that no step names, rather than the entries attached to it. Every scenario keeps its title; one is added.*

*Modified by `list-what-a-project-receives`: a directory's rules are the managed block in its `AGENTS.md`, and the fragment defers to that file rather than to a README. Every scenario keeps its title; a title naming the README reads it as that file.*

*Modified by `one-file-per-backlog-entry`: the backlog is the directory `docs/backlog/`, its entry rules stated in `docs/backlog/README.md`. Every scenario keeps its title.*

The workflow fragment SHALL direct, at **draft**, that a change's proposal names the workstream in `docs/workstreams/` that names the change among its steps or whose goal the change serves, and otherwise states that the change advances none. Where the change is one of several a goal needs and no workstream holds them, the fragment SHALL direct proposing that one be opened, and SHALL NOT direct opening one without the operator: which goals are worth tracking as one line of work is the operator's judgement about their work.

The fragment SHALL NOT state, where it routes an identified change to `docs/backlog/`, which workstream the entry takes. That an entry recorded during a change in a workstream takes that workstream is an entry rule, owned by `project-bootstrap` and stated in the backlog's `AGENTS.md`, and the fragment already directs recording as that file directs.

The fragment's **archive** step SHALL direct, where the change advanced a workstream, re-reading that workstream before the record's pull request is opened: placing the entries that name it and that no step names, revising the steps the change made obsolete, and archiving the workstream once what finishes it holds, as `docs/workstreams/AGENTS.md` directs, in the commit that carries the record.

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

#### Scenario: The archive re-read names the entries no step names

- **WHEN** a session reads the fragment's **archive** step for a change that advanced a workstream
- **THEN** it is directed to place the entries that name that workstream and that no step names, and the fragment names no entry field in saying so

## ADDED Requirements

### Requirement: Recording and sweeping the backlog are bound to a skill

The workflow fragment SHALL carry two Claude Code bindings naming `ai-toolkit:backlog`: one, under *A second change surfacing*, as what a session uses to record an entry, naming its **record** operation; and one, at the **archive** step, as what a session uses for the entries' part of the re-read, naming its **sweep** operation. Revising a workstream's obsolete steps and archiving it stay the session's. Both forms of the workflow SHALL carry them.

The bindings state which tool carries an obligation out and add no obligation: the rules the entry and the re-read follow stay in `docs/backlog/AGENTS.md` and `docs/workstreams/AGENTS.md`. A session that wrote its entries by hand never met the skill's steps, and nothing in the fragment sent it there.

#### Scenario: Both bindings name a shipped skill

- **WHEN** either workflow fragment is read at *A second change surfacing* and at **archive**
- **THEN** each carries a Claude Code binding naming `ai-toolkit:backlog`, the first its **record** and the second its **sweep**, and the library ships `skills/backlog/SKILL.md`

#### Scenario: A binding restates no entry rule

- **WHEN** a binding is read for how an entry is written
- **THEN** it names the skill and the operation, and names no entry field
