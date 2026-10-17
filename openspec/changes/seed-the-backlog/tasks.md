## 1. Tool

- [x] 1.1 In `scripts/project-init`, check `docs/backlog.md` alongside the other concerns, before any write, as present when `[ -e ] || [ -L ]`
- [x] 1.2 Create `docs/` if absent and write the seeded text from `design.md` via heredoc where the file is absent; report `backlog: created`, or `backlog: already present`; on a failed write finish with `ERROR` naming the backlog
- [x] 1.3 Mention the backlog in `--help` where it lists what the tool never overwrites, if the wording needs it

## 2. Fragment

- [x] 2.1 In `rules/development-workflow.md`, drop "creating that file if absent" from the routing bullet
- [x] 2.2 Replace the three closing backlog paragraphs with the single paragraph `design.md` describes; no mention of entry numbers remains
- [x] 2.3 Increment `version` from 4 to 5

## 3. Tests and docs

The new cases — seeded content, existing backlog preserved, the backlog on a repeated run — come from the derived-tests step, not from these tasks.

- [x] 3.1 Add the backlog line to the report contract in `tests/README.md`
- [x] 3.2 Update `tests/cases/workflow-fragment-fixed-paths.sh`: remove the cite-by-number assertion, and rewrite its header comments, which name the create-if-absent direction; keep the path assertion
- [x] 3.3 Account for the new and modified scenarios in `tests/coverage.md`
- [x] 3.4 Mention the backlog in `skills/project-init/SKILL.md` where it lists what the tool sets up

## 4. Verify

- [x] 4.1 `bash tests/run.sh` passes
- [x] 4.2 `shellcheck scripts/project-init tests/cases/*.sh` is clean
- [x] 4.3 Run the tool in a scratch directory and read the created `docs/backlog.md`
