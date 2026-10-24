## 1. Seeded files

- [ ] 1.1 In `scripts/project-init`'s seeded backlog, add the **Workstream** line after **Design with** with the text in `design.md` decision 9. Verify with the derived seeded-backlog cases and `tests/cases/backlog-seeded-structured-fields.sh`
- [ ] 1.2 In `scripts/project-init`, seed `docs/workstreams/README.md` with the text in decision 8 as a concern of its own, reported `workstreams: created` / `workstreams: already present`, with the backlog's presence rule (any path type, a dangling link included) and its error path on a failed write, creating no `archive/`, and add the `workstreams:` line directly after `backlog:` to `tests/README.md`'s report contract. Verify with the derived workstream-register cases, including repeated execution and a partial run
- [ ] 1.3 Apply 1.1 to this repository's `docs/backlog.md` preamble and add this repository's `docs/workstreams/README.md` with the seeded text. Verify by diffing each against the seeded text

## 2. Workflow fragment

- [ ] 2.1 In `rules/development-workflow.md`, make decision 10's two insertions (draft, archive) and decision 13's status row, its cell-source sentence and example, and bump `version` to 11. Verify with the derived fragment cases and that the existing fragment cases (fixed paths, names no entry field, rules not restated) still pass

## 3. Backlog skill

- [ ] 3.1 In `skills/backlog/SKILL.md`, add Workstream to *Before any operation*'s fields and the workstream register to what it reads, state that workstream rules are read from the README, and extend **record**, **pick**, **close** and **sweep** as decision 11 states, each step gated by what it reads (decision 11's last paragraph). Verify with the derived skill cases
- [ ] 3.2 Add the **workstreams** operation to `skills/backlog/SKILL.md` (decision 11), read-only, naming the statuses and taking their precedence and sources from the README rather than restating them, the Waits-on-aware **next**, and unplaced entries and open changes, and update the description to six operations with the workstream phrasings, keeping the trigger fixtures routing as before plus one positive fixture for a workstream status phrasing. Verify the trigger check and the derived cases
- [ ] 3.3 In `skills/backlog/references/audit.md`, add the open-workstream check to the brief and report an entry naming an archived or absent workstream under *Stale facts*. Verify with the derived audit cases

## 4. Records

- [ ] 4.1 Account for the new and modified scenarios in `tests/coverage.md`

## 5. Verify

The new test cases come from the derived-tests step (`change-test-writer`, `test-plan.md`), not from these tasks.

- [ ] 5.1 `bash tests/run.sh` passes
- [ ] 5.2 `shellcheck scripts/project-init tests/*.sh tests/cases/*.sh tests/cases/lib/*.sh` is clean
- [ ] 5.3 `openspec validate add-workstreams --strict` passes
