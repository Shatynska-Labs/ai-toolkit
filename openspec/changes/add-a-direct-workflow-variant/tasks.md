## 1. Fragments and manifest

- [ ] 1.1 Copy `rules/development-workflow.md` to `rules/development-workflow-direct.md` at `1.0.0`, unchanged in body
- [ ] 1.2 Edit `rules/development-workflow.md`'s current `ship`, taking from `commerce-ops`'s `v12` block only what design.md decision 6 names, keeping the pull-request binding and the waiver under `confirm`; change its three lines outside `ship`, add its one paragraph on states, and set `version: 2.0.0` and `alternative_since: 2.0.0`
- [ ] 1.3 Add `alternative: development-workflow-direct` to `rules/manifest`'s first record

- [ ] 1.4 Add a comparison taking two paths that allows exactly the differences `session-workflow` states, with cases over supplied files and over the shipped fragments

## 2. Tools

- [ ] 2.1 `scripts/project-init`: read and validate `alternative`, take `--workflow`, treat either marker as present, report a contrary choice; document it in `--help`
- [ ] 2.2 `scripts/project-update`: read and validate `alternative` and `alternative_since`, classify under either marker, `malformed` where both are held; document `--workflow` in `--help`
- [ ] 2.3 `scripts/project-update`: block before every git precondition and any write where a choice is owed; apply `--workflow`, including a switch that replaces an unedited block of the other variant
- [ ] 2.4 `skills/project-init/SKILL.md`: pass `--workflow` through, and name the choice

## 3. Documentation and records

- [ ] 3.1 `AGENTS.md` and `rules/README.md`: the two workflows, the default, that this repository follows the direct one, and the frontmatter key `alternative_since`
- [ ] 3.2 `tests/README.md`: the revised report lines and flags
- [ ] 3.3 Revise the cases `test-plan.md` lists as obsolete: a case reading a moved sentence changes only what it reads, and a case driving a workflow block below `2.0.0` gains `--workflow full` or moves its fixture to another record; no assertion changes
- [ ] 3.4 Account for the requirements and scenarios in `tests/coverage.md`

## 4. Verify

- [ ] 4.1 `bash tests/run.sh` passes
- [ ] 4.2 `shellcheck scripts/project-init scripts/project-update scripts/backlog-migrate tests/*.sh tests/cases/*.sh tests/cases/lib/*.sh` is clean
- [ ] 4.3 `openspec validate add-a-direct-workflow-variant --strict` passes
