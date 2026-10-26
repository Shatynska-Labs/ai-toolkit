## 1. Derived tests

- [x] 1.1 Dispatch `ai-toolkit:change-test-writer` against the committed plan; verify new cases under `tests/cases/` and a `test-plan.md` map every added and modified scenario, each mechanical scan discriminated by a fixture it must reject.

## 2. Specification

- [x] 2.1 Edit the Purpose of `openspec/specs/session-workflow/spec.md`, which a delta cannot change, to name `change-code-review` as the third owner of the workflow fragment, owning the content of `build`'s Claude Code binding; verify by reading.
- [x] 2.2 Confirm `rules/development-workflow.md` already states each amended rule — committing the handoff branch at once, no declined path, the **Markdown prose** rule — and leave its text and version unchanged; verify `git diff origin/main -- rules/` is empty.

## 3. Record

- [x] 3.1 Add a section to `tests/coverage.md` for this change, recording each added and modified scenario against its case or as uncovered with the reason; verify by reading.
- [x] 3.2 Run `openspec validate reconcile-commit-rule-with-spec --strict` and `bash tests/run.sh`; verify both pass. `tests/cases/session-workflow-publication-names-third-owner.sh` reads the main specification, which takes the delta's text only at archive, so it is held at `openspec/changes/reconcile-commit-rule-with-spec/held/` during the work and moved into `tests/cases/` in the archive commit, where it must pass (test-plan.md, Q2).
