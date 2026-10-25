## MODIFIED Requirements

### Requirement: A backlog is seeded where none exists

*Modified by `one-file-per-backlog-entry`: the backlog is a directory with a README and one file per entry, an entry's values are frontmatter, Waits on is split into `waits_on` and `waits_for`, and a project still on the single file is pointed to the migration tool. Every scenario keeps its title; their bodies follow the new shape.*

Where neither `docs/backlog/` nor `docs/backlog.md` exists in the target, the tool SHALL create `docs/backlog/README.md`, in both the new-project and the adoption mode, creating `docs/` and `docs/backlog/` if absent. Where `docs/backlog/README.md` exists, the tool SHALL leave it byte-for-byte unchanged and report the backlog present. Where `docs/backlog.md` exists and `docs/backlog/` does not, the tool SHALL leave the file byte-for-byte unchanged, create nothing under `docs/backlog/`, and report that the backlog is present in the single-file shape and that `scripts/backlog-migrate` converts it. Where `docs/backlog/` exists as a directory, not through a symbolic link, without a README, the tool SHALL create the README, leave every other file in the directory unchanged, and report the README created beside existing entries. Where `docs/backlog` exists as a symbolic link or as anything other than a directory, the tool SHALL write nothing there and report that the path is not a directory it will write into, the remaining concerns proceeding as usual.

The tool SHALL read the README's text from its own copy of the library, at `scripts/seed/backlog-README.md`, the file `scripts/backlog-migrate` writes from too, so that a seeded backlog and a converted one carry the same rules. Where the backlog concern is outstanding and that file is absent from the tool's copy, the tool SHALL report `BLOCKED` before any write, as it does for an absent rule fragment; where the concern is satisfied, its absence SHALL NOT block.

The workflow fragment routes out-of-scope work to that directory and defers to its README for how an entry is written. A README each project's first session invents carries a different entry shape and deletion rule in every project, so the rules the fragment defers to would not be the same rules anywhere.

The created README SHALL state, as prose a session reads before adding an entry:

- that the directory lists changes the project has identified and not yet archived, each recorded instead of being folded into the change that found it, one file per entry beside this README;
- that an entry's file is named for the change's kebab-case name, `<name>.md` — the name its branch and change directory are expected to take, which the session that opens the change may revise if the work turns out different — that the file's name is the entry's only identifier and the file carries no heading repeating it, that an entry is referred to only by that name, and that a fix takes it as its branch's name only;
- that entries carry no order, and that an entry states in its own fields what it waits on, how urgent it is, and which entries share a design with it;
- that an entry is kept short: what is needed and why, with files, specifications and changes named as pointers, and without line numbers, census tables or step-by-step plans;
- that an entry's file is deleted when its change is archived, when the operator takes it as a fix rather than a change, when a change makes it obsolete, or when the operator decides the change will not be made;
- that when a change is archived, the entries it unblocked, unparked or made stale are updated and their `re_checked` date set;
- that the README is kept when there are no entries;
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

**This requirement owns the backlog's entry rules**; `session-workflow` owns only routing work to the directory and when it is re-read, and its fragment defers to the README for these rules rather than restating them. `backlog-maintenance` performs operations over the directory and likewise reads these rules from the README. `backlog-migration` converts a single-file backlog into this shape.

A path is present where it exists of any type, including a symbolic link whether or not it resolves. A link counted as absent would be written through, to wherever it points.

The created directory SHALL contain no entry, and the README SHALL NOT number entries or mention entry numbers. An entry carrying a number invites citing and ordering by it; a name is the identifier that survives other entries being deleted.

The README is kept when there are no entries because the tool created it: deleting it would leave the next session to recreate it from no text at all, which is the variance this requirement removes, and would leave a directory version control does not keep.

#### Scenario: A project without a backlog receives the seeded file

- **WHEN** the tool runs in a target with neither `docs/backlog/` nor `docs/backlog.md`
- **THEN** `docs/backlog/README.md` is created with every statement listed above, no entry file is created, and the report states the backlog was created

#### Scenario: An existing backlog is preserved exactly

- **WHEN** the target already contains `docs/backlog/README.md`
- **THEN** it and every entry file beside it are left byte-for-byte unchanged and the report states the backlog is already present

#### Scenario: The seeded file carries no numbering

- **WHEN** the seeded README is created
- **THEN** no heading in it begins with a number and no sentence in it refers to an entry's number

#### Scenario: The seeded entry shape carries the structured fields

- **WHEN** the seeded README is created
- **THEN** its entry shape names the keys `priority`, `parked_until`, `kind`, `waits_on`, `waits_for`, `design_with`, `workstream`, `recorded_by` and `re_checked`, in that order, and does not name Depends on

#### Scenario: A fix is distinguished from a change by what it owes

- **WHEN** a session reads the seeded README to record an entry that owes a specification delta
- **THEN** the README's definition of `kind` leaves only `change` available to it, because `fix` is stated as owing no delta, needing no decision and fitting one review sitting

#### Scenario: Priority's values and default are stated

- **WHEN** the seeded README is created
- **THEN** its entry shape states `priority`'s three values `high`, `normal` and `parked`, that `high` needs evidence of harm happening now, that `parked` needs a condition in `parked_until` that can be checked, and that an entry without the key is `normal`

#### Scenario: The seeded file offers no low priority

- **WHEN** a session reads the seeded README to record an entry it judges not worth taking
- **THEN** the README offers no `low` value, so the entry is either parked with a condition or not recorded

#### Scenario: The seeded file states how an entry leaves parked and high

- **WHEN** a session reads the seeded README at the archive of a change that fulfilled a parked entry's condition, or removed a `high` entry's evidence
- **THEN** the README directs that entry to `normal`, or to `high` with evidence for the parked one, and names unparked entries among those the archive updates

#### Scenario: Workstream's default is stated

- **WHEN** the seeded README is created
- **THEN** its entry shape states that an entry recorded by a change in a workstream takes that workstream unless it serves another goal, and that an entry without the key is `none`

#### Scenario: The seeded entry's fields are a list

- **WHEN** the seeded README is created
- **THEN** its entry shape gives the values as frontmatter keys, one per line in the stated order, and the reasons as one Markdown list in the body, `- **Kind**: …`, `- **Priority**: …`, `- **Recorded by**: …`, with no blank line between them

#### Scenario: An absent value reads as its field

- **WHEN** the seeded README is created
- **THEN** its entry shape gives the empty `waits_on` and `design_with` as `[]` and the absent `workstream` as `none`, and states the meaning of each key's absence

#### Scenario: A single-file backlog is pointed to the migration tool

- **WHEN** the tool runs in a target with `docs/backlog.md` and no `docs/backlog/`
- **THEN** `docs/backlog.md` is unchanged, `docs/backlog/` is not created, and the report states the backlog is in the single-file shape and names `scripts/backlog-migrate`

#### Scenario: A missing seed blocks only an outstanding backlog

- **WHEN** the tool runs where `scripts/seed/backlog-README.md` is absent from its copy, once in a target with no backlog and once in a target whose `docs/backlog/README.md` exists
- **THEN** the first run reports `BLOCKED` and writes nothing, and the second does not block on it

#### Scenario: A README is added beside existing entries

- **WHEN** the tool runs in a target whose `docs/backlog/` holds entry files and no README
- **THEN** the README is created, and every entry file is byte-for-byte unchanged

#### Scenario: A backlog path that is not a directory is not written through

- **WHEN** the tool runs in a target where `docs/backlog` is a symbolic link, or a regular file
- **THEN** nothing is written at or through that path, and the report states it is not a directory the tool writes into

#### Scenario: Waits on holds only names

- **WHEN** a session reads the seeded README to record an entry waiting on a person's answer and on a named change
- **THEN** the README directs the change's name into `waits_on` and the answer, as a double-quoted condition, into `waits_for`

#### Scenario: The frontmatter is flat

- **WHEN** the seeded README is created
- **THEN** its entry shape states that names, set values and dates are bare, free text is double-quoted with `"` and `\` escaped, lists are inline, nothing is nested, and no value spans lines

### Requirement: A workstream register is seeded where none exists

*Modified by `one-file-per-backlog-entry`: a step is recorded where `docs/backlog/` holds an entry of its name, and a step's ordering wait is its entry's `waits_on`.*

Where `docs/workstreams/README.md` does not exist in the target, the tool SHALL create it, in both the new-project and the adoption mode, creating `docs/workstreams/` if absent. Where the file exists, the tool SHALL leave it byte-for-byte unchanged and report it present. The file is present where a path exists at `docs/workstreams/README.md` of any type, including a symbolic link whether or not it resolves. The tool SHALL NOT create `docs/workstreams/archive/`.

A workstream is a goal that takes more than one change. The workflow fragment sends a session to this directory at a change's proposal and at its archive, and defers to the README for how a workstream is written, as it defers to the backlog's README for an entry. Unseeded, each project's first session would invent those rules, and the fragment's references would mean something different in every project.

The created file SHALL state, as prose a session reads before opening, editing or archiving a workstream:

- that a workstream is a goal that takes more than one change, each open one a file in this directory named `<name>.md` for its kebab-case name, unique among workstreams open and archived and not also a change's name, and referred to only by that name;
- that a workstream file holds the plan and never its progress, and that a step's status is read from the repository by the step's name, the first that holds winning: done where the freshly fetched trunk holds an archived change of that name; in flight where it holds an open change of that name, or a local or remote branch or an open pull request of that name exists; recorded where its `docs/backlog/` holds an entry of that name; and planned otherwise;
- that the order of the steps is the intended order of work and gates nothing, a step that cannot start before another saying so in its backlog entry's `waits_on`;
- that the file is edited only when the plan changes — a step added, removed, reordered or renamed, what finishes it or what is out of scope revised, an open question added or answered, or the workstream archived;
- that a workstream is opened when the operator decides a goal needs more than one change, and committed with the plan of the first change that advances it or as work too small to be a change;
- that a change or a backlog entry may name the workstream it serves before any step names it, and that each such change or entry is placed among the steps or detached at the next edit of the workstream, and at the latest at the archive of a change in it;
- that when what finishes a workstream holds, its file moves to `archive/<YYYY-MM-DD>-<name>.md`, dated the day it is archived, in the commit that carries the record of the change that completed it, after each step not done, other than the change whose record that commit carries, is removed from the steps, first recorded as a backlog entry naming no workstream where it is still wanted and not yet in flight, an in-flight one continuing as its own change, and every backlog entry still naming it is re-pointed or cleared;
- that the operator may abandon a workstream whose goal will not be met, which gains an **Abandoned** item after Opened, with the date and the reason, has its steps and entries dealt with as on completion, and is moved to `archive/` the same way, as work too small to be a change;
- that a workstream is kept short, its lasting decisions recorded in a document or a change's design it points to, and that the README is kept when there is no workstream;
- the shape of a workstream: its heading, the name; its **Goal**; its **Done when**, a condition that can be checked against the repository, the forge or production; its **Steps**, an ordered list each naming a change in kebab-case with what it does; what is **Not in scope**, or `none`; its **Open questions**, each deleted once answered with the answer recorded where its decisions are, or `none`; its **Decisions**, where they are recorded, or `none`; and when and by what it was **Opened** — Goal and Done when as paragraphs, and the fields after the steps as one list, one item per field, with no blank line between them.

**The file holds no status because status written by hand goes stale.** Progress happens in every session, and a status field is edited by none of them at the moment it changes; a status read from the repository by name is current whenever it is read. That is why a step is named by the change it is expected to be: the name is the key the lookups use. **The precedence and the trunk are stated because the sources overlap**: a backlog entry survives until its change is archived, and a branch until the record's pull request merges, so a step matches more than one source in the ordinary course of its life; and a session's own working tree may predate a step's archive, so reading it would give each session a different answer.

**Order gates nothing because precedence already has one authority.** `waits_on` is the side the pick and the archive re-read read, and the backlog dropped a second side because two statements of one constraint drift; a step's "comes after" in the workstream file would reintroduce it.

**A finished or abandoned workstream is archived, not deleted** (operator, 2026-10-24), so its plan and the decisions it points to stay readable after its goal is met, as an archived change's record does.

**This requirement owns the workstream rules**; `session-workflow` owns only when the fragment sends a session to the directory, and its fragment defers to the README rather than restating them. `backlog-maintenance` reads them from the README.

The created file SHALL contain no workstream.

#### Scenario: A project without a workstream register receives the seeded file

- **WHEN** the tool runs in a target with no `docs/workstreams/README.md`
- **THEN** the file is created with every statement listed above and no workstream, no `archive/` directory is created, and the report states the workstream register was created

#### Scenario: An existing workstream register is preserved exactly

- **WHEN** the target already contains `docs/workstreams/README.md`, or a symbolic link at that path
- **THEN** it is left byte-for-byte unchanged and not written through, and the report states the workstream register is already present

#### Scenario: The seeded register carries no status field

- **WHEN** the seeded file is created
- **THEN** its workstream shape names Goal, Done when, Steps, Not in scope, Open questions, Decisions and Opened, and names no field recording a step's status

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

- **WHEN** the seeded file is created
- **THEN** its workstream shape gives Not in scope, Open questions, Decisions and Opened as consecutive list items after the steps, each absent value as `none`

#### Scenario: A step is recorded by its entry file

- **WHEN** the seeded file is created
- **THEN** it states that a step is recorded where `docs/backlog/` holds an entry of the step's name, and does not name `docs/backlog.md`
