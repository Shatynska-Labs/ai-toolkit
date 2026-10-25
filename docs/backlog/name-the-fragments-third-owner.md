---
kind: change
waits_on: []
design_with: [reconcile-commit-rule-with-spec]
recorded_by: add-change-code-reviewer
re_checked: 2026-10-18
---

`session-workflow`'s Purpose and its publication requirement name `session-workflow` and `project-bootstrap` as the workflow fragment's owners. `change-code-review` also governs one sentence of it, the content of `build`'s Claude Code binding, and an editor starting from `session-workflow` will not learn that. Name the third owner there.

- **Kind**: It owes a `session-workflow` delta; too small to be a change alone, so it goes in with the next change amending that specification.
- **Recorded by**: `add-change-code-reviewer` (design decision 7 and Risks), which created the third owner and kept `session-workflow` out of its scope.
