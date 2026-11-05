## MODIFIED Requirements

### Requirement: The backlog's rules are written where none exist

*Modified by `report-a-tasks-kind-and-wait`: the entry shape gains `need`, after `kind`, and `waits_for_type`, after `waits_for`, with their meanings, the absent `need` read as `should`, and **Need** among the body's reasons. Every scenario keeps its title; four are added.*

*Modified by `match-backlog-entries-to-a-workstream`: the rule on `workstream` requires reading the open workstreams' Goals before `none` is written. Every scenario keeps its title; one is added.*

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
- the shape of an entry's frontmatter, its keys in this order, one per line: `priority`, `high`, `normal` or `parked`; `parked_until`, present only on a parked entry, the condition that can be checked under which it becomes worth taking; `kind`, `fix` or `change`; `need`, `must`, `should` or `could`, measured against the Goal of the entry's workstream — `must` where the Goal does not hold without it, `could` where the Goal holds without it and the operator would not keep it among the steps, `should` otherwise, being a step making no entry `must` even where the Done when requires every step to be done — or, for an entry naming no workstream, against the project — `must` where its absence does harm, `could` where it is an improvement only, `should` otherwise; `waits_on`, a list of the names of entries or changes that must be archived first; `waits_for`, present only where the entry waits on something that is not a name, the condition that can be checked — a person's answer, an access grant, an event — kept short, what is awaited and from whom, the reasons in the body; `waits_for_type`, present only beside `waits_for`, the kinds of wait it states, from `decision`, the operator's decision; `answer`, an answer from someone other than the operator; `access`, an access grant, a credential or a setting someone must enable; `release`, a release reaching an environment; and `event`, any other condition that can be checked; `design_with`, a list of the entries that share a design with this one; `workstream`, the workstream the entry is a step of or serves, by name, or `none`; `recorded_by`, the change that identified it by name, or a double-quoted text where no change did; and `re_checked`, the date it was last verified against the repository, as `YYYY-MM-DD`;
- the frontmatter's form: a name, a value from a stated set or a date is written bare; free text is double-quoted, with `"` and `\` escaped by a backslash; a list is written inline as `[a, b]`, and empty as `[]`; nothing is nested, and no value spans more than one line;
- the meaning of an absent key: an entry without `priority` is `normal`; without `need`, `should`; with `waits_for` and without `waits_for_type`, untyped; without `waits_on` or `design_with`, the empty list; without `workstream`, `none`;
- the rules on `priority`: that `high` needs evidence of harm happening now — an incident, a measurement, an observation; that a parked entry is not folded into another change before its condition holds; that a parked entry whose condition holds becomes `normal`, or `high` with evidence; and that a `high` entry whose evidence no longer holds becomes `normal`;
- the rule on `workstream`: that an entry recorded by a change in a workstream takes that workstream unless it serves another goal or that workstream's Not in scope leaves it out; that otherwise it takes the open workstream whose Goal it serves, found by reading the Goal and Not in scope of every open workstream; and that `none` is written only after that read finds none, or on the operator's word;
- the shape of an entry's body: what the change is and why, written for a session that has not seen the work that found it, followed by one list giving the reasons the frontmatter's values need — **Kind**, why it is a fix or a change; **Need**, on a `must` or `could` entry only, why; **Priority**, on a `high` or parked entry only, the evidence or why it is parked; **Recorded by**, why it was not done there — and that further items a project's own rules add to that list are kept as written.

**Kind is `fix` only where the entry owes no specification delta, needs no decision from the operator, and is small enough to review in one sitting**; otherwise it is `change`. The size condition is the workflow's own: a fix is work too small to be a change, which skips `plan`, so an entry too large for one sitting is not one whatever it owes. The reason is stated because the label alone cannot be checked, and an entry's kind is the first thing a session picking work reads.

**Waits on replaces a list of changes that must land first, and holds only names.** An entry that should precede another says so from the waiting side: the later entry names it in `waits_on`. A constraint stated on both sides is two statements that drift, and the waiting side is the one the pick and the archive re-read read. **A wait on something that is not a name is `waits_for`, apart from the names**, because a name is an edge a reader can follow and resolve — archived or not — and a sentence is not: mixed into one field, every reader has to guess which words are names. An entry may wait on both.

**Need is apart from priority.** Priority says how urgent an entry is, need whether the goal it serves holds without it, and the two vary independently: a `could` may be urgent while an opportunity lasts, and a `must` may be parked until its precondition exists. It is measured against the Goal and not the Done when, because a Done when may require every step to be done, which would make every step `must`, and a `could` step is one the operator may remove and return to the backlog without failing the Goal. `must` and `could` are the operator's judgement, so each states its reason; there is no "won't", which is already a deletion ground.

**A condition states its kind of wait beside it.** Whose move a wait is — the operator's decision, someone else's answer or grant, or nobody's yet — is what a reader of the backlog acts on, and a sentence makes every reader parse it. The type is a list because one condition may hold two waits, and a key of its own because the condition's words stay free text, valid without it.

**Priority is `high` only with evidence of harm happening now**, and **`parked` only with a condition that can be checked**, under which the entry becomes worth taking. Both are stated so that a later reading can tell whether they still hold, which a bare label cannot show. There is no `low`: an entry not worth taking with no condition under which it would be is one the operator has decided will not be made, which is already a deletion ground. Parked is not a wait: a waiting entry cannot be taken, a parked one can and is deliberately deferred, and an entry may be both. The condition has a key of its own, `parked_until`, because it is what a later reading checks; the reason it was parked is prose, in the body.

**Workstream is not Design with.** Design with groups entries that share a design, a property of the work; Workstream places an entry in a goal's sequence of changes, a property of the plan. Two entries may share either without the other, so neither field stands in for the other. The default is the recording change's workstream because work a change identifies usually serves the goal that change serves, and an entry recorded without it is detached from the plan it belongs to. **The search is an obligation of the entry rule, not only of the `backlog` skill**, because a session writing an entry by hand owes the same, and `none` written unexamined leaves a fitting goal unserved.

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
- **THEN** its entry shape names the keys `priority`, `parked_until`, `kind`, `need`, `waits_on`, `waits_for`, `waits_for_type`, `design_with`, `workstream`, `recorded_by` and `re_checked`, in that order, and does not name Depends on

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

#### Scenario: The seeded block makes `none` the end of a search

- **WHEN** the seeded block is written
- **THEN** its entry shape states that the Goal and Not in scope of every open workstream are read, that the entry takes the one whose Goal it serves, and that `none` is written only after that read finds none or on the operator's word

#### Scenario: Need's values and default are stated

- **WHEN** the seeded block is written
- **THEN** its entry shape states `need`'s three values `must`, `should` and `could`, each measured against the Goal of the entry's workstream or, naming none, against the project, and that an entry without the key is `should`

#### Scenario: A condition's types are stated

- **WHEN** the seeded block is written
- **THEN** its entry shape states that `waits_for_type` is present only beside `waits_for`, and names its five values `decision`, `answer`, `access`, `release` and `event` with their meanings

#### Scenario: A condition without a type stays valid

- **WHEN** a session reads the seeded block for an entry carrying `waits_for` and no `waits_for_type`
- **THEN** the block reads the entry as untyped, not as malformed

#### Scenario: A step is not must for being a step

- **WHEN** a session reads the seeded block for a step of a workstream whose Done when requires every step to be done, and the Goal holds without that step
- **THEN** the block leaves `could` available to it, since being a step does not make an entry `must`
