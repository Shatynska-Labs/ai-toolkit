## 1. Authoring standard

- [ ] 1.1 In `skills/create-agent/references/cold-run-check.md`'s *Isolation for write-capable agents*, state the removal: once the outcome is read, on a pass, a failure or an abort, before the agent is reported complete; forced, from the authoring checkout, with any branch created with the worktree deleted; a harness-removed worktree needs nothing; and add the removal to the real-dispatch steps: return to the authoring checkout from the `cd <wt>` before `git worktree remove --force <wt>`, and delete a harness-created branch with `git branch -D`, since the run may have committed to it (design decisions 2 and 4). Verify with the derived cases
- [ ] 1.2 In the same section, state that a failing run's worktree is removed before the revised body runs, and that the revised body runs in a fresh, newly populated worktree (decision 3). Verify with the derived cases
- [ ] 1.3 In `skills/create-agent/SKILL.md`'s isolation summary, name the removal. Verify by reading it against the requirement

## 2. Tests and records

- [ ] 2.1 Account for the three added scenarios in `tests/coverage.md`. Verify by reading
- [ ] 2.2 Deal with every entry under the test plan's *Missing shared arrangement*, if any, promoting into `tests/lib.sh` or keeping with a reason, recorded against the entry

## 3. Verify

- [ ] 3.1 `bash tests/run.sh` passes
- [ ] 3.2 `shellcheck tests/*.sh tests/cases/*.sh tests/cases/lib/*.sh` is clean
- [ ] 3.3 `openspec validate oblige-removing-a-cold-run-worktree --strict` passes
