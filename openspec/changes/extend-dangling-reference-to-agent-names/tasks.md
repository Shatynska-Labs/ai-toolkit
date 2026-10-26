## 1. Derived tests

- [x] 1.1 Dispatch `ai-toolkit:change-test-writer` against the committed plan; verify a new case under `tests/cases/` and a `test-plan.md` map the new scenario, and that the case carries a fixture naming an unshipped `ai-toolkit:` name that it reports.
- [x] 1.2 Check the case against the real tree: temporarily name an absent agent in `rules/development-workflow.md`, see the case fail, and restore it with `git restore`; verify `git status` is clean afterwards.

## 2. Record

- [x] 2.1 Add a section to `tests/coverage.md` for this change, following the per-change sections, recording *A fragment names only agents and skills the library ships* against the new case; leave `consolidate-development-workflow`'s snapshot and its counts unchanged; verify by reading.
- [x] 2.2 Run `openspec validate extend-dangling-reference-to-agent-names --strict` and `bash tests/run.sh`; verify both pass.
