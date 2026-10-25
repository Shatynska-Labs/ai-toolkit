---
priority: normal
kind: change
waits_on: [one-file-per-backlog-entry]
design_with: []
workstream: see-the-backlog-across-projects
recorded_by: one-file-per-backlog-entry
re_checked: 2026-10-25
---

A read-only board over the backlogs and workstreams of one or more repositories on the directory shape: each project's entries in columns by status derived from the repository (planned, recorded, in flight, done), grouped by workstream, and a graph of the links between entries (`waits_on`, `design_with`, workstream steps) across projects. It is served locally, regenerated on each request, or written as one self-contained HTML file, and it offers the same model as JSON for agents. It reads `docs/backlog/`, `docs/workstreams/`, `openspec/changes/`, the working trees and branches, and the forge's pull requests read-only; it never stores a status. The operator asked for it on 2026-10-25 to keep parallel work across projects findable.

- **Kind**: it adds a new shipped tool and its capability, and needs the operator's decision on its language: a Python script run by `uv` conflicts with `AGENTS.md`'s rule that using the library requires nothing installed.
- **Recorded by**: `one-file-per-backlog-entry` made the entries readable by a program and left the board to its own change, as the workstream's next step.
