## MODIFIED Requirements

### Requirement: Repository is an installable plugin

*Modified by `list-what-a-project-receives`: `plugin.json` declares a semantic `version`, `1.0.0` from the release that introduces the manifest. *The plugin carries a semantic version* is added; every other scenario keeps its title.*


The repository SHALL be a Claude Code plugin. It SHALL contain `.claude-plugin/plugin.json` declaring at least `name` and `version`, the version in the form `MAJOR.MINOR.PATCH` and never below `1.0.0`, where it started in the release that introduced `rules/manifest`, and SHALL contain `.claude-plugin/marketplace.json` describing a single-plugin marketplace so the repository can be added by local path.

Component directories SHALL reside at the plugin root — the directory containing `.claude-plugin/` — and MUST NOT be placed inside `.claude-plugin/`. The plugin root SHALL be the repository root if a marketplace entry sourced at `"./"` is accepted; otherwise the plugin root is the subdirectory the marketplace entry points at, and the shape actually used SHALL be recorded in `design.md`.

#### Scenario: The plugin carries a semantic version

- **WHEN** `.claude-plugin/plugin.json` is read
- **THEN** its `version` has the form `MAJOR.MINOR.PATCH` and is not below `1.0.0`

#### Scenario: Repository is installed as a plugin

- **WHEN** a user adds this repository's local path as a marketplace and installs the plugin
- **THEN** the plugin's skills and agents become available in the consuming project without any file being copied into that project

#### Scenario: Manifest placement

- **WHEN** the repository is inspected
- **THEN** `plugin.json` and `marketplace.json` are inside `.claude-plugin/`, while `skills/`, `agents/`, and `rules/` sit beside `.claude-plugin/` at the plugin root rather than inside it

#### Scenario: Development without installing

- **WHEN** an asset is being edited and needs testing before commit
- **THEN** the repository can be loaded directly with `claude --plugin-dir <repo path>`, requiring no install step

#### Scenario: Packaging is verified, not assumed

- **WHEN** the manifests are written
- **THEN** the plugin is installed and a component is confirmed to load from it before any asset is authored against the layout

#### Scenario: Verification observes a component, not just the plugin

- **WHEN** the packaging is checked and the library ships no assets of its own
- **THEN** a throwaway asset is added, observed to load as a component of this plugin, and removed — because a structurally wrong manifest installs without error and simply carries nothing, which an "the plugin appears" check cannot distinguish from success

### Requirement: One directory level for every asset type

*Modified by `list-what-a-project-receives`: a fragment's `version` is `MAJOR.MINOR.PATCH`, and `rules/` holds one file that is not a fragment, the manifest. *The manifest is the one file in rules/ that is not a fragment* is added; every other scenario keeps its title.*


Assets SHALL be placed at exactly one directory level, with no grouping directories:

- `skills/<skill-name>/SKILL.md`
- `agents/<agent-name>.md`
- `rules/<rule-name>.md`

A skill's `SKILL.md` MUST reside directly inside the skill's own directory, which MUST reside directly inside `skills/`. Agent and rule files MUST reside directly inside `agents/` and `rules/` respectively.

`rules/` SHALL hold reusable markdown fragments consumed by reference or by a shipped tool reading them. A fragment SHALL declare its kind in YAML frontmatter at the top of the file, and a fragment that is inlined into a consuming project SHALL additionally declare its version:

```yaml
---
kind: standing-constraint    # or: procedural-checklist
version: 1.0.0               # inlined fragments only: MAJOR.MINOR.PATCH
---
```

The two kinds are:

- a **standing constraint**, intended to reach a consuming project's `CLAUDE.md` or `AGENTS.md` and remain in force there; or
- a **procedural checklist**, describing a one-time procedure, read on demand and NOT intended for a project's conventions file.

`version` is the fragment's own, a semantic version, and is unrelated to any package or plugin version: the plugin's version names a release, and a fragment's names what changed in that fragment. The form is fixed here rather than in a design document because this requirement outlives the change that introduces it, and a normative obligation deferred to an archived file cannot be checked afterwards. When it increments is NOT fixed here: that obligation belongs to `project-bootstrap`'s requirement "The fragment's version increments when its body changes", which owns it because the increment exists to make a project's inlined copy distinguishable from a current one, and only the capability that inlines the fragment can say which part of it a project actually carries. The deferral covers every fragment this repository inlines, not only the workflow rule fragment that occasions it: an inlined fragment's increment condition is the body-scoped one `project-bootstrap` states, whatever the fragment. This clause states where the rule lives so that an author checking a fragment edit reaches one answer rather than two.

The distinction is behavioral rather than cosmetic: inlining a one-time procedure into a project's conventions file would leave permanent instructions for work already finished, while leaving a standing constraint unimported would mean it never takes effect.

`rules/` SHALL also hold `rules/manifest`, which lists the fragments a shipped tool writes into a project as managed blocks and where, as `project-bootstrap` states. Besides `rules/README.md`, which describes the directory, it is the one file in `rules/` that is not a fragment: it carries no frontmatter and no `.md` extension, and it is read by tools, never imported or inlined. It is a delivery list, not the asset index *Repository is browsable without an index* forbids: no asset loads or is found through it, and browsing the library never reads it; it says only which fragments `scripts/project-init` writes into a project.

A placeholder document standing in for an unpopulated directory MUST NOT be discoverable as an asset. Since every `.md` file directly inside `agents/` is read as an agent definition — including one whose name begins with a dot — a placeholder there SHALL take a non-`.md` extension, which is the form discovery ignores.

#### Scenario: Placing a new skill

- **WHEN** a skill named `create-skill` is added
- **THEN** its definition resides at `skills/create-skill/SKILL.md`

#### Scenario: Skill placed too deep is undiscoverable

- **WHEN** a `SKILL.md` is placed with any directory between `skills/` and the skill's own directory
- **THEN** the layout is invalid, because discovery does not descend that far and the skill would fail to load with no error reported

#### Scenario: Agent invocation name carries no grouping

- **WHEN** an agent named `commit-message` is added
- **THEN** its definition resides at `agents/commit-message.md` and it is invoked as `ai-toolkit:commit-message`, so reclassifying it later does not rename it

#### Scenario: Names are unique per directory

- **WHEN** an asset is proposed with a name already used in the same directory
- **THEN** the name collision is resolved before the asset is added, since a flat directory cannot hold two assets of the same name

#### Scenario: Placeholders for unpopulated directories

- **WHEN** `skills/`, `agents/`, and `rules/` exist but contain no assets
- **THEN** each contains a short placeholder document stating what belongs in it, so the documented layout is true from the first commit

#### Scenario: A placeholder is not mistaken for an asset

- **WHEN** the plugin carrying an `agents/` placeholder is installed
- **THEN** no agent originating from that placeholder is exposed, and no parse failure is reported for it

#### Scenario: A non-`.md` file beside an agent is not an asset

- **WHEN** a file that is not a `.md` document sits directly inside `agents/` beside an agent definition
- **THEN** it is neither discovered as an agent nor reported as a parse failure, because the extension rather than the depth is what discovery selects on

#### Scenario: A procedural fragment is not inlined into a project

- **WHEN** a fragment describing a one-time procedure is added to `rules/`
- **THEN** it states that it is a procedural checklist, and nothing inlines it into a consuming project's conventions file

#### Scenario: The manifest is the one file in rules/ that is not a fragment

- **WHEN** a reader lists `rules/`
- **THEN** every `.md` file in it other than `README.md` is a fragment declaring its `kind`, and `manifest` is the one file that is neither

#### Scenario: The increment rule has exactly one owner

- **WHEN** an author editing a rule fragment needs to know whether to increment its `version`
- **THEN** this requirement names `project-bootstrap` as the owner of that obligation and states no competing condition of its own, so the two capabilities cannot give divergent answers for the same edit

### Requirement: Documentation separation of concerns

*Modified by `one-file-per-backlog-entry`: shipped tooling admits `scripts/seed/`, the texts the shipped tools write verbatim into a project. Every scenario keeps its title.*

*Modified by `list-what-a-project-receives`: `scripts/seed/` is removed; every rule text a shipped tool writes into a project is a `rules/` fragment the manifest lists. Every scenario keeps its title; *A text two tools write has one home* now reads as the one home of a text any tool writes, `scripts/project-init` being the one that writes it today.*

Repo-level conventions SHALL live in `AGENTS.md`, and `CLAUDE.md` SHALL consist of a single `@AGENTS.md` import so the conventions have exactly one source of truth.

`AGENTS.md` SHALL state the layout, the constraint that makes each asset type flat, the tags convention, and the naming rules. It MUST NOT carry authoring standards for producing an asset; those belong with the asset type's authoring skill, which `AGENTS.md` MAY reference by path.

`AGENTS.md` SHALL distinguish three categories:

- **Library assets** — `skills/`, `agents/`, and `rules/`, which ship in the plugin and are the library's substance.
- **Shipped tooling** — `scripts/`, holding executables that ship with the library and are runnable directly, without any agent harness. These are not assets: nothing discovers them, they carry no frontmatter, and they are reached by path or by `--help` rather than by description.
- **Repository tooling** — `.claude/`, holding configuration for working in this repository, which is not part of the library.

`AGENTS.md` SHALL state what belongs in `scripts/`: the deterministic half of a workflow, where an operation has exactly one correct outcome and therefore should not be re-derived by a model. A capability requiring judgment belongs in a skill or agent, not in `scripts/`.

`AGENTS.md` SHALL state that every rule text a shipped tool writes into a project is a `rules/` fragment, written as a managed block without its frontmatter, and that `rules/manifest` lists which fragments are written and where. A rule text kept anywhere else would be one no update could reach, since an update replaces what the manifest lists. What a tool writes once and the project then owns — the ignore file, and the one line `@AGENTS.md` in a directory's `CLAUDE.md` — is not a rule text and stays in the tool.

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

- **WHEN** a reader looks for the text a shipped tool writes as the block in a project's `docs/backlog/AGENTS.md`
- **THEN** `AGENTS.md` places it in `rules/`, as the fragment the manifest names, and no copy of it exists under `scripts/`
