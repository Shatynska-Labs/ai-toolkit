---
kind: change
waits_on: []
design_with: []
workstream: keep-projects-on-the-current-workflow
recorded_by: consolidate-development-workflow
re_checked: 2026-11-01
---

`scripts/project-init` writes the blocks `rules/manifest` lists, and the manifest does not list `rules/development-workflow-database.md`, so the database binding reaches a project by `@` import or by hand. The tool learns a workflow variant that writes it as one more managed block, a second one in the root `AGENTS.md`, and the update tool reports its version per block.

- **Kind**: It owes a `project-bootstrap` delta for a second block in one target and the variant that selects it. The manifest's `alternative` chooses between two fragments for one block, so it is not this second block, and `--workflow` is a choice this may extend or stand beside.
- **Recorded by**: `consolidate-development-workflow` (proposal, *Follow-up*; design decision 3, which fixes the block composition), which produced the binding fragment and left the tooling out of scope.
