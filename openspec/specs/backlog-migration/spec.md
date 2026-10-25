# backlog-migration Specification

## Purpose
Defines `scripts/backlog-migrate`, the shipped tool that converts a project's single-file backlog, `docs/backlog.md`, into the directory shape `project-bootstrap` seeds: one entry file per entry with its values as frontmatter. It states what the tool maps, from which earlier shapes, what it refuses, and what it reports, so that every project's conversion is the same conversion.

## Requirements

### Requirement: The tool converts a single-file backlog into the directory

The library SHALL ship an executable at `scripts/backlog-migrate`, run as `scripts/backlog-migrate [<target>]`, the target defaulting to the current directory. It SHALL read `<target>/docs/backlog.md` and write `<target>/docs/backlog/`: a `README.md`, and one file `<name>.md` for each entry, named for the entry's heading. It SHALL then delete `docs/backlog.md`. It SHALL write nothing else, and SHALL NOT commit, stage or push.

An **entry heading** is a level-2 heading — a line starting `## ` — outside any fenced code block, consisting of exactly one kebab-case name in backticks. The **preamble** is everything before the first entry heading; an entry is its heading and everything up to the next level-2 heading outside a fenced code block, or the end of the file. Headings inside fenced code blocks are text: the seeded preamble shows an example entry, `` ## `change-name` ``, inside a fence, and it is not an entry. A fenced code block opens on a line starting ```` ``` ```` or `~~~` and closes only on a line starting with the same marker. A carriage return at a line's end is ignored, so a file with Windows line endings reads as any other.

The README it writes SHALL be byte-for-byte the README `scripts/project-init` seeds. The preamble is not carried into it; the report says so.

A conversion each session performed by its own reading would produce a different result in each of the eight projects that carry a backlog, which is the drift the directory shape exists to end. The tool is deterministic, so the same backlog converts the same way wherever it is run.

The tool SHALL NOT commit because the operator reads the conversion in the diff before it reaches a pull request, and the deleted file stays recoverable from the commit that last held it.

#### Scenario: A backlog is converted

- **WHEN** the tool runs in a target whose `docs/backlog.md` holds three entries
- **THEN** `docs/backlog/` holds the seeded README and three entry files, each named for its entry's heading, and `docs/backlog.md` no longer exists

#### Scenario: The README is the seeded one

- **WHEN** the tool converts a backlog whose preamble differs from the seeded one
- **THEN** the README it writes is byte-for-byte the one `scripts/project-init` seeds, and the report states that the old preamble was not carried over

#### Scenario: The tool commits nothing

- **WHEN** the tool converts a backlog in a repository with a clean index
- **THEN** the index and the commit history are unchanged after the run

### Requirement: Every run ends in one of three outcomes, and the exit code agrees

Each run SHALL end in exactly one of `SUCCESS`, exit code zero; `BLOCKED`, a precondition unmet and nothing written, exit code non-zero; or `ERROR`, a write attempted and failed, exit code non-zero and distinct from `BLOCKED`'s. The outcome SHALL be stated in the report. These are `scripts/project-init`'s outcomes and codes, so a caller reads both tools the same way.

The tool SHALL report `BLOCKED` and write nothing where:

- `git` is unavailable, or the target is not inside a git repository;
- `docs/backlog/` exists, of any type, including a symbolic link — the backlog is converted already, or a conversion is in progress by hand;
- `docs/backlog.md` does not exist, is not a regular file, is not tracked by git, or differs from its committed content in the working tree or the index;
- after the first entry heading, a level-2 heading outside a fenced code block is not an entry heading; or, before it, a level-2 heading outside a fenced code block begins with a backtick, as an entry's does, but is not an entry heading, which would otherwise be read as preamble and left out; two entries carry one name; or an entry's name is `readme` in any case, which would collide with `README.md` on a filesystem that ignores case;
- the seeded README is absent from the tool's own copy.

Every precondition SHALL be checked before any write. The tool SHALL write the new directory under a temporary name in `docs/` and move it into place, then delete `docs/backlog.md`; where a write fails, it SHALL remove what it wrote, leave `docs/backlog.md` in place, and report `ERROR`.

**The old file must be committed and unmodified** because the tool deletes it: a commit is what makes the deletion recoverable, and an uncommitted edit would be lost with it. **A heading that is not one name blocks** because the name is the entry's file and its only identifier, and a name the tool guessed at is an identifier nobody chose.

#### Scenario: An uncommitted edit blocks

- **WHEN** `docs/backlog.md` has an edit not yet committed
- **THEN** the tool reports `BLOCKED`, exits non-zero, and writes and deletes nothing

#### Scenario: A converted backlog is not converted twice

- **WHEN** the tool runs in a target that already has `docs/backlog/`
- **THEN** the tool reports `BLOCKED`, names the existing directory, and changes nothing

#### Scenario: A heading that is not a name blocks

- **WHEN** a level-2 heading after the first entry heading reads `## Fix the install script` rather than one backticked kebab-case name
- **THEN** the tool reports `BLOCKED`, names the heading, and writes nothing

#### Scenario: The seeded preamble's example is not an entry

- **WHEN** the tool converts a backlog whose preamble is the one `scripts/project-init` seeded before this change, with its fenced example `` ## `change-name` ``, followed by two entries
- **THEN** `docs/backlog/` holds the README and exactly two entry files, and no `change-name.md`

#### Scenario: A preamble with sections of its own

- **WHEN** a backlog's preamble carries a level-2 heading of its own, such as `## How we use this file`, before its first entry heading
- **THEN** the heading is part of the preamble, the tool does not block on it, and the entries convert

#### Scenario: An entry named readme blocks

- **WHEN** a backlog holds an entry headed `` ## `readme` ``
- **THEN** the tool reports `BLOCKED`, names the entry, and writes nothing

#### Scenario: A malformed first entry blocks

- **WHEN** a backlog's first backticked level-2 heading reads `` ## `First_Entry` ``, which is not a kebab-case name
- **THEN** the tool reports `BLOCKED`, names the heading, and writes nothing, rather than reading the entry as preamble

#### Scenario: Windows line endings

- **WHEN** a backlog's lines end in a carriage return and a newline
- **THEN** its entries convert as they do with newlines alone

#### Scenario: A failed write leaves the old file

- **WHEN** a write fails partway through the conversion
- **THEN** the tool reports `ERROR`, no `docs/backlog/` and no temporary directory remain, and `docs/backlog.md` is unchanged

### Requirement: Each entry's fields are mapped into frontmatter, and nothing is dropped

For each entry the tool SHALL write frontmatter in the form and key order the seeded README states, and a body holding the entry's prose followed by one list of the reasons and of whatever it could not map.

It SHALL recognise a field by its label in bold followed by a colon — `**Label**:` — at the start of a line, whether the line is a list item or a paragraph, since both layouts are in use. It SHALL map the fields as follows, ignoring the case of a leading value word and any backticks, trailing full stop or trailing comma around it:

- **Priority**: a value starting `high` becomes `priority: high`, the rest of the text the body's **Priority** item; `normal` becomes `priority: normal`; `parked until` becomes `priority: parked` with the rest of the text as `parked_until`.
- **Kind**: a value starting `fix` or `change` becomes `kind`, the rest of the text the body's **Kind** item.
- **Waits on**, and **Depends on** in the oldest shape: a value starting `nothing` or `none` becomes `waits_on: []`, and any text after that word is the body's **Waits on** item. Otherwise each backticked kebab-case name that is a **known name** goes into `waits_on`, and where any text remains beyond those names and the separators between them (commas, `and`, semicolons, full stops), the whole value is kept as `waits_for`.
- **Design with**: a value starting `nothing` or `none` becomes `design_with: []`. Otherwise each backticked kebab-case name that is a known name goes into `design_with`. Any other text is the body's **Design with** item.
- **Workstream**: a value starting `nothing` or `none` becomes `workstream: none`, and a value starting with one backticked kebab-case name becomes `workstream`. Any other text is the body's **Workstream** item.
- **Recorded by**: the first backticked kebab-case name that is a known name becomes `recorded_by`, and the whole value is the body's **Recorded by** item.
- **Re-checked**: a date in `YYYY-MM-DD` form becomes `re_checked`.

A **known name** is the name of an entry in the same file, or of a change directory, open or archived, under `openspec/changes/` — an archived one without its date prefix. A kebab-case word in backticks that is neither — a specification's name, say — is text, not a name.

**Nothing is dropped.** Where a field's value, or any part of it the rules above do not consume, cannot be mapped, the tool SHALL omit the key or keep the mapped part, and keep the unmapped text in the body's list under the field's own label. A field the rules do not name — **Must not undo**, say — SHALL be kept in that list as written. Text in the entry that is neither prose before the first field nor a field SHALL follow the prose. Free text written into the frontmatter SHALL be double-quoted, with `"` and `\` escaped.

**An absent field leaves its key absent.** Where an entry has no Kind, no Priority or no Workstream, the tool SHALL write no such key and invent no value; the README's defaults and the `backlog` skill's handling of entries in an older shape apply to it.

#### Scenario: A listed and a paragraph entry convert alike

- **WHEN** one entry gives its fields as list items and another gives the same fields as paragraphs
- **THEN** both entry files carry the same keys with the same values

#### Scenario: A parked entry

- **WHEN** an entry reads `- **Priority**: parked until a second brand is onboarded`
- **THEN** its file carries `priority: parked` and `parked_until: "a second brand is onboarded"`

#### Scenario: A wait on a change and on an answer

- **WHEN** an entry's Waits on reads `` `automate-gate-a`, and the operator's answer on VAT `` and `automate-gate-a` is an open change
- **THEN** its file carries `waits_on: [automate-gate-a]` and the whole value as `waits_for`

#### Scenario: A specification's name is not a wait

- **WHEN** an entry's Waits on names `` `project-bootstrap` `` and no entry or change has that name
- **THEN** `project-bootstrap` is not in `waits_on`, and the value is kept as `waits_for`

#### Scenario: Waits on nothing with a note

- **WHEN** an entry's Waits on reads `` `nothing`. The open change `update-managed-block` must be designed with it. ``
- **THEN** its file carries `waits_on: []`, and the note is kept in the body under **Waits on**

#### Scenario: A fence after a field stays out of the value

- **WHEN** a fenced code block starts on the line after an entry's last field, with no blank line between
- **THEN** the field's value holds none of the fenced text, and the block is kept in the body whole

#### Scenario: A fence of the other marker does not close

- **WHEN** an entry's prose holds a `~~~` fence containing a ```` ``` ```` line, followed by the next entry's heading
- **THEN** the next entry converts as an entry of its own

#### Scenario: An unknown field is kept

- **WHEN** an entry carries `- **Must not undo**: the pinned project name`
- **THEN** its file's body list carries that item as written, and the report names the field

#### Scenario: An entry with no Kind

- **WHEN** an entry carries Depends on and no Kind
- **THEN** its file has no `kind` key, carries its dependencies in `waits_on` where they are known names, and the report names it among the entries without a Kind

#### Scenario: Earlier absent values are normalised

- **WHEN** entries give Design with as `nothing.` and Workstream as `nothing`
- **THEN** their files carry `design_with: []` and `workstream: none`

### Requirement: The report names what the tool could not map

The tool's report SHALL state the outcome, the number of entries converted, and, by entry name: each field whose value was kept in whole or in part in the body rather than mapped, each field the rules do not name, each entry written without a `kind`, and each `waits_for` and `parked_until` it wrote, since either may hold a reason beside its condition. It SHALL state that the old preamble was not carried over. On `BLOCKED` it SHALL name the precondition and, for a heading or a name, the offending text.

The report is what the operator reads before committing the conversion, so it names every place the tool used judgement it does not have: text it kept as prose is text a person may want to move into a value.

#### Scenario: A written condition is reported

- **WHEN** an entry's Priority reads `parked until` a condition followed by its reason
- **THEN** the report names that entry's `parked_until` among the conditions written

#### Scenario: An unmapped Recorded by is reported

- **WHEN** an entry's Recorded by names no entry or change
- **THEN** its file carries no `recorded_by`, the value is kept in the body, and the report names the entry and its Recorded by

#### Scenario: A kept note is reported

- **WHEN** an entry's Waits on carries a note after `nothing`
- **THEN** the report names that entry and the Waits on field among those kept in the body

### Requirement: The tool locates its resources itself and runs where project-init runs

The tool SHALL derive its own directory from its invocation path and read the seeded README from its own copy of the library, not from an environment variable, as `scripts/project-init` does. It SHALL declare `bash` via `#!/usr/bin/env bash`, use no construct unavailable in bash 3.2, rely on no command beyond `git` and the POSIX utilities, and pass ShellCheck. Using the library requires nothing installed, and the tool is part of the library.

#### Scenario: The README comes from the tool's own copy

- **WHEN** the tool runs from one copy of the library while an environment variable names another
- **THEN** the README it writes is the one in the copy it was invoked from

#### Scenario: An older bash

- **WHEN** the tool runs under bash 3.2
- **THEN** it converts the backlog as it does under a newer bash
