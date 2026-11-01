---
kind: change
waits_on: []
design_with: []
workstream: none
recorded_by: update-managed-block
re_checked: 2026-11-01
---

`rules/test-plan.md` is at `1.0.0`, and adopting projects hold it as a `test-plan` `v3` block in their root `AGENTS.md`, but `rules/manifest` does not list it. `scripts/project-update` therefore never reports or replaces that block, and it stays on `v3` after every update, which `AGENTS.md`'s rule that an update replaces what the manifest lists leaves unreachable.

- **Kind**: It needs the decision whether the fragment is written by the tools at all, and owes `project-bootstrap` and `project-update` deltas.
- **Recorded by**: `update-managed-block`, whose confirmation found the block unchanged in all five adopting projects; outside its Impact.
