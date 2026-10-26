## Context

The fragments reach a consuming project inlined into its conventions file, and the agents they name reach it as part of the installed plugin. A name the plugin does not carry is a dispatch that finds nothing, the same failure as a `rules/` path the project cannot open. The existing case already strips each fragment's frontmatter and scans the body; this change adds the same kind of scan for `ai-toolkit:` names, in a case of its own.

## Goals / Non-Goals

**Goals:**

- Every `ai-toolkit:<name>` in either fragment's body resolves to something the library ships.
- The scan is shown to fail on a name that does not resolve, so a green run is not vacuous.

**Non-Goals:**

- Scanning other `rules/` fragments, skills or agents for dangling names. The requirement this amends binds the two session fragments only.
- Checking that a named agent is the right one for its gate. That is prose, verified by reading.

## Decisions

### 1. A name resolves to an agent or a skill

The plugin namespaces both agents and skills as `ai-toolkit:<name>`, and the layout is flat (`AGENTS.md`, *Layout*), so `<name>` maps to `agents/<name>.md` or `skills/<name>/SKILL.md` and to nothing else. The fragments name only agents today, but a binding naming a skill would be just as valid, and a scan accepting agents alone would fail it falsely. *Alternative:* agents only, as the backlog entry's title says. Rejected: it turns a future valid reference into a red suite, and the requirement is about naming something that exists, not about its type.

### 2. The name is matched as `ai-toolkit:` followed by a kebab-case name

`ai-toolkit:[a-z0-9][a-z0-9-]*`, taken from the body only. The managed-block markers `scripts/project-init` writes (`<!-- ai-toolkit:development-workflow vN -->`) are not in the fragment body, so they do not match. Should a fragment body ever carry such a marker, the scan reports it, and the case is the place to widen.

### 3. The discriminator is a fixture body run through the same scan

The scan runs once over a fixture body naming `ai-toolkit:` plus a name with no agent or skill, and must report it; and once over a fixture naming an agent that exists, and must not. Without the first, a regex that never matches passes on the real tree. The fixtures are written under `$TESTDIR`, not into `rules/`. The scan is therefore written to return a status rather than exit on the first hit, so it can run over the real bodies and both fixtures.

### 4. The scan is derived by `change-test-writer` as a new case

The deliverable here is a test, which is exactly what the derive-tests step produces, so the step is taken rather than exempted: `change-test-writer` derives the scan from the new scenario, and `tests/README.md` records no exemption because none is used. The test writer only adds tests, so the scan lands in a new case rather than in `workflow-fragment-no-dangling-reference.sh`, which stays as it is. That also keeps the existing case's header, which names the scenario it guards, accurate. What implementation is left is the coverage record. The new case passes as soon as it is written, since every name the fragments carry resolves; its discriminator fixture is what shows it is not vacuous.

### 5. Coverage is recorded in a section of this change's own

`tests/coverage.md`'s `session-workflow` section is `consolidate-development-workflow`'s snapshot, with counts of its own; adding a row there would leave those counts stale. Later changes each add a section, and this one does too, naming the scenario and the case. The snapshot's sentence that `workflow-fragment-no-dangling-reference.sh` covers no scenario stays true and is left alone.

## Risks / Trade-offs

- [A plugin name other than `ai-toolkit` would escape the scan] → The plugin's name is fixed by `.claude-plugin/plugin.json`; a rename would rename every binding at once and is a change of its own.
- [The scan cannot tell a name used as a dispatch from one quoted in prose] → Either way the name points at nothing; both are reported.
