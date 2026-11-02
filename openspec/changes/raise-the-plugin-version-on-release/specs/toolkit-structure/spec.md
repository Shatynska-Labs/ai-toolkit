## ADDED Requirements

### Requirement: The plugin's version rises with what it ships

A pull request whose diff changes a path under `skills/`, `agents/`, `rules/` or `scripts/` SHALL raise the `version` in `.claude-plugin/plugin.json`, so that `/plugin update` finds what it ships. A diff changing none of them MAY leave the version alone. The diff is read against the point where the branch left the trunk, and the raised version SHALL also be above the version at the trunk's tip, so that two branches cannot ship under one number. The size of the rise SHALL be measured from the higher of the two versions. A fragment's version remains its own number, as *One directory level for every asset type* states: a fragment's rise sets a floor on the plugin's rise and nothing more.

A major rise SHALL be made where a project or a caller must do something by hand, a minor rise for a new capability or a changed obligation needing no edit, and a patch rise otherwise. The repository's test suite SHALL refuse a diff in which the rise is smaller than the diff requires: a major where a fragment in `rules/` rises a major version, or a skill, agent, script or fragment is removed or renamed; at least a minor where a fragment rises a minor version, or a skill, agent, script or fragment is added. What no diff shows, whether a change inside a script or a skill is a fix or a new behaviour, SHALL be the author's judgement, stated in `AGENTS.md` with the meanings of the three sizes.

#### Scenario: A shipped change without a rise is refused

- **WHEN** a branch's diff changes a file under `skills/`, `agents/`, `rules/` or `scripts/` and leaves the plugin's version unchanged
- **THEN** the test suite fails and names the version as not raised

#### Scenario: A lowered version is refused

- **WHEN** a branch's plugin version is numerically below the one where the branch left the trunk, whatever else its diff changes
- **THEN** the test suite fails

#### Scenario: A number the trunk already took is refused

- **WHEN** a branch's diff changes a shipped path and raises the plugin to a version not above the one at the trunk's tip, the trunk having risen since the branch left it
- **THEN** the test suite fails and names the trunk's version

#### Scenario: A rise is sized from the trunk's tip where the trunk has risen

- **WHEN** a branch's diff requires a major, the trunk has risen to `3.0.0` since the branch left it at `2.0.0`, and the branch sets `3.0.1`
- **THEN** the test suite fails

#### Scenario: A diff touching nothing shipped owes no rise

- **WHEN** a branch's diff changes only paths outside `skills/`, `agents/`, `rules/` and `scripts/`
- **THEN** the test suite passes with the version unchanged, and passes with it raised

#### Scenario: A fragment's major needs a plugin major

- **WHEN** a branch's diff raises a fragment's major version and raises the plugin by a minor or a patch
- **THEN** the test suite fails

#### Scenario: A fragment's minor needs at least a plugin minor

- **WHEN** a branch's diff raises a fragment's minor version and raises the plugin by a patch
- **THEN** the test suite fails

#### Scenario: A new skill, agent, script or fragment needs at least a plugin minor

- **WHEN** a branch's diff adds a skill, an agent, a script or a fragment and raises the plugin by a patch
- **THEN** the test suite fails

#### Scenario: A removed skill, agent, script or fragment needs a plugin major

- **WHEN** a branch's diff removes or renames a skill, an agent, a script or a fragment and raises the plugin by a minor or a patch
- **THEN** the test suite fails

#### Scenario: A sufficient rise passes

- **WHEN** a branch's diff changes a shipped path and raises the plugin by at least what the diff requires
- **THEN** the test suite passes

#### Scenario: The trunk itself owes nothing

- **WHEN** the suite runs where the branch has no diff from the trunk
- **THEN** the test suite passes

#### Scenario: No trunk to compare with is a failure

- **WHEN** the suite runs where the point the branch left the trunk cannot be found
- **THEN** the test suite fails and says so, rather than passing without having compared

#### Scenario: The suite checks this repository

- **WHEN** the suite runs on a branch of this repository
- **THEN** the check reads that branch's own diff and version, not only fixtures

#### Scenario: The rule is stated

- **WHEN** `AGENTS.md` is read
- **THEN** it states that the version rises with every shipped change and what each of the three sizes means

## MODIFIED Requirements

### Requirement: Skills are discovered without manifest enumeration

Skills SHALL be discoverable by auto-discovery alone. The marketplace entry MUST NOT rely on an explicit `skills` path array to make skills loadable, so that adding a skill enumerates it in no manifest and omitting one cannot silently remove it. The version rise *The plugin's version rises with what it ships* requires is not an enumeration, and discovery does not depend on it.

#### Scenario: New skill needs no manifest change

- **WHEN** a new skill directory containing `SKILL.md` is added under `skills/`
- **THEN** it is discovered in the next session with no entry naming it in `plugin.json` or `marketplace.json`

#### Scenario: Enumeration is not used

- **WHEN** the marketplace entry for this plugin is inspected
- **THEN** it contains no `skills` array enumerating individual skill paths
