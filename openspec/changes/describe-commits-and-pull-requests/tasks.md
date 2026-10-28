## 1. Skill (authored through `create-skill`)

- [ ] 1.1 Checkpoint 1 (Intent) and Checkpoint 3 (Draft) with the operator: name `commits-and-pull-requests`, tags `[git]`, the description per design decision 7, and a body outline covering every requirement in `specs/commit-and-pull-request-practice/spec.md`
- [ ] 1.2 Write `skills/commits-and-pull-requests/SKILL.md`: precedence of project conventions; commit messages (subject per project convention, body says why, folded-in commits); pull request title; description sections and the not-run rule; revising the description after review; the work and fix kinds; a pointer to the record reference
- [ ] 1.3 Write `skills/commits-and-pull-requests/references/record-pull-request.md`: the record pull request's content, without restating when it is opened or how many pull requests a change takes
- [ ] 1.4 Run `create-skill`'s post-write validation and report each check
- [ ] 1.5 Run the trigger check (fresh-context evaluator holding every skill, agent, and `.claude/` skill and command) with a positive and an adjacent negative prompt; record the fixtures in the skill's `## Trigger check fixtures`
- [ ] 1.6 Re-run the recorded fixtures of the competing assets — `create-skill`, `create-agent`, `n8n-workflow-review`, `backlog` and `agents/change-code-reviewer.checks.yaml` — and correct any description that now misroutes

## 2. Workflow fragment

- [ ] 2.1 Add under `open pr` in `rules/development-workflow.md`: `_Claude Code binding:_ write the pull request's title and description with `ai-toolkit:commits-and-pull-requests`.`
- [ ] 2.2 Confirm the fragment still states, without the skill, every obligation the skill's content touches (folded-in work named in the description), per the form-skill clause
- [ ] 2.3 Increment the fragment's `version` from 12 to 13

## 3. Foundation checklist

- [ ] 3.1 `rules/project-foundation.md`: add a **Pull requests** concern after **Commit messages** — what a pull request's title and description carry, whether the forge supplies a template, and whether anything checks it — and add `Pull requests` to the design artifact's `Development Tooling` items
- [ ] 3.2 `skills/project-foundation/SKILL.md`: add `Pull requests` to its `Development Tooling` items

## 4. Verification

- [ ] 4.1 `bash tests/run.sh`, including `workflow-fragment-names-shipped-assets`, passes
- [ ] 4.2 ShellCheck over any new or changed test case is clean
- [ ] 4.3 `openspec validate describe-commits-and-pull-requests --strict` passes
- [ ] 4.4 `tests/coverage.md` accounts for every added and modified scenario
