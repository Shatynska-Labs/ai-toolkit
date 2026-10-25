---
priority: normal
kind: change
waits_on: []
design_with: []
recorded_by: add-workstreams
re_checked: 2026-10-24
---

`session-workflow`'s *A session reports where its change stands before acting* requires the entering report to carry one further cell, the verification result, beyond the change, stage, task progress and committed state. `rules/development-workflow.md`'s row template and its example carry no such cell, so a session following the fragment prints a row the requirement calls incomplete. Decide which side is right, and bring the requirement or the fragment's row into line with it.

- **Kind**: It owes a `session-workflow` delta, or a fragment edit and version increment, and the choice between them is the operator's.
- **Waits on**: `add-workstreams`, archived 2026-10-24, gave the row its leading workstream cell and kept this disagreement as it found it.
- **Recorded by**: `add-workstreams`, whose plan review found the disagreement (2026-10-24); widening the row twice in one change was kept out of its scope.
