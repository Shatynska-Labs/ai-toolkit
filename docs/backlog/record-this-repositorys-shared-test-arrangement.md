---
kind: change
waits_on: []
design_with: [share-a-suites-test-arrangement]
recorded_by: hand-missing-test-arrangement-to-apply
re_checked: 2026-10-28
---

This repository's `AGENTS.md` records no test command, test-path glob or shared test arrangement, so its own changes dispatch `change-test-writer` from values supplied by hand, and the arrangement audit's import check cannot run here. Record all three — `bash tests/run.sh`, `tests/cases/**`, and `tests/lib.sh` as the shared arrangement — then merge `tests/cases/lib/static-scan.sh` into `tests/lib.sh` (it lies inside the glob, so it is a test module) and move the scan helper `hand-missing-test-arrangement-to-apply`'s five cases each declare locally onto it. That change's `test-plan.md` lists the helper as kept for exactly this reason. Since `list-the-entry-fields` (2026-10-25), seven seeded-backlog cases each carry an identical local `fenced_field`, kept for this reason; once the arrangement is recorded they move to `tests/lib.sh` beside `fenced_line`. Since `reconcile-commit-rule-with-spec` (2026-10-27), three `workflow-fragment-*` cases (`handoff-branch-committed`, `prose-one-line`, `prose-structure-exception`) each declare a line-scan helper locally (`lscan`/`lselect`/`lcheck`/`ldiscriminate`), kept for this reason; once the arrangement is recorded they move onto it, as `tests/cases/lib/line-scan.sh` offers the same scan. Since `describe-commits-and-pull-requests` (2026-10-28), fifteen cases (the eleven `commits-and-pull-requests-skill-*`, `workflow-fragment-open-pr-binds-commits-and-pull-requests`, `workflow-fragment-no-pull-request-format`, `project-foundation-pull-request-concern` and `project-foundation-development-tooling-pull-requests-item`) each declare an identical line-scan helper locally (`sc_run`/`sc_hits`/`sc_check`/`sc_discriminate`/`sc_body`), kept for this reason; once the arrangement is recorded they move onto it as well.

- **Kind**: Moving the scan helpers edits existing tests beyond the bounded promotion permission, and which file is the shared arrangement is a testing-strategy decision.
- **Recorded by**: `hand-missing-test-arrangement-to-apply`, whose apply rule keeps every entry where the conventions record no shared arrangement.
