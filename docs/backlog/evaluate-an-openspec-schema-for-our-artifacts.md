---
kind: change
waits_on: []
design_with: []
recorded_by: consolidate-development-workflow
re_checked: 2026-10-18
---

`test-plan.md` and a reviewer's report are files the `spec-driven` schema does not know, so `openspec status` and `openspec instructions apply` never surface them, and `change-test-authoring` has to tell the agent to read `test-plan.md` deliberately. A custom or forked schema (OpenSpec documents `anvil`, which declares `test-plan.md`, `review.md` and `verify.md`) would surface them. Evaluate adopting or forking one, and what it costs every change; adding bespoke verdict files without a schema would bring back the ledger `consolidate-development-workflow` removed.

- **Kind**: Adopting a schema is the operator's decision.
- **Recorded by**: `consolidate-development-workflow` (design decision 6; its archived `handoff.md`, the vocabulary survey).
