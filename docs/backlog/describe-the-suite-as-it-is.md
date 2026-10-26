---
kind: change
waits_on: []
design_with: []
recorded_by: state-the-committed-artifact-situation
re_checked: 2026-10-18
---

`AGENTS.md` describes `tests/` as "a dependency-free harness exercising `scripts/`", but about half its cases never run `scripts/project-init`: they read `skills/`, `agents/` or `rules/` and assert what a file says. `tests/README.md` and `tests/coverage.md` carry the same description, so correcting one leaves the others to mislead. Decide whether static-read cases are in scope and say so in all of them, and settle whether an obsolete case is deleted or rewritten, which no convention records.

- **Kind**: Both are the operator's decisions.
- **Recorded by**: `state-the-committed-artifact-situation`'s and `consolidate-development-workflow`'s `test-plan.md`, *Unresolved project questions*; outside both changes' Impact.
