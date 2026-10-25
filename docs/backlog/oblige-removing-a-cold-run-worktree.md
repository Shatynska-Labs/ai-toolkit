---
kind: change
waits_on: []
design_with: []
recorded_by: add-session-workflow-fragments
re_checked: 2026-10-18
---

`agent-authoring` requires the cold-run check to run in an isolated git worktree and states no removal. The workflow's removal rules are keyed to a change, so a worktree carrying none falls outside them, and nothing obliges anyone to remove it. Add a removal clause to `agent-authoring`, or name what else takes the obligation.

- **Kind**: It owes an `agent-authoring` delta.
- **Recorded by**: `add-session-workflow-fragments`, whose sixth review round found the collision.
