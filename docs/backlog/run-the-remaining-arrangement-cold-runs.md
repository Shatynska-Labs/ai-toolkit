---
kind: fix
waits_on: []
design_with: []
recorded_by: hand-missing-test-arrangement-to-apply
re_checked: 2026-10-19
---

`agents/change-test-writer.checks.yaml` and `agents/change-code-reviewer.checks.yaml` carry arrangement variants (b)–(d) and (b)–(e) that `hand-missing-test-arrangement-to-apply` did not run: conventions silent on the shared arrangement, stating none, recording no glob, no change name, and nothing missing. Run each and record any body revision it forces.

- **Kind**: No delta and no decision, unless a run fails — then the revision is a change of its own.
- **Recorded by**: `hand-missing-test-arrangement-to-apply` (design decision 10), which ran only variant (a) of each, by the operator's decision to limit usage.
