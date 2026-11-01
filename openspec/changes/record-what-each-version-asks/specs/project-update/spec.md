## ADDED Requirements

### Requirement: A run says what each version it crossed asks

The library SHALL ship `rules/changelog`. For each fragment version above `1.0.0` it SHALL hold one record of `---`-separated `key: value` lines: `name`, the fragment, in kebab-case; `version`, a `MAJOR.MINOR.PATCH` above `1.0.0`; `changed`, one line stating what the version changed; and one `ask` line for each thing a project must do by hand. A major version's record, one whose minor and patch are both zero, SHALL hold at least one `ask`; any other record SHALL hold none.

Where a run replaces a block or converts a `legacy block` or `legacy README`, the tool SHALL print, directly beneath that record's line, each changelog record of the fragment written whose version is above the version the project held and at or below the version written, oldest first by numeric comparison, except those whose version is a patch. Each SHALL print one indented line `<version>: <changed>`, followed by one indented line `<version> by hand: <ask>` for each `ask`, in the record's order. A block converted from a `v<N>` version or from a `README.md`, and a block crossing variants, SHALL count as held at `1.0.0`, the crossing's records being those of the variant it arrives at.

For each major version `M.0.0` above the version held, at or below the version written, with no record, the tool SHALL print one indented line stating that no record says what `M.0.0` asks, in version order among the lines above.

The tool SHALL print no changelog line for a block it did not replace or convert. These lines SHALL NOT change the outcome or the `Attention:` line, and `--help` SHALL describe them.

**A major lists what only a person can do** (`keep-projects-on-the-current-workflow`'s decision 2). The version alone says whether to print: a patch is replaced silently, a minor says what changed, a major lists the steps. Records begin above `1.0.0` because every fragment started there and it asked nothing; a conversion is what the shapes before it needed. The two variants' versions are separate lines, so a crossing reads the line it arrives on from its floor: a step shown twice costs a line, and a step never shown cannot be recovered, since the next run reports `current`.

#### Scenario: A major prints what it changed and what it asks

- **WHEN** a run replaces an unedited block from a version below a major version whose record holds two `ask` lines
- **THEN** beneath the block's line the report holds the record's `changed` line and one `by hand` line for each `ask`, in the record's order

#### Scenario: A minor prints what changed

- **WHEN** a run replaces an unedited block across a minor version whose record holds no `ask`
- **THEN** beneath the block's line the report holds that record's `changed` line and no `by hand` line

#### Scenario: A patch prints nothing

- **WHEN** a run replaces an unedited block across a patch version only
- **THEN** the report holds no line from that record

#### Scenario: Every version crossed is printed, oldest first by number

- **WHEN** a run replaces an unedited block held at `1.9.0` where the changelog holds that fragment's `1.10.0` and `2.0.0`
- **THEN** the `1.10.0` lines precede the `2.0.0` lines, and no record at or below `1.9.0`, above the version written, or of another fragment is printed

#### Scenario: A conversion counts as coming from 1.0.0

- **WHEN** `project-update --workflow full` converts a `development-workflow v12` block, and in the same run a `workstreams` README is converted
- **THEN** beneath each line the report holds that fragment's `2.0.0` lines

#### Scenario: A direct block reads its own records

- **WHEN** a run replaces an unedited `development-workflow-direct` block across a version the changelog records under that name, and the changelog holds a record of the same version under `development-workflow`
- **THEN** only the record under `development-workflow-direct` is printed

#### Scenario: A crossing prints the records of the variant it arrives at

- **WHEN** `project-update --workflow full` replaces an unedited, current `development-workflow-direct` block
- **THEN** beneath the line naming both variants the report holds every `development-workflow` record above `1.0.0` that is not a patch

#### Scenario: A crossing onto a variant with no record prints none

- **WHEN** `project-update --workflow direct` replaces an unedited `development-workflow` block or converts a `development-workflow v12` block, and `development-workflow-direct` is at `1.0.0` with no record
- **THEN** the report holds no changelog line for that block

#### Scenario: A block not written prints no record

- **WHEN** a block below a recorded major version is edited, ahead, malformed or current
- **THEN** the report holds no changelog line for it

#### Scenario: A second run prints nothing

- **WHEN** the tool runs twice in a row in a project holding a block below a recorded major version
- **THEN** the first report holds the record's lines and the second holds none

#### Scenario: A major without a record says so

- **WHEN** a run replaces an unedited block across a major version the changelog does not record
- **THEN** beneath the block's line one line states that no record says what that version asks, and the outcome is `SUCCESS`

#### Scenario: A recorded major does not hide an unrecorded one

- **WHEN** a run replaces an unedited block held at `1.0.0` with a fragment at `3.0.0`, where the changelog records that fragment's `2.0.0` and not its `3.0.0`
- **THEN** the report holds the `2.0.0` lines and a line stating that no record says what `3.0.0` asks

#### Scenario: Help describes the changelog lines

- **WHEN** `scripts/project-update --help` is run
- **THEN** it states that a run prints what the versions it crossed changed and ask by hand

#### Scenario: The shipped records are printed for a project below them

- **WHEN** `project-update --workflow full` runs from this repository's copy in a project whose `development-workflow` and `workstreams` blocks are unedited at `1.0.0`
- **THEN** the report holds a `2.0.0 by hand` line beneath each

## MODIFIED Requirements

### Requirement: Every run ends in one of three outcomes, and the exit code agrees

*Modified by `record-what-each-version-asks`: `rules/changelog` joins what a run reads before anything else. Every scenario keeps its title; *A missing changelog blocks* and *A malformed changelog record blocks* are added.*

Each run SHALL end in exactly one of `SUCCESS`, exit code `0`; `ERROR`, a write attempted and failed, exit code `1`; or `BLOCKED`, a precondition unmet and nothing written, exit code `2` — `scripts/project-init`'s outcomes and codes. The outcome SHALL be stated in the report, with a reason for `ERROR` and `BLOCKED`.

The tool SHALL report `BLOCKED` and write nothing where the target is unusable; where `rules/manifest`, or a fragment it lists, is missing, or a fragment lacks a `kind` or a `MAJOR.MINOR.PATCH` version, whether or not that record would be written, a fragment an `alternative` names counting as listed; where a record with an `alternative` lacks a `MAJOR.MINOR.PATCH` `alternative_since`; where `rules/changelog` is missing or holds a record *A run says what each version it crossed asks* does not allow; where `--workflow` holds a value other than `full` or `direct`; where a choice is owed, as *A project states its workflow where its block predates the choice* states; where neither `sha256sum` nor `shasum` is available; or where a precondition *The shapes before 1.0.0 are converted only where git holds the original* states is unmet. Every precondition SHALL be checked before the first write. On `ERROR`, the report SHALL state what was already written.

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

#### Scenario: A missing changelog blocks

- **WHEN** the tool runs from a copy that holds no `rules/changelog`
- **THEN** it reports `BLOCKED`, exits `2`, and the project is unchanged

#### Scenario: A malformed changelog record blocks

- **WHEN** a record in `rules/changelog` has no kebab-case `name`, no `changed`, or a `version` that is not `MAJOR.MINOR.PATCH` above `1.0.0`; or is a major with no `ask`; or is a minor or patch with one
- **THEN** the tool reports `BLOCKED`, exits `2`, and the project is unchanged
