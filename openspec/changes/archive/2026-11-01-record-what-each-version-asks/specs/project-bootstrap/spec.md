## MODIFIED Requirements

### Requirement: The fragment's version increments when its body changes

*Modified by `list-what-a-project-receives`: the version is `MAJOR.MINOR.PATCH`, the part raised says what a project must do, and every fragment carrying a version starts at `1.0.0`. The scenarios keep their titles; *Which part rises is decided by what the project must do* and *A legacy version reads as older* are added.*

*Modified by `record-what-each-version-asks`: a rise above `1.0.0` owes its record in `rules/changelog`. The scenarios keep their titles; *A version rise carries its changelog record* is added.*

A rule fragment's `version` SHALL be a semantic version, `MAJOR.MINOR.PATCH`, and SHALL rise whenever the body text inlined into a project changes. This holds for every fragment the manifest lists and for any fragment carrying a version. It SHALL NOT rise for a change confined to the fragment's own frontmatter, and it SHALL NOT remain unchanged across a body edit.

The part that rises SHALL be decided by what the edit asks of a project: **PATCH** where the wording changes and no obligation does; **MINOR** where an obligation is added or changed and the project need do nothing by hand to meet it; **MAJOR** where the project must do something by hand — move a file, rewrite an entry, adopt a text outside the block. A major version always asks something by hand and a minor or patch never does, so a later tool can decide from the versions alone whether to list steps for the operator. Raising one part resets the parts after it to zero.

Every fragment version above `1.0.0` SHALL have its record in `rules/changelog` in the form `project-update`'s *A run says what each version it crossed asks* states, added in the edit that raises it. A version without one is a step no project is told about.

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

#### Scenario: A version rise carries its changelog record

- **WHEN** a fragment in `rules/` carries a version above `1.0.0`
- **THEN** `rules/changelog` holds exactly one record of that fragment at that version, every major version from `2.0.0` up to that version has a record, and every record names a fragment in `rules/` at a version no higher than that fragment's
