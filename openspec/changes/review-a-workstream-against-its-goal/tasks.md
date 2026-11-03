## 1. The agent

- [x] 1.1 Present the agent's proposed frontmatter and body outline to the operator, `create-agent`'s Checkpoints 1 and 3. Verify that the operator approved them before any file is written
- [x] 1.2 Write `agents/workstream-reviewer.md` to design.md decision 1 and the `workstream-review` spec. Verify with `create-agent`'s post-write validation and the derived cases

## 2. The plan review and the checks

- [x] 2.1 In `agents/change-plan-reviewer.md`, add `workstreamFile` to the description's inputs and the dispatch contract, add the Decisions to the evidence levels' second level, and state the check as the `change-review` delta states it. Verify with the derived cases
- [x] 2.2 Run `create-agent`'s trigger check for `workstream-reviewer`, then its cold-run check on decision 10's fixture, and record the inputs in `agents/workstream-reviewer.checks.yaml`. Verify that the fixture returns `FIX REQUIRED` naming both gaps
- [x] 2.3 Re-run `change-plan-reviewer`'s trigger and cold-run checks, the latter supplying a `workstreamFile`, update `agents/change-plan-reviewer.checks.yaml`'s inputs, and re-run the `backlog` skill's recorded trigger check and any other recorded prompt routing to `change-plan-reviewer` or competing with it as a review. Verify that all pass

## 3. The workflow

- [x] 3.1 In `rules/development-workflow.md` and `rules/development-workflow-direct.md`, add decision 5's text under Throughout and decision 6's two edits, and raise the versions to `2.2.0` and `1.2.0`. Verify with `workflow-fragments-differ-only-in-ship.sh`, `workflow-fragments-binding-restates-no-rule.sh` and the derived cases
- [x] 3.2 Add one record per fragment to `rules/changelog`, none with an `ask`. Verify that `scripts/project-update` does not block on it

## 4. Records

- [x] 4.1 Raise `.claude-plugin/plugin.json` to `2.2.0`. Verify with `plugin-version-rise-checks-this-repository.sh`
- [x] 4.2 Account for the added and modified scenarios in `tests/coverage.md`. Verify that every scenario has a row

## 5. Verify

- [x] 5.1 `bash tests/run.sh` passes
- [x] 5.2 `shellcheck` is clean on every test this change adds or modifies
- [x] 5.3 `openspec validate review-a-workstream-against-its-goal --strict` passes
