## ADDED Requirements

### Requirement: A project chooses its workflow when it is initialized

`scripts/project-init` SHALL accept `--workflow <full|direct>`, default `full`, and SHALL document it in `--help`. `full` writes the first record's own fragment and `direct` its alternative. Any other value SHALL produce `BLOCKED` before anything is written.

A block is present in a target where it holds an opening marker of the record's name or of its alternative's. Where one is present, the tool SHALL write neither, and SHALL report it as it reports any block it finds, with the root line `conventions file: block already present` naming `development-workflow-direct` where that is what it holds, and comparing its version against the fragment of the variant it holds; where both are present, it SHALL write neither and report both names. Where `--workflow` was given and names the other one, the report SHALL also name `scripts/project-update --workflow` as what switches it, and the tool SHALL NOT change the block.

A fragment an `alternative` names SHALL count as a fragment the manifest lists: where it is missing, or lacks a `kind` or a `MAJOR.MINOR.PATCH` version, the tool SHALL report `BLOCKED` whichever variant was selected.

**The promoting workflow is the default** (operator, 2026-11-01). A project that runs a product has staging and promotes to production, so that is what a project gets without asking; a repository with no production, or whose job is that every server runs, asks for `direct`.

#### Scenario: A new project gets the promoting workflow

- **WHEN** `project-init` runs with no `--workflow` in a new project
- **THEN** `AGENTS.md` holds a `development-workflow` block with the text of `rules/development-workflow.md`, and no `development-workflow-direct` block

#### Scenario: Direct is asked for

- **WHEN** `project-init --workflow direct` runs in a new project
- **THEN** `AGENTS.md` holds a `development-workflow-direct` block with the text of `rules/development-workflow-direct.md`, and no `development-workflow` block

#### Scenario: A missing alternative blocks

- **WHEN** the manifest names an `alternative` whose fragment that copy does not hold
- **THEN** the outcome is `BLOCKED` and nothing is written, with or without `--workflow`

#### Scenario: An unknown value blocks

- **WHEN** `project-init --workflow staged` runs
- **THEN** the outcome is `BLOCKED`, the report names `full` and `direct`, and nothing is written

#### Scenario: A project holding one never receives the other

- **WHEN** `project-init` runs in a project whose `AGENTS.md` holds a `development-workflow-direct` block
- **THEN** no `development-workflow` block is written and the existing block is unchanged

#### Scenario: A direct block is compared with its own fragment

- **WHEN** `project-init` runs in a project holding `development-workflow-direct` at that fragment's version
- **THEN** the report reads it as matching, names `development-workflow-direct`, and does not say to bring it current

#### Scenario: A contrary choice is reported, not applied

- **WHEN** `project-init --workflow full` runs in a project holding a `development-workflow-direct` block
- **THEN** the block is unchanged and the report names `scripts/project-update --workflow`

## MODIFIED Requirements

### Requirement: A project receives exactly the blocks the manifest lists

*Modified by `add-a-direct-workflow-variant`: a record may name an alternative fragment, and a project holds one of the two. Every scenario keeps its title.*

The library SHALL carry a manifest at `rules/manifest` listing every managed block a shipped tool writes into a project. It SHALL hold one record per block, records separated by a line `---`, in the order the tool writes them, each with `name` and `target`: `name`, which is both the name in the block's markers and the fragment `rules/<name>.md` the block is read from; and `target`, the path of the `AGENTS.md` the block is written into, relative to the project root. It SHALL be written in the flat subset of YAML the backlog's entries use, so that a shell reads it with nothing installed.

The manifest SHALL list, as its first three records: `development-workflow` into `AGENTS.md`; `backlog` into `docs/backlog/AGENTS.md`; and `workstreams` into `docs/workstreams/AGENTS.md`. A later change may add a record after them.

A record MAY carry a third key, `alternative`, naming a second fragment `rules/<alternative>.md` that is written into the same target in the record's place. A project holds at most one of the two, and the marker it holds says which. `alternative` is what a project chooses between, not a block of its own, so it adds no record.

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
