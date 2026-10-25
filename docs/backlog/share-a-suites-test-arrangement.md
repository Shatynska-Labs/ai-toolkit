---
kind: change
waits_on: []
design_with: [record-this-repositorys-shared-test-arrangement]
recorded_by: state-the-committed-artifact-situation
re_checked: 2026-10-19
---

`skills/testing` gains guidance on a suite's shared test arrangement: where fixture builders live, when a bespoke one is warranted, how a keep is recorded, and how a pointer to a shared type is spelled so a later sweep can match it. Migration-sweep material goes in `skills/testing/references/`, which does not exist yet. `commerce-ops` has proved the body (`tests/support/`, a project-local skill, `docs/test-harness-sweeps.md`); promote its project-agnostic rules. `hand-missing-test-arrangement-to-apply` has since shipped how a derivation feeds a shared arrangement — the test writer's **Missing shared arrangement** manifest section and the promote-or-keep step in **apply** — so this entry covers what a good shared arrangement is, and how a kept double is marked in source, and refers to that section rather than restating it. Settle two things rather than inherit them: that consolidating a keep is its own change, since a test author only adds, and whether *a source comparison can only veto a migrate, execution only a keep* holds beyond Python.

- **Kind**: Too large, and both questions are decisions.
- **Recorded by**: `state-the-committed-artifact-situation` (proposal, *Non-Goals*; design decision 3, which folds this into `testing`).
