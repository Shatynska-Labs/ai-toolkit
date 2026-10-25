---
priority: parked
parked_until: "no consuming project has a docs/backlog.md: commerce-ops, fuperia/infrastructure, shatynska/infrastructure, infrastructure-template, basis, subscribed-agent, subscribed-agent-platform and this repository are all on docs/backlog/"
kind: change
waits_on: []
design_with: []
workstream: none
recorded_by: one-file-per-backlog-entry
re_checked: 2026-10-25
---

`scripts/backlog-migrate` exists to convert each project's single-file backlog once. When the last project has converted, retire it whole: the tool, its 28 `tests/cases/backlog-migrate-*.sh` cases, the `backlog-migration` capability, `project-init`'s report for a single-file backlog, which names the tool, and the `backlog` skill's refusal of one, which does too. Retiring the tests alone would leave a shipped tool unchecked, and retiring nothing leaves a dead tool, its spec and its pointers in every consumer's plugin. Three infrastructure backlogs must first rename `assert-every-role-has-a-mock_roles-entry`, whose underscore the tool blocks on, and infrastructure-template matters most: projects made from it carry its backlog.

- **Kind**: it removes the `backlog-migration` capability and modifies `project-bootstrap` and `backlog-maintenance`.
- **Priority**: parked because seven projects still have to convert, and the tool and its tests guard each of those conversions; the operator asked for this entry on 2026-10-25, when the tests were read as one-off.
- **Recorded by**: `one-file-per-backlog-entry` shipped the converter for the projects it had not converted yet.
