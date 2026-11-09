## 0. Tests

- [x] 0.1 Derive the cases for the added scenarios with `ai-toolkit:change-test-writer` from the committed plan, static scans where a statement can be scanned and the conduct-only scenarios marked so in `test-plan.md`. Verify that each new case fails before the implementation for the reason it names

## 1. Rules

- [x] 1.1 In `rules/workstreams.md`, apply design.md decisions 1 and 2, and raise `version` to `2.2.0`. Verify with the derived cases and `workstreams-seeded-statements.sh`
- [x] 1.2 In `rules/backlog.md`, apply decision 3, and raise `version` to `1.3.0`. Verify with the derived cases and `backlog-dir-seeded-workstream-default.sh`
- [x] 1.3 Add one record per fragment to `rules/changelog`, neither with an `ask` (decision 8). Verify with the `project-update-changelog-*` cases

## 2. Skill

- [x] 2.1 In `skills/backlog/SKILL.md`, apply decision 4 to **record**, decision 5 to **sweep** and decision 6 to **audit**. Verify with the `backlog-skill-*` cases, the restatement scans among them
- [x] 2.2 In `skills/backlog/references/audit.md`, add the **Shared goals** section and renumber the sections after it (decision 6). Verify with the `backlog-skill-audit*` cases

## 3. Records

- [x] 3.1 Raise `.claude-plugin/plugin.json` to `2.4.0`. Verify with `plugin-version-rise-checks-this-repository.sh`
- [x] 3.2 Bring this repository's `docs/backlog/AGENTS.md` and `docs/workstreams/AGENTS.md` current by running `scripts/project-update` against it. Verify that the markers name `1.3.0` and `2.2.0` and that nothing outside the blocks changed
- [x] 3.3 Account for the modified scenarios in `tests/coverage.md`. Verify that every scenario has a row

## 4. Verify

- [x] 4.1 `bash tests/run.sh` passes
- [x] 4.2 `shellcheck` is clean on every test this change adds or modifies
- [x] 4.3 `openspec validate propose-a-workstream-for-entries-sharing-a-goal --strict` passes
