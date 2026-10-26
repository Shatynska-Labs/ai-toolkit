---
kind: change
waits_on: []
design_with: []
recorded_by: "run-the-remaining-arrangement-cold-runs, a backlog fix with no change of its own"
re_checked: 2026-10-26
---

In the cold run of `agents/change-test-writer.checks.yaml` arrangement variant (d), where the shared arrangement holds every double and builder the scenarios need, the agent took all of them from `tests_support/` but also declared a convenience helper wrapping the shared `FakeClock`, and recorded it in the manifest's **Missing shared arrangement** section with a proposed home. The variant's criterion says the agent "declared nothing locally" and the section "states that nothing was declared locally", so the run fails on its letter. `agents/change-test-writer.md` does not bar such a wrapper: it requires a local declaration only where arrangement is missing, and requires every local declaration to be recorded, which the agent did. Decide whether a local helper over shared arrangement is missing arrangement — then the body says when it may be declared — or is outside the section, and revise the body or the (d) criterion to match.

- **Kind**: It needs the operator's decision, and a body revision owes a `change-test-authoring` delta.
- **Recorded by**: The cold-run backlog entry was a fix owing no delta and no decision; a failing run's revision was to be a change of its own.
