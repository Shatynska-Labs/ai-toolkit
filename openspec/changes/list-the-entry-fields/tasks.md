## 1. Seeded text

- [ ] 1.1 In `scripts/project-init`'s seeded backlog, make the fields a list with no blank lines and give Design with and Workstream `none` (design.md decision 2). Verify with the derived seeded-backlog cases
- [ ] 1.2 In `scripts/project-init`'s seeded workstream README, list Not in scope, Open questions, Decisions and Opened, each with `none`, and say an abandoned workstream gains an **Abandoned** item after Opened. Verify with the derived workstream-register cases
- [ ] 1.3 Bring this repository's `docs/backlog.md` preamble and `docs/workstreams/README.md` to the seeded text, and convert its own entries to the list layout, changing `nothing` to `none` in Design with and Workstream. Verify by diffing each against the seeded text, and that no entry's prose changed

## 2. Skill

- [ ] 2.1 In `skills/backlog/SKILL.md`, have record and sweep write the file's absent value where they set Design with or Workstream empty, have pick group an entry naming no workstream apart whichever word it carries, and state under *Entries in an older shape* the reading of an earlier `nothing` and of paragraph fields (decision 4). Verify the description is unchanged, and with the derived skill cases
- [ ] 2.2 In `skills/backlog/references/audit.md`, use the file's absent value (`none` in the seeded file) where the report re-points or clears a workstream. Verify by reading

## 3. Tests and records

- [ ] 3.1 Let `tests/lib.sh`'s `fenced_line` accept a list marker before the label, and update its comment and its description in `tests/README.md`. Judge each existing case `test-plan.md` lists as obsolete. Verify that `bash tests/run.sh` passes
- [ ] 3.2 Account for the modified scenarios in `tests/coverage.md`

## 4. Verify

- [ ] 4.1 `bash tests/run.sh` passes
- [ ] 4.2 `shellcheck scripts/project-init tests/*.sh tests/cases/*.sh tests/cases/lib/*.sh` is clean
- [ ] 4.3 `openspec validate list-the-entry-fields --strict` passes
