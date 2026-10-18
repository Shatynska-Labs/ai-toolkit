## 1. Seeded backlog

- [ ] 1.1 Replace the heredoc in `scripts/project-init` with the seeded text from `design.md` decision 2. Verify by running the tool in a scratch directory and reading the created `docs/backlog.md`
- [ ] 1.2 Update the obsolete `Depends on` assertion in `tests/cases/backlog-seeded-new-project.sh` (and any sibling the test plan lists as obsolete) to the new shape. Verify with `bash tests/run.sh`

## 2. Fragment

- [ ] 2.1 Append the archive re-read sentence from `design.md` decision 3 to **archive** in `rules/development-workflow.md`. Verify that no entry field name appears in the fragment (`grep -E 'Kind|Waits on|Re-checked' rules/development-workflow.md` finds nothing)
- [ ] 2.2 Increment the fragment's `version` from 6 to 7. Verify `tests/cases/inlined-body-matches-fragment.sh` passes

## 3. Skill

- [ ] 3.1 Run `create-skill` checkpoints 1 and 3 with the inputs in `design.md` decision 5, and get the operator's approval of the frontmatter and outline before writing
- [ ] 3.2 Write `skills/backlog/SKILL.md`: the five operations, the read-from-file seam, older-shape handling. Verify with create-skill's post-write validation list
- [ ] 3.3 Write `skills/backlog/references/audit.md`: the agent brief, sources (archived changes and merged PRs named), verdict vocabulary, return format, merged report sections. Verify that every reference in `SKILL.md` resolves
- [ ] 3.4 Run the trigger check (positive and negative from decision 5) with a fresh-context evaluator, and record the fixtures in `SKILL.md`. Report both outcomes
- [ ] 3.5 Re-run `project-init`'s recorded trigger check, now that `backlog` competes with it, and update its fixtures if the expected routing changes

## 4. Docs and records

- [ ] 4.1 Mention `backlog` in `skills/project-init/SKILL.md` where it names the seeded file, if the description needs disambiguation after 3.5
- [ ] 4.2 Account for the new and modified scenarios in `tests/coverage.md`

## 5. Verify

- [ ] 5.1 `bash tests/run.sh` passes
- [ ] 5.2 `shellcheck scripts/project-init tests/cases/*.sh` is clean
- [ ] 5.3 `openspec validate add-backlog-skill --strict` passes
