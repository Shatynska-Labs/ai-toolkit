## 1. Rules text

- [ ] 1.1 In `rules/workstreams.md`, replace the opening of the status paragraph with design.md decision 1's text, add decision 3's paragraph immediately after the paragraph stating that order gates nothing, and apply decision 4's two replacements. Verify with the derived cases
- [ ] 1.2 Raise `rules/workstreams.md`'s `version` to `2.0.0` (decision 6)
- [ ] 1.3 Bring this repository's `docs/workstreams/AGENTS.md` to the fragment by running `scripts/project-update` against the repository (decision 7). Verify that the block's marker names `2.0.0` and that nothing outside the block changed
- [ ] 1.4 In `skills/backlog/SKILL.md`'s **close**, reword the sentence naming a closed entry's workstream and step so that, where the entry was taken as a fix, the step is said to stay and read as done once its pull request merges, and otherwise its plan can be revised (design.md decision 5)

## 2. Records

- [ ] 2.1 Account for the modified and added scenarios in `tests/coverage.md`, and retire the obsolete assertions that the test plan lists

## 3. Verify

- [ ] 3.1 `bash tests/run.sh` passes
- [ ] 3.2 `shellcheck tests/*.sh tests/cases/*.sh tests/cases/lib/*.sh` is clean
- [ ] 3.3 `openspec validate define-what-a-step-is --strict` passes
