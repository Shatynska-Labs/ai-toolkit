---
priority: normal
kind: change
waits_on: []
design_with: []
workstream: see-a-projects-tasks
recorded_by: "the operator"
re_checked: 2026-11-01
---

Most backlog entries belong to no workstream, and the `backlog` skill records and closes entries but has no operation for gathering them into one, so it is done by hand-editing each entry's `workstream` and the workstream's steps. Add an operation that takes entries with no workstream and groups them into a new or an existing workstream, asking the operator for a new workstream's Goal and Done when, and one that moves a task from one workstream to another. Both carry out what `docs/workstreams/AGENTS.md` states: an entry's `workstream` and the steps naming it agree, a change remains a step of one workstream only, and a new workstream is opened only on the operator's decision that the goal needs more than one change.

- **Kind**: It owes a `backlog-maintenance` delta for the new operations.
- **Recorded by**: the operator, 2026-11-01, when the board was kept read-only and changing tasks was left to the skill.
