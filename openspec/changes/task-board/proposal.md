## Why

A project's tasks are spread across `docs/workstreams/`, `docs/backlog/`, `openspec/changes/`, branches and pull requests. The `backlog` skill's **workstreams** operation reports them in a session, one answer at a time, but nothing shows them all at once, so with parallel sessions the operator holds the picture in memory. commerce-ops has 18 workstreams and 101 entries.

**Workstream**: `see-a-projects-tasks`, its second step. Its Decisions fix the board's scope and form: one project, grouped by workstream, read-only, a bash tool writing one HTML file.

## What Changes

- **A new shipped tool, `scripts/task-board`.** Run in a project, it writes one self-contained HTML file and prints where.
- **What is in work comes first.** The page opens with every task in flight, each with the stage it has reached, the workstream it belongs to, or none, and a link to that workstream's group.
- **Changes, workstreams and backlog entries are one view.** A task of one name is one task, and in what is in flight it shows which of these it has: a step, an entry, a change, a branch, a pull request. Every task shows its last commit and, where it has one, its summary.
- **Workstreams come next, the active ones first.** Each active workstream is a closed row with its progress, opening to its Goal, Done when and steps in order, each with its status. Workstreams with nothing in work sit together in one collapsed row. A step that is only a name shows as planned.
- **Every other task is shown too.** An entry or open change that names a workstream without being one of its steps shows there as unplaced. One that belongs to no workstream sits in a collapsed group, as does one naming a workstream that is not open, and so does a branch or open pull request in flight that matches no other task, so a new change is visible before its first pull request merges.
- **Status is derived, never stored.** The tool applies the lookups this library's `rules/workstreams.md` states, in their order, and says so on the page where the forge could not be reached.
- **It changes nothing in the project.** Grouping and moving tasks is `group-tasks-into-workstreams`, a later step.

## Capabilities

### New Capabilities

- `task-board`: the tool that writes a project's board: what it reads, how each task is placed and given a status, what the page shows, and how it reports failure.

### Modified Capabilities

None.

## Impact

- **New:** `scripts/task-board` and its `tests/cases/task-board-*.sh`. `prototype/` in this change holds the generator and page the layout was agreed from, run on real data, and is not shipped.
- **Documentation:** `tests/README.md` gains the tool and its report contract, and `tests/coverage.md` its cases.
- **Dependencies:** bash, awk, sed, tar and git. `gh` is used where present and is not required.
- **This repository's plan:** the workstream `see-a-projects-tasks` and the entries `give-tasks-a-summary`, `task-board` and `group-tasks-into-workstreams` are revised in this change's plan commit, replacing `see-the-backlog-across-projects` and `backlog-board`.
- **Consumers:** the tool ships with the plugin and runs in any project on the directory shape. It reaches an installed copy only when the plugin's version rises, which `raise-the-plugin-version-on-release` covers.
