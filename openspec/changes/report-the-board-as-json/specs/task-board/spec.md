## ADDED Requirements

### Requirement: The tool reports the board as JSON

With `--json`, `scripts/task-board` SHALL print one JSON document on standard output and write no page. The document SHALL be derived by the same lookups and placement as the page, so a task reads the same in both, and SHALL be printed only once complete, so a failed run leaves standard output empty. It SHALL hold these keys:

- `schema_version`: integer, `1` for this shape. It SHALL rise when a field is removed or renamed, or a field's meaning or set of values changes. A field added SHALL NOT raise it.
- `project`: string, the name of the project's main working tree.
- `written_at`: string, an ISO 8601 time in UTC.
- `trunk`: an object of `ref`, string, the reference read; `branch`, string; `commit`, string, the short commit; and `state`, one of `fetched`, `fetch_failed` or `no_origin`.
- `remote_branches_read`: boolean.
- `forge`: one of `full`, `partly` or `none`; and `forge_limit`: integer, the number of pull requests read at most.
- `warnings`: integer, the number the report states, and the sum of the warnings in `workstreams` and `tasks`.
- `workstreams`: a list sorted by name, each of `name`, string; `summary`, string or `null`; `goal`, string; `done_when`, string; `active`, boolean; `steps`, a list of objects of `name` and `description`, strings, in the file's order; and `warnings`, a list of strings. A step two workstreams list SHALL carry its warning in the `warnings` of each, and not on the task.
- `tasks`: a list sorted by name, holding each task's name once, each of `name`, string; `status`, one of `done`, `in_flight`, `recorded` or `planned`; `stage`, string or `null`; `workstreams`, a list of strings naming each workstream it is placed in, none twice, empty where it is in none; `unplaced`, boolean; `closed_workstream`, string or `null`, the name the page's note gives on a task in no workstream, and `null` on any other task; `parts`, a list drawn from `step`, `entry`, `change`, `archived_change`, `branch`, `open_pr` and `merged_pr`, where `change` is one open on the trunk or on its branch; `last_commit`, integer seconds since the epoch, or `null`; `summary`, string or `null`; `priority`, string or `null`, `null` meaning `normal`; `waits_on`, a list of strings; `body`, string or `null`; `merge_unchecked`, boolean, true where the page shows a task's unchecked mark; and `warnings`, a list of strings.

Text SHALL be as the repository holds it, not escaped for a page.

`--json` with `--output` SHALL be refused as `BLOCKED`, whichever comes first, since the document has one destination and a path would mean nothing.

#### Scenario: A document

- **WHEN** the tool runs with `--json` in a project on the directory shape
- **THEN** standard output parses as one JSON document holding `schema_version`, and no page is written

#### Scenario: The same reading as the page

- **WHEN** the tool runs on one project with and without `--json`
- **THEN** every task has the same status, stage and placement in both

#### Scenario: A value with quotes, backslashes and a tab

- **WHEN** an entry's body holds a quote, a backslash, a tab and non-ASCII text
- **THEN** the document parses, and `body` holds them as the file does

#### Scenario: Markup stays as written

- **WHEN** an entry's body holds `<script>`
- **THEN** `body` holds `<script>`, not its escaped form

#### Scenario: No origin

- **WHEN** the repository has no remote named `origin`
- **THEN** `trunk.state` is `no_origin` and `trunk.branch` names the branch read

#### Scenario: A failed fetch

- **WHEN** the fetch fails
- **THEN** `trunk.state` is `fetch_failed`

#### Scenario: A step of two workstreams

- **WHEN** two workstreams list the same step
- **THEN** `tasks` holds it once, with both names in `workstreams`, and each workstream's `warnings` holds one warning for it

#### Scenario: A step with another workstream's entry value

- **WHEN** a step of workstream A has an entry naming B
- **THEN** its `workstreams` holds A only and its `unplaced` is false

#### Scenario: A workstream that is not open

- **WHEN** an entry that no step names gives a workstream with no open file
- **THEN** its `closed_workstream` holds that name

#### Scenario: A task with no workstream

- **WHEN** a task is placed in no workstream
- **THEN** its `workstreams` is an empty list and its `unplaced` is false

#### Scenario: Forge not reached

- **WHEN** the forge was not reached
- **THEN** `forge` is `none`, and a task with no change of its name has `merge_unchecked` true

#### Scenario: A blocked run

- **WHEN** the tool runs with `--json` on a target that is not a Git repository
- **THEN** standard output is empty, the exit status is 2, and standard error carries the outcome

#### Scenario: With an output

- **WHEN** the tool runs with `--json --output <path>`, in either order
- **THEN** the outcome is `BLOCKED` on standard error, the exit status is 2, and nothing is written to the path

#### Scenario: A usage error with --json

- **WHEN** the tool runs with an unknown flag and `--json`, in either order
- **THEN** standard output is empty and the outcome is on standard error

#### Scenario: A failed run

- **WHEN** the run fails with `--json` after reading has begun
- **THEN** standard output is empty, the exit status is 1, and standard error carries the outcome

## MODIFIED Requirements

### Requirement: The tool reports its outcome

The tool SHALL print a fixed report: the target, the page's path where one was written, the trunk read, whether the trunk was fetched, whether remote branches were read, whether the forge was read in full, partly or not at all, the number of warnings, and an `Outcome:` of `SUCCESS`, `BLOCKED` or `ERROR`, exiting 0, 2 or 1 respectively. With `--json` the report SHALL go to standard error, so standard output holds only the document, and the page's path SHALL be left out. It SHALL block, writing nothing, where the target is not a Git repository, where no trunk can be resolved and the repository has `origin`, where the repository has no commit, or where the trunk holds neither `docs/backlog/` nor `docs/workstreams/`, and where the trunk holds `docs/backlog.md` and no `docs/backlog/` it SHALL block naming `scripts/backlog-migrate`. A page that cannot be written SHALL be an `ERROR`.

#### Scenario: Not a repository

- **WHEN** the target is not a Git repository
- **THEN** the outcome is `BLOCKED`, the exit status is 2, and no page is written

#### Scenario: No trunk

- **WHEN** the repository has a remote named `origin` and no trunk reference resolves, or has no commit
- **THEN** the outcome is `BLOCKED` and the reason says what is missing

#### Scenario: A single-file backlog

- **WHEN** the trunk holds `docs/backlog.md` and no `docs/backlog/`
- **THEN** the outcome is `BLOCKED` and the reason names `scripts/backlog-migrate`

#### Scenario: Nothing to show

- **WHEN** the trunk holds neither `docs/backlog/` nor `docs/workstreams/`
- **THEN** the outcome is `BLOCKED` and the reason names `scripts/project-init`

#### Scenario: Unwritable output

- **WHEN** the output path cannot be written
- **THEN** the outcome is `ERROR` and the exit status is 1

#### Scenario: The report under --json

- **WHEN** the tool runs with `--json`
- **THEN** the report and its `Outcome:` are on standard error, and standard output holds only the document

### Requirement: The tool writes one self-contained page for one project

`scripts/task-board` SHALL take a project's directory as its one optional argument, defaulting to the current working directory, and, without `--json`, write one HTML file for that project. The file SHALL load nothing from outside itself and work with scripting disabled. It SHALL state when it was written and from which trunk commit, since its elapsed times are measured from then. It SHALL be written to the path given by `--output`, or otherwise to a file in the system's temporary directory named for the project's main working tree, so every working tree of a project shares one page. The tool SHALL print the file's path. It SHALL accept `--help`, which prints usage and writes nothing.

#### Scenario: Default output

- **WHEN** the tool runs in a project on the directory shape with no `--output`
- **THEN** it writes the page outside the project and prints its path, and `git status` in the project is unchanged

#### Scenario: A named output

- **WHEN** the tool runs with `--output <path>`
- **THEN** the page is written to that path

#### Scenario: The page states its moment

- **WHEN** the page is written
- **THEN** it shows the time of the run and the trunk commit read

#### Scenario: The page stands alone

- **WHEN** the page is opened with no network and scripting disabled
- **THEN** it refers to no external resource, and every group can still be opened and read
