---
kind: change
waits_on: []
design_with: [discriminate-every-scan-in-the-static-suite]
recorded_by: state-the-committed-artifact-situation
re_checked: 2026-10-18
---

`change-test-authoring`'s manifest gains entries for what a fixture-driven discriminator falsifies, a check left without a discriminator, a discriminator written but not executable where it was authored, and a repeat pass carrying forward entries still outstanding. The carry-forward needs the earlier `test-plan.md`, an optional dispatch input the agent may not go looking for, so it either reaches the requirements bounding the agent's inputs or needs a dispatcher-facing signal. Key the exception to the check's state, not how the pass produced it.

- **Kind**: It owes `change-test-authoring` deltas across several requirements, which six review rounds found too large to fold into the change that raised it.
- **Recorded by**: `state-the-committed-artifact-situation` (proposal, *Non-Goals*; design decision 4).
