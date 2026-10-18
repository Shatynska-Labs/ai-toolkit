## MODIFIED Requirements

### Requirement: A backlog is seeded where none exists

Where `docs/backlog.md` does not exist in the target, the tool SHALL create it, in both the new-project and the adoption mode, creating `docs/` if absent. Where the file exists, the tool SHALL leave it byte-for-byte unchanged and report it present.

The workflow fragment routes out-of-scope work to that path and defers to the file for how an entry is written. A file each project's first session invents carries a different header, entry shape and deletion rule in every project, so the rules the fragment defers to would not be the same rules anywhere.

The created file SHALL state, as prose a session reads before adding an entry:

- that it lists changes the project has identified and not yet archived, each recorded instead of being folded into the change that found it;
- that an entry's heading is the change's kebab-case name — the name its branch and change directory are expected to take, which the session that opens the change may revise if the work turns out different — and that an entry is referred to only by that name, a fix taking it as its branch's name only;
- that the order of entries carries no meaning, and that an entry states in its own fields what it waits on and which entries share a design with it;
- that an entry is kept short: what is needed and why, with files, specifications and changes named as pointers, and without line numbers, census tables or step-by-step plans;
- that an entry is deleted when its change is archived, when the operator takes it as a fix rather than a change, when a change makes it obsolete, or when the operator decides the change will not be made;
- that when a change is archived, the entries it unblocked or made stale are updated and their re-checked date set;
- that the file is kept when it has no entries;
- the shape of an entry: its heading; what the change is and why, written for a session that has not seen the work that found it; its **Kind**, `fix` or `change`, with the reason; what it **Waits on**, as `nothing` or as something that can be checked — a change by name, a person's answer, an event; which entries it is to be **designed with**, or nothing; what **recorded** it and why it was not done there; and the date it was last **re-checked** against the repository.

**Kind is `fix` only where the entry owes no specification delta, needs no decision from the operator, and is small enough to review in one sitting**; otherwise it is `change`. The size condition is the workflow's own: a fix is work too small to be a change, which skips `plan`, so an entry too large for one sitting is not one whatever it owes. The reason is stated because the label alone cannot be checked, and an entry's kind is the first thing a session picking work reads.

**Waits on replaces a list of changes that must land first.** An entry that should precede another says so from the waiting side: the later entry names it in Waits on. The earlier shape also let an entry state what it should precede; that direction is dropped, because a constraint stated on both sides is two statements that drift, and Waits on is the side the pick and the archive re-read read.

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
- **THEN** its entry shape names Kind, Waits on, Design with, Recorded by and Re-checked, and does not name Depends on

#### Scenario: A fix is distinguished from a change by what it owes

- **WHEN** a session reads the seeded file to record an entry that owes a specification delta
- **THEN** the file's definition of Kind leaves only `change` available to it, because `fix` is stated as owing no delta, needing no decision and fitting one review sitting
