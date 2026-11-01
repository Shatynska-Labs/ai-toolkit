## Purpose

Shows the operator all of one project's tasks on one page, grouped by workstream, with each task's status derived from the repository and nothing stored.

## ADDED Requirements

### Requirement: The tool writes one self-contained page for one project

`scripts/task-board` SHALL take a project's directory as its one optional argument, defaulting to the current working directory, and write one HTML file for that project. The file SHALL load nothing from outside itself and work with scripting disabled. It SHALL state when it was written and from which trunk commit, since its elapsed times are measured from then. It SHALL be written to the path given by `--output`, or otherwise to a file in the system's temporary directory named for the project's main working tree, so every working tree of a project shares one page. The tool SHALL print the file's path. It SHALL accept `--help`, which prints usage and writes nothing.

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

### Requirement: The tool changes nothing in the project

The tool SHALL NOT change a tracked file, a branch, a pull request or the working tree. Fetching from `origin`, without pruning, SHALL be the only change it makes to the repository's state.

#### Scenario: Run in a working tree with uncommitted edits

- **WHEN** the tool runs in a working tree holding uncommitted edits
- **THEN** those edits and the current branch are as they were before the run

### Requirement: The board is read from the trunk

The tool SHALL fetch from the remote named `origin`, and read `docs/backlog/`, `docs/workstreams/` and `openspec/changes/` from the trunk as fetched, not from the working tree, so that the board does not depend on which working tree it runs in. For a task in flight only, its change's files SHALL be read as *A task in flight shows its stage* states, since a change is on its branch until its first pull request merges. Where the fetch fails, it SHALL read the trunk as last fetched and say so on the page and in its report. Where the repository has no remote named `origin`, it SHALL read the current branch and say so. Where remote branches cannot be listed, it SHALL say on the page and in its report that they were not read.

#### Scenario: A worktree on another branch

- **WHEN** the tool runs in a working tree whose branch adds a backlog entry the trunk lacks
- **THEN** that entry is not on the board as an entry

#### Scenario: The fetch fails

- **WHEN** the remote cannot be reached
- **THEN** the board is written from the last fetched trunk, and the page and the report say the trunk may be stale

#### Scenario: No remote

- **WHEN** the repository has no remote named `origin`
- **THEN** the board is written from the current branch, and the page and the report say so

#### Scenario: Remote branches cannot be listed

- **WHEN** the remote cannot be reached
- **THEN** the page and the report say remote branches were not read

### Requirement: Open workstreams are the board's groups

The page SHALL show one group for each open workstream, a `.md` file directly in `docs/workstreams/` other than `AGENTS.md`, `CLAUDE.md` and `README.md`. A workstream is active where any task placed in it is in flight. Active workstreams SHALL be listed first, each a closed row showing its name, its summary where it has one, and its progress as one mark per step with the count of steps done and of placed tasks in work, unplaced ones included. Every other open workstream SHALL be listed the same way inside one collapsed row. Where no workstream is active, the page SHALL say so. Opening a row SHALL show the workstream's Goal, its Done when, and its steps in the order the file lists them, each with its name, its status and the description the file gives it. Archived workstreams SHALL NOT be shown. A workstream file whose steps cannot be read SHALL still appear, with a warning on its group, and a numbered line among its steps that cannot be read SHALL be warned on rather than dropped silently.

#### Scenario: Active and other workstreams

- **WHEN** a project has four workstreams with a task in flight and fourteen without
- **THEN** the four are listed first and the fourteen are inside one collapsed row

#### Scenario: Nothing active

- **WHEN** no workstream has a task in flight
- **THEN** the page says no workstream is active

#### Scenario: Steps keep their order

- **WHEN** a workstream lists three steps
- **THEN** its group shows them in that order, whatever their statuses

#### Scenario: A step that is only a name

- **WHEN** a step has no backlog entry, no change and no branch
- **THEN** it is shown by its name and description, with the status planned

#### Scenario: An archived workstream

- **WHEN** a file exists under `docs/workstreams/archive/`
- **THEN** no group is shown for it

#### Scenario: A workstream with no readable steps

- **WHEN** a workstream file has no steps in the expected shape
- **THEN** its group appears with a warning saying its steps could not be read

#### Scenario: One unreadable step

- **WHEN** a numbered line among a workstream's steps has no backticked name
- **THEN** the other steps are shown, and the group warns about that line

### Requirement: Every task is placed once

A task SHALL be identified by its name, so a step, an entry, a change, a branch and a pull request of one name are one task. Tasks SHALL be gathered from: each open workstream's steps; each backlog entry, a `.md` file directly in `docs/backlog/` other than `AGENTS.md`, `CLAUDE.md` and `README.md`; each open change, a directory directly in `openspec/changes/` other than `archive`; and each local or remote branch or open pull request whose name is one kebab-case word, is not the trunk's, is not `main` or `master`, and has the status in flight. Other than a step two workstreams list, a task SHALL appear once, placed by the first of these that holds: the open workstream whose steps name it; the open workstream its proposal's `**Workstream**` line names, the proposal of a task in flight being read from its branch; the open workstream its entry's `workstream` value names. A task placed by a proposal or an entry SHALL be marked unplaced in that workstream's group. Every other task SHALL appear in a collapsed group of its own, with a note on each that names a workstream that is not open. A name that two workstreams list as a step, which the rules forbid, SHALL appear as a step of each, with a warning on both, since a step list is not to lose a step. An entry with no `workstream` key, or with `none` or `nothing`, names no workstream. The group SHALL be open instead of collapsed where the project has no open workstream.

#### Scenario: An entry that is a step

- **WHEN** an entry's name is a step of a workstream
- **THEN** it appears once, as that step

#### Scenario: A step named by another workstream's entry value

- **WHEN** a step of workstream A has an entry whose `workstream` value is B
- **THEN** it appears once, as a step of A

#### Scenario: An entry no step names

- **WHEN** an entry names workstream A and no step of A names it
- **THEN** it appears in A's group, marked unplaced

#### Scenario: An open change no step names

- **WHEN** an open change's proposal names workstream A and no step of A names it
- **THEN** it appears in A's group, marked unplaced

#### Scenario: A task with no workstream

- **WHEN** an entry has `workstream: none`, or an open change names no workstream and has no entry
- **THEN** it appears in the collapsed group

#### Scenario: A workstream that is not open

- **WHEN** an entry names a workstream that has no open file
- **THEN** it appears in the collapsed group with a note naming that workstream

#### Scenario: A change on its branch naming a workstream

- **WHEN** a change's proposal is on its branch only, names open workstream A, and no step or entry names the change
- **THEN** it appears in A's group, marked unplaced

#### Scenario: A proposal naming a workstream that is not open

- **WHEN** an open change's proposal names a workstream with no open file, and its entry names open workstream A
- **THEN** it appears in A's group, marked unplaced

#### Scenario: A branch matching no task

- **WHEN** a branch or open pull request of a kebab-case name exists, and no step, entry or change has that name
- **THEN** it appears in the collapsed group as in flight

#### Scenario: Branches that are not tasks

- **WHEN** a branch is the trunk's, has a `/` in its name, or has the status done
- **THEN** it adds no task to the board

#### Scenario: A step in two workstreams

- **WHEN** two workstreams list the same name as a step
- **THEN** it appears as a step of each, and both groups warn about it

#### Scenario: A project with no workstreams

- **WHEN** a project has entries and no open workstream
- **THEN** its entries are shown in a group that is open

### Requirement: The page opens with what is in flight

The page SHALL begin with a section listing every task whose status is in flight, whichever group it is placed in, the most recent last commit first, in columns for the task, its stage, its last commit and its workstream. Each SHALL show its name, its stage, the workstream it is placed in, or that it has none, with a link to that group, and whether it is unplaced. A step two workstreams list SHALL name both. Where nothing is in flight, the section SHALL say so. This section repeats tasks placed below it and is not a second placement.

#### Scenario: A change in a workstream

- **WHEN** an open change is a step of workstream A
- **THEN** the section lists it, naming A and linking to A's group, and it also appears as a step in A's group

#### Scenario: A change with no workstream

- **WHEN** a branch matching no other task exists, holding no proposal that names an open workstream
- **THEN** the section lists it as having no workstream

#### Scenario: Nothing in flight

- **WHEN** no task has the status in flight
- **THEN** the section says nothing is in flight

### Requirement: A task in flight shows its stage

A task in flight SHALL show a stage derived from the repository, and the first of these that holds SHALL win:

1. `ship:merged`, where the trunk holds an open change of its name and a pull request from a branch of that name has merged, so its archive is outstanding;
2. `ship:pr-open`, where a pull request of its name is open;
3. unknown, where the branch is on the remote with no local reference to read and the trunk holds no change of its name;
4. `build:applying`, with the number of tasks ticked out of the total, where its `tasks.md` holds at least one ticked task;
5. `plan:drafting`, where its change has a `proposal.md`;
6. `plan:exploring` otherwise.

These SHALL be state names `session-workflow` fixes, the nearest the repository shows, so `plan:drafting` also covers a plan under review. The stage SHALL NOT depend on a review's verdict, which the repository does not hold, and the page SHALL say that a session's own status report is finer than this one.

A change's files SHALL be read from the first of the local branch of its name, the remote's, and the trunk that holds a reference to them.  Every stage SHALL carry the unchecked mark where the forge was not read in full, since the first two depend on it.

#### Scenario: A merged change not yet archived

- **WHEN** the trunk holds an open change and a pull request of its name has merged
- **THEN** its stage is `ship:merged`

#### Scenario: A pull request open

- **WHEN** a pull request of the task's name is open and none has merged with an open change on the trunk
- **THEN** its stage is `ship:pr-open`

#### Scenario: Tasks partly done on a branch

- **WHEN** the branch's `tasks.md` has 4 of 12 tasks ticked, and no pull request is open
- **THEN** its stage is `build:applying` with 4/12

#### Scenario: A proposal with no ticked task

- **WHEN** the branch holds a proposal and no ticked task
- **THEN** its stage is `plan:drafting`

#### Scenario: A branch with no proposal

- **WHEN** the branch holds no change directory of its name
- **THEN** its stage is `plan:exploring`

#### Scenario: A remote branch with no reference

- **WHEN** `git ls-remote` lists a branch that no local reference reaches, the trunk holds no change of its name, and no pull request of its name is open
- **THEN** its stage is unknown

#### Scenario: The forge is not read in full

- **WHEN** the forge was not read in full
- **THEN** every stage carries the unchecked mark

### Requirement: A task shows what it consists of

In the section of what is in flight, each task SHALL state which of these exist under its name: a workstream step, a backlog entry, a change, whether on the trunk or on its branch, a branch, an open pull request, a merged pull request. In a group's list, each task SHALL show the description its step gives where it has one, and its summary where its entry has one. The section of what is in flight SHALL show a task's summary where it has one, and no step description. Where neither exists it SHALL show its name alone: a Goal or an entry's body SHALL NOT stand in for a summary.

#### Scenario: One name in three concepts

- **WHEN** a name is a step, has a backlog entry, and has an open change
- **THEN** one line is shown for it, stating step, entry and change

#### Scenario: No summary

- **WHEN** an entry that no step names has no summary
- **THEN** it shows its name and no description

#### Scenario: A summary

- **WHEN** an entry has a `summary` value, or a workstream a `**Summary**` line
- **THEN** that text is shown under its name

### Requirement: Tasks are listed in columns

Every list of tasks inside a group SHALL have the same columns, with a heading on each: status, task, last commit, and a control opening the entry's body. The section of what is in flight SHALL be the one exception: its status is the same on every row, so its columns are task, stage, last commit and workstream, each with a heading, and its rows open no body. Rows without a body SHALL leave that cell empty and keep the columns aligned. The last commit SHALL show only an elapsed time, such as `6 d`, measured when the page was written: the branch's last commit where the task has a branch with commits of its own, otherwise the last commit on the trunk touching its change directory or entry. A task with neither SHALL leave the cell empty. A task with an entry in a group's list SHALL open by a click anywhere on its row. The list of tasks in no workstream SHALL put tasks in flight first, then the most recent, then parked.

#### Scenario: A branch's commit

- **WHEN** a task's branch has commits the trunk does not
- **THEN** its last commit is the branch's

#### Scenario: A branch with no commits of its own

- **WHEN** a task's branch is at or behind the trunk's tip
- **THEN** its last commit is the one touching its change directory or entry

#### Scenario: A step that is only a name

- **WHEN** a step has no branch, change or entry
- **THEN** its last commit cell is empty

#### Scenario: Rows with and without a body

- **WHEN** a list holds a task with an entry and a task without
- **THEN** their columns line up

#### Scenario: The in-flight section's columns

- **WHEN** the page lists what is in flight
- **THEN** its columns are task, stage, last commit and workstream, and a row there opens no body

#### Scenario: Clicking a row

- **WHEN** a task with an entry in a group's list is clicked anywhere on its row
- **THEN** its body opens

#### Scenario: Order of tasks in no workstream

- **WHEN** the group of tasks in no workstream holds tasks in flight, recorded and parked
- **THEN** those in flight come first, then the most recent, then those parked

### Requirement: A task's status is derived by its name

Each task's status SHALL be derived by its name, and the first of these that holds SHALL win:

1. done, where the trunk holds an archived change of that name, or holds no change of that name, open or archived, and a pull request from a branch of that name has merged;
2. in flight, where the trunk holds an open change of that name, or a local or remote branch or an open pull request of that name exists;
3. recorded, where the trunk's `docs/backlog/` holds an entry of that name;
4. planned otherwise.

This SHALL be the order this library's `rules/workstreams.md` states. No status SHALL be stored by the tool or read from a task's own values.

#### Scenario: An archived change

- **WHEN** the trunk holds `openspec/changes/archive/<date>-<name>`
- **THEN** the task is done, even where a branch of that name remains

#### Scenario: A fix

- **WHEN** the trunk holds no change of the name and a pull request from a branch of that name has merged
- **THEN** the task is done

#### Scenario: An open change

- **WHEN** the trunk holds `openspec/changes/<name>`
- **THEN** the task is in flight, even where an entry of that name exists

#### Scenario: A branch with no change

- **WHEN** the trunk holds no change of the name and a local or remote branch of that name exists
- **THEN** the task is in flight

#### Scenario: A deleted remote branch

- **WHEN** a branch was deleted on the remote and the local clone still holds a remote-tracking reference to it
- **THEN** that reference does not make the task in flight

#### Scenario: An entry alone

- **WHEN** an entry of the name exists and no change, branch or pull request does
- **THEN** the task is recorded

### Requirement: An unreachable forge is stated, never read as planned

The forge SHALL be read in full, partly, or not at all. It is not reached where `gh` is absent, unauthenticated or fails, and partly read where its answer reaches the tool's limit on pull requests. Where it is not read in full, the tool SHALL still write the board, derive what it can, and say so on the page and in its report, and each task with no change of its name on the trunk SHALL carry a mark that a merged pull request could not be checked.

#### Scenario: No gh

- **WHEN** `gh` is not installed
- **THEN** the board is written, the page and the report say the forge was not reached, and a step with no change of its name is marked as unchecked rather than shown as plainly planned

#### Scenario: Forge partly read

- **WHEN** the forge's answer reaches the tool's limit
- **THEN** the page and the report say pull requests were partly read, and tasks with no change of their name carry the unchecked mark

#### Scenario: Forge read in full

- **WHEN** the forge answers below the limit
- **THEN** no task carries the unchecked mark

### Requirement: The page carries what a task's entry states

For a task with a backlog entry, the page SHALL show the entry's priority where it is not `normal`, its `waits_on` names, and its body, the body being collapsed. A task SHALL be marked unplaced beside its name. Every value read from the repository SHALL be escaped, so that no text in a file can add markup to the page.

#### Scenario: A parked entry

- **WHEN** an entry has `priority: parked`
- **THEN** the task shows that it is parked

#### Scenario: Markup in an entry

- **WHEN** an entry's body contains `<script>`
- **THEN** the page shows it as text and it does not run

#### Scenario: An entry without frontmatter

- **WHEN** an entry file has no frontmatter
- **THEN** it is shown with a warning, reading as `normal` and naming no workstream

### Requirement: The tool reports its outcome

The tool SHALL print a fixed report: the target, the page's path where one was written, the trunk read, whether the trunk was fetched, whether remote branches were read, whether the forge was read in full, partly or not at all, the number of warnings on the page, and an `Outcome:` of `SUCCESS`, `BLOCKED` or `ERROR`, exiting 0, 2 or 1 respectively. It SHALL block, writing nothing, where the target is not a Git repository, where no trunk can be resolved and the repository has `origin`, where the repository has no commit, or where the trunk holds neither `docs/backlog/` nor `docs/workstreams/`, and where the trunk holds `docs/backlog.md` and no `docs/backlog/` it SHALL block naming `scripts/backlog-migrate`. A page that cannot be written SHALL be an `ERROR`.

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
