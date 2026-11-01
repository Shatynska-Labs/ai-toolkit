---
kind: change
waits_on: []
design_with: []
workstream: none
recorded_by: update-managed-block
re_checked: 2026-11-01
---

Prettier's check failed on the generated `docs/backlog/AGENTS.md` and `docs/workstreams/AGENTS.md` in `shatynska/basis`, and running its fix would change a block's hash, which `scripts/project-update` then reports as an edit. `basis` ignores the two files in its `.prettierignore`. A project running a formatter meets this with no warning, so either the fragments are written to pass one, or `project-init` and `project-update` name the files to ignore.

- **Kind**: It needs a decision between those two, and owes a `project-bootstrap` delta if a tool reports it.
- **Recorded by**: `update-managed-block`, whose confirmation met it in `shatynska/basis`; outside its Impact.
