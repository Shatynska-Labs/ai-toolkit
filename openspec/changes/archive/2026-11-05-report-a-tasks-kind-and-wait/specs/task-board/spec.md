## MODIFIED Requirements

### Requirement: The page carries what a task's entry states

*Modified by `report-a-tasks-kind-and-wait`: the page also shows the entry's `kind`, its `need` where it is not `should`, which `waits_on` names are done, a named wait not checked, and its `waits_for` with its types. Every scenario keeps its title; four are added.*

For a task with a backlog entry, the page SHALL show the entry's priority where it is not `normal`, its `kind`, its `need` where it is not `should`, its `waits_on` names, each marked done where its status is `done`, with the warning the document gives for a named wait not checked, its `waits_for` condition preceded by its `waits_for_type` values where it has them, and its body, the body being collapsed. A task SHALL be marked unplaced beside its name. Every value read from the repository SHALL be escaped, so that no text in a file can add markup to the page.

#### Scenario: A parked entry

- **WHEN** an entry has `priority: parked`
- **THEN** the task shows that it is parked

#### Scenario: Markup in an entry

- **WHEN** an entry's body contains `<script>`
- **THEN** the page shows it as text and it does not run

#### Scenario: An entry without frontmatter

- **WHEN** an entry file has no frontmatter
- **THEN** it is shown with a warning, reading as `normal` and naming no workstream

#### Scenario: Kind and need are shown

- **WHEN** an entry carries `kind: fix` and `need: could`
- **THEN** its task shows `fix` and `could`

#### Scenario: A named wait already done

- **WHEN** an entry's `waits_on` names a change that is archived
- **THEN** its task shows that name marked done

#### Scenario: A typed condition is shown

- **WHEN** an entry carries `waits_for: "the operator's choice of model"` and `waits_for_type: [decision]`
- **THEN** its task shows the condition with `decision` before it

#### Scenario: An unchecked named wait is warned of on the page

- **WHEN** the forge was not read in full, and an entry's only `waits_on` name is neither an archived nor an open change and no merged pull request of that name was read
- **THEN** its task shows a warning that the wait was not checked

### Requirement: The tool reports the board as JSON

*Modified by `report-a-tasks-kind-and-wait`: each task gains `kind`, `need`, `waits_for`, `waits_for_type`, `parked_until`, `waits_on_done` and `readiness`, and a named wait the forge could not check is warned of; `schema_version` stays `1`. Every scenario keeps its title; nine are added.*

With `--json`, `scripts/task-board` SHALL print one JSON document on standard output and write no page. The document SHALL be derived by the same lookups and placement as the page, so a task reads the same in both, and SHALL be printed only once complete, so a failed run leaves standard output empty. It SHALL hold these keys:

- `schema_version`: integer, `1` for this shape. It SHALL rise when a field is removed or renamed, or a field's meaning or set of values changes. A field added SHALL NOT raise it.
- `project`: string, the name of the project's main working tree.
- `written_at`: string, an ISO 8601 time in UTC.
- `trunk`: an object of `ref`, string, the reference read; `branch`, string; `commit`, string, the short commit; and `state`, one of `fetched`, `fetch_failed` or `no_origin`.
- `remote_branches_read`: boolean.
- `forge`: one of `full`, `partly` or `none`; and `forge_limit`: integer, the number of pull requests read at most.
- `warnings`: integer, the number the report states, and the sum of the warnings in `workstreams` and `tasks`.
- `workstreams`: a list sorted by name, each of `name`, string; `summary`, string or `null`; `goal`, string; `done_when`, string; `active`, boolean; `steps`, a list of objects of `name` and `description`, strings, in the file's order; and `warnings`, a list of strings. A step two workstreams list SHALL carry its warning in the `warnings` of each, and not on the task.
- `tasks`: a list sorted by name, holding each task's name once, each of `name`, string; `status`, one of `done`, `in_flight`, `recorded` or `planned`; `stage`, string or `null`; `workstreams`, a list of strings naming each workstream it is placed in, none twice, empty where it is in none; `unplaced`, boolean; `closed_workstream`, string or `null`, the name the page's note gives on a task in no workstream, and `null` on any other task; `parts`, a list drawn from `step`, `entry`, `change`, `archived_change`, `branch`, `open_pr` and `merged_pr`, where `change` is one open on the trunk or on its branch; `last_commit`, integer seconds since the epoch, or `null`; `summary`, string or `null`; `priority`, string or `null`, `null` meaning `normal`; `waits_on`, a list of strings; `kind`, string or `null`, the entry's value, `null` where there is no entry or no key; `need`, string or `null`, the entry's value, `should` where the entry has no key, `null` where there is no entry; `waits_for`, string or `null`; `waits_for_type`, a list of strings, empty where the entry has none; `parked_until`, string or `null`; `waits_on_done`, a list of the names in `waits_on` whose status, by the lookups that give a task's `status`, is `done`; `readiness`, `null` for a task whose status is `done` or `in_flight`, and otherwise `blocked` where a name in `waits_on` is not done, else `waiting` where the entry has `waits_for`, else `parked` where its `priority` is `parked`, else `ready`; `body`, string or `null`; `merge_unchecked`, boolean, true where the page shows a task's unchecked mark; and `warnings`, a list of strings.

Text SHALL be as the repository holds it, not escaped for a page. A value SHALL be given as the entry writes it, unchecked against the README's sets, as `priority` is.

Readiness follows the wait first and parking after, as **pick** does, and reads every `waits_for` as unmet, since the tool cannot check a condition. A name counts as done by a task's own status lookups, so a fix merged under that name clears the wait. A name SHALL be counted done exactly where its status is `done`. Where it is not done, `forge` is not `full` and the name has no change, open or archived, the task's `warnings` SHALL name it as a wait not checked against every merged pull request, since a fix merged under it may lie beyond the forge read.

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

#### Scenario: Kind, need and a typed condition

- **WHEN** an entry carries `kind: change`, `need: must`, `waits_for: "the head's answer"` and `waits_for_type: [answer]`
- **THEN** its task has `kind` `change`, `need` `must`, `waits_for` `the head's answer` and `waits_for_type` `["answer"]`

#### Scenario: Need's default

- **WHEN** an entry carries no `need`, and a step has no entry
- **THEN** the entry's task has `need` `should`, and the step's task has `need` `null` and `kind` `null`

#### Scenario: A wait on a done name

- **WHEN** an entry's `waits_on` names one archived change and one open change
- **THEN** its `waits_on_done` holds the archived one only, and its `readiness` is `blocked`

#### Scenario: A wait cleared by a merged fix

- **WHEN** an entry's only `waits_on` name has no change and a merged pull request from a branch of that name, and the entry has no `waits_for`
- **THEN** its `waits_on_done` holds that name, and its `readiness` is `ready`

#### Scenario: A condition is a wait

- **WHEN** an entry's `waits_on` is empty and it carries `waits_for`
- **THEN** its `readiness` is `waiting`

#### Scenario: Parked after the wait

- **WHEN** one parked entry has an empty `waits_on` and no `waits_for`, and another parked entry carries `waits_for`
- **THEN** the first's `readiness` is `parked` and the second's `waiting`

#### Scenario: No readiness for a task in flight or done

- **WHEN** a task's status is `in_flight` or `done`
- **THEN** its `readiness` is `null`

#### Scenario: A named wait the forge could not check

- **WHEN** the forge was not read in full, and an entry's only `waits_on` name is neither an archived nor an open change and no merged pull request of that name was read
- **THEN** its `waits_on_done` is empty, its `readiness` is `blocked`, and its `warnings` names that wait as not checked

#### Scenario: A merged fix the partial read found

- **WHEN** the forge was read in part, and an entry's only `waits_on` name has no change and a merged pull request of that name among those read
- **THEN** its `waits_on_done` holds that name, its `readiness` is `ready`, and its `warnings` names no unchecked wait
