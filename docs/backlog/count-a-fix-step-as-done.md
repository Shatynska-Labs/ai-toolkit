---
priority: normal
kind: change
waits_on: []
design_with: [name-a-shared-step-once]
workstream: complete-the-workstream-loop
recorded_by: "commerce-ops's adopt-workstreams plan review"
re_checked: 2026-10-24
---

A workstream step taken as a fix leaves no archived change, and its backlog entry is deleted when it is taken. By `docs/workstreams/AGENTS.md`'s status lookups it then reads as `planned` again, and **workstreams** names it as next. Work that is done reads as work to do, and a workstream whose Done when is "every step archived" can never be met while it holds a fix. commerce-ops's `adopt-workstreams` works around it locally: its `speed-up-the-test-suite` removes a fix step from Steps in the fix's own commit. Decide the rule for every project. Options: the seeded README directs that removal; a fix's merged pull request counts as `done`; or a workstream holds only changes.

- **Kind**: It owes a `project-bootstrap` delta to *A workstream register is seeded where none exists*, and likely a `backlog-maintenance` delta to **workstreams**. The choice between the options is the operator's.
- **Recorded by**: commerce-ops's `adopt-workstreams` plan review (2026-10-24), which found four fix steps in one of its workstreams. The rule is the library's, not that project's.
