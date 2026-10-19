## 1. Fragment

- [x] 1.1 Replace **Scope** in `rules/development-workflow.md` with the text in `design.md` decision 2. Verify with the derived fold-in cases
- [x] 1.2 Replace the opening of **A second change surfacing** and its second bullet with the text in decision 2. Verify with the derived routing cases and `tests/cases/workflow-fragment-backlog-not-created-by-fragment.sh`
- [x] 1.3 Add the backlog pickup sentence from decision 2 to **apply**. Verify with the derived pickup cases and `tests/cases/workflow-fragment-backlog-rules-not-restated.sh`
- [x] 1.4 Increment the fragment's `version` from 8 to 9. Verify `tests/cases/inlined-body-matches-fragment.sh` passes

## 2. Code reviewer

- [x] 2.1 Extend **Scope** in `agents/change-code-reviewer.md` with the fold-in exemption in decision 6, deferring to the project's conventions for the conditions, and add to *Resolving the target* reading the range's commits with `git log --name-only <base>..<head>`. Verify with the derived reviewer cases and `tests/cases/change-code-reviewer-finding-vocabulary.sh`
- [x] 2.2 Extend the cold-run fixture in `agents/change-code-reviewer.checks.yaml` as decision 6 describes (the fixture's fold-in rule; `README.md` with a typo in its install section on `main`; the proposal and a fixture task naming a greet section in `README.md`, replacing "No other file changes"; the greet commit adding it; the folded-in typo commit) and add its pass criteria
- [x] 2.3 Run the cold-run check against the extended fixture by real dispatch, as the fixture's `form` states, and report the outcome against every pass criterion

## 3. Backlog skill

- [x] 3.1 Add the fold-in test as the first step of **record** in `skills/backlog/SKILL.md`, as decision 7 states, naming no condition itself. Verify the description and trigger fixtures are unchanged

## 4. Records

- [x] 4.1 Account for the new and modified scenarios in `tests/coverage.md`

## 5. Verify

The new test cases come from the derived-tests step (`change-test-writer`, `test-plan.md`), not from these tasks.

- [x] 5.1 `bash tests/run.sh` passes
- [x] 5.2 `shellcheck scripts/project-init tests/*.sh tests/cases/*.sh tests/cases/lib/*.sh` is clean
- [x] 5.3 `openspec validate fold-small-work-in --strict` passes
