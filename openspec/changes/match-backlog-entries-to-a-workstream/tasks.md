## 1. Rules

- [ ] 1.1 In `rules/backlog.md`, replace the `workstream` key's second sentence with design.md decision 1's text, and raise `version` to `1.1.0`. Verify with the derived cases and `backlog-dir-seeded-workstream-default.sh`
- [ ] 1.2 In `rules/workstreams.md`, replace the placement paragraph and the archive paragraph's two sentences with decision 2's text, and raise `version` to `2.1.0`. Verify with the derived cases
- [ ] 1.3 In `rules/development-workflow.md` and `rules/development-workflow-direct.md`, apply decision 5's three edits, raising the versions to `2.1.0` and `1.1.0` and leaving `alternative_since` as it is. Verify with `workflow-fragments-differ-only-in-ship.sh` and the derived cases
- [ ] 1.4 Add one record per fragment to `rules/changelog`, none with an `ask` (decision 8). Verify that `scripts/project-update` does not block on it

## 2. Skill

- [ ] 2.1 In `skills/backlog/SKILL.md`, apply decision 3 to **record** and decision 4 to **sweep** and **workstreams**. Verify with the `backlog-skill-*` cases
- [ ] 2.2 Replace the description with decision 6's text and add the follow-ups fixture. Verify that it holds at most 1,024 characters and no angle bracket, and run `create-skill`'s trigger check

## 3. Records

- [ ] 3.1 Raise `.claude-plugin/plugin.json` to `2.1.0`. Verify with `plugin-version-rise-checks-this-repository.sh`
- [ ] 3.2 Bring this repository's `docs/backlog/AGENTS.md` and `docs/workstreams/AGENTS.md` current by running `scripts/project-update` against it. Verify that the markers name `1.1.0` and `2.1.0` and that nothing outside the blocks changed
- [ ] 3.3 Account for the added and modified scenarios in `tests/coverage.md`, and retire the obsolete assertions in `manifest-alternative-and-versions.sh` and `workstreams-seeded-statements.sh` that the test plan lists. Verify that every scenario has a row and that the case passes

## 4. Verify

- [ ] 4.1 `bash tests/run.sh` passes
- [ ] 4.2 `shellcheck tests/*.sh tests/cases/*.sh tests/cases/lib/*.sh` is clean
- [ ] 4.3 `openspec validate match-backlog-entries-to-a-workstream --strict` passes
