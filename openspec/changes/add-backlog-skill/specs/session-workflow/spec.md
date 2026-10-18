## MODIFIED Requirements

### Requirement: A rule states an action and a defect appears only as its reason

**A rule SHALL state what to do, and reasoning SHALL appear only where it changes what a reader does.** The fragment is inlined into a consuming project's conventions file and read by every session there, so its length is paid for on every read — brevity is the reason for the obligations below, not itself an obligation whose satisfaction anyone can test.

Three kinds of text SHALL NOT appear in the fragment, because each is written for this library rather than for the project holding the file: an argument against an alternative the fragment does not adopt, a statement about what other project shapes would need, and a justification for the fragment's own structure. Where such reasoning is worth keeping, it belongs in the change that decided it.

**Where this rule and a requirement obliging the fragment to state a particular reason conflict, the obliged reason wins.** A requirement that names a reason has decided that the reason changes what a reader does; brevity governs what is left. Unstated, the conflict is resolved by whoever edits last, which is how six mandated statements were dropped in a single compression pass.

Where such reasoning is additionally published so a session can seek it out — a skill, say — that publication SHALL carry reasoning only: an instruction, a gate, an exemption, or an edge case whose answer differs SHALL stay in the fragment, because a separately published document is loaded when something judges it relevant and there is no guarantee that happens at the moment it is needed. The fragment SHALL remain sufficient on its own. This binds any such publication when one is written; none exists today.

**A skill that performs an operation is not such a publication.** A skill MAY carry the procedure for carrying out an obligation the fragment states — how to search, what to compare, what to report — and procedures of its own for work no obligation requires, where they are operations a session invokes on demand. It SHALL NOT carry an obligation on a session that the fragment does not state, nor an edge case of a fragment obligation whose answer differs; each of those stays in the fragment, so that a session that never loads the skill still meets every obligation. `backlog-maintenance`'s `backlog` skill is one such skill.

The distinction is stated because the clause above reads, unscoped, as forbidding any skill that touches what the fragment governs — and an operation is exactly what a session wants to find by description at the moment it needs it, which is the case a publication of the fragment's reasoning is not.

Each session-derived rule in the workflow fragment, and each rule in the database binding fragment, SHALL be phrased as an action to take. A defect, incident, or current shortcoming MAY appear only as the reason a stated action matters, never as a standing entry of its own.

Each rule SHALL be phrased so that its durable half is the instruction and its perishable half is the consequence. A rule built around a defect goes stale when the defect is fixed and, until someone notices, contradicts the fix.

A rule SHALL NOT be omitted on the grounds that the defect motivating it is being fixed, where the instruction survives the fix. The instruction and the damage are separable, and only the damage expires.

#### Scenario: A rule outlives the defect that motivated it

- **WHEN** the defect a rule cites as its reason is subsequently fixed, or is enforced more strictly
- **THEN** the rule's instruction is unchanged and still correct, and only the consequence it names is out of date

#### Scenario: The fragment carries no argument written for the library

- **WHEN** a rule is written into the fragment
- **THEN** it states what to do and, where reasoning changes what a reader does, states it in as few words as carry it — and carries no argument against a rejected alternative, no account of what another project shape would need, and no justification for the fragment's own structure

#### Scenario: An incident does not become a standing entry

- **WHEN** an incident from a consuming project is used as evidence for a rule
- **THEN** it appears as the reason that rule's action matters, and no rule consists of the incident alone

#### Scenario: An operational skill carries procedure, not obligation

- **WHEN** a skill offers a procedure for an obligation the fragment states
- **THEN** the fragment states the obligation and every edge case whose answer differs, and a session that never loads the skill meets the obligation from the fragment alone

## ADDED Requirements

### Requirement: Archiving a change re-reads the backlog against it

The workflow fragment's **archive** step SHALL direct, before the record's pull request is opened, that `docs/backlog.md` is re-read for the entries the archived change completed, made obsolete, unblocked or made stale — **including entries that name the files or specifications the change touched, not only entries that name the change** — and that each is updated as the file directs, in the commit that carries the record.

The search by what the change touched SHALL be stated in the fragment, not left to a skill: it is the edge case whose answer differs from a search by name, and it is the one the motivating audit found most often.

An entry is recorded against the state of the repository when it is written, and the change that falsifies it seldom names it: a change that finishes an entry's work, supersedes it, or delivers what it waits on usually does so without mentioning it. Without a step that re-reads the backlog at the moment a change lands, the backlog accumulates entries that are done, obsolete or silently unblocked, and every session picking work reads them as live.

The archive step is the point at which to re-read, because it is the one moment every change passes through after its effect is confirmed and before its branch is removed, and its commit already carries only the record of the change and its consequences.

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
