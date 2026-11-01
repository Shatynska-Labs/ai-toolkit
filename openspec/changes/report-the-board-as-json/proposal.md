## Why

The page `scripts/task-board` writes is a snapshot of one project, and the operator wants a tab kept open over several projects, always fresh. That is a local application, `dev-task-board`, in a repository of its own, since `AGENTS.md` promises that using this library needs nothing installed. For the application to show tasks without restating the workstream rules, this tool has to hand over what it derives as data. The rules then keep one implementation.

**Workstream**: `see-a-projects-tasks`, its third step.

## What Changes

- **`--json`.** The tool prints what it derives for one project as one JSON document on standard output, in place of writing a page: its workstreams, every task with its status, stage, placement and last commit, and what could not be read.
- **The document carries a version.** `schema_version` is an integer that rises when a field changes meaning or goes, so a reader can refuse a shape it does not know.
- **The report moves to standard error under `--json`**, so standard output stays one parseable document. Exit codes and outcomes keep their meaning. Without `--json`, nothing changes.
- **This repository's plan.** `see-a-projects-tasks` gains this step and records that the live view belongs to `dev-task-board`, revising its Decisions on a server and on one project.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `task-board`: gains a requirement for the JSON document. *The tool reports its outcome* states where the report goes under `--json`, and *The tool writes one self-contained page for one project* applies without it.

## Impact

- **Changed:** `scripts/task-board`, which derives once and renders the model as a page or as JSON; `tests/README.md`; `tests/coverage.md`.
- **New:** `tests/cases/task-board-json-*.sh`.
- **Dependencies:** none. A case may use `python3` or `jq` to parse the output only where present, so the suite needs neither.
- **Consumers:** the page is unchanged. `dev-task-board` will carry a pinned copy of the tool and check `schema_version`.
