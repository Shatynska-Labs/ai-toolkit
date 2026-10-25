---
kind: change
waits_on: []
design_with: []
recorded_by: add-change-code-reviewer
re_checked: 2026-10-18
---

`tests/cases/workflow-fragment-no-dangling-reference.sh` scans the workflow fragment for `rules/` paths, fragment filenames and `@` imports, but not for an `ai-toolkit:` agent name with no file under `agents/`. That gap let `build`'s binding name a code reviewer that did not exist, and nothing would report a recurrence.

- **Kind**: It owes a `session-workflow` delta to the publication requirement the case guards.
- **Recorded by**: `add-change-code-reviewer` (design decision 8), which split it out of its own backlog entry.
