## 1. Plan

- [x] 1.1 Commit the approved plan, and verify `git log -1` holds proposal, design, delta spec and tasks
- [x] 1.2 Dispatch `ai-toolkit:change-test-writer` with test command `bash tests/run.sh` and test-path glob `tests/cases/*.sh`, and verify `test-plan.md` maps the four new or changed scenarios and lists `empty-directory-new-project.sh`'s import assertion as obsolete

## 2. Implementation

- [x] 2.1 Update the normative report form in `tests/README.md` before the script: the import line's condition and wording (design, Decision 2a), the new note line (Decision 2), and the assumption that no shadowing file exists above `$TESTDIR`. Verify the form names both lines and the assumption
- [x] 2.2 In `scripts/project-init`, set the import-needed report only where the target's `CLAUDE.md` lacks `@AGENTS.md` and a shadowing file exists (Decision 1), reworded per Decision 2a, and print the version note where none does; update `--help` if it describes the import. Verify the derived cases, `import-line-reported.sh` and `claude-md-only.sh` pass, and that the script's empty-directory output matches the form from 2.1
- [x] 2.3 Update the obsolete assertion in `tests/cases/empty-directory-new-project.sh` to the note, as `test-plan.md` lists it, guarded by the no-shadowing-file precondition, and verify the case passes
- [x] 2.4 Add the change's scenarios to `tests/coverage.md`, and verify every scenario in the delta is named there
- [x] 2.5 Delete `act-on-the-claude-md-import-at-initialization` from `docs/backlog.md`, and verify no live file still names it outside the archive and this change

## 3. Verification

- [x] 3.1 Run `bash tests/run.sh`, `shellcheck scripts/project-init`, and `openspec validate retire-the-claude-md-import-notice --strict`, and verify all pass
