---
priority: normal
kind: change
waits_on: []
design_with: [task-board]
workstream: see-a-projects-tasks
recorded_by: "the operator"
re_checked: 2026-11-01
---

Nothing short says what a backlog entry or a workstream is: an entry's first sentence runs to 400 characters and a Goal to 345, so a list can show only names. Add an optional `summary` to an entry's frontmatter and a `**Summary**` line to a workstream's shape, in `rules/backlog.md` and `rules/workstreams.md`, expected of new ones and optional on existing ones, and have the `backlog` skill write one when it records. Filling in existing tasks is each project's own, later.

- **Kind**: It owes a `project-bootstrap` delta to the seeded rules and a `backlog-maintenance` delta to **record**, and raises both fragments by a minor version.
- **Recorded by**: the operator, 2026-11-01, when a Goal cut to two lines read badly on `task-board`'s prototype.
