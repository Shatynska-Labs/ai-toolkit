---
kind: change
waits_on: []
design_with: [review-a-workstream-against-its-goal]
workstream: complete-the-workstream-loop
re_checked: 2026-10-25
---

The seeded `docs/workstreams/README.md` asks Done when for "a condition that can be checked against the repository, the forge or production", and "every step is archived" satisfies it while proving only that the step list was worked through, not that the Goal holds; a step list missing a step meets it all the same. Three of commerce-ops's four open workstreams use that form; `purchase-order-process` shows the stronger one, a staging observation of the Goal. The README directs Done when to name an observable effect of the Goal, alongside the steps being archived where that is wanted.

- **Kind**: It owes a `project-bootstrap` delta to the seeded README.
- **Design with**: `review-a-workstream-against-its-goal`, which checks it.
- **Recorded by**: the operator, from a comparison of this workflow with BMAD-METHOD (2026-10-25), opening `complete-the-workstream-loop`.
