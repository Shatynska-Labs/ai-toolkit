## 1. Plan

- [x] 1.1 Commit the approved plan, and verify `git log -1` on the branch holds proposal, design, delta specs and tasks
- [x] 1.2 Dispatch `ai-toolkit:change-test-writer` against the committed plan, with test command `bash tests/run.sh` and test-path glob `tests/cases/*.sh`, and verify `test-plan.md` maps every scenario in both delta specs to a case or states why none

## 2. The project-init skill

- [x] 2.1 Rewrite the opening paragraph and step 4 of `skills/project-init/SKILL.md`, and step 5's adoption ending: the mode is taken from the tool's report; the direct commit is offered only in the new-project mode, after listing every staged path and every untracked path git does not exclude; a declined commit states that the first commit and a remote are outstanding; the adoption ending offers no commit onto the current branch, says the writes reach the trunk through a pull request, and that a remote is needed first where none is configured. Verify the derived cases for the first `project-bootstrap` requirement pass
- [x] 2.2 Add the remote step after the commit: ask for the URL of a hosted repository the operator created, never create one, add `origin` and push with upstream only on confirmation, report a rejected push and that `origin` now names the URL, without forcing or merging, state the gap on declining, leave an existing remote alone. Verify the derived cases for the second `project-bootstrap` requirement pass
- [x] 2.3 Revise the skill's description to mention connecting a remote, and verify its two trigger-check fixtures still route as recorded, using a fresh-context evaluator holding every skill and agent in the library

## 3. The workflow fragment

- [x] 3.1 Add the first-commit sentence beside "Every change reaches the trunk through pull requests" in `rules/development-workflow.md`, identified by there being no commit before it and naming no class of commit, and increment `version` from 6 to 7. Verify the derived `session-workflow` cases and `inlined-body-matches-fragment` pass

## 4. Verification

- [x] 4.1 Run `bash tests/run.sh` and `openspec validate establish-the-remote-and-the-first-commit --strict`, and verify both pass with no failures
- [x] 4.2 Cold-run the revised skill against a scratch directory holding one file of its own, not ignored, with a local bare repository as the remote, and verify `origin` is set, the trunk is pushed with upstream, and the commit offer listed a pre-existing file
