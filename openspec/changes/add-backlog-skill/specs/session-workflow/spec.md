## ADDED Requirements

### Requirement: Archiving a change re-reads the backlog against it

The workflow fragment's **archive** step SHALL direct, before the record's pull request is opened, that `docs/backlog.md` is re-read for the entries the archived change completed, made obsolete, unblocked or made stale, and that each is updated as the file directs, in the commit that carries the record.

An entry is recorded against the state of the repository when it is written, and the change that falsifies it seldom names it: a change that finishes an entry's work, supersedes it, or delivers what it waits on usually does so without mentioning it. Without a step that re-reads the backlog at the moment a change lands, the backlog accumulates entries that are done, obsolete or silently unblocked, and every session picking work reads them as live.

The archive step is the point at which to re-read, because it is the one moment every change passes through after its effect is confirmed and before its branch is removed, and its commit is already a record-only commit on the trunk.

The fragment SHALL state which entries to look for and that they are updated in the archive commit. It SHALL NOT state how an entry is updated — which field changes, what the date records, when an entry is deleted. Those are entry rules, owned by `project-bootstrap` and stated in the file, and this capability defers to the file for them as its backlog requirement already provides.

The obligation SHALL be stated in the fragment itself. Where a skill offers a procedure for performing it, the fragment remains sufficient without that skill, per the rule that a separately published document is loaded only when something judges it relevant.

#### Scenario: An entry completed by an archived change is removed with its record

- **WHEN** a change is archived that finishes the work a backlog entry describes, without naming the entry
- **THEN** the archive step's re-read finds the entry, and the commit carrying the record also removes it as the file directs

#### Scenario: An entry waiting on the archived change is marked takeable

- **WHEN** a change is archived and a backlog entry names it in what it waits on
- **THEN** the entry is updated in the archive commit, so a session picking work afterwards reads it as no longer blocked

#### Scenario: The fragment defers the update's form to the file

- **WHEN** a session reads the archive step to learn how to update an entry it found
- **THEN** the fragment directs it to update the entry as `docs/backlog.md` directs, and names no entry field, date rule or deletion ground itself

#### Scenario: The obligation holds where the skill is absent

- **WHEN** a project carries the workflow fragment and no `backlog` skill is installed
- **THEN** the archive step still directs the re-read, and a session following the fragment alone performs it
