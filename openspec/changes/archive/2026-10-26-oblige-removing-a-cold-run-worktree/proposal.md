## Why

`agent-authoring` requires the live half of a write-capable agent's cold-run check to run in an isolated git worktree, and says how to create and populate it, but nothing about removing it. The development workflow's removal rules are keyed to a change: a working tree goes once the change's pull requests have merged. A cold-run worktree belongs to no change and opens no pull request, so it falls outside those rules, and nothing obliges anyone to remove it. Each run that leaves one behind adds a stale checkout holding an untracked agent definition and whatever the run wrote, and a later run of the same agent that reuses the path starts from that residue rather than from a clean tree.

`add-session-workflow-fragments` found the gap in its sixth review round and recorded it as the backlog entry `oblige-removing-a-cold-run-worktree`. This change advances no workstream.

## What Changes

- The cold-run isolation requirement gains a removal obligation: the worktree a run created is removed once the run's outcome has been read from it, whether the run passed, failed or was aborted, and before the agent is reported complete.
- A failing run's worktree is removed before the revised body is run again, which runs in a fresh worktree, so the next run does not start from the previous run's writes.
- Removal is made from the authoring checkout, discards the worktree's contents, and deletes any branch created with the worktree.
- `skills/create-agent/references/cold-run-check.md` states the removal step beside the creation steps, and `skills/create-agent/SKILL.md`'s summary of the isolation names it.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `agent-authoring`: *Cold runs are isolated when the agent can write* — adds the obligation to remove the worktree, when it is removed, and how.

## Impact

- `openspec/specs/agent-authoring/spec.md`, through the delta.
- `skills/create-agent/references/cold-run-check.md` and `skills/create-agent/SKILL.md`.
- New cases under `tests/cases/` derived from the delta, and `tests/coverage.md`.
- `docs/backlog/oblige-removing-a-cold-run-worktree.md` is deleted when the change is archived.
- Nothing in `rules/development-workflow.md` changes: its removal rules stay keyed to a change.
