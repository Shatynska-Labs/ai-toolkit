---
kind: change
waits_on: []
design_with: []
workstream: none
recorded_by: "the operator"
re_checked: 2026-11-01
---

The operator holds staging with production reached only by promotion as the ordinary shape, and a repository with no production, such as this one, or whose job is that every server runs, such as `infrastructure`, as the exception. `rules/development-workflow.md` states the reverse: one deploy triggered by merging. Make the promoting workflow the default, taken from `fuperia/commerce-ops`'s `v12` block without what is that project's alone (`publish-prompts`, the name `promote.yml`), and with "previous release" meaning what production runs. Keep the one-deploy `ship` as a variant named `development-workflow-direct`. The two share everything but `ship`, about 4 KB of 18 KB, so one shared text with a `ship` section per variant rather than two copies. `project-init` writes the default unless told otherwise, and `project-update` keeps the variant the marker names.

- **Kind**: It owes `project-bootstrap` and `project-update` deltas and a change to a fragment every project receives.
- **Migration**: `fuperia/commerce-ops` stays on `v12` until this ships. A project already at `development-workflow` `1.0.0` that wants the one-deploy `ship` switches by hand once, so the release is a major one.
- **Recorded by**: the operator, when confirming `update-managed-block` found `fuperia/commerce-ops` keeping its stages inside the block; the shared-text design is proposed and not yet confirmed.
