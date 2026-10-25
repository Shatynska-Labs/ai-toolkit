---
kind: change
waits_on: []
design_with: []
recorded_by: consolidate-development-workflow
re_checked: 2026-10-18
---

`scripts/project-init` writes only the `rules/development-workflow.md` block, so `rules/development-workflow-database.md` reaches a project by `@` import or by hand, carrying a `version` nothing increments. The tool learns a workflow variant that writes the database binding as a second managed block, and reports version skew per block.

- **Kind**: It owes a `project-bootstrap` delta for the second block and per-block skew.
- **Waits on**: The open change `update-managed-block` must locate a block by its own marker rather than assume one per file, so the two are designed together.
- **Recorded by**: `consolidate-development-workflow` (proposal, *Follow-up*; design decision 3, which fixes the block composition), which produced the binding fragment and left the tooling out of scope.
