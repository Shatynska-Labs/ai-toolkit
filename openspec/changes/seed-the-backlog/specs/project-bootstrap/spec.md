## ADDED Requirements

### Requirement: A backlog is seeded where none exists

Where `docs/backlog.md` does not exist in the target, the tool SHALL create it, in both the new-project and the adoption mode, creating `docs/` if absent. Where the file exists, the tool SHALL leave it byte-for-byte unchanged and report it present.

The workflow fragment routes out-of-scope work to that path and defers to the file for how an entry is written. A file each project's first session invents carries a different header, entry shape and deletion rule in every project, so the rules the fragment defers to would not be the same rules anywhere.

The created file SHALL state, as prose a session reads before adding an entry:

- that it lists changes the project has identified and not yet archived, each recorded instead of being folded into the change that found it;
- that an entry's heading is the change's kebab-case name — the name its branch and change directory will take — and that an entry is referred to only by that name;
- that the order of entries carries no meaning, and that an entry states for itself what it waits on or should precede;
- that an entry is deleted when its change is archived, when the operator takes it as a fix rather than a change, or when the operator decides the change will not be made;
- that the file is kept when it has no entries;
- the shape of an entry: its heading, what the change is and why, written for a session that has not seen the work that found it, what recorded it and why it was not done there, and what it depends on.

**This requirement owns the backlog's entry rules**; `session-workflow` owns only routing work to the file, and its fragment defers to the file for these rules rather than restating them.

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

## MODIFIED Requirements

### Requirement: Each concern is checked independently and is safe to repeat

The tool SHALL evaluate each concern on its own — repository initialized, specification tooling initialized, ignore file present, backlog present, conventions file present, managed block present — completing what is absent and skipping what is satisfied.

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
