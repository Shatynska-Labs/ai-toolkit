## ADDED Requirements

### Requirement: A project receives exactly the blocks the manifest lists

The library SHALL carry a manifest at `rules/manifest` listing every managed block a shipped tool writes into a project. It SHALL hold one record per block, records separated by a line `---`, in the order the tool writes them, each with two keys: `name`, which is both the name in the block's markers and the fragment `rules/<name>.md` the block is read from; and `target`, the path of the `AGENTS.md` the block is written into, relative to the project root. It SHALL be written in the flat subset of YAML the backlog's entries use, so that a shell reads it with nothing installed.

The manifest SHALL list, as its first three records: `development-workflow` into `AGENTS.md`; `backlog` into `docs/backlog/AGENTS.md`; and `workstreams` into `docs/workstreams/AGENTS.md`. A later change may add a record after them.

`scripts/project-init` SHALL write the blocks the manifest lists, each into its target, and SHALL write no managed block the manifest does not list. A version SHALL NOT appear in the manifest: it is the fragment's own, in its frontmatter, beside the text it versions.

Where a target other than the project root's `AGENTS.md`, or the directory holding it, is a symbolic link or exists as something other than what the tool would write there, the tool SHALL write nothing for that record and report that the path is not one it writes into, the remaining records proceeding as usual. The root's `AGENTS.md` keeps the rules *Workflow rules reach a project as a versioned managed block* states for it, under which a link there is written through as before: the project chose that file, where a seeded directory is the toolkit's.

What the tool writes once and the project owns afterwards — the ignore file, the specification tooling, a directory's `CLAUDE.md` — is not a managed block and SHALL NOT be listed.

**The manifest is the one place that says what a project receives** (operator, 2026-10-28, `keep-projects-on-the-current-workflow`). Projects are synced by hand today because nothing states what they are synced to; a tool that updates them needs a list it can iterate, and a reader needs the same list. The record names a fragment rather than a path so that the two cannot disagree, and holds no version so that a body edit and its version are made in one file.

#### Scenario: The manifest lists the three blocks

- **WHEN** a reader opens `rules/manifest`
- **THEN** its first three records are `development-workflow`, `backlog` and `workstreams`, in that order, with targets `AGENTS.md`, `docs/backlog/AGENTS.md` and `docs/workstreams/AGENTS.md`, and no record carries a version

#### Scenario: Every listed fragment exists with a kind and a semantic version

- **WHEN** the manifest names a block
- **THEN** `rules/<name>.md` exists, and its frontmatter carries a `kind` and a `version` of the form `MAJOR.MINOR.PATCH`

#### Scenario: A new project receives exactly the listed blocks

- **WHEN** the tool runs in an empty directory
- **THEN** each target the manifest lists holds exactly one block, of the listed name, and no file in the project holds a block of a name the manifest does not list

#### Scenario: A record added to the manifest is written without a change to the tool

- **WHEN** a copy of the toolkit's manifest gains a record naming a fragment that copy holds, with a target under `docs/`
- **THEN** a run of that copy's tool in an empty directory writes that block into that target as well

#### Scenario: A link at a target is not written through

- **WHEN** the tool runs in a target whose `docs/workstreams/AGENTS.md` is a symbolic link
- **THEN** nothing is written at or through that path, the report states it is not a path the tool writes into, and the other blocks are written

### Requirement: A block's opening marker records its version and a hash of what was written

Every managed block SHALL be delimited by an opening line `<!-- ai-toolkit:<name> <version> sha256:<hash> -->` and a closing line `<!-- /ai-toolkit:<name> -->`, where `<name>` is the manifest's name for it, `<version>` is the fragment's `version` when the block was written, and `<hash>` is the SHA-256 digest, in 64 lowercase hexadecimal digits, of every byte between the opening line and the closing line, both excluded, each line with its newline. The first lines inside SHALL be the notice that the contents are generated and replaced on update, and that project-specific text belongs outside the markers; the fragment's body, without its frontmatter, SHALL follow.

The tool SHALL read a block's version from either form of opening line: this one, or the earlier `<!-- ai-toolkit:<name> v<N> -->`, which carries no hash.

**The hash lets a later tool tell an edited block from an older one with nothing but the block** (operator, 2026-10-28, `keep-projects-on-the-current-workflow`'s decision 4). Recomputed over the same lines, it equals the marker's where nobody edited inside the block, and differs where somebody did. A record file in the project would be one more file to keep true, and comparing with the text of the version stated would need the toolkit to carry every past text, which an installed copy does not.

#### Scenario: The marker's hash is the hash of what lies between the markers

- **WHEN** the tool writes any block
- **THEN** the SHA-256 digest of the lines strictly between its opening and closing lines equals the hash its opening line carries

#### Scenario: The marker's version is the fragment's

- **WHEN** the tool writes a block
- **THEN** the version its opening line carries is the `version` in that fragment's frontmatter, and the lines after the notice are the fragment's body, byte for byte

#### Scenario: An edit inside a block changes what its hash describes

- **WHEN** a line between a written block's markers is changed
- **THEN** the digest of the lines between the markers no longer equals the hash the opening line carries

#### Scenario: An earlier marker is read

- **WHEN** the tool runs where `AGENTS.md` holds `<!-- ai-toolkit:development-workflow v12 -->`
- **THEN** it reports the block present at version `v12`, beside the version it carries, and rewrites nothing

### Requirement: A directory's rules block is imported by a CLAUDE.md beside it

Where the tool writes a block into an `AGENTS.md` other than the project root's, or finds one there, it SHALL treat the `CLAUDE.md` in the same directory as follows:

- no path of any type at that name — the tool SHALL create it holding exactly the line `@AGENTS.md`;
- a file holding `@AGENTS.md` — the tool SHALL leave it unchanged and say nothing of it;
- anything else at that path — the tool SHALL leave it unchanged, and the report SHALL state the line to add to it for the rules to load.

Where the tool creates a directory's `CLAUDE.md`, the report SHALL say so on its own line, apart from the block's status, so that a run reporting a block already present still names the file it created.

The project root's `CLAUDE.md` keeps the rule *Workflow rules reach a project as a versioned managed block* states for it: the tool never creates or writes it.

**A directory's `AGENTS.md` does not load on its own where a project has a root `CLAUDE.md`.** Claude Code 2.1.312 reads `AGENTS.md` without an import only where no `CLAUDE.md`, `CLAUDE.local.md` or `.claude/CLAUDE.md` exists in the working directory or above it, and loads a subdirectory's `CLAUDE.md` once a session reads, writes or edits a file in that subdirectory; a `CLAUDE.md` holding `@AGENTS.md` loads it under every setting. Every adopting project has a root `CLAUDE.md`. **The tool creates the directory's file, unlike the root's**, because the directory is one the tool seeds and its `CLAUDE.md` is one fixed line of the tool's, where a project's root `CLAUDE.md` holds the project's own instructions.

#### Scenario: A seeded directory gets its import

- **WHEN** the tool writes the backlog block into a new `docs/backlog/AGENTS.md`
- **THEN** `docs/backlog/CLAUDE.md` exists holding exactly `@AGENTS.md`

#### Scenario: A directory CLAUDE.md of the project's own is not written

- **WHEN** `docs/workstreams/CLAUDE.md` exists holding other text and no `@AGENTS.md`
- **THEN** it is byte-for-byte unchanged, and the report states that `@AGENTS.md` must be added to it

#### Scenario: A CLAUDE.md created beside a present block is reported

- **WHEN** `docs/backlog/AGENTS.md` holds the backlog block and `docs/backlog/CLAUDE.md` is absent
- **THEN** the report states the backlog present, `CLAUDE.md` is created holding `@AGENTS.md`, and the report states on its own line that it was created

#### Scenario: The root CLAUDE.md is never created

- **WHEN** the tool runs in a directory with no `CLAUDE.md`
- **THEN** no `CLAUDE.md` is created at the project root, while `docs/backlog/CLAUDE.md` and `docs/workstreams/CLAUDE.md` are

### Requirement: A directory holding its rules in a README is reported, not converted

Where a directory the manifest targets, other than the project root, holds `README.md` and its `AGENTS.md` holds no block of the record's name, the tool SHALL write neither that `AGENTS.md` nor that directory's `CLAUDE.md`, SHALL leave the README byte-for-byte unchanged, and SHALL report that the directory holds its rules in the shape before `1.0.0` and that converting it is out of scope for this tool.

The project root is excluded because its `README.md` is the project's own documentation, not a copy of the toolkit's rules. Writing the block beside the README would leave the directory with two texts of its rules, one of them a session may still be sent to, and the tool cannot tell an untouched README from one the project edited. Converting one is the work of an update tool, which `keep-projects-on-the-current-workflow` plans as its next step.

#### Scenario: A backlog README is left alone

- **WHEN** the tool runs in a target whose `docs/backlog/` holds `README.md` and entry files and no `AGENTS.md`
- **THEN** no `AGENTS.md` or `CLAUDE.md` is created in it, every file in it is unchanged, and the report states that the backlog's rules are in the shape before `1.0.0`

#### Scenario: A root README does not hold back the workflow block

- **WHEN** the tool runs in a project whose root holds `README.md` and no `AGENTS.md`
- **THEN** the root `AGENTS.md` is created with the workflow block

#### Scenario: A workstreams README is left alone

- **WHEN** the tool runs in a target whose `docs/workstreams/` holds `README.md`
- **THEN** no `AGENTS.md` or `CLAUDE.md` is created in it, and the report states that the workstreams' rules are in the shape before `1.0.0`

### Requirement: The backlog's rules are written where none exist

*Replaces `A backlog is seeded where none exists`, removed by `list-what-a-project-receives`: the rules are a managed block in `docs/backlog/AGENTS.md`, read from the fragment `rules/backlog.md`, beside a `CLAUDE.md` importing it; a backlog holding them in a README is reported, not converted; a missing fragment blocks every run. The entry rules are carried over unchanged.*

Where neither `docs/backlog/` nor `docs/backlog.md` exists in the target, the tool SHALL write the backlog's rules as a managed block into `docs/backlog/AGENTS.md`, in both the new-project and the adoption mode, creating `docs/` and `docs/backlog/` if absent, and SHALL give the directory a `CLAUDE.md` as *A directory's rules block is imported by a `CLAUDE.md` beside it* states. Where `docs/backlog/AGENTS.md` holds a block of that name, the tool SHALL leave every file in the directory byte-for-byte unchanged and report the backlog present, with the versions *Workflow rules reach a project as a versioned managed block* requires of a block already present. Where `docs/backlog/` holds `README.md` and no such block, the tool SHALL act as *A directory holding its rules in a README is reported, not converted* states. Where `docs/backlog.md` exists and `docs/backlog/` does not, the tool SHALL leave the file byte-for-byte unchanged, create nothing under `docs/backlog/`, and report that the backlog is present in the single-file shape and that `scripts/backlog-migrate` converts it. Where `docs/backlog/` exists as a directory, not through a symbolic link, holding neither a block of that name nor a `README.md`, the tool SHALL write the block, appending it to an `AGENTS.md` the directory already holds and creating that file otherwise, leave every other file in the directory unchanged, and report the rules written beside existing entries. Where `docs/backlog` exists as a symbolic link or as anything other than a directory, the tool SHALL write nothing there and report that the path is not a directory it will write into, the remaining concerns proceeding as usual.

The tool SHALL read the block's text from its own copy of the library, from the fragment `rules/backlog.md`, which the manifest lists under the name `backlog` with `docs/backlog/AGENTS.md` as its target, and SHALL write the fragment's body without its frontmatter, as it does the workflow fragment's. A converted backlog receives the same block from the same tool, so a seeded backlog and a converted one carry the same rules. The fragment's absence blocks as any listed fragment's does.

The workflow fragment routes out-of-scope work to that directory and defers to its `AGENTS.md` for how an entry is written. Rules each project's first session invents carry a different entry shape and deletion rule in every project, so the rules the fragment defers to would not be the same rules anywhere.

The block SHALL state, as prose a session has loaded once it reads or writes a file in the directory:

- that the directory lists changes the project has identified and not yet archived, each recorded instead of being folded into the change that found it, one file per entry beside this file;
- that an entry's file is named for the change's kebab-case name, `<name>.md` — the name its branch and change directory are expected to take, which the session that opens the change may revise if the work turns out different — that the file's name is the entry's only identifier and the file carries no heading repeating it, that an entry is referred to only by that name, and that a fix takes it as its branch's name only;
- that `readme`, `agents` and `claude`, in any case, are not entry names, since their files would collide with `README.md`, `AGENTS.md` and `CLAUDE.md` where the filesystem ignores case;
- that entries carry no order, and that an entry states in its own fields what it waits on, how urgent it is, and which entries share a design with it;
- that an entry is kept short: what is needed and why, with files, specifications and changes named as pointers, and without line numbers, census tables or step-by-step plans;
- that an entry's file is deleted when its change is archived, when the operator takes it as a fix rather than a change, when a change makes it obsolete, or when the operator decides the change will not be made;
- that when a change is archived, the entries it unblocked, unparked or made stale are updated and their `re_checked` date set;
- that this file is kept when there are no entries;
- the shape of an entry's frontmatter, its keys in this order, one per line: `priority`, `high`, `normal` or `parked`; `parked_until`, present only on a parked entry, the condition that can be checked under which it becomes worth taking; `kind`, `fix` or `change`; `waits_on`, a list of the names of entries or changes that must be archived first; `waits_for`, present only where the entry waits on something that is not a name, the condition that can be checked — a person's answer, an access grant, an event; `design_with`, a list of the entries that share a design with this one; `workstream`, the workstream the entry is a step of or serves, by name, or `none`; `recorded_by`, the change that identified it by name, or a double-quoted text where no change did; and `re_checked`, the date it was last verified against the repository, as `YYYY-MM-DD`;
- the frontmatter's form: a name, a value from a stated set or a date is written bare; free text is double-quoted, with `"` and `\` escaped by a backslash; a list is written inline as `[a, b]`, and empty as `[]`; nothing is nested, and no value spans more than one line;
- the meaning of an absent key: an entry without `priority` is `normal`; without `waits_on` or `design_with`, the empty list; without `workstream`, `none`;
- the rules on `priority`: that `high` needs evidence of harm happening now — an incident, a measurement, an observation; that a parked entry is not folded into another change before its condition holds; that a parked entry whose condition holds becomes `normal`, or `high` with evidence; and that a `high` entry whose evidence no longer holds becomes `normal`;
- the rule on `workstream`: that an entry recorded by a change in a workstream takes that workstream unless it serves another goal;
- the shape of an entry's body: what the change is and why, written for a session that has not seen the work that found it, followed by one list giving the reasons the frontmatter's values need — **Kind**, why it is a fix or a change; **Priority**, on a `high` or parked entry only, the evidence or why it is parked; **Recorded by**, why it was not done there — and that further items a project's own rules add to that list are kept as written.

**Kind is `fix` only where the entry owes no specification delta, needs no decision from the operator, and is small enough to review in one sitting**; otherwise it is `change`. The size condition is the workflow's own: a fix is work too small to be a change, which skips `plan`, so an entry too large for one sitting is not one whatever it owes. The reason is stated because the label alone cannot be checked, and an entry's kind is the first thing a session picking work reads.

**Waits on replaces a list of changes that must land first, and holds only names.** An entry that should precede another says so from the waiting side: the later entry names it in `waits_on`. A constraint stated on both sides is two statements that drift, and the waiting side is the one the pick and the archive re-read read. **A wait on something that is not a name is `waits_for`, apart from the names**, because a name is an edge a reader can follow and resolve — archived or not — and a sentence is not: mixed into one field, every reader has to guess which words are names. An entry may wait on both.

**Priority is `high` only with evidence of harm happening now**, and **`parked` only with a condition that can be checked**, under which the entry becomes worth taking. Both are stated so that a later reading can tell whether they still hold, which a bare label cannot show. There is no `low`: an entry not worth taking with no condition under which it would be is one the operator has decided will not be made, which is already a deletion ground. Parked is not a wait: a waiting entry cannot be taken, a parked one can and is deliberately deferred, and an entry may be both. The condition has a key of its own, `parked_until`, because it is what a later reading checks; the reason it was parked is prose, in the body.

**Workstream is not Design with.** Design with groups entries that share a design, a property of the work; Workstream places an entry in a goal's sequence of changes, a property of the plan. Two entries may share either without the other, so neither field stands in for the other. The default is the recording change's workstream because work a change identifies usually serves the goal that change serves, and an entry recorded without it is detached from the plan it belongs to.

**One entry is one file, and its values are frontmatter.** A backlog shared by every session of a project is edited by several at once, and one file makes their edits conflict where one file per entry keeps them apart. A value a program reads — to build a board, to resolve a wait, to group a workstream — has to be found where it is without reading prose, and the free-text fields of the single file drifted in spelling across projects (`nothing`, `none`, `nothing.`) until no reader could rely on them. **The form is a flat subset of YAML** so that any YAML reader reads it and a shell tool reads it with no parser installed, which this library's tooling requires. **Reasons stay prose in the body**, because they are read by a person deciding, not by a program, and a long quoted value is harder to write and to read than a sentence.

**An absent key has a stated meaning, and the empty values are `[]` and `none`.** The file states them so that an entry written with fewer keys needs no edit, and so that one spelling of absence holds wherever the value is read. `none` is also the word the status row and a proposal use for a change in no workstream.

Entry brevity is stated because the details it excludes are the ones that go stale first, and the session that takes the entry up redoes them anyway. A census worth keeping belongs in the change's own artifacts once the change is opened.

**This requirement owns the backlog's entry rules**; `session-workflow` owns only routing work to the directory and when it is re-read, and its fragment defers to the directory's `AGENTS.md` for these rules rather than restating them. `backlog-maintenance` performs operations over the directory and likewise reads these rules from that file. `backlog-migration` converts a single-file backlog into this shape.

A path is present where it exists of any type, including a symbolic link whether or not it resolves. A link counted as absent would be written through, to wherever it points.

The tool SHALL create no entry, and the block SHALL NOT number entries or mention entry numbers. An entry carrying a number invites citing and ordering by it; a name is the identifier that survives other entries being deleted.

The file is kept when there are no entries because the tool created it: deleting it would leave the next session to recreate the rules from no text at all, which is the variance this requirement removes, and would leave a directory version control does not keep.

#### Scenario: A project without a backlog receives the seeded file

- **WHEN** the tool runs in a target with neither `docs/backlog/` nor `docs/backlog.md`
- **THEN** `docs/backlog/AGENTS.md` is created holding the block with every statement listed above, `docs/backlog/CLAUDE.md` is created holding `@AGENTS.md`, no entry file is created, and the report states the backlog was created

#### Scenario: An existing backlog is preserved exactly

- **WHEN** the target already contains `docs/backlog/AGENTS.md` holding a backlog block
- **THEN** it and every file beside it are left byte-for-byte unchanged and the report states the backlog is already present

#### Scenario: The seeded file carries no numbering

- **WHEN** the seeded block is written
- **THEN** no heading in it begins with a number and no sentence in it refers to an entry's number

#### Scenario: The seeded entry shape carries the structured fields

- **WHEN** the seeded block is written
- **THEN** its entry shape names the keys `priority`, `parked_until`, `kind`, `waits_on`, `waits_for`, `design_with`, `workstream`, `recorded_by` and `re_checked`, in that order, and does not name Depends on

#### Scenario: A fix is distinguished from a change by what it owes

- **WHEN** a session reads the seeded block to record an entry that owes a specification delta
- **THEN** the block's definition of `kind` leaves only `change` available to it, because `fix` is stated as owing no delta, needing no decision and fitting one review sitting

#### Scenario: Priority's values and default are stated

- **WHEN** the seeded block is written
- **THEN** its entry shape states `priority`'s three values `high`, `normal` and `parked`, that `high` needs evidence of harm happening now, that `parked` needs a condition in `parked_until` that can be checked, and that an entry without the key is `normal`

#### Scenario: The seeded file offers no low priority

- **WHEN** a session reads the seeded block to record an entry it judges not worth taking
- **THEN** the block offers no `low` value, so the entry is either parked with a condition or not recorded

#### Scenario: The seeded file states how an entry leaves parked and high

- **WHEN** a session reads the seeded block at the archive of a change that fulfilled a parked entry's condition, or removed a `high` entry's evidence
- **THEN** the block directs that entry to `normal`, or to `high` with evidence for the parked one, and names unparked entries among those the archive updates

#### Scenario: Workstream's default is stated

- **WHEN** the seeded block is written
- **THEN** its entry shape states that an entry recorded by a change in a workstream takes that workstream unless it serves another goal, and that an entry without the key is `none`

#### Scenario: The seeded entry's fields are a list

- **WHEN** the seeded block is written
- **THEN** its entry shape gives the values as frontmatter keys, one per line in the stated order, and the reasons as one Markdown list in the body, `- **Kind**: …`, `- **Priority**: …`, `- **Recorded by**: …`, with no blank line between them

#### Scenario: An absent value reads as its field

- **WHEN** the seeded block is written
- **THEN** its entry shape gives the empty `waits_on` and `design_with` as `[]` and the absent `workstream` as `none`, and states the meaning of each key's absence

#### Scenario: A single-file backlog is pointed to the migration tool

- **WHEN** the tool runs in a target with `docs/backlog.md` and no `docs/backlog/`
- **THEN** `docs/backlog.md` is unchanged, `docs/backlog/` is not created, and the report states the backlog is in the single-file shape and names `scripts/backlog-migrate`

#### Scenario: A missing backlog fragment blocks every run

- **WHEN** the tool runs where `rules/backlog.md` is absent from its copy, once in a target with no backlog and once in a target whose `docs/backlog/AGENTS.md` holds the block
- **THEN** both runs report `BLOCKED` and write nothing

#### Scenario: The rules are added beside existing entries

- **WHEN** the tool runs in a target whose `docs/backlog/` holds entry files and neither `AGENTS.md` nor `README.md`
- **THEN** `AGENTS.md` holding the block and `CLAUDE.md` holding `@AGENTS.md` are created, and every entry file is byte-for-byte unchanged

#### Scenario: Project text beside the block survives

- **WHEN** the tool runs in a target whose `docs/backlog/AGENTS.md` holds text of the project's own and no backlog block
- **THEN** the block is appended, and every line the file held before is unchanged

#### Scenario: A backlog path that is not a directory is not written through

- **WHEN** the tool runs in a target where `docs/backlog` is a symbolic link, or a regular file
- **THEN** nothing is written at or through that path, and the report states it is not a directory the tool writes into

#### Scenario: Waits on holds only names

- **WHEN** a session reads the seeded block to record an entry waiting on a person's answer and on a named change
- **THEN** the block directs the change's name into `waits_on` and the answer, as a double-quoted condition, into `waits_for`

#### Scenario: The frontmatter is flat

- **WHEN** the seeded block is written
- **THEN** its entry shape states that names, set values and dates are bare, free text is double-quoted with `"` and `\` escaped, lists are inline, nothing is nested, and no value spans lines

## MODIFIED Requirements

### Requirement: The running script locates its own resources

*Modified by `list-what-a-project-receives`: the script reads the manifest beside the fragments it lists, from the same copy. Every scenario keeps its title.*


Once running, the script SHALL derive its own directory from its invocation path and SHALL locate the manifest and the rule fragments it reads relative to that. It SHALL NOT consult `$AI_TOOLKIT_ROOT`, `$CLAUDE_PLUGIN_ROOT`, or any other environment variable to find them.

Resolution therefore happens exactly once, in the caller. A script that re-resolved could read fragments from a different copy than the one it was invoked from, making the version it stamps into a project's marker untrue of the text it inlined.

#### Scenario: Fragments come from the copy the script belongs to

- **WHEN** the script runs from an installed copy while an environment variable names a different toolkit root
- **THEN** it reads the fragments belonging to the copy it was invoked from, and the version it stamps describes the text it actually inlined

#### Scenario: Explicit root reaches the working tree through the caller

- **WHEN** `$AI_TOOLKIT_ROOT` names a working tree while an older version is also installed as a plugin
- **THEN** the caller resolves to the working tree and invokes the script there, so a toolkit developer exercises the fragments they are editing rather than a pinned installed copy

### Requirement: Every run ends in one of three outcomes, and the exit code agrees

*Modified by `list-what-a-project-receives`: the manifest and every fragment it lists are read before anything else, and a missing or invalid one, or a missing hash command where a block is outstanding, blocks. The scenario *Missing fragment blocks rather than degrades* covers any fragment the manifest lists, and *A missing manifest blocks* is added.*


Each run SHALL terminate in exactly one of:

- `SUCCESS` — every applicable concern was completed or was already satisfied. Exit code SHALL be zero.
- `BLOCKED` — a precondition was unmet and no filesystem change was attempted. Exit code SHALL be non-zero.
- `ERROR` — a step was attempted and failed. Exit code SHALL be non-zero and distinct from the code used for `BLOCKED`.

The outcome SHALL be stated in the report, and the exit code SHALL never contradict it. A run that reports `BLOCKED` and exits zero is a defect, because shell and CI callers act on the exit code rather than the text.

Unmet preconditions that SHALL produce `BLOCKED` include: the manifest absent from the script's own copy; a fragment it lists absent, or lacking a `kind`, or a `version` that is not `MAJOR.MINOR.PATCH`; a required external command (`git`, or the specification tooling the script drives) unavailable; and, where a block is outstanding, neither `sha256sum` nor `shasum` available to hash it.

**The manifest and every fragment it lists are read unconditionally, before anything else, and the absence of any of them always blocks.** They are not scoped to whether a block's concern is outstanding, because the report requirement below (*Workflow rules reach a project as a versioned managed block*) obliges the tool to state its own carried version even when a managed block already exists and nothing will be written — a case where the concern is satisfied but the fragment must still be read to produce that report. A copy missing one fragment the manifest lists is, besides, not a copy the tool can vouch for. Treating the fragments as scoped like a command precondition would leave that report field unproducible in exactly the case it exists to cover.

**External-command preconditions SHALL be computed from the concerns that are actually outstanding, and SHALL be validated in full before any write.** Determining which concerns are outstanding is a set of filesystem reads, not attempts, so it precedes validation without violating the no-change guarantee.

Scoping commands this way is required, not merely economical: validating every command precondition unconditionally would make the tool report `BLOCKED` when a command is missing for a concern that is already satisfied — refusing to run because some concerns are complete, which a separate requirement forbids. Validating lazily instead, at each concern's point of use, would report `BLOCKED` after earlier concerns had already written, making the outcome's own definition false. Only the scoped-then-eager order satisfies both, and it is why the manifest and its fragments — read once, up front, for reasons unrelated to any single concern's completion — are carved out of it rather than folded in. The hash command is a command precondition like any other, scoped to a block being outstanding.

Root resolution is not among the preconditions. A script that is running was found, so an unresolvable root is a condition its caller reports before invoking anything.

#### Scenario: A machine consumer can branch on the result

- **WHEN** a CI job runs the tool and checks its exit status
- **THEN** a zero status means initialization succeeded, and any non-zero status means it did not, without the caller parsing report text

#### Scenario: A command missing for an already-satisfied concern does not block

- **WHEN** the tool runs where specification tooling is already present but the command that would initialize it is unavailable
- **THEN** that command is not among the preconditions validated, the run proceeds with the remaining concerns, and the satisfied concern is reported as already present

#### Scenario: The fragment is read even when nothing will be written

- **WHEN** the tool runs where a managed block is already present and the fragment is absent from the script's own copy
- **THEN** the tool reports `BLOCKED`, because the version it would need to report as "the version the tool carries" cannot be produced without reading the fragment, regardless of the conventions-file concern being satisfied

#### Scenario: Missing fragment blocks rather than degrades

- **WHEN** the toolkit root resolves but a fragment the manifest lists, the workflow fragment or the backlog's, is absent from it, whether or not that fragment's block is already present in the target
- **THEN** the tool reports `BLOCKED`, exits non-zero and writes nothing, rather than writing some blocks without the others

#### Scenario: A missing manifest blocks

- **WHEN** the toolkit root resolves but `rules/manifest` is absent from it
- **THEN** the tool reports `BLOCKED`, names the manifest, exits non-zero and writes nothing

### Requirement: Files the project already owns are never overwritten

*Modified by `list-what-a-project-receives`: the one exception covers each `AGENTS.md` the manifest names, not only the root's. Every scenario keeps its title.*


The tool SHALL create what is absent and report what is present. It SHALL NOT itself modify, merge into, extend, or truncate a file it did not create, with exactly one exception: appending a managed block to an `AGENTS.md` the manifest names as its target.

A script cannot distinguish a deliberate project decision from an oversight, so editing a file it did not write risks discarding an intentional choice with no way to detect it.

**The guarantee is bounded to the tool's own writes.** The tool delegates specification-tooling initialization to an external command, whose writes it does not control and SHALL NOT claim to prevent. What that command creates or modifies SHALL be established before implementation and recorded, and the report SHALL attribute those changes to it rather than presenting the run as having touched only the files the tool wrote itself.

An unbounded guarantee would be false on the adoption path — the path this tool exists to serve — precisely where a project has files worth protecting.

#### Scenario: A delegated command's writes are attributed, not concealed

- **WHEN** the tool initializes specification tooling in a project that already has files, and that command writes files of its own
- **THEN** the report attributes those changes to the delegated command, and the tool's own never-overwrite guarantee is stated as covering the files it writes itself

#### Scenario: An existing ignore file is preserved exactly

- **WHEN** the target directory already contains an ignore file
- **THEN** its contents are left byte-for-byte unchanged, its presence is reported, and no entry is appended or merged

#### Scenario: An existing conventions file receives only the managed block

- **WHEN** the target directory already contains a conventions file with project content
- **THEN** the managed block is added and every line outside the block is left unchanged

### Requirement: Workflow rules reach a project as a versioned managed block

*Modified by `list-what-a-project-receives`: the delimiters carry a semantic version and the hash of what was written, as *A block's opening marker records its version and a hash of what was written* states for every block, and the notice places project rules outside the markers. Every scenario keeps its title.*


The project's conventions file SHALL be `AGENTS.md` at the project root. It is named here rather than left to the implementer because it is the file every targeted harness reads, and because a project may hold more than one candidate.

The tool SHALL apply the following, in order:

- `AGENTS.md` exists — the block is appended to it.
- `AGENTS.md` is absent and `CLAUDE.md` exists — `AGENTS.md` is created with the block, and `CLAUDE.md` is left untouched. The tool SHALL NOT write into `CLAUDE.md`, whose contents are the project's own and may be a single import of another file.
- Neither exists — `AGENTS.md` is created with the block.

**Writing the file is not the same as the rules taking effect, and the tool SHALL NOT conflate them.** Whether a harness loads `AGENTS.md` without an explicit import SHALL be established by observation and recorded, and established again when the harness changes it. For Claude Code it was observed on 2026-08-17 that it did not. On 2026-10-18, at version 2.1.302, it was observed to read `AGENTS.md` without an import only where no project instructions file is found for the target — no `CLAUDE.md`, `CLAUDE.local.md` or `.claude/CLAUDE.md` in the target or in any directory above it, up to the filesystem root, the user's own `~/.claude/CLAUDE.md` excepted. Any such file switched the fallback off, whether in the target, in an enclosing repository, or in a directory above that is no repository; with `@AGENTS.md` added to the target's `CLAUDE.md`, the rules loaded where the shadowing file was an enclosing directory's `CLAUDE.md` or the target's `.claude/CLAUDE.md`, the arrangements in which that was observed. Its changelog records the fallback as added in 2.1.277 and extended in 2.1.281 to Amazon Bedrock, Google Vertex AI, Microsoft Foundry, LLM gateways and sessions with telemetry disabled.

A **shadowing file** is any of `CLAUDE.md`, `CLAUDE.local.md` or `.claude/CLAUDE.md`, in the target or in any directory above it, other than `.claude/CLAUDE.md` in the user's home directory.

Where the target's `CLAUDE.md` contains the `@AGENTS.md` import, the report SHALL state nothing about the import. Otherwise, where a shadowing file exists, the report SHALL state the one line the user must add for the rules to load, naming the target's own `CLAUDE.md` as where it goes and that the file may need creating — a `CLAUDE.md` above the target would import that directory's `AGENTS.md`, not this one's — and SHALL still write nothing into any such file. This holds whichever of the ordered branches above produced `AGENTS.md`.

Where no shadowing file exists, the report SHALL NOT state that the import is needed for the rules to take effect: on a current Claude Code they take effect without it, and an instruction to do what is not needed is an untrue report. The report SHALL instead carry a note, phrased as a condition rather than an instruction and not beginning `Import needed:`, naming the version from which Claude Code reads `AGENTS.md` without a `CLAUDE.md`, the later version for the providers and sessions it reached afterwards, and that its "Project instructions" setting can turn the fallback off. A session on an older version, or with the setting changed, is then not left with inert rules unannounced.

Reporting `SUCCESS` and stamping a version while the rules are inert would be the silent divergence this workflow exists to prevent, and it would be worse than an obvious failure: the marker's whole purpose is to answer "is this workflow adopted here", and it would answer yes.

The tool SHALL write the workflow rule fragment into that file between delimiters that name the fragment and the version inlined, in the form *A block's opening marker records its version and a hash of what was written* states, and SHALL include a notice inside the block stating that its contents are generated and that project-specific rules belong outside it.

Where a managed block for the same fragment is already present, whether its marker is in that form or the earlier `v<N>` one, the concern is satisfied and the block SHALL NOT be rewritten. The report SHALL then state both the version recorded in the existing block and the version the tool carries, and SHALL state that reconciling a difference is out of scope for this tool. Reporting a version as "inlined" when nothing was inlined would make the report untrue in the one case where version skew is visible.

Content between the delimiters SHALL be defined as generated and replaceable. Content outside them SHALL belong to the project and SHALL never be modified by this tool or any future update to it.

The delimiters SHALL be greppable and SHALL carry the version, so that a later update can locate and replace the block without parsing hand-written text, and so that a project's adopted workflow version is readable without comparing file contents.

#### Scenario: A project's adopted version is readable

- **WHEN** a reader needs to know whether a project uses this workflow and at which version
- **THEN** the delimiters in the conventions file state both, without any separate state file being consulted

#### Scenario: Project content below the block survives

- **WHEN** a project has added its own conventions beneath the managed block and the tool runs again
- **THEN** those conventions are unchanged

#### Scenario: A project with only a CLAUDE.md

- **WHEN** the tool runs where `CLAUDE.md` exists and `AGENTS.md` does not
- **THEN** `AGENTS.md` is created carrying the managed block, and `CLAUDE.md` is not read into, written to, or modified

#### Scenario: Rules written but not yet loadable are reported as such

- **WHEN** the tool writes the managed block into `AGENTS.md` where the target's `CLAUDE.md` exists and does not import `AGENTS.md`
- **THEN** the report states the import line the user must add for the rules to take effect, and does not present the rules as being in force merely because the file was written

#### Scenario: A shadowing file above the target is reported like one in it

- **WHEN** the tool writes the managed block into `AGENTS.md` in a target with no `CLAUDE.md` of its own, inside a directory that holds a `CLAUDE.md` without the import
- **THEN** the report states the import line the user must add to the target's `CLAUDE.md`, not the version note

#### Scenario: The user's own instructions file does not shadow

- **WHEN** the only shadowing candidate is `.claude/CLAUDE.md` in the user's home directory
- **THEN** the report carries the version note, not the import line

#### Scenario: No CLAUDE.md yields a version note, not an instruction

- **WHEN** the tool writes the managed block into `AGENTS.md` where no shadowing file exists
- **THEN** the report does not state that an import is needed for the rules to take effect, and states the Claude Code versions from which `AGENTS.md` is read without one

#### Scenario: An existing block at a different version is reported, not rewritten

- **WHEN** the tool runs where a managed block for the same fragment already exists at an earlier version
- **THEN** the block is left unchanged, and the report states both versions and that reconciling them is out of scope

### Requirement: The fragment's version increments when its body changes

*Modified by `list-what-a-project-receives`: the version is `MAJOR.MINOR.PATCH`, the part raised says what a project must do, and every fragment carrying a version starts at `1.0.0`. The scenarios keep their titles; *Which part rises is decided by what the project must do* and *A legacy version reads as older* are added.*


A rule fragment's `version` SHALL be a semantic version, `MAJOR.MINOR.PATCH`, and SHALL rise whenever the body text inlined into a project changes. This holds for every fragment the manifest lists and for any fragment carrying a version. It SHALL NOT rise for a change confined to the fragment's own frontmatter, and it SHALL NOT remain unchanged across a body edit.

The part that rises SHALL be decided by what the edit asks of a project: **PATCH** where the wording changes and no obligation does; **MINOR** where an obligation is added or changed and the project need do nothing by hand to meet it; **MAJOR** where the project must do something by hand — move a file, rewrite an entry, adopt a text outside the block. A major version always asks something by hand and a minor or patch never does, so a later tool can decide from the versions alone whether to list steps for the operator. Raising one part resets the parts after it to zero.

Every fragment carrying a version, and the plugin's own version, SHALL be at least `1.0.0`; all of them started at `1.0.0` in the release that introduced the manifest. A marker in the earlier form, `v<N>`, SHALL be read as older than `1.0.0`, so that every block written before that release is stale against it.

The operator chose semantic versions for this (2026-10-28, `keep-projects-on-the-current-workflow`'s decision 2): a bare counter says that something changed, and an update tool needs to know whether to replace silently, replace and say what changed, or stop for steps done by hand.

The version is what a project's managed block records, and the only thing distinguishing an adopted copy from a current one. A body edit that leaves the version alone makes every project carrying the old text indistinguishable from one carrying the new, which defeats the marker's stated purpose of answering which version a project adopted.

This requirement owns when the version increments. `toolkit-structure` fixes the frontmatter's form and states that the version is unrelated to any package or plugin version; it defers the increment condition here by name, so that an author checking a fragment edit reaches one answer rather than two.

#### Scenario: An edited fragment is distinguishable from the copy already adopted

- **WHEN** the fragment's body is edited and a project already carries a managed block of the previous text
- **THEN** the version the tool carries differs from the version recorded in that project's block, and the skew is therefore reportable

#### Scenario: A frontmatter-only edit does not consume a version

- **WHEN** the fragment's frontmatter changes while the body inlined into a project does not
- **THEN** the version is unchanged, because no project's inlined text differs from any other's

#### Scenario: Which part rises is decided by what the project must do

- **WHEN** a fragment at `1.2.3` gains an obligation that a project meets with no edit of its own
- **THEN** its version becomes `1.3.0`, and an edit that further asks the project to move a file would have made it `2.0.0`

#### Scenario: A legacy version reads as older

- **WHEN** a project's block carries the marker `v12` and the tool carries `1.0.0`
- **THEN** the project's block is the older of the two

### Requirement: A workstream register is seeded where none exists

*Modified by `list-what-a-project-receives`: the rules are a managed block in `docs/workstreams/AGENTS.md`, read from the fragment `rules/workstreams.md`, beside a `CLAUDE.md` importing it, and a register holding them in a README is reported, not converted. Every scenario keeps its title.*


*Modified by `one-file-per-backlog-entry`: a step is recorded where `docs/backlog/` holds an entry of its name, and a step's ordering wait is its entry's `waits_on`.*

*Modified by `observe-what-finishes-a-workstream`: a workstream's Done when names an observable effect of its Goal, and every step being archived may stand beside it but never in its place.*

*Modified by `hold-shared-research-in-a-workstream`: a workstream holds, besides its plan, the context and decisions its steps share, which are never progress and are revised in place when overturned.*

Where `docs/workstreams/` holds neither a block of that name in `AGENTS.md` nor a `README.md`, the tool SHALL write the workstreams' rules as a managed block into `docs/workstreams/AGENTS.md`, in both the new-project and the adoption mode, creating `docs/workstreams/` if absent, appending the block to an `AGENTS.md` the directory already holds and creating that file otherwise, and SHALL give the directory a `CLAUDE.md` as *A directory's rules block is imported by a `CLAUDE.md` beside it* states. Where the block is present, the tool SHALL leave every file in the directory byte-for-byte unchanged and report the register present, with the versions *Workflow rules reach a project as a versioned managed block* requires of a block already present. Where the directory holds `README.md` and no such block, the tool SHALL act as *A directory holding its rules in a README is reported, not converted* states. The tool SHALL NOT create `docs/workstreams/archive/`.

The tool SHALL read the block's text from the fragment `rules/workstreams.md`, which the manifest lists under the name `workstreams` with `docs/workstreams/AGENTS.md` as its target, and SHALL write the fragment's body without its frontmatter.

A workstream is a goal that takes more than one change. The workflow fragment sends a session to this directory at a change's proposal and at its archive, and defers to the directory's `AGENTS.md` for how a workstream is written, as it defers to the backlog's for an entry. Unseeded, each project's first session would invent those rules, and the fragment's references would mean something different in every project.

The block SHALL state, as prose a session has loaded once it reads or writes a file in the directory, before opening, editing or archiving a workstream:

- that a workstream is a goal that takes more than one change, each open one a file in this directory named `<name>.md` for its kebab-case name, unique among workstreams open and archived and not also a change's name, and referred to only by that name;
- that `readme`, `agents` and `claude`, in any case, are not workstream names, for the same collision;
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
- that this file is kept when there is no workstream;
- the shape of a workstream: its heading, the name; its **Goal**; its **Done when**, an observable effect of the Goal that can be checked against the repository, the forge or production, with every step being archived beside it where that is wanted; its **Steps**, an ordered list each naming a change in kebab-case with what it does; what is **Not in scope**, or `none`; its **Open questions**, each deleted once answered with the answer recorded under Decisions, or `none`; and when and by what it was **Opened** — Goal and Done when as paragraphs, and the fields after the steps as one list, one item per field, with no blank line between them; then an optional `## Context` section and an optional `## Decisions` section, in that order, each omitted where it would be empty.

**The file holds no status because status written by hand goes stale.** Progress happens in every session, and a status field is edited by none of them at the moment it changes; a status read from the repository by name is current whenever it is read. That is why a step is named by the change it is expected to be: the name is the key the lookups use. **The precedence and the trunk are stated because the sources overlap**: a backlog entry survives until its change is archived, and a branch until the record's pull request merges, so a step matches more than one source in the ordinary course of its life; and a session's own working tree may predate a step's archive, so reading it would give each session a different answer.

**Done when names an effect of the Goal because the steps are the plan's guess at reaching it.** "Every step is archived" is checked against the repository, so it meets the old wording, yet it holds for a step list that missed a step as surely as for one that did not: it confirms the plan was carried out, not that the Goal was reached. A change's `confirm` already asks for its effect to be observed rather than inferred from a merge; a workstream's Done when asks the same of its Goal. Archiving every step stays available beside the effect, for a workstream whose steps are each wanted whatever the effect shows.

**A workstream holds what its steps share because nowhere else ties it to the goal.** A change's design belongs to one step and is archived with it, so research shared by several steps is copied into each or leaves with the first to finish; a separate document under `docs/` is tied to no goal and retired by nothing. The workstream file is the one place every step points to, and it is archived whole. The two reasons the file was once kept short still hold, and are answered rather than dropped. Status written by hand goes stale because progress happens in every session; what Context and Decisions hold changes only when understanding of the goal changes, and never records progress. Edits were kept rare so parallel sessions seldom meet in one file; they stay tied to events — research done, a decision taken or overturned — not to sessions. **Overturned content is revised in place** (operator, 2026-10-27) because a record a reader must reconcile entry by entry is the stale table in another form; the file's history keeps what was held before.

**Order gates nothing because precedence already has one authority.** `waits_on` is the side the pick and the archive re-read read, and the backlog dropped a second side because two statements of one constraint drift; a step's "comes after" in the workstream file would reintroduce it.

**A finished or abandoned workstream is archived, not deleted** (operator, 2026-10-24), so its plan, context and decisions stay readable after its goal is met, as an archived change's record does.

**This requirement owns the workstream rules**; `session-workflow` owns only when the fragment sends a session to the directory, and its fragment defers to the directory's `AGENTS.md` rather than restating them. `backlog-maintenance` reads them from that file.

The tool SHALL create no workstream.

#### Scenario: A project without a workstream register receives the seeded file

- **WHEN** the tool runs in a target with no `docs/workstreams/`
- **THEN** `docs/workstreams/AGENTS.md` is created holding the block with every statement listed above and no workstream, `docs/workstreams/CLAUDE.md` is created holding `@AGENTS.md`, no `archive/` directory is created, and the report states the workstream register was created

#### Scenario: An existing workstream register is preserved exactly

- **WHEN** the target already contains `docs/workstreams/AGENTS.md` holding a workstreams block
- **THEN** it and every file beside it are left byte-for-byte unchanged, and the report states the workstream register is already present

#### Scenario: The seeded register carries no status field

- **WHEN** the seeded file is written
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

- **WHEN** the seeded file is written
- **THEN** its workstream shape gives Not in scope, Open questions and Opened as consecutive list items after the steps, each absent value as `none`, gives no Decisions list item, and places `## Context` and then `## Decisions` after the list

#### Scenario: A step is recorded by its entry file

- **WHEN** the seeded file is written
- **THEN** it states that a step is recorded where `docs/backlog/` holds an entry of the step's name, and does not name `docs/backlog.md`

#### Scenario: Done when asks for an observable effect of the Goal

- **WHEN** the seeded file is written
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

## REMOVED Requirements

### Requirement: A backlog is seeded where none exists

**Reason**: The backlog's rules move from a seeded `docs/backlog/README.md` into a managed block in `docs/backlog/AGENTS.md`, and two of its scenarios — a missing seed blocking only an outstanding backlog, and a README added beside existing entries — describe behavior that no longer holds.

**Migration**: Replaced by *The backlog's rules are written where none exist*, which carries the entry rules unchanged. A project holding `docs/backlog/README.md` is reported by *A directory holding its rules in a README is reported, not converted*; converting it is the update tool's.
