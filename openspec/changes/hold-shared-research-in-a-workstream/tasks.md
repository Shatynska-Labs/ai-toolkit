## 1. Seeded text

- [x] 1.1 In `scripts/project-init`'s seeded workstream README, replace the edit sentence and the "Keep a workstream short" paragraph with design.md decision 7's text, remove the shape's `Decisions` item, revise Open questions' answer to "recorded under Decisions", and add the `## Context` and `## Decisions` sections after the list. Verify with the derived cases
- [x] 1.2 Bring this repository's `docs/workstreams/README.md` to the seeded text. Verify by diffing it against the heredoc
- [x] 1.3 In `docs/workstreams/complete-the-workstream-loop.md` and `docs/workstreams/see-the-backlog-across-projects.md`, move the `Decisions` item's pointer into a `## Decisions` section after the list, and reword step 4 of `complete-the-workstream-loop` from "the document Decisions names" to the workstream's Decisions
- [x] 1.4 Reword `docs/backlog/review-a-workstream-against-its-goal.md`'s "the document its Decisions names" to the workstream's Decisions

## 2. Tests and records

- [x] 2.1 Revise the obsolete assertions the test plan lists in `workstreams-seeded-statements`, `workstreams-seeded-fields-are-a-list` and `workstreams-seeded-no-status-field` to the new shape, changing only what the delta replaced
- [x] 2.2 Account for the modified and added scenarios in `tests/coverage.md`

## 3. Verify

- [x] 3.1 `bash tests/run.sh` passes
- [x] 3.2 `shellcheck scripts/project-init tests/*.sh tests/cases/*.sh tests/cases/lib/*.sh` is clean
- [x] 3.3 `openspec validate hold-shared-research-in-a-workstream --strict` passes
