---
kind: fix
waits_on: []
design_with: [seed-the-worktree-ignore-entry]
recorded_by: seed-the-backlog
re_checked: 2026-10-18
---

`scripts/project-init` tests `.gitignore` with `-f`, so a dangling link reads as absent and the heredoc writes through it to wherever it points. The backlog step already tests `[ -e ] || [ -L ]` for this reason; the ignore file should match.

- **Kind**: No delta, no decision, one line and a test case.
- **Recorded by**: `seed-the-backlog`'s code review; outside that change's scope.
