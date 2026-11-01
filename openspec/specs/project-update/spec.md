# project-update Specification

## Purpose
Defines `scripts/project-update`, the shipped tool that brings one project's managed blocks to the text of the library copy it belongs to: it classifies each block `rules/manifest` lists from the project alone, replaces a stale one nobody edited, reports an edited one without overwriting it, and converts the shapes before `1.0.0` once, where git holds the original.

## Requirements

### Requirement: The update tool is a standalone executable beside project-init

The library SHALL ship `scripts/project-update`, a shell script that brings one project's managed blocks to the text of the library copy it belongs to. It SHALL be runnable by a human, a shell or any agent in any harness, with no skill, plugin or model present, and SHALL be a separate executable from `scripts/project-init`, which keeps its contract that it never rewrites a block it finds.

The tool SHALL operate on the current working directory, or on the directory a single optional path argument names, SHALL accept `--workflow <full|direct>` as *A project states its workflow where its block predates the choice* describes, and SHALL state that target in its report before any change. A target that does not exist, is not a directory or is not writable SHALL produce `BLOCKED`. It SHALL document its arguments, flags, outcomes and exit codes in `--help`, which makes no change and exits zero.

It SHALL derive its own directory from its invocation path and read `rules/manifest` and the fragments it lists from that copy, never from an environment variable. It SHALL declare `bash` via `#!/usr/bin/env bash`, use no construct unavailable in bash 3.2, rely on no command beyond `git`, `sha256sum` or `shasum`, `diff` and the POSIX utilities, and pass ShellCheck.

**One project per run, and a separate tool** (operator, 2026-10-28, `keep-projects-on-the-current-workflow`'s step 2). A loop over projects is one line in the caller, and a report about one project has one outcome. An overwrite path added to `project-init` would make its never-overwrite contract hold only without a flag.

#### Scenario: Help describes the tool and changes nothing

- **WHEN** `scripts/project-update --help` is run in a project
- **THEN** it names the target argument, the outcomes and their exit codes, exits zero, and the project is unchanged

#### Scenario: The target is stated before any change

- **WHEN** the tool is given a path argument naming another directory
- **THEN** the first line of its report names that directory, and it acts on that directory

#### Scenario: An unusable target blocks

- **WHEN** the target does not exist, is not a directory, or is not writable
- **THEN** the tool reports `BLOCKED`, exits with `BLOCKED`'s code, and writes nothing

#### Scenario: Fragments come from the copy the tool belongs to

- **WHEN** the tool runs from one copy of the library while an environment variable names another
- **THEN** the blocks it writes carry the fragments and versions of the copy it was invoked from

#### Scenario: An older bash

- **WHEN** the tool runs under bash 3.2
- **THEN** it classifies and replaces blocks as it does under a newer bash

### Requirement: Every run ends in one of three outcomes, and the exit code agrees

Each run SHALL end in exactly one of `SUCCESS`, exit code `0`; `ERROR`, a write attempted and failed, exit code `1`; or `BLOCKED`, a precondition unmet and nothing written, exit code `2` — `scripts/project-init`'s outcomes and codes. The outcome SHALL be stated in the report, with a reason for `ERROR` and `BLOCKED`.

The tool SHALL report `BLOCKED` and write nothing where the target is unusable; where `rules/manifest`, or a fragment it lists, is missing, or a fragment lacks a `kind` or a `MAJOR.MINOR.PATCH` version, whether or not that record would be written, a fragment an `alternative` names counting as listed; where a record with an `alternative` lacks a `MAJOR.MINOR.PATCH` `alternative_since`; where `--workflow` holds a value other than `full` or `direct`; where a choice is owed, as *A project states its workflow where its block predates the choice* states; where neither `sha256sum` nor `shasum` is available; or where a precondition *The shapes before 1.0.0 are converted only where git holds the original* states is unmet. Every precondition SHALL be checked before the first write. On `ERROR`, the report SHALL state what was already written.

A run that leaves any record `edited`, `ahead`, `malformed`, `not writable`, `absent` or `single file` SHALL still end in `SUCCESS`, and SHALL print, before the outcome, one line `Attention: ` followed by those records' names, comma-separated, in manifest order. Where no record is left so, the line SHALL NOT appear.

#### Scenario: A missing fragment blocks

- **WHEN** the tool runs from a copy whose manifest lists a fragment that copy does not hold
- **THEN** it reports `BLOCKED`, exits `2`, and the project is unchanged

#### Scenario: An edited block still succeeds, and is named

- **WHEN** one block is edited and every other is current
- **THEN** the outcome is `SUCCESS`, the exit code `0`, and the line `Attention: ` names the edited block's record only

#### Scenario: Several records to attend to are named in manifest order

- **WHEN** the `workstreams` block is edited and the `backlog` block's target is a symbolic link
- **THEN** the report holds one line `Attention: backlog, workstreams`

#### Scenario: A fragment without a semantic version blocks

- **WHEN** a fragment the manifest lists carries no `kind`, or a `version` such as `12` that is not `MAJOR.MINOR.PATCH`
- **THEN** the tool reports `BLOCKED`, exits `2`, and the project is unchanged

#### Scenario: No hash command blocks

- **WHEN** neither `sha256sum` nor `shasum` is on the `PATH`
- **THEN** the tool reports `BLOCKED`, exits `2`, and the project is unchanged

#### Scenario: A failed write reports what was written

- **WHEN** two blocks are stale and writing the second fails
- **THEN** the tool reports `ERROR`, exits `1`, and the report states that the first was replaced

#### Scenario: Nothing to attend to

- **WHEN** every block the manifest lists is current
- **THEN** the report holds no `Attention:` line and the outcome is `SUCCESS`

### Requirement: Each block the manifest lists is classified from the project alone

An **opening marker** of a record is any line beginning `<!-- ai-toolkit:<name> `, with the record's name, or with its `alternative` as *A block is read under either variant* states — the prefix `scripts/project-init` reads a block's presence by, so the two tools agree on whether a block is present. A **well-formed** opening marker is exactly `<!-- ai-toolkit:<name> <version> sha256:<hash> -->`, with `<version>` of the form `MAJOR.MINOR.PATCH` and `<hash>` 64 lowercase hexadecimal digits, or exactly the earlier `<!-- ai-toolkit:<name> v<N> -->`, with `<N>` one or more digits. A **closing marker** is the line `<!-- /ai-toolkit:<name> -->`.

For each record in `rules/manifest`, in order, the tool SHALL determine exactly one state, the first of these that applies, and report it on one line beginning with the name of the variant it holds, or the record's name where it holds neither:

- `not writable` — the target, or the directory holding it, other than the project root's `AGENTS.md`, is a symbolic link or exists as something other than the file or directory the tool would write there;
- `single file` — the record is `backlog`, `docs/backlog/` does not exist and `docs/backlog.md` does;
- `legacy README` — the target's directory, other than the project root, holds `README.md`, and the target holds no opening marker of the record's name;
- `absent` — the target holds no opening marker of the record's name;
- `malformed` — the target holds more than one opening marker of the record's name, or its opening marker is not well-formed, or no closing marker of that name follows it;
- `legacy block` — the opening marker is the earlier form, `<!-- ai-toolkit:<name> v<N> -->`;
- `edited` — the SHA-256 digest of every line strictly between the opening and closing markers, each with its newline, differs from the hash the opening marker carries;
- `ahead` — the marker's version is greater than the fragment's;
- `current` — the marker's version equals the fragment's;
- `stale` — the marker's version is less than the fragment's.

Versions SHALL be compared numerically by major, then minor, then patch. A `v<N>` version is below every semantic version.

**The block alone decides** (`keep-projects-on-the-current-workflow`'s decision 4). The hash is recomputed from the lines the project holds, so no record file in the project and no history of past texts in the toolkit is needed; an edit is told from an older text by the hash, and an older text from a current one by the version. Edited comes before the version so that a block edited at the current version is not reported as current.

#### Scenario: An untouched block at the fragment's version is current

- **WHEN** a block was written by `project-init` from the fragment the tool reads, and not changed since
- **THEN** its line reports it current, with its version, and the target is byte-for-byte unchanged

#### Scenario: An edit at the current version is reported as an edit

- **WHEN** a block at the fragment's version has one line inside its markers changed
- **THEN** its line reports it edited, not current

#### Scenario: Versions compare by number, not by text

- **WHEN** a block untouched since it was written carries version `1.9.0` and the fragment carries `1.10.0`
- **THEN** its line reports it replaced, from `1.9.0` to `1.10.0`

#### Scenario: A block ahead of the toolkit

- **WHEN** an untouched block carries version `2.0.0` and the fragment carries `1.0.0`
- **THEN** its line reports it ahead of this toolkit, with both versions, and the target is byte-for-byte unchanged

#### Scenario: Two blocks of one name are malformed

- **WHEN** a target holds two opening markers of the record's name
- **THEN** its line reports the markers malformed, and the target is byte-for-byte unchanged

#### Scenario: A marker in neither form is malformed

- **WHEN** a target's opening marker reads `<!-- ai-toolkit:backlog 1.0 sha256:` followed by 64 lowercase hexadecimal digits and ` -->`, or `<!-- ai-toolkit:backlog 1.0.0 -->` with no hash
- **THEN** its line reports the markers malformed, not absent, and the target is byte-for-byte unchanged

#### Scenario: An opening marker without a closing one is malformed

- **WHEN** a target holds a record's opening marker and no closing marker of that name after it
- **THEN** its line reports the markers malformed, and the target is byte-for-byte unchanged

### Requirement: A stale block nobody edited is replaced, and nothing outside its markers changes

*Modified by `add-a-direct-workflow-variant`: a scenario holding a workflow block below `alternative_since` runs with `--workflow full`, as *A project states its workflow where its block predates the choice* requires. Every scenario keeps its title.*

For a `stale` record, the tool SHALL replace the lines from the opening marker to the closing marker, both included, with the block the toolkit writes today: the opening marker with the fragment's name, version and hash, the notice, the fragment's body without its frontmatter, and the closing marker, built exactly as `scripts/project-init` builds a block. Every byte before the opening marker's line and after the closing marker's line SHALL be unchanged. Where the root's `AGENTS.md` is a symbolic link, the tool SHALL write through it, as `project-init` appends through it; the file's permission bits SHALL be kept. The report line SHALL state the version replaced and the version written.

**Content outside the markers belongs to the project** (`project-bootstrap`'s *Workflow rules reach a project as a versioned managed block*). The hash proves nobody edited inside them, so replacing the inside discards nothing a project wrote, and an uncommitted edit outside them survives by construction.

#### Scenario: A stale block is brought current

- **WHEN** a block untouched since it was written carries a version below the fragment's
- **THEN** after the run the block's opening marker carries the fragment's version and a hash equal to the digest of the lines between the markers, the lines after the notice are the fragment's body byte for byte, and the report states both versions

#### Scenario: Project text around the block survives

- **WHEN** a stale block's target holds project text above the opening marker and below the closing marker, one of those lines not yet committed
- **THEN** after the run every line outside the markers is byte-for-byte what it was

#### Scenario: The replacement is project-init's block

- **WHEN** the tool replaces a stale block from a fragment
- **THEN** the lines from its opening marker to its closing marker equal those `scripts/project-init` writes from the same fragment into a new project, for every fragment the manifest lists and for a fragment whose body contains a `---` line and ends without a newline, both with `sha256sum` available and with only `shasum`

#### Scenario: Both tools agree on whether a block is present

- **WHEN** a target holds a line beginning `<!-- ai-toolkit:<name> ` in any of the forms *Each block the manifest lists is classified from the project alone* names, well-formed or not
- **THEN** `scripts/project-init` reports the block present exactly where `scripts/project-update` reports a state other than `absent`

#### Scenario: A second run changes nothing

- **WHEN** the tool runs twice in a row in a project holding stale blocks
- **THEN** the second run reports every block it replaced as current, and leaves every file byte-for-byte as the first run left it

#### Scenario: The file's mode is kept

- **WHEN** a stale block's target has permission bits `0640`
- **THEN** after the replacement its permission bits are `0640`

#### Scenario: A root AGENTS.md link is written through

- **WHEN** `project-update --workflow full` runs where the root's `AGENTS.md` is a symbolic link to a file holding a stale workflow block
- **THEN** the link is still a link to the same file, and that file holds the current block

### Requirement: An edited block is reported with its difference and never overwritten

For an `edited` record, the tool SHALL leave the target byte-for-byte unchanged and SHALL report, under the record's line, a unified diff of the lines currently between the markers against the lines the toolkit would write between them, each line of the diff indented. It SHALL offer no option that overwrites an edited block.

The tool SHALL likewise leave the target byte-for-byte unchanged for an `ahead`, `malformed` or `not writable` record.

**An edit the hash detects is never overwritten** (operator, 2026-10-28, `keep-projects-on-the-current-workflow`'s step 2). The project moves its own text outside the markers, or restores the block, and runs the tool again; the diff shows which.

#### Scenario: An edited block is left with its diff

- **WHEN** a block carries an older version and one line inside its markers was changed after it was written
- **THEN** the target is byte-for-byte unchanged, the record's line reports it edited with the version it carries and the version the toolkit carries, and the report holds a diff in which the changed line appears

#### Scenario: A target that is a link is left

- **WHEN** `docs/backlog/AGENTS.md` is a symbolic link to a file holding a stale backlog block
- **THEN** the link and the file it points to are unchanged, and the `backlog` line states the path is not one the tool writes into

#### Scenario: Other blocks proceed past an edited one

- **WHEN** the workflow block is edited and the backlog block is stale and untouched
- **THEN** the backlog block is replaced and the workflow block is unchanged

### Requirement: The shapes before 1.0.0 are converted only where git holds the original

*Modified by `add-a-direct-workflow-variant`: a scenario holding a legacy workflow block runs with `--workflow full`, as *A project states its workflow where its block predates the choice* requires, and that check comes first. Every scenario keeps its title.*

A `legacy block` and a `legacy README` carry no hash, so an edit in them cannot be detected. The tool SHALL convert them, and SHALL do so only where git holds what the conversion replaces: where any record is `legacy block` or `legacy README`, the tool SHALL report `BLOCKED` and write nothing unless the target is the top level of a git working tree with at least one commit, and every file the conversions would write or remove is tracked and identical, in the working tree and in the index, to its content at `HEAD`. Those files are, in manifest order and within a record in this order: the target of a `legacy block`; and, for a `legacy README`, the `README.md`, then the directory's `AGENTS.md` where it is present. A directory's `CLAUDE.md` is not among them, since the conversion never writes one that is present. Where the root's `AGENTS.md` holding a `legacy block` is a symbolic link, the file checked SHALL be the one it finally resolves to, following every link in a chain, which SHALL lie inside the working tree; a link resolving outside it, or a chain of more than eight links, SHALL block. The report SHALL name the first file, in that order, that fails, and for a link both the link and what it resolves to.

Where any record is `legacy block` or `legacy README`, the tool SHALL also report `BLOCKED` and write nothing where a `not writable` record's directory holds `README.md`: that directory's rules could not be converted in the same run.

Where no record is `legacy block` or `legacy README`, the tool SHALL require no git repository.

The tool SHALL convert:

- a `legacy block`, by replacing it as *A stale block nobody edited is replaced, and nothing outside its markers changes* replaces a stale block;
- a `legacy README`, by first writing the block into the directory's `AGENTS.md`, appended after a blank line to a file that exists and the file created otherwise, then treating the directory's `CLAUDE.md` as `project-bootstrap`'s *A directory's rules block is imported by a CLAUDE.md beside it* states, with the report's `directory import:` lines, and only then removing `README.md`, so that a failed write never leaves the directory without its rules.

Each converted record's line SHALL state the shape it was converted from, the version written, and that it was not checked for edits and `git diff` shows the conversion. Every legacy record in a run SHALL be converted in that run, so that a project never holds a root block at `1.0.0` or later beside a directory's rules in a README.

On `ERROR` during a conversion, the report SHALL name every file the run wrote, created or removed, marking each as one of: checked by the precondition above, which `git restore` returns to its state before the run; created by the run, which removing returns; or holding a hashed block already replaced, which needs nothing, since a re-run reports it `current` and `git restore` would discard uncommitted text outside its markers. From there a re-run converts again.

**Brought to `1.0.0` without reconciling by hand, recoverably** (`keep-projects-on-the-current-workflow`'s decisions 3 and 5). Refusing to convert without a hash would strand every adopting project before `1.0.0`; carrying every past text would be the history the workstream decided against. Requiring the original to be committed and unmodified keeps an edit the tool could not see one `git restore` away, and the conversion one `git diff` to review. The README is the toolkit's own earlier shape of the directory's rules, which the root block at `1.0.0` no longer sends any session to.

#### Scenario: A v12 workflow block is converted

- **WHEN** `project-update --workflow full` runs where a project's committed, unmodified `AGENTS.md` holds a `<!-- ai-toolkit:development-workflow v12 -->` block with project text below it
- **THEN** the block is replaced by the current workflow block, the project text is unchanged, and the report states it was converted from `v12`, not checked for edits, and to be reviewed with `git diff`

#### Scenario: A backlog README is converted

- **WHEN** `docs/backlog/` holds a committed, unmodified `README.md` and entry files, and no `AGENTS.md` or `CLAUDE.md`
- **THEN** `README.md` is gone, `docs/backlog/AGENTS.md` holds the backlog block, `docs/backlog/CLAUDE.md` holds exactly `@AGENTS.md`, every entry file is unchanged, and the report states the conversion and that it was not checked for edits

#### Scenario: An uncommitted legacy file blocks the whole run

- **WHEN** the root `AGENTS.md` holds a `v12` block and `docs/workstreams/README.md` has an uncommitted change
- **THEN** the tool reports `BLOCKED`, names `docs/workstreams/README.md`, and every file in the project is unchanged, the root block included

#### Scenario: An untracked legacy README blocks

- **WHEN** `docs/backlog/README.md` exists and is not tracked by git
- **THEN** the tool reports `BLOCKED`, names it, and writes nothing

#### Scenario: Legacy items outside a repository block

- **WHEN** the target holds a `v12` block and is not the top level of a git working tree
- **THEN** the tool reports `BLOCKED` and writes nothing

#### Scenario: A project with no legacy item needs no repository

- **WHEN** the target is not a git working tree and holds only hashed blocks, one of them stale
- **THEN** the stale block is replaced and the outcome is `SUCCESS`

#### Scenario: A staged change to a legacy file blocks

- **WHEN** the root `AGENTS.md` holds a `v12` block and has a change staged in the index but not committed
- **THEN** the tool reports `BLOCKED` and writes nothing

#### Scenario: A repository with no commit blocks a conversion

- **WHEN** the target holds a `v12` block and is the top level of a git working tree with no commit
- **THEN** the tool reports `BLOCKED` and writes nothing

#### Scenario: A root link resolving outside the working tree blocks

- **WHEN** the root `AGENTS.md` is a tracked symbolic link to a file outside the working tree, and that file holds a `v12` block
- **THEN** the tool reports `BLOCKED`, names the link and the file it resolves to, and neither is changed

#### Scenario: A chain of links resolving outside the working tree blocks

- **WHEN** the root `AGENTS.md` is a link to `conf/AGENTS.md` inside the working tree, itself a tracked link to a file outside it holding a `v12` block
- **THEN** the tool reports `BLOCKED`, names the file outside the working tree, and nothing is changed

#### Scenario: A root link resolving to a modified file blocks

- **WHEN** the root `AGENTS.md` is a symbolic link to a tracked file inside the working tree that holds a `v12` block and has an uncommitted change
- **THEN** the tool reports `BLOCKED`, names the file it resolves to, and writes nothing

#### Scenario: A README is converted into an existing AGENTS.md

- **WHEN** `docs/workstreams/` holds a committed, unmodified `README.md` and a committed, unmodified `AGENTS.md` of project text with no block
- **THEN** `AGENTS.md` holds its project text unchanged, followed by a blank line and the workstreams block, and `README.md` is gone

#### Scenario: A README beside a CLAUDE.md of the project's own

- **WHEN** `docs/backlog/` holds a committed, unmodified `README.md` and a `CLAUDE.md` holding other text, with an uncommitted change
- **THEN** the conversion proceeds, `CLAUDE.md` is byte-for-byte unchanged, and the report states the line `@AGENTS.md` to add to it

#### Scenario: A README the run cannot reach blocks a conversion

- **WHEN** the root `AGENTS.md` holds a `v12` block, and `docs/workstreams/` is a symbolic link to a directory holding `README.md`
- **THEN** the tool reports `BLOCKED` and writes nothing, the root block included

#### Scenario: A failed write during a conversion keeps the README

- **WHEN** writing `docs/backlog/AGENTS.md` fails during a README conversion
- **THEN** the tool reports `ERROR`, `docs/backlog/README.md` is still present, and the report names every file the run wrote, created or removed

### Requirement: A block the project lacks is named, not written

For an `absent` record the tool SHALL write nothing and its line SHALL name the `scripts/project-init` in its own copy of the library as what writes the block. For a `single file` record it SHALL write nothing and its line SHALL name the `scripts/backlog-migrate` in its own copy. The tool SHALL NOT create a `.gitignore`, a repository, specification tooling, or a block for an `absent` record.

**Writing a block a project never had is initialization.** `project-init` already places blocks into every shape a project can be in, with the checks those shapes need; a second writer of first blocks would be a second implementation of them.

#### Scenario: A missing workstreams directory is named

- **WHEN** the project holds the workflow and backlog blocks and no `docs/workstreams/`
- **THEN** `docs/workstreams/` is still absent after the run, and the `workstreams` line names `scripts/project-init`

#### Scenario: A single-file backlog is named

- **WHEN** the project holds `docs/backlog.md` and no `docs/backlog/`
- **THEN** `docs/backlog.md` is unchanged, nothing is created under `docs/backlog/`, and the `backlog` line names `scripts/backlog-migrate`

### Requirement: A block is read under either variant

For a record with an `alternative`, the tool SHALL read a target holding the alternative's marker as holding that variant: its markers, version and hash are the alternative's, and the state, the report line, `Attention:` and any replacement use the alternative's name and fragment. A target holding opening markers of both SHALL be `malformed` under the record's name, and neither SHALL be replaced. An `edited` block's difference SHALL be taken against the fragment of the variant it holds.

The variant a marker names SHALL be kept. Without `--workflow`, a run SHALL NOT turn one variant into the other.

#### Scenario: A stale direct block stays direct

- **WHEN** a project holds an unedited `development-workflow-direct` block below that fragment's version
- **THEN** the block is replaced with the current `rules/development-workflow-direct.md` text under that marker, and no `development-workflow` block appears

#### Scenario: A current direct block is current

- **WHEN** a project holds an unedited `development-workflow-direct` block at that fragment's version
- **THEN** its line reads `current` under the name `development-workflow-direct` and nothing is written

#### Scenario: Both variants in one target

- **WHEN** a target holds a `development-workflow` block and a `development-workflow-direct` block
- **THEN** the record is `malformed` and neither block changes

### Requirement: A project states its workflow where its block predates the choice

A fragment MAY carry `alternative_since: <version>` in its frontmatter: the first version at which a project chooses between that fragment and its alternative. `rules/development-workflow.md` SHALL carry it at `2.0.0`.

Where a record's own block is `stale` or `legacy block` at a version below `alternative_since`, and no `--workflow` was given, the tool SHALL report `BLOCKED`, write nothing to any record, and name both `--workflow full` and `--workflow direct` and what each does. This check SHALL come before every write and before every git precondition of *The shapes before 1.0.0 are converted only where git holds the original*, so that an old project is asked for its choice first and meets those preconditions on the run that states it. A block in any other state owes no choice: an `edited` or `malformed` one is never replaced, so it stays `SUCCESS` with `Attention:` and needs no flag to stay safe.

`--workflow full` selects the record's own fragment and `--workflow direct` its alternative. Any other value SHALL produce `BLOCKED` before anything is written. Given a value, the tool SHALL bring the block to the selected fragment: a `stale` or `legacy block` is replaced or converted as those requirements state, under the selected fragment's marker; a block already at the selected variant follows its state as usual; and a `current` block of the other variant SHALL be replaced in the same way. Every replacement or conversion that crosses variants SHALL name both variants on its line. `edited`, `ahead` and `malformed` blocks SHALL be reported and left, whichever is selected. Where the record is `absent` and a value was given, its line SHALL name `scripts/project-init --workflow <value>`.

**A block written before the choice says nothing about which the project wants** (operator, 2026-11-01). The default for a new project is the promoting workflow, but a `1.0.0` block was written by a tool with one workflow, so reading it as a choice of `full` would give `infrastructure` promotion rules it does not want, silently, by the replacement a major version is meant to stop for. Blocking the run keeps a project from being half converted where anything would have been replaced.

#### Scenario: An old block blocks until chosen

- **WHEN** `project-update` runs with no `--workflow` in a project holding `development-workflow` at `1.0.0`
- **THEN** the outcome is `BLOCKED`, the report names `--workflow full` and `--workflow direct`, and no file changes, including a stale backlog block

#### Scenario: A legacy block blocks until chosen

- **WHEN** `project-update` runs with no `--workflow` in a project holding `development-workflow v12`
- **THEN** the outcome is `BLOCKED` and no file changes

#### Scenario: The choice is asked before a git precondition

- **WHEN** `project-update` runs with no `--workflow` in a project holding `development-workflow v12` whose `AGENTS.md` has an uncommitted change
- **THEN** the outcome is `BLOCKED`, and the report names `--workflow full` and `--workflow direct` and does not name the git precondition

#### Scenario: Full is chosen

- **WHEN** `project-update --workflow full` runs in a project holding an unedited `development-workflow` at `1.0.0`
- **THEN** the block is the current `rules/development-workflow.md` text, and the rest of the run proceeds

#### Scenario: Direct is chosen for an old block

- **WHEN** `project-update --workflow direct` runs in a project holding an unedited `development-workflow` at `1.0.0`
- **THEN** the file holds one block, under `development-workflow-direct`, with that fragment's text, every byte outside it is unchanged, and its line names both variants

#### Scenario: A legacy block is converted to the chosen variant

- **WHEN** `project-update --workflow direct` runs in a project holding `development-workflow v12` with the git preconditions met
- **THEN** the block is converted under `development-workflow-direct`, and its line states it was not checked for edits

#### Scenario: A project already chosen is not asked again

- **WHEN** `project-update` runs with no `--workflow` in a project holding `development-workflow` at or above `2.0.0`, or `development-workflow-direct` at any version
- **THEN** the run proceeds as usual

#### Scenario: A later switch

- **WHEN** `project-update --workflow full` runs in a project holding an unedited, current `development-workflow-direct` block
- **THEN** the file holds one block, under `development-workflow`, and its line names both variants

#### Scenario: An edited block is not switched

- **WHEN** `project-update --workflow direct` runs in a project whose `development-workflow` block has been edited
- **THEN** the block is reported as edited and left unchanged

#### Scenario: An edited old block owes no choice

- **WHEN** `project-update` runs with no `--workflow` in a project whose `development-workflow` block at `1.0.0` has been edited and whose backlog block is stale
- **THEN** the outcome is `SUCCESS`, `Attention:` names `development-workflow`, and the backlog block is replaced

#### Scenario: A block ahead is not downgraded

- **WHEN** `project-update --workflow direct` runs in a project whose unedited `development-workflow` block is newer than the toolkit's
- **THEN** the block is reported as ahead and left unchanged

#### Scenario: A choice for an absent block is carried to project-init

- **WHEN** `project-update --workflow direct` runs in a project with no workflow block
- **THEN** nothing is written for that record and its line names `scripts/project-init --workflow direct`

#### Scenario: A missing alternative blocks

- **WHEN** the manifest names an `alternative` whose fragment is missing, or `alternative_since` is absent or not `MAJOR.MINOR.PATCH` where `alternative` is present
- **THEN** the outcome is `BLOCKED` and the project is unchanged

#### Scenario: An unknown value blocks

- **WHEN** `project-update --workflow staged` runs
- **THEN** the outcome is `BLOCKED`, the report names `full` and `direct`, and nothing is written
