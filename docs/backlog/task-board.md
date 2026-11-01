---
priority: normal
kind: change
waits_on: []
design_with: [give-tasks-a-summary]
workstream: see-a-projects-tasks
recorded_by: one-file-per-backlog-entry
re_checked: 2026-11-01
---

A read-only tool that writes one self-contained HTML file for the project it is run in. It opens with every task in flight, its stage and the workstream it belongs to. Each open workstream is a group listing its steps in order with their status (done, in flight, recorded, planned); a step with no backlog entry shows by its name and description, and an entry naming the workstream that no step names shows as unplaced. Entries naming no workstream sit in a collapsed group. It reads `docs/backlog/`, `docs/workstreams/`, `openspec/changes/`, branches and the forge's pull requests read-only, applies the status lookups this library's `rules/workstreams.md` states, in their order, as the `backlog` skill's **workstreams** operation does, says so where the forge cannot be reached, and never stores a status. The operator asked for it on 2026-10-25 to keep parallel work findable, and narrowed it to one project, seen through workstreams, on 2026-11-01.

- **Kind**: it adds a new shipped tool and its capability; its form is decided in `see-a-projects-tasks`'s Decisions.
- **Recorded by**: `one-file-per-backlog-entry` made the entries readable by a program and left the board to its own change, as the workstream's next step.
