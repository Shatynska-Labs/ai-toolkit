## Why

`change-plan-reviewer` reviews one change's artifacts, and nothing reviews a workstream. Whether its steps together reach its Goal, agree with its Decisions and leave out what Not in scope says, whether Done when is an effect someone can observe, and whether Context and Decisions record progress, which `docs/workstreams/AGENTS.md` forbids, are checked by no one when it is opened or when its steps change. A plan above a single change has none of the guarantees a change has.

**Workstream**: `complete-the-workstream-loop`, of which this change is a step. Its Decision 2 fixes the shape: an agent of its own, sharing `change-plan-reviewer`'s severity scale and verdict mapping, and a change's workstream file as supplementary evidence to `change-plan-reviewer`.

## What Changes

- **A new agent, `workstream-reviewer`.** It reads one workstream, the workstream rules and the artifacts of its steps, and reports whether the steps cover the Goal, whether Done when is observable, whether the steps agree with the Decisions and stay out of Not in scope, and whether Context and Decisions record progress. It is read-only and ends in one verdict from the set `change-plan-reviewer` uses.
- **`change-plan-reviewer` takes a workstream file.** A supplementary input, read as evidence, so a change is checked against the Decisions of the workstream it serves. A change contradicting one is a finding unless its proposal states that it overturns it, which the workstream rules allow.
- **The workflow says when.** Both workflow fragments gain a rule under Throughout: a workstream is reviewed before the commit that opens it, and before a commit whose edit changes its plan: its steps or what they do, what it is for, what finishes it, what it leaves out or what it has decided. The loop is bounded at six rounds. The plan review's role and binding supply the workstream the proposal names.
- **Versions.** `development-workflow` rises to `2.2.0`, `development-workflow-direct` to `1.2.0` and the plugin to `2.2.0`. None asks a project to edit anything by hand.

## Capabilities

### New Capabilities

- `workstream-review`: what a review of a workstream must establish and how it reports.

### Modified Capabilities

- `change-review`: *Review operates on a dispatched change* and *Conclusions declare their evidence level*, and a new requirement checking a change against its workstream's Decisions.
- `session-workflow`: a new requirement stating when a workstream is reviewed and what the plan review is supplied.

## Impact

- `agents/workstream-reviewer.md` and `agents/workstream-reviewer.checks.yaml`, new.
- `agents/change-plan-reviewer.md` and its recorded checks, which a description and body edit invalidate, and whose trigger check the new agent competes with.
- `rules/development-workflow.md`, `rules/development-workflow-direct.md` and `rules/changelog`.
- `.claude-plugin/plugin.json`.
- `tests/coverage.md` and derived cases.
- Consumers: `scripts/project-update` replaces an unedited block and prints the changelog lines. A workstream already open is first reviewed at its next edit of the kind the rule names. A project without the plugin reads the role and has no agent to dispatch, as for every other agent these fragments bind.
