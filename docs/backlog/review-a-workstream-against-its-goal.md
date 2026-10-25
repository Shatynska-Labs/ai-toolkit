---
kind: change
waits_on: []
design_with: [observe-what-finishes-a-workstream]
workstream: complete-the-workstream-loop
recorded_by: "the operator"
re_checked: 2026-10-25
---

`change-plan-reviewer` reviews one change's artifacts; nothing reviews a workstream. Whether its steps together reach its Goal, agree with the document its Decisions names, and leave out what Not in scope says, is checked by no one when it is opened or when its steps change. BMAD's readiness check does this for its epics against the product requirements and architecture. Add the review and the point in `rules/development-workflow.md` at which it is dispatched, bounded like the plan review. Whether it is a second mode of `change-plan-reviewer` or an agent of its own is open.

- **Kind**: It owes a `change-review` delta, or a new capability for a new agent, and a `session-workflow` delta for when it runs; the choice between the two forms is the operator's.
- **Recorded by**: the operator, from a comparison of this workflow with BMAD-METHOD (2026-10-25), opening `complete-the-workstream-loop`.
