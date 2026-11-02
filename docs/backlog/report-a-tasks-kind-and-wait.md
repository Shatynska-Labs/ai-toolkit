---
priority: normal
kind: change
waits_on: []
design_with: []
workstream: none
recorded_by: "the operator, using dev-task-board on 2026-11-02"
re_checked: 2026-11-02
---

`scripts/task-board --json` gives a task's `priority` and `waits_on` but not its `kind` or `waits_for`, so a reader cannot tell a fix from a change, and most of what an entry waits on is missing: in `commerce-ops`, 21 entries carry `waits_for` and 8 a named `waits_on`. Add `kind` and `waits_for` to each task, each `null` where the task has no entry or the entry has no such value, and show them on the HTML page as `waits_on` is shown. `parked_until` is the same kind of gap and worth deciding in the same change. New fields keep `schema_version` at 1, which rises only when a field goes or changes meaning.

- **Kind**: it owes a delta to `specs/task-board/spec.md`, on both the page and the JSON document's keys.
- **Recorded by**: seen in use on `dev-task-board`, whose `show-a-tasks-kind-and-wait` needs these fields.
