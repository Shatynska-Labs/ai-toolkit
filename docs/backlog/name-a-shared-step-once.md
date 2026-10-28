---
kind: change
waits_on: []
design_with: [count-a-fix-step-as-done]
workstream: complete-the-workstream-loop
recorded_by: "the operator"
re_checked: 2026-10-25
---

A change can be a step of two open workstreams: in commerce-ops, `serve-a-subject-other-than-a-launch` is step 1 of both `purchase-order-process` and `unit-economics-beyond-the-launch`. The status row's workstream field reads "the open one whose steps name the change" (`rules/development-workflow.md`, *Reporting where the change stands*), which is singular, so the row is ambiguous for that change, and the archive re-read does not say which workstream places its entries. BMAD avoids it by giving a story exactly one epic. Decide the rule: the change is listed in one workstream and the other names it through a backlog entry's Waits on, or the row names every workstream listing it.

- **Kind**: It owes a `session-workflow` delta to the status row and the archive re-read, and a `project-bootstrap` delta to the seeded `docs/workstreams/AGENTS.md`. The choice is the operator's.
- **Recorded by**: the operator, from a comparison of this workflow with BMAD-METHOD (2026-10-25), opening `complete-the-workstream-loop`.
