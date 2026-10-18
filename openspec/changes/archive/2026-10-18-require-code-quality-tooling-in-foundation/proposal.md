## Why

In `basis`, `project-init` and then `project-foundation` both ran to completion and left the project with no linter or formatter configuration, no hooks, no continuous integration and no branch protection. Foundation's `Development Tooling` section recorded decisions — but "linting, formatting, build tooling, and any other development-time tooling" is too loose to guarantee the quality layer is ever discussed, and foundation's only concrete tooling deliverable is extending the ignore file, so nothing owned turning the decisions into files. A whole separate change built them afterwards, after the operator had asked whether any ai-toolkit skill would. Both gaps are in this library: coverage (what foundation must reach) and delivery (who builds what it decides).

## What Changes

- The development-tooling decision gains a fixed set of named items, each answered or marked not applicable with a reason: linting, formatting, type checking, build tooling, local hooks, commit-message convention, secret handling, dependency updates and audit, the continuous-integration gate, toolchain pinning, branch protection, and provisioning. Every item names a concern, never a tool. All items are proposable, not elicited — "converse, don't interrogate" is unchanged.
- Three items carry a fixed position rather than an open choice, absorbed from the backlog entry `move-setup-gates-to-project-setup`: continuous integration is the authority and fails rather than skips on a dependency it cannot reach; a local hook is not a gate, so its silence is not a pass; secrets are kept out of version control by the ignore file, which foundation extends with the stack's secret-bearing paths.
- Branch protection is decided and recorded by foundation; where a policy is decided, it is applied by the change that introduces continuous integration, as a task the operator confirms. `project-init` is unchanged.
- Foundation does not archive until its tooling decisions have a named owner: it opens a successor change — its own branch and `handoff.md`, per the workflow's rule for a second change surfacing — that builds the decided tooling and the decided test runner where absent, reading the decisions from `AGENTS.md` rather than from the soon-archived `design.md`. Foundation itself stays decision-only and keeps its test-authoring exemption; the successor is not exempt.
- `rules/project-foundation.md` and `skills/project-foundation/SKILL.md` are updated to match; the `move-setup-gates-to-project-setup` backlog entry is deleted when this change archives.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `project-foundation`: the fixed-decisions requirement names the development-tooling concerns; the coverage requirement's `Development Tooling` section gains named items and admits a reasoned "not applicable"; three new requirements fix the three setup positions, state that foundation decides branch protection and does not apply it, and require a named successor owner before foundation archives.

## Impact

- `rules/project-foundation.md` (procedural checklist, unversioned — never inlined, so no skew to report), `skills/project-foundation/SKILL.md`.
- `tests/coverage.md` accounts for the modified and added scenarios, and for the four existing "Settled decisions are surfaced…" scenarios it currently omits; like every existing `project-foundation` scenario they are verified by structural review, since `tests/cases/` exercises `scripts/` and foundation has no script.
- `docs/backlog.md`: `move-setup-gates-to-project-setup` is deleted at archive, its three open obligations having a home in `project-foundation`.
- No change to `scripts/project-init`, `skills/project-init/SKILL.md`, `project-bootstrap`, or the workflow fragment. Projects that already archived a foundation are unaffected — foundation is a historical record.
