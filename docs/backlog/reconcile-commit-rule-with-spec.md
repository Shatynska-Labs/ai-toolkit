---
kind: change
waits_on: []
design_with: [name-the-fragments-third-owner]
recorded_by: "the operator"
re_checked: 2026-10-18
---

`rules/development-workflow.md` directs a session to create commits, not propose them, and `openspec/specs/session-workflow/spec.md` still records the removed behaviour: the requirement at *A second change surfacing* directs "proposing a commit" on a handoff branch with a declined-commit path, and its scenario "A handoff is not left uncommitted on a branch the session leaves" expects "it has proposed a commit". Amend both to committing, and drop the declined path. Decide too whether the fragment's **Markdown prose** rule gets a requirement.

- **Kind**: It owes a `session-workflow` delta, and the Markdown-prose question is the operator's.
- **Design with**: `name-the-fragments-third-owner`, which amends the same specification.
- **Recorded by**: the operator's instruction that agents commit without stopping, applied to the fragment directly without a change, which is why the spec was left behind.
