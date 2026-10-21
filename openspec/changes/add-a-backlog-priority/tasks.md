## 1. Seeded backlog

- [x] 1.1 In `scripts/project-init`'s seeded backlog, replace the order sentence and add the **Priority** line to the entry shape with the text in `design.md` decision 5, and the archive sentence's change there. Verify with the derived seeded-backlog cases and `tests/cases/backlog-seeded-structured-fields.sh`
- [x] 1.2 Apply the same edits as 1.1 to this repository's `docs/backlog.md` preamble, so it stays identical to the seeded text. Verify by diffing the two preambles

## 2. Backlog skill

- [x] 2.1 In `skills/backlog/SKILL.md`, add Priority to the fields named in *Before any operation*, add a **Priority** step to **record** (decision 6), and state under *Entries in an older shape* that a field the file gives a default for is read as that default, and extend **pick** and **sweep** as decision 8 states, each step applying only where the file's shape names Priority, each deferring to the file for what the values mean. Verify the description and trigger fixtures are unchanged, and with the derived skill cases
- [x] 2.2 In `skills/backlog/references/audit.md`, add the `high`-evidence and `parked`-condition checks to the brief, rename *Now unblocked* to *Now unblocked or unparked*, and report a `high` whose evidence no longer holds under *Stale facts*, its Priority corrected as the file directs. Verify with the derived audit cases

## 3. Records

- [x] 3.1 Account for the new and modified scenarios in `tests/coverage.md`

## 4. Verify

The new test cases come from the derived-tests step (`change-test-writer`, `test-plan.md`), not from these tasks.

- [x] 4.1 `bash tests/run.sh` passes
- [x] 4.2 `shellcheck scripts/project-init tests/*.sh tests/cases/*.sh tests/cases/lib/*.sh` is clean
- [x] 4.3 `openspec validate add-a-backlog-priority --strict` passes
