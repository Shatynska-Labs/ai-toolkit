---
kind: change
waits_on: []
design_with: []
recorded_by: name-initial-branch-main
re_checked: 2026-10-18
---

`scripts/project-init` leaves undecided what happens to a `.git` git cannot open: a corrupt or missing `HEAD`, or a `.git` holding only non-repository content, is reinitialized by `git init` and reported as created, which can move the branch. A readable repository git refuses for `safe.directory` (common on WSL `/mnt/c`) is misreported the same way. One repository probe used for both the report and the mode would remove the disagreement. `initial-branch-missing-head-not-rewritten.sh` and `initial-branch-corrupted-head-not-rewritten.sh` need hardening alongside: the first asserts only `!= main`, and both guard with `git -C`, which can discover a repository above `$TESTDIR`.

- **Kind**: It needs the operator's decision between refusing, reporting and leaving such a directory alone, and owes a `project-bootstrap` delta.
- **Recorded by**: `name-initial-branch-main` (design decision 5; `test-plan.md`, open questions), which kept to the branch name.
