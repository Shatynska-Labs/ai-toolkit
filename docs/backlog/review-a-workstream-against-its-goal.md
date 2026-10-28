---
kind: change
waits_on: []
design_with: []
workstream: complete-the-workstream-loop
recorded_by: "the operator"
re_checked: 2026-10-28
---

`change-plan-reviewer` reviews one change's artifacts; nothing reviews a workstream. Whether its steps together reach its Goal, agree with its Decisions, and leave out what Not in scope says, and whether its Context and Decisions record progress, which `hold-shared-research-in-a-workstream` forbids but nothing checks, is checked by no one when it is opened or when its steps change. BMAD's readiness check does this for its epics against the product requirements and architecture. Add the review and the point in `rules/development-workflow.md` at which it is dispatched, bounded like the plan review. It is an agent of its own, and `change-plan-reviewer` takes a change's workstream file as supplementary evidence, as `complete-the-workstream-loop`'s Decisions record.

- **Kind**: It owes a new capability for the new agent, a `change-review` delta for the workstream file `change-plan-reviewer` takes, and a `session-workflow` delta for when it runs.
- **Recorded by**: the operator, from a comparison of this workflow with BMAD-METHOD (2026-10-25), opening `complete-the-workstream-loop`.
