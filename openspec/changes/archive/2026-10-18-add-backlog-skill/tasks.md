## 1. Seeded backlog

- [x] 1.1 Replace the heredoc in `scripts/project-init` with the seeded text from `design.md` decision 2. Verify by running the tool in a scratch directory and reading the created `docs/backlog.md`
- [x] 1.2 Update the tests the test plan lists as obsolete (at least the `Depends on` assertion in `tests/cases/backlog-seeded-new-project.sh`) to the new shape. Verify with `bash tests/run.sh`

## 2. Fragment

- [x] 2.1 Append the archive re-read sentence from `design.md` decision 3 to **archive** in `rules/development-workflow.md`. Verify with the derived fragment cases and `tests/cases/workflow-fragment-backlog-rules-not-restated.sh`
- [x] 2.2 Increment the fragment's `version` from 7 to 8. Verify `tests/cases/inlined-body-matches-fragment.sh` passes

## 3. Skill

- [x] 3.1 Run `create-skill` checkpoints 1, 2 and 3 with the inputs in `design.md` decisions 4 and 5, and get the operator's approval of the shape, frontmatter and outline before writing
- [x] 3.2 Write `skills/backlog/SKILL.md`: the five operations, the read-from-file seam, sweep's forge-first source with its fallback, older-shape handling. Verify with create-skill's post-write validation list
- [x] 3.3 Write `skills/backlog/references/audit.md`: the agent brief, the sources (archived changes and merged PRs named), the verdict vocabulary (with `fix?` carrying its size reason), the return format, and the merged report's sections. Verify that every reference in `SKILL.md` resolves
- [x] 3.4 Run the trigger check (positive and negative from decision 5) with a fresh-context evaluator, and record the fixtures in `SKILL.md`. Report both outcomes
- [x] 3.5 Re-run the recorded trigger checks of `project-init` and `project-foundation` now that `backlog` competes with them, and update their fixtures if the expected routing changes. Report the outcomes

## 4. Docs and records

- [x] 4.1 Mention `backlog` in `skills/project-init/SKILL.md` where it names the seeded file, if 3.5 shows the descriptions need disambiguation
- [x] 4.2 Account for the new and modified scenarios in `tests/coverage.md`

## 5. Verify

The new test cases (seeded statements, the structured fields, the fragment's re-read sentence and its field-free form, the skill's scenarios) come from the derived-tests step (`change-test-writer`, `test-plan.md`), not from these tasks.

- [x] 5.1 `bash tests/run.sh` passes
- [x] 5.2 `shellcheck scripts/project-init tests/cases/*.sh` is clean
- [x] 5.3 `openspec validate add-backlog-skill --strict` passes
