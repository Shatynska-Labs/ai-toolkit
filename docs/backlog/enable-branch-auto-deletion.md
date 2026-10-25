---
kind: change
waits_on: []
design_with: []
recorded_by: "the operator"
re_checked: 2026-10-21
---

A change's branch outlives its merged pull requests on the forge: `rules/development-workflow.md` removes it locally and on the remote only after the archive pull request merges, and a session can be refused that remote deletion, or end before it. GitHub's repository setting "Automatically delete head branches" (`delete_branch_on_merge`) removes a branch as each of its pull requests merges; the archive step's push recreates it, so the workflow is unaffected. Have `skills/project-init` offer to enable it, on the operator's confirmation since it changes a hosted repository: after step 5's first push in a new project, and in an adoption whose remote is already configured. Only a GitHub remote with `gh` authenticated; otherwise state that the setting is enabled by hand, without failing the run. `scripts/project-init` stays deterministic and touches no forge.

- **Kind**: It owes a `project-bootstrap` delta to "A wrapper connects a remote only from a URL the operator supplies", whose wrapper today configures nothing on the hosted repository.
- **Recorded by**: the operator, after Basis's `add-identity-authentication` archive left other changes' merged branches on GitHub; it is this repository's work, not Basis's.
