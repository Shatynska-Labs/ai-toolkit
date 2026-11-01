## 1. The record

- [ ] 1.1 Add `rules/changelog` with the `development-workflow` `2.0.0` and `workstreams` `2.0.0` records, and verify the case for *A version rise carries its changelog record* passes.
- [ ] 1.2 State the changelog in `rules/README.md` and `AGENTS.md`: a second file that is not a fragment, and the record a version rise owes. Revise `tests/cases/rules-manifest-only-non-fragment.sh`, recorded as obsolete in the test plan, to allow `changelog`, and verify it passes against a fixture holding a third non-fragment file failing.

## 2. The tool

- [ ] 2.1 Read and validate `rules/changelog` in `scripts/project-update` before anything else, and verify the missing and malformed changelog cases report `BLOCKED`.
- [ ] 2.2 Print the records in range beneath each replaced or converted block, and the line for a major without a record, and verify every `A run says what each version it crossed asks` case passes.
- [ ] 2.3 Describe the lines in `--help` and in `tests/README.md`'s report contract, and verify the help case passes.

## 3. Close

- [ ] 3.1 Record the derived cases in `tests/coverage.md`, and verify `bash tests/run.sh` and ShellCheck on `scripts/project-update` pass.
