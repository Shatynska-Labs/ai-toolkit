## MODIFIED Requirements

### Requirement: Documentation separation of concerns

*Modified by `one-file-per-backlog-entry`: shipped tooling admits `scripts/seed/`, the texts the shipped tools write verbatim into a project. Every scenario keeps its title.*

Repo-level conventions SHALL live in `AGENTS.md`, and `CLAUDE.md` SHALL consist of a single `@AGENTS.md` import so the conventions have exactly one source of truth.

`AGENTS.md` SHALL state the layout, the constraint that makes each asset type flat, the tags convention, and the naming rules. It MUST NOT carry authoring standards for producing an asset; those belong with the asset type's authoring skill, which `AGENTS.md` MAY reference by path.

`AGENTS.md` SHALL distinguish three categories:

- **Library assets** — `skills/`, `agents/`, and `rules/`, which ship in the plugin and are the library's substance.
- **Shipped tooling** — `scripts/`, holding executables that ship with the library and are runnable directly, without any agent harness. These are not assets: nothing discovers them, they carry no frontmatter, and they are reached by path or by `--help` rather than by description. Its one subdirectory of non-executables, `scripts/seed/`, holds the texts the shipped tools write into a project verbatim — the backlog's README, written by `scripts/project-init` and `scripts/backlog-migrate` alike — so that two tools writing one text read it from one place.
- **Repository tooling** — `.claude/`, holding configuration for working in this repository, which is not part of the library.

`AGENTS.md` SHALL state what belongs in `scripts/`: the deterministic half of a workflow, where an operation has exactly one correct outcome and therefore should not be re-derived by a model. A capability requiring judgment belongs in a skill or agent, not in `scripts/`.

`AGENTS.md` SHALL state what `scripts/seed/` holds and why it is not `rules/`: a rule fragment carries `kind` frontmatter and is read, imported or inlined as instructions, whereas a seed is written byte for byte as a file the project then owns, and frontmatter of the library's own would be written into it.

Because `scripts/` conventionally names a repository's internal helpers, `AGENTS.md` SHALL state explicitly that its contents ship with the library and are intended to be run by its consumers. Tooling used only for working *on* this repository belongs in `.claude/`, not here.

#### Scenario: Claude Code picks up conventions

- **WHEN** Claude Code loads project memory for this repository
- **THEN** `CLAUDE.md` imports `AGENTS.md`, and the conventions take effect without a second copy existing

#### Scenario: Layout constraint is explained, not just stated

- **WHEN** a reader asks why no asset type uses grouping directories
- **THEN** `AGENTS.md` gives the discovery and naming constraints as the reason, so the rule is not mistaken for arbitrary preference

#### Scenario: Library assets are distinguished from repository tooling

- **WHEN** an agent working in this repository needs to place a new library skill, and `.claude/skills/` already exists holding this repository's own tooling
- **THEN** `AGENTS.md` makes `skills/` the destination for library assets, so an asset meant to ship in the plugin is not written into `.claude/` where it would work locally and never ship

#### Scenario: Authoring guidance is not duplicated into conventions

- **WHEN** a reader looks for the rules on writing a skill's frontmatter well
- **THEN** `AGENTS.md` does not restate them, and points to the authoring standard instead

#### Scenario: A deterministic operation is placed in shipped tooling

- **WHEN** a capability is added whose steps have exactly one correct outcome and require no judgment
- **THEN** `AGENTS.md` makes `scripts/` its destination, and any skill wrapping it calls it rather than restating what it does

#### Scenario: Shipped tooling is distinguished from repository helpers

- **WHEN** a reader familiar with the common use of `scripts/` assumes its contents are internal development helpers
- **THEN** `AGENTS.md` states that these executables ship with the library and are meant to be run by consumers, and names `.claude/` as the home for tooling used only to work on this repository

#### Scenario: Shipped tooling is not mistaken for an asset

- **WHEN** a reader enumerates the library's assets
- **THEN** `scripts/` is excluded, because nothing discovers its contents by description and they carry no asset frontmatter

#### Scenario: A text two tools write has one home

- **WHEN** a reader looks for the text `scripts/project-init` and `scripts/backlog-migrate` both write as a project's `docs/backlog/README.md`
- **THEN** `AGENTS.md` places it under `scripts/seed/`, and states why it is not a `rules/` fragment
