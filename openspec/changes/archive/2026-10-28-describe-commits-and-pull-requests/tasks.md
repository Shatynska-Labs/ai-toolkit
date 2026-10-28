## 1. Skill (authored through `create-skill`)

- [x] 1.1 Checkpoint 1 (Intent) and Checkpoint 3 (Draft) with the operator: name `commits-and-pull-requests`, tags `[git]`, the description per design decision 7, and a body outline covering every requirement in `specs/commit-and-pull-request-practice/spec.md`
- [x] 1.2 Write `skills/commits-and-pull-requests/SKILL.md`: precedence of project conventions; commit messages (subject per project convention, body says why, folded-in commits); pull request title; description sections and the not-run rule; revising the description after review; the work and fix kinds; a pointer to the record reference
- [x] 1.3 Write `skills/commits-and-pull-requests/references/record-pull-request.md`: the record pull request's content, without restating when it is opened or how many pull requests a change takes
- [x] 1.4 Run `create-skill`'s post-write validation and report each check
- [x] 1.5 Run the trigger check (fresh-context evaluator holding every skill, agent, and `.claude/` skill and command) with a positive and an adjacent negative prompt; record the fixtures in the skill's `## Trigger check fixtures`
- [x] 1.6 Re-run the recorded fixtures of the competing assets — `create-skill`, `create-agent`, `n8n-workflow-review`, `backlog` and `agents/change-code-reviewer.checks.yaml` — and correct any description that now misroutes

## 2. Workflow fragment

- [x] 2.1 Add under `open pr` in `rules/development-workflow.md`: `_Claude Code binding:_ write the pull request's title and description with `ai-toolkit:commits-and-pull-requests`.`
- [x] 2.2 Confirm the fragment still states, without the skill, every obligation the skill's content touches (folded-in work named in the description), per the form-skill clause
- [x] 2.3 Increment the fragment's `version` from 12 to 13

## 3. Foundation checklist

- [x] 3.1 `rules/project-foundation.md`: add a **Pull requests** concern after **Commit messages** — what a pull request's title and description carry, whether the forge supplies a template, and whether anything checks it — and add `Pull requests` to the design artifact's `Development Tooling` items
- [x] 3.2 `skills/project-foundation/SKILL.md`: add `Pull requests` to its `Development Tooling` items

## 4. Verification

- [x] 4.1 `bash tests/run.sh`, including `workflow-fragment-names-shipped-assets`, passes
- [x] 4.2 ShellCheck over any new or changed test case is clean
- [x] 4.3 `openspec validate describe-commits-and-pull-requests --strict` passes
- [x] 4.4 `tests/coverage.md` accounts for every added and modified scenario

## 5. Confirmation

- [x] 5.1 Confirmation waived by the operator on 2026-10-28, after PR #74 merged (no observation can actually be made): the proposed observation — a fresh session loading `commits-and-pull-requests` to write a pull request — was not performable when waived, since library skills reached sessions on this machine through per-skill links into a checkout not yet pulled past the merge, with no link for the new skill, and the installed plugin predated the change.
