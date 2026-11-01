# Test plan: `task-board`

This manifest is not an artifact the OpenSpec schema knows about, so it does not appear among `openspec instructions apply`'s context files. Read it on purpose before implementing.

Every test is one file in `tests/cases/`, selected by name: `bash tests/run.sh task-board-status-fix`. All of them: `bash tests/run.sh $(cd tests/cases && ls task-board-*.sh)`, from the working tree. This pass wrote 142 cases and changed no existing file in the suite.

## Baseline

Full suite, before any case was written: `bash tests/run.sh`, 364 passed, 0 failed, on `d753bd1`. No prior case bears on `scripts/task-board`, which does not exist.

## State of the new cases

All 142 fail in state 2: `target absent — scripts/task-board does not exist yet`. The guard sits in `board_in`, after each fixture is built, so every fixture ran to the first call of the tool. Their assertions have never executed against the tool: that they discriminate is unverified until it exists. The page reader and `status_is`, `in_order`, `one` and `in_loose_group` were exercised outside the suite on `prototype/page-style.html`, positively and with deliberately wrong expectations, and the `gh` stub by hand. The cases pass ShellCheck at warning level.

A case that passes on the first run of the finished tool is expected. A case that passes while the tool is still partial, or passes when its behaviour is removed, is an alarm. Any case asserting absence (`hasnt`, `one ... 0`, `status_is` over a row) is the first to check: for these, a wrong page can satisfy the assertion.

## Scenarios

66 `#### Scenario:` blocks in the delta spec, all under `ADDED`; 66 accounted for, each covered by at least one test; none uncovered.


### The tool writes one self-contained page for one project

| Scenario | Tests |
| --- | --- |
| Default output | `task-board-default-output` |
| A named output | `task-board-named-output` |
| The page states its moment | `task-board-page-states-trunk-commit`, `task-board-page-states-time` |
| The page stands alone | `task-board-page-refers-to-nothing-external`, `task-board-page-works-without-scripting` |

### The tool changes nothing in the project

| Scenario | Tests |
| --- | --- |
| Run in a working tree with uncommitted edits | `task-board-working-tree-untouched` |

### The board is read from the trunk

| Scenario | Tests |
| --- | --- |
| A worktree on another branch | `task-board-worktree-on-another-branch` |
| The fetch fails | `task-board-fetch-fails-reads-last-fetched`, `task-board-fetch-fails-says-stale` |
| No remote | `task-board-no-remote-reads-current-branch`, `task-board-no-remote-says-so` |
| Remote branches cannot be listed | `task-board-remote-branches-not-read-says-so` |

### Open workstreams are the board's groups

| Scenario | Tests |
| --- | --- |
| Active and other workstreams | `task-board-groups-active-listed-first`, `task-board-groups-others-in-one-collapsed-row` |
| Nothing active | `task-board-groups-nothing-active` |
| Steps keep their order | `task-board-groups-steps-keep-order` |
| A step that is only a name | `task-board-groups-step-only-a-name` |
| An archived workstream | `task-board-groups-archived-not-shown` |
| A workstream with no readable steps | `task-board-groups-no-readable-steps` |
| One unreadable step | `task-board-groups-one-unreadable-step` |

### Every task is placed once

| Scenario | Tests |
| --- | --- |
| An entry that is a step | `task-board-place-entry-is-a-step` |
| A step named by another workstream's entry value | `task-board-place-step-with-another-workstreams-entry` |
| An entry no step names | `task-board-place-entry-no-step-names` |
| An open change no step names | `task-board-place-change-no-step-names` |
| A task with no workstream | `task-board-place-entry-workstream-none`, `task-board-place-change-no-workstream` |
| A workstream that is not open | `task-board-place-workstream-not-open` |
| A change on its branch naming a workstream | `task-board-place-change-on-its-branch` |
| A proposal naming a workstream that is not open | `task-board-place-proposal-not-open-falls-to-entry` |
| A branch matching no task | `task-board-place-branch-matching-no-task`, `task-board-place-open-pr-matching-no-task` |
| Branches that are not tasks | `task-board-branch-not-a-task-trunk`, `task-board-branch-not-a-task-slash`, `task-board-branch-not-a-task-done` |
| A step in two workstreams | `task-board-place-step-in-two-workstreams`, `task-board-place-step-in-two-warns-on-both` |
| A project with no workstreams | `task-board-place-no-workstreams-group-open` |

### The page opens with what is in flight

| Scenario | Tests |
| --- | --- |
| A change in a workstream | `task-board-flight-change-in-a-workstream`, `task-board-flight-links-to-the-group` |
| A change with no workstream | `task-board-flight-no-workstream` |
| A step of two workstreams in flight | `task-board-flight-step-of-two-workstreams` |
| Nothing in flight | `task-board-flight-nothing` |

### A task in flight shows its stage

| Scenario | Tests |
| --- | --- |
| A merged change not yet archived | `task-board-stage-merged-not-archived` |
| A pull request open | `task-board-stage-merged-over-pr-open`, `task-board-stage-pr-open` |
| Tasks partly done on a branch | `task-board-stage-tasks-partly-done-on-branch` |
| A proposal with no ticked task | `task-board-stage-proposal-no-ticked-task` |
| A branch with no proposal | `task-board-stage-branch-no-proposal` |
| A remote branch with no reference | `task-board-stage-remote-branch-no-reference` |
| The forge is not read in full | `task-board-stage-carries-unchecked-mark` |

### A task shows what it consists of

| Scenario | Tests |
| --- | --- |
| One name in three concepts | `task-board-consists-one-name-in-three-concepts` |
| No summary | `task-board-summary-absent-name-alone` |
| A summary | `task-board-summary-of-an-entry`, `task-board-summary-of-a-workstream` |

### Tasks are listed in columns

| Scenario | Tests |
| --- | --- |
| A branch's commit | `task-board-commit-from-the-branch` |
| A branch with no commits of its own | `task-board-commit-branch-level-with-trunk`, `task-board-commit-branch-behind-trunk` |
| A step that is only a name | `task-board-commit-empty-for-a-bare-step` |
| Rows with and without a body | `task-board-rows-with-and-without-a-body-line-up` |
| The in-flight section's columns | `task-board-columns-in-the-flight-section`, `task-board-flight-row-opens-no-body` |
| Clicking a row | `task-board-click-anywhere-on-a-row` |
| Order of tasks in no workstream | `task-board-order-of-tasks-in-no-workstream` |

### A task's status is derived by its name

| Scenario | Tests |
| --- | --- |
| An archived change | `task-board-status-archived-change` |
| A fix | `task-board-status-fix` |
| An open change | `task-board-status-open-change` |
| A branch with no change | `task-board-status-local-branch`, `task-board-status-remote-branch` |
| A deleted remote branch | `task-board-status-deleted-remote-branch` |
| An entry alone | `task-board-status-entry-alone` |

### An unreachable forge is stated, never read as planned

| Scenario | Tests |
| --- | --- |
| No gh | `task-board-forge-no-gh-says-not-reached`, `task-board-forge-no-gh-marks-a-step` |
| Forge partly read | `task-board-forge-partly-read-says-so`, `task-board-forge-partly-read-marks-a-step` |
| Forge read in full | `task-board-forge-read-in-full-no-mark` |

### The page carries what a task's entry states

| Scenario | Tests |
| --- | --- |
| A parked entry | `task-board-entry-parked` |
| Markup in an entry | `task-board-markup-in-an-entry-body` |
| An entry without frontmatter | `task-board-entry-without-frontmatter` |

### The tool reports its outcome

| Scenario | Tests |
| --- | --- |
| Not a repository | `task-board-report-not-a-repository` |
| No trunk | `task-board-report-no-trunk`, `task-board-report-no-commit`, `task-board-report-no-commit-no-remote` |
| A single-file backlog | `task-board-report-single-file-backlog` |
| Nothing to show | `task-board-report-nothing-to-show` |
| Unwritable output | `task-board-report-unwritable-output` |

## Tests beyond the scenarios

These cover what a requirement's text, or the design, states and no scenario names.

| Test | Requirement |
| --- | --- |
| `task-board-one-page-across-working-trees` | The tool writes one self-contained page for one project |
| `task-board-target-argument` | The tool writes one self-contained page for one project |
| `task-board-help-writes-nothing` | The tool writes one self-contained page for one project |
| `task-board-leaves-no-temporary-files` | The tool writes one self-contained page for one project |
| `task-board-no-branch-changed` | The tool changes nothing in the project |
| `task-board-fetch-does-not-prune` | The tool changes nothing in the project |
| `task-board-reads-the-fetched-trunk` | The board is read from the trunk |
| `task-board-trunk-is-origin-head` | The board is read from the trunk |
| `task-board-trunk-falls-back-to-master` | The board is read from the trunk |
| `task-board-groups-opening-shows-goal-and-done-when` | Open workstreams are the board's groups |
| `task-board-groups-row-shows-progress` | Open workstreams are the board's groups |
| `task-board-groups-reserved-files-not-groups` | Open workstreams are the board's groups |
| `task-board-place-entry-workstream-nothing` | Every task is placed once |
| `task-board-place-entry-no-workstream-key` | Every task is placed once |
| `task-board-place-proposal-over-entry` | Every task is placed once |
| `task-board-place-step-over-proposal` | Every task is placed once |
| `task-board-branch-not-a-task-main` | Every task is placed once |
| `task-board-place-reserved-backlog-files-not-tasks` | Every task is placed once |
| `task-board-place-archive-directory-not-a-change` | Every task is placed once |
| `task-board-flight-section-comes-first` | The page opens with what is in flight |
| `task-board-flight-shows-unplaced` | The page opens with what is in flight |
| `task-board-flight-newest-first` | The page opens with what is in flight |
| `task-board-stage-closed-pull-request-does-not-count` | A task in flight shows its stage |
| `task-board-stage-pr-open-over-applying` | A task in flight shows its stage |
| `task-board-stage-tasks-on-trunk` | A task in flight shows its stage |
| `task-board-stage-remote-only-branch-is-read` | A task in flight shows its stage |
| `task-board-stage-local-branch-before-remote` | A task in flight shows its stage |
| `task-board-stage-pr-open-over-unknown` | A task in flight shows its stage |
| `task-board-stage-page-says-session-is-finer` | A task in flight shows its stage |
| `task-board-consists-branch-and-pull-requests` | A task shows what it consists of |
| `task-board-consists-claims-only-what-exists` | A task shows what it consists of |
| `task-board-consists-change-on-its-branch` | A task shows what it consists of |
| `task-board-summary-step-with-description-and-summary` | A task shows what it consists of |
| `task-board-summary-in-flight-no-step-description` | A task shows what it consists of |
| `task-board-summary-quoted-with-escapes` | A task shows what it consists of |
| `task-board-commit-of-an-entry` | Tasks are listed in columns |
| `task-board-commit-of-a-change-directory` | Tasks are listed in columns |
| `task-board-columns-in-a-group` | Tasks are listed in columns |
| `task-board-columns-in-no-workstream-group` | Tasks are listed in columns |
| `task-board-entry-of-a-finished-change-shows-done` | Tasks are listed in columns |
| `task-board-status-archived-over-open-change` | A task's status is derived by its name |
| `task-board-status-archived-over-entry` | A task's status is derived by its name |
| `task-board-status-fix-over-branch` | A task's status is derived by its name |
| `task-board-status-fix-over-open-pull-request` | A task's status is derived by its name |
| `task-board-status-open-change-over-merged-pull-request` | A task's status is derived by its name |
| `task-board-status-open-pull-request` | A task's status is derived by its name |
| `task-board-status-closed-pull-request-is-nothing` | A task's status is derived by its name |
| `task-board-status-not-read-from-the-entry` | A task's status is derived by its name |
| `task-board-forge-failing-gh-says-not-reached` | An unreachable forge is stated, never read as planned |
| `task-board-entry-priority-normal-not-shown` | The page carries what a task's entry states |
| `task-board-entry-waits-on` | The page carries what a task's entry states |
| `task-board-entry-body-collapsed` | The page carries what a task's entry states |
| `task-board-markup-in-every-other-value` | The page carries what a task's entry states |
| `task-board-report-success` | The tool reports its outcome |
| `task-board-report-counts-warnings` | The tool reports its outcome |
| `task-board-report-reads-the-trunk-for-blocking` | The tool reports its outcome |

## Uncovered scenarios

None.

## Assertion classification

Each case also carries this in its header. **The reader's contract below is derived and applies to every case using it.**

| Test | Classification |
| --- | --- |
| `task-board-default-output` | SPECIFIED: with no --output the page is written outside the project and its path printed, and git status in the project is unchanged. DERIVED (design decision 10): the path is $TMPDIR/task-board-<project>.html. |
| `task-board-one-page-across-working-trees` | SPECIFIED: the file is named for the main working tree, so every working tree of a project shares one page. |
| `task-board-named-output` | SPECIFIED: --output <path> writes the page to that path, and the tool prints it. |
| `task-board-target-argument` | SPECIFIED: the project directory is the one optional argument. DERIVED: run from a directory that is not a repository, so the argument and not the working directory is what is read. |
| `task-board-help-writes-nothing` | SPECIFIED: --help prints usage and writes nothing. DERIVED: exit 0, as the other shipped tools; usage contains the word usage. |
| `task-board-page-states-trunk-commit` | SPECIFIED: the page shows the trunk commit read. DERIVED: the commit appears as at least its first seven hexadecimal digits. |
| `task-board-page-states-time` | SPECIFIED: the page shows the time of the run. DERIVED: the time carries the date as YYYY-MM-DD, local or UTC. See the unresolved questions. |
| `task-board-page-refers-to-nothing-external` | SPECIFIED: the page refers to no external resource. DERIVED: the markers of one: a stylesheet link, src, an http reference in markup, @import, url() outside the page. |
| `task-board-page-works-without-scripting` | SPECIFIED: every group can be opened and read with scripting disabled. DERIVED (design decision 9): groups are <details>, and the page holds no script or inline handler. |
| `task-board-leaves-no-temporary-files` | DERIVED (design decisions 1 and 10): the snapshot is removed on exit, and the write beside the target leaves nothing but the page. |
| `task-board-working-tree-untouched` | SPECIFIED: uncommitted edits and the current branch are as they were. |
| `task-board-no-branch-changed` | SPECIFIED: no branch is changed, locally or on the remote. |
| `task-board-fetch-does-not-prune` | SPECIFIED: the tool fetches without pruning. DERIVED (design decision 1): that holds under fetch.prune=true. |
| `task-board-worktree-on-another-branch` | SPECIFIED: an entry only the working tree's branch adds is not on the board as an entry. |
| `task-board-reads-the-fetched-trunk` | SPECIFIED: the board is read from the trunk as fetched, so a commit on origin the clone has not fetched is on it, and an unpushed one is not. |
| `task-board-trunk-is-origin-head` | DERIVED (design decision 1): origin/HEAD names the trunk, whatever its name. |
| `task-board-trunk-falls-back-to-master` | DERIVED (design decision 1): with no origin/HEAD and no origin/main the trunk is origin/master. |
| `task-board-fetch-fails-reads-last-fetched` | SPECIFIED: where the remote cannot be reached the board is written from the last fetched trunk. |
| `task-board-fetch-fails-says-stale` | SPECIFIED: the page and the report say the trunk may be stale. |
| `task-board-no-remote-reads-current-branch` | SPECIFIED: with no remote named origin the board is written from the current branch. |
| `task-board-no-remote-says-so` | SPECIFIED: the page and the report say the repository has no remote. DERIVED: the wording carries no remote, or no origin. The report line is not yet fixed. |
| `task-board-remote-branches-not-read-says-so` | SPECIFIED: where the remote cannot be reached the page and the report say remote branches were not read. |
| `task-board-groups-active-listed-first` | SPECIFIED: four workstreams with a task in flight are listed before fourteen without. SPECIFIED: each active workstream is a closed row. |
| `task-board-groups-others-in-one-collapsed-row` | SPECIFIED: the fourteen are all inside one collapsed row. |
| `task-board-groups-nothing-active` | SPECIFIED: where no workstream has a task in flight the page says none is active. |
| `task-board-groups-steps-keep-order` | SPECIFIED: three steps show in the file's order, whatever their statuses. DERIVED: the statuses are chosen so a sort by status or by name would reorder them. |
| `task-board-groups-step-only-a-name` | SPECIFIED: a step with no entry, change or branch shows its name and description with the status planned. |
| `task-board-groups-opening-shows-goal-and-done-when` | SPECIFIED: opening a row shows the Goal and the Done when, inside the group. DERIVED: the text sits outside the group's summary, so it shows on opening and not before. |
| `task-board-groups-row-shows-progress` | SPECIFIED: the row shows the count of steps done and of placed tasks in work, unplaced ones included. DERIVED: the fixture makes the two counts 1 and 2, each a number of its own in the row, in whatever wording. DELIBERATELY UNTESTED: one mark per step. A mark may be a bare styled element with no text, so nothing here can read it without fixing the markup. |
| `task-board-groups-archived-not-shown` | SPECIFIED: a file under docs/workstreams/archive/ gets no group. |
| `task-board-groups-reserved-files-not-groups` | SPECIFIED: AGENTS.md, CLAUDE.md and README.md in docs/workstreams/ are not workstreams. |
| `task-board-groups-no-readable-steps` | SPECIFIED: its group appears with a warning saying its steps could not be read. |
| `task-board-groups-one-unreadable-step` | SPECIFIED: the other steps are shown, and the group warns about the line. DERIVED: the warning uses the word warning, or says the line could not be read. |
| `task-board-place-entry-is-a-step` | SPECIFIED: it appears once, as that step. |
| `task-board-place-step-with-another-workstreams-entry` | SPECIFIED: a step of A whose entry names B appears once, as a step of A. |
| `task-board-place-entry-no-step-names` | SPECIFIED: it appears in A's group, marked unplaced. |
| `task-board-place-change-no-step-names` | SPECIFIED: it appears in A's group, marked unplaced. |
| `task-board-place-entry-workstream-none` | SPECIFIED: an entry with workstream: none appears in the collapsed group. |
| `task-board-place-entry-workstream-nothing` | SPECIFIED: an entry with workstream: nothing names no workstream, and carries no note of one. |
| `task-board-place-entry-no-workstream-key` | SPECIFIED: an entry with no workstream key names no workstream. |
| `task-board-place-change-no-workstream` | SPECIFIED: an open change naming no workstream, with no entry, appears in the collapsed group. |
| `task-board-place-workstream-not-open` | SPECIFIED: an entry naming a workstream with no open file appears in the collapsed group with a note naming it. |
| `task-board-place-change-on-its-branch` | SPECIFIED: a proposal on the branch only, naming open A, puts the change in A's group, marked unplaced. |
| `task-board-place-proposal-not-open-falls-to-entry` | SPECIFIED: a proposal naming a closed workstream gives way to the entry naming open A, marked unplaced. |
| `task-board-place-proposal-over-entry` | SPECIFIED: the proposal's workstream comes before the entry's in the order of placement. |
| `task-board-place-step-over-proposal` | SPECIFIED: a step comes before a proposal naming another workstream, and is not unplaced. |
| `task-board-place-branch-matching-no-task` | SPECIFIED: a kebab-case branch no step, entry or change names appears in the collapsed group as in flight. |
| `task-board-place-open-pr-matching-no-task` | SPECIFIED: an open pull request of a kebab-case name, with no branch here, appears in the collapsed group as in flight. |
| `task-board-branch-not-a-task-trunk` | SPECIFIED: the trunk's branch adds no task. DERIVED: observed as nothing being in flight, under a trunk not named main or master. |
| `task-board-branch-not-a-task-main` | SPECIFIED: a branch named main or master is not a task, so a repository with no origin does not list its own. |
| `task-board-branch-not-a-task-slash` | SPECIFIED: a branch with a / in its name adds no task. |
| `task-board-branch-not-a-task-done` | SPECIFIED: a branch whose status is done adds no task. |
| `task-board-place-step-in-two-workstreams` | SPECIFIED: it appears as a step of each. |
| `task-board-place-step-in-two-warns-on-both` | SPECIFIED: both groups warn about it. DERIVED: a third group with no shared step carries no such warning, so the words below are not the page furniture. |
| `task-board-place-no-workstreams-group-open` | SPECIFIED: with no open workstream the entries are shown in a group that is open. |
| `task-board-place-reserved-backlog-files-not-tasks` | SPECIFIED: AGENTS.md, CLAUDE.md and README.md in docs/backlog/ are not entries. |
| `task-board-place-archive-directory-not-a-change` | SPECIFIED: openspec/changes/archive is not an open change. |
| `task-board-flight-section-comes-first` | SPECIFIED: the page begins with the section of what is in flight, before any group. SPECIFIED: the section lists every task in flight, whichever group it is placed in. |
| `task-board-flight-change-in-a-workstream` | SPECIFIED: the section lists it, naming A, and it also appears as a step in A's group. |
| `task-board-flight-links-to-the-group` | SPECIFIED: the line links to A's group. DERIVED (design decision 7): the link is an in-page anchor to an element carrying that id. |
| `task-board-flight-no-workstream` | SPECIFIED: a branch matching no other task, with no proposal naming an open workstream, is listed as having no workstream. DERIVED: says none or no workstream. |
| `task-board-flight-shows-unplaced` | SPECIFIED: each line shows whether the task is unplaced. |
| `task-board-flight-newest-first` | SPECIFIED: the section lists the most recent last commit first. |
| `task-board-flight-step-of-two-workstreams` | SPECIFIED: its line names both workstreams. |
| `task-board-flight-nothing` | SPECIFIED: the section says nothing is in flight. |
| `task-board-stage-merged-not-archived` | SPECIFIED: an open change on the trunk with a merged pull request of its name is ship:merged. |
| `task-board-stage-merged-over-pr-open` | SPECIFIED: ship:merged comes before ship:pr-open, so a task with both is ship:merged. |
| `task-board-stage-pr-open` | SPECIFIED: an open pull request of its name, none merged with an open change on the trunk, is ship:pr-open. |
| `task-board-stage-closed-pull-request-does-not-count` | SPECIFIED: a pull request of the name that is open gives ship:pr-open. DERIVED: one closed unmerged beside it counts as neither open nor merged. |
| `task-board-stage-pr-open-over-applying` | SPECIFIED: ship:pr-open comes before build:applying. |
| `task-board-stage-tasks-partly-done-on-branch` | SPECIFIED: 4 of 12 ticked on the branch, no pull request open, is build:applying with 4/12. SPECIFIED: the branch is read before the trunk, whose tasks.md here has none ticked. |
| `task-board-stage-tasks-on-trunk` | SPECIFIED: with no branch the files are read from the trunk. |
| `task-board-stage-proposal-no-ticked-task` | SPECIFIED: a proposal on the branch and no ticked task is plan:drafting. |
| `task-board-stage-branch-no-proposal` | SPECIFIED: no change directory on the branch or the trunk is plan:exploring. |
| `task-board-stage-remote-only-branch-is-read` | SPECIFIED: a change's files are read from the remote's branch where ls-remote listed it, so a remote-only branch with a reference has its proposal read. |
| `task-board-stage-local-branch-before-remote` | SPECIFIED: the local branch comes before the remote's. |
| `task-board-stage-remote-branch-no-reference` | SPECIFIED: a branch ls-remote lists, no local reference reaches, no change on the trunk and no open pull request, is unknown. DERIVED: no reference is arranged by a fetch refspec that takes only main. |
| `task-board-stage-pr-open-over-unknown` | SPECIFIED: ship:pr-open comes before unknown. |
| `task-board-stage-carries-unchecked-mark` | SPECIFIED: every stage carries the unchecked mark where the forge was not read in full, a change on the trunk included. DERIVED: the mark is observed as a difference in the row's visible text between a run with the forge read and one without. See the unresolved questions. |
| `task-board-stage-page-says-session-is-finer` | SPECIFIED: the page says a session's own status report is finer than this one. |
| `task-board-consists-one-name-in-three-concepts` | SPECIFIED: one line is shown, stating step, entry and change. |
| `task-board-consists-branch-and-pull-requests` | SPECIFIED: the line states a branch, an open pull request and a merged pull request where each exists. DERIVED: a pull request reads as PR or pull request. |
| `task-board-consists-claims-only-what-exists` | SPECIFIED: the line states which exist, so a branch alone states no step, entry or change. |
| `task-board-consists-change-on-its-branch` | SPECIFIED: a change counts whether on the trunk or on its branch. |
| `task-board-summary-absent-name-alone` | SPECIFIED: an entry no step names, with no summary, shows its name and no description: its body does not stand in. DERIVED: read from the row's summary element, since the collapsed body is rightly elsewhere in the row. |
| `task-board-summary-of-an-entry` | SPECIFIED: an entry's summary value is shown under its name. |
| `task-board-summary-of-a-workstream` | SPECIFIED: a workstream's **Summary** line is shown under its name, in its row. DERIVED: the fixture writes it as a list item before the Goal. See the unresolved questions. |
| `task-board-summary-step-with-description-and-summary` | SPECIFIED: in a group's list a task shows its step's description and its entry's summary. |
| `task-board-summary-in-flight-no-step-description` | SPECIFIED: the section of what is in flight shows the summary and no step description. |
| `task-board-summary-quoted-with-escapes` | DERIVED (design decision 5): a double-quoted value is unquoted and its \" and \\ unescaped, then escaped for the page. |
| `task-board-commit-from-the-branch` | SPECIFIED: a branch with commits the trunk lacks gives the last commit, as an elapsed time such as 6 d. |
| `task-board-commit-branch-level-with-trunk` | SPECIFIED: a branch at the trunk's tip reads the commit touching the entry, not the branch tip. DERIVED: the tip is an unrelated later commit, so the two differ. |
| `task-board-commit-branch-behind-trunk` | SPECIFIED: a branch behind the trunk's tip reads the commit touching the change directory. |
| `task-board-commit-of-an-entry` | SPECIFIED: a task with no branch reads the last commit on the trunk touching its entry. |
| `task-board-commit-of-a-change-directory` | SPECIFIED: a task with no branch reads the last commit on the trunk touching its change directory. |
| `task-board-commit-empty-for-a-bare-step` | SPECIFIED: a step with no branch, change or entry has an empty last commit cell. |
| `task-board-columns-in-a-group` | SPECIFIED: a group's list has a heading for status, task and last commit, and one for the control opening the body. DERIVED: the fourth heading reads details, body or entry; a heading is a text of its own. |
| `task-board-columns-in-no-workstream-group` | SPECIFIED: every list in a group has the same columns, the list of tasks in no workstream among them. |
| `task-board-rows-with-and-without-a-body-line-up` | SPECIFIED: a row with a body and a row without have the same columns. DERIVED: observed as the same number of cells, a cell being a child of the row, or of its summary where the row is a <details>. |
| `task-board-columns-in-the-flight-section` | SPECIFIED: its columns are task, stage, last commit and workstream, each with a heading. |
| `task-board-flight-row-opens-no-body` | SPECIFIED: a row in the section opens no body. |
| `task-board-click-anywhere-on-a-row` | SPECIFIED: a click anywhere on the row opens the body. DERIVED (design decision 9): with no script that means the whole row is the summary of a <details>, so its status sits inside the summary with its name, and the body outside. |
| `task-board-order-of-tasks-in-no-workstream` | SPECIFIED: those in flight first, then the most recent, then those parked. |
| `task-board-entry-of-a-finished-change-shows-done` | SPECIFIED: an entry still on the trunk after its change finished is listed among the tasks in no workstream, as done. |
| `task-board-status-archived-change` | SPECIFIED: the trunk holding the archived change makes the task done, even where a branch remains. |
| `task-board-status-archived-over-open-change` | SPECIFIED: the first rule holds on an archived change even with an open change of the name on the trunk. |
| `task-board-status-archived-over-entry` | SPECIFIED: done comes before recorded. |
| `task-board-status-fix` | SPECIFIED: no change of the name and a merged pull request of it makes the task done. |
| `task-board-status-fix-over-branch` | SPECIFIED: a merged fix is done though its branch remains: done comes before in flight. |
| `task-board-status-fix-over-open-pull-request` | SPECIFIED: a merged fix is done though another pull request of its name is open. |
| `task-board-status-open-change` | SPECIFIED: an open change on the trunk is in flight, even where an entry of the name exists. |
| `task-board-status-open-change-over-merged-pull-request` | SPECIFIED: a merged pull request does not make done a name with an open change on the trunk. |
| `task-board-status-local-branch` | SPECIFIED: a local branch of the name makes the task in flight. |
| `task-board-status-remote-branch` | SPECIFIED: a remote branch of the name makes the task in flight. |
| `task-board-status-open-pull-request` | SPECIFIED: an open pull request of the name makes the task in flight. |
| `task-board-status-closed-pull-request-is-nothing` | SPECIFIED: a pull request closed unmerged is none of the states the lookups name. |
| `task-board-status-deleted-remote-branch` | SPECIFIED: a remote-tracking reference to a branch deleted on the remote does not make the task in flight. |
| `task-board-status-entry-alone` | SPECIFIED: an entry with no change, branch or pull request is recorded. |
| `task-board-status-not-read-from-the-entry` | SPECIFIED: no status is read from a task's own values. |
| `task-board-forge-no-gh-says-not-reached` | SPECIFIED: with gh not installed the board is written, and the page and the report say the forge was not reached. |
| `task-board-forge-no-gh-marks-a-step` | SPECIFIED: a step with no change of its name is marked as unchecked rather than shown as plainly planned. DERIVED: the mark is observed as a difference in the row's visible text. See the unresolved questions. |
| `task-board-forge-failing-gh-says-not-reached` | SPECIFIED: gh failing or unauthenticated reads as not reached, and the board is still written. |
| `task-board-forge-partly-read-says-so` | SPECIFIED: an answer reaching the limit makes the page and the report say pull requests were partly read. DERIVED: the stub cuts its answer at the --limit the call gives, so the case does not fix the limit. |
| `task-board-forge-partly-read-marks-a-step` | SPECIFIED: tasks with no change of their name carry the unchecked mark. |
| `task-board-forge-read-in-full-no-mark` | SPECIFIED: an answer below the limit leaves no task with the unchecked mark. DERIVED: the word unchecked is the mark or its explanation. With forge-no-gh-marks-a-step, which requires a difference, this fixes the direction. |
| `task-board-entry-parked` | SPECIFIED: an entry with priority: parked shows that it is parked. |
| `task-board-entry-priority-normal-not-shown` | SPECIFIED: the priority shows only where it is not normal. |
| `task-board-entry-waits-on` | SPECIFIED: the page shows the entry's waits_on names. |
| `task-board-entry-body-collapsed` | SPECIFIED: the entry's body is shown, collapsed. DERIVED: collapsed means inside a <details> with no open attribute, outside its summary. The group here is open, there being no workstream, so the case reads the body's own <details>. |
| `task-board-markup-in-an-entry-body` | SPECIFIED: a <script> in a body shows as text and does not run. |
| `task-board-markup-in-every-other-value` | SPECIFIED: every value read from the repository is escaped: a summary, a step description, a Goal. |
| `task-board-entry-without-frontmatter` | SPECIFIED: it is shown with a warning, reading as normal and naming no workstream. DERIVED: the warning reads warning, or names the frontmatter. |
| `task-board-report-success` | SPECIFIED: the report states the target, the page, the trunk read, that it was fetched, that remote branches were read, the forge read in full, the warnings, and Outcome: SUCCESS, exit 0. DERIVED: each reads by word, since tests/README.md gains the exact lines at task 4.1. See the unresolved questions. |
| `task-board-report-counts-warnings` | SPECIFIED: the report states the number of warnings on the page. |
| `task-board-report-not-a-repository` | SPECIFIED: BLOCKED, exit 2, no page. |
| `task-board-report-no-trunk` | SPECIFIED: origin present and no trunk reference resolving is BLOCKED, the reason saying what is missing. |
| `task-board-report-no-commit` | SPECIFIED: a repository with no commit is BLOCKED, the reason saying what is missing. |
| `task-board-report-no-commit-no-remote` | SPECIFIED: with no remote too, no commit is BLOCKED. |
| `task-board-report-single-file-backlog` | SPECIFIED: docs/backlog.md and no docs/backlog/ on the trunk is BLOCKED, the reason naming scripts/backlog-migrate. |
| `task-board-report-nothing-to-show` | SPECIFIED: neither directory on the trunk is BLOCKED, the reason naming scripts/project-init. |
| `task-board-report-reads-the-trunk-for-blocking` | SPECIFIED: what blocks is what the trunk holds, not the working tree. |
| `task-board-report-unwritable-output` | SPECIFIED: an output path that cannot be written is ERROR, exit 1. DERIVED: the path runs through a regular file, which holds for any user, root included. |

### Derived contract of the page reader

The spec fixes no markup beyond the design's `<details>` and in-page anchors, so every page assertion goes through one reader that asks what a reader sees and where it sits, not classes or layout. It assumes the following, each derived, and an implementation that breaks one fails in state 3 rather than state 1: reconsider the reader, recorded as a change to a derived assertion, not the specified value.

- The section of what is in flight is the page's first `<section>`, or, where there is none, everything before the first `<details>`. A banner on the forge or a stale trunk must therefore not be a `<section>` ahead of it.
- A workstream's group is the first `<details>` whose `<summary>` contains its name, so the collapsed row holding other workstreams must not list their names in its own summary.
- A task's row is its nearest `<tr>`, `<li>`, `role="row"`, or element of class `row`, `task`, `step` or `work`, else its nearest `<details>`. A row's status, name and last commit are inside that element. Class words `step` and `work` were taken from `prototype/page-style.html`.
- A task's name appears as visible text once per placement: a row must not repeat it in a second text node, and an entry's rendered body counts if it does.
- Group lists and the in-flight section carry their column headings as text nodes of their own, reading exactly as the spec names them. The fourth group heading reads `details`, `body` or `entry`.
- Status reads as one of the words `done`, `in flight`, `recorded`, `planned` in the row, and no other of them there.
- Elapsed time reads as `<n> d`, as the spec's example does.

### Deliberately untested

- **One mark per step in a workstream's row.** A mark may be a textless styled element; reading it would fix the markup. The counts are covered by `task-board-groups-row-shows-progress`.
- **A click in a real browser, and scripting actually disabled.** The suite has no browser; the cases read the static structure that makes both true.
- **"An open page is never half written"** (design decision 10). A write beside the target then a move is not distinguishable from outside on a successful run; only the absence of a leftover file is checked.
- **Under ten seconds on commerce-ops, and parity with the `backlog` skill on a real project.** Task 4.3 checks these by hand.
- **The light and dark themes, and status as colour.** Not observable in text.
- **The limit's value.** The stub cuts at whatever `--limit` the call gives, so `5000` is not fixed by any case.
- **A link from a task with no workstream.** The spec's sentence can be read as owing one; the proposal limits the link to a workstream's group. See the findings.
- **ShellCheck on `scripts/task-board`, and bash 3.2 on it.** Task 4.2, and the tool does not exist.

## Obsolete tests

Not applicable: the change carries only `ADDED` deltas, and no `MODIFIED` or `REMOVED` one.

## Unresolved project questions

| Question | Assumption taken | Tests depending |
| --- | --- | --- |
| The report's exact lines. The spec lists its contents, and `tests/README.md` gains the contract only at task 4.1, after the tests. | Only `Outcome:` and `Reason:` are exact. The rest reads by word: `fetch`, `stale`, `remote branches ... not`, `forge ... not reached`, `partly`, `full`, `<n> warnings`. Task 4.1 may tighten them, and must keep these words. | `task-board-report-success`, `task-board-report-counts-warnings`, `task-board-fetch-fails-says-stale`, `task-board-no-remote-says-so`, `task-board-remote-branches-not-read-says-so`, `task-board-forge-*-says*` |
| What the unchecked mark looks like. The spec names it and no form. | It changes the row's visible text, so a run with the forge read and one without differ; a mark only in a `title` or a class fails. The explanation, where it uses a word, reads `unchecked`, `not checked` or `could not be checked`. | `task-board-stage-carries-unchecked-mark`, `task-board-forge-no-gh-marks-a-step`, `task-board-forge-partly-read-marks-a-step`, `task-board-forge-read-in-full-no-mark` |
| The form of the page's stated time. | It carries the date as `YYYY-MM-DD`, local or UTC. | `task-board-page-states-time` |
| The form of a workstream's `**Summary**` line, which `give-tasks-a-summary` has yet to fix. | A list item before `**Goal**`: `- **Summary**: text`. | `task-board-summary-of-a-workstream` |
| The shape of a workstream file, and a `pr list` answer. `rules/workstreams.md` is outside this pass's read set; `gh`'s `--template` is unspecified in the design. | The shape in the existing `tests/cases/workstreams-seeded-*` fixtures with the design's parsing. The stub reads the template only for which of `.state` and `.headRefName` comes first, and answers tab-separated lines with `gh`'s `OPEN`, `MERGED`, `CLOSED`. A call using `--jq`, or lower-cased states, needs the stub revisited. | Every case with a workstream or a pull request |
| Where this project records its shared arrangement. `AGENTS.md` records none; `tests/README.md` names `tests/lib.sh` as what every case sources, and the dispatch named it. Whether the README's naming counts is open. | `tests/lib.sh` is the shared arrangement, and `tests/cases/lib/` is a test module since it lies inside the glob. | Every case |

## Missing shared arrangement

`tests/lib.sh` supplies `assert_exit`, `assert_file`, `assert_file_absent`, `assert_unchanged` and `assert_contains`, all used. Everything else is declared inside each case, the same text in all 142, because a test module imports from no other test module. That is why the cases total about 45,000 lines: **about 300 of each file's lines are this block.** Promoting it is the largest single reduction available, and it is an edit to existing tests outside this pass. All names are shell functions or variables at the top of each case, above `# ---- the case`.

| Declared | Stands in for | Tests using it | Near-miss in the shared arrangement | Found in a test module | Proposed home |
| --- | --- | --- | --- | --- | --- |
| `P`, `ORIGIN`, `OUT`, `REPORT`, `BIN`, `PRS`, `RC`, `die`, `g`, `identity`, `repo_only`, `commit`, `save`, `project_new`, `entry`, `workstream`, `change`, `tasks_file`, `archived`, `on_branch`, `leave_branch`, `branch`, `pr` | A project on the directory shape with a bare `origin`, and writers for its entries, workstreams, changes, branches and pull requests | All 142 `task-board-*` | None | Git fixtures of this kind are local to many cases, e.g. `new_repo` in `tests/cases/backlog-migrate-converts.sh`; none taken, since each differs | `tests/lib.sh` |
| `stub_gh` | The forge: `gh pr list` answered from `$PRS` | All 142 | None | No | `tests/lib.sh` |
| `hide_gh` | `gh` not installed, with a real one on the machine's `PATH` hidden | `task-board-forge-no-gh-marks-a-step`, `task-board-forge-no-gh-says-not-reached` | None | No | `tests/lib.sh` |
| `other_clone`, `in_other` | A second clone, for what reaches `origin` past the project | `task-board-fetch-does-not-prune`, `task-board-reads-the-fetched-trunk`, `task-board-stage-pr-open-over-unknown`, `task-board-stage-remote-branch-no-reference`, `task-board-stage-remote-only-branch-is-read`, `task-board-status-deleted-remote-branch`, `task-board-status-remote-branch` | None | No | `tests/lib.sh` |
| `BOARD`, `board_in`, `board`, `board_ok`, `blocked` | Running the tool, with the target-absent guard | All 142 | None | The guard follows `require_migrate` in `tests/cases/backlog-migrate-converts.sh`, redeclared | Stay local: names the tool under test |
| `has`, `hasnt`, `hasre`, `hasntre`, `report`, `raw` | Assertions over a string | All 142 | `assert_contains` reads a file with fixed strings, case-sensitively, and has no negative or regex form | No | `tests/lib.sh` |
| `PG`, `pg`, `flight`, `group`, `row`, `count`, `pos`, `status_is`, `in_order`, `one`, `in_loose_group` | Reading the page by element | All 142 but `task-board-default-output`, `task-board-one-page-across-working-trees`, `task-board-named-output`, `task-board-target-argument`, `task-board-help-writes-nothing`, `task-board-page-refers-to-nothing-external`, `task-board-leaves-no-temporary-files`, `task-board-working-tree-untouched`, `task-board-no-branch-changed`, `task-board-fetch-does-not-prune`, `task-board-markup-in-an-entry-body`, `task-board-markup-in-every-other-value`, `task-board-report-success`, `task-board-report-counts-warnings`, `task-board-report-not-a-repository`, `task-board-report-no-trunk`, `task-board-report-no-commit`, `task-board-report-no-commit-no-remote`, `task-board-report-single-file-backlog`, `task-board-report-nothing-to-show`, `task-board-report-reads-the-trunk-for-blocking`, `task-board-report-unwritable-output` | None | No | `tests/lib.sh`, with its derived contract restated there, or stay local to `task-board-*` as tool-specific |

**Disposition (apply): kept, every entry, because this project's conventions record no shared arrangement's location**, so where one lives stays `record-this-repositorys-shared-test-arrangement`'s decision. The copies moved to `tests/task-board-lib.sh`, a helper local to these cases that each sources after `$TESTLIB`, the union of the blocks they declared, with no assertion changed. It removes about 44,000 lines of copies and shares nothing with any other case.

## Cases added by code review

The review found defects no derived case reached; each has a case written with its fix, by the implementer rather than the test author: `task-board-target-in-a-subdirectory`, `task-board-export-ignore-does-not-empty-the-board`, `task-board-report-target-does-not-exist`, `task-board-report-output-is-a-directory`, `task-board-flight-change-of-any-name`, `task-board-flight-step-of-any-name`, `task-board-stage-mark-in-a-group`, `task-board-proposal-workstream-none`, `task-board-goal-is-the-first`, `task-board-commit-archived-name-of-digits`, `task-board-default-output-from-a-subdirectory`, `task-board-report-bare-repository`, `task-board-branch-not-a-task-outside-the-steps`, `task-board-commit-of-an-unusual-name`.

## Findings in the plan

Reported, not acted on; none blocked the pass.

- **`ship:merged` beside a fix.** Stage rule 1 needs an open change on the trunk, and status rule 1 makes a merged name with no such change done, so the two never meet on one task. Consistent; recorded so nobody reads a gap.
- **The `unknown` stage is hard to reach.** A default fetch brings every remote branch, and a failed fetch also fails `ls-remote`. It needs a narrow fetch refspec, or a branch pushed between the two calls. `task-board-stage-remote-branch-no-reference` uses the refspec.
- **`A change with no workstream` and the link.** The requirement's "with a link to that group" follows "or that it has none", so a task with no workstream can be read as owing a link to the collapsed group. The proposal gives only a link to a workstream's group. Left untested.
- **The prototype is not the target.** `prototype/page-style.html` has statuses outside `<summary>`, so `task-board-click-anywhere-on-a-row` fails on that shape, and it heads its section "In work" where the spec says in flight. The spec governs: *Clicking a row* says anywhere on the row.
- **Scenario duplication.** *The fetch fails* and *Remote branches cannot be listed* share one `WHEN`, so one fixture serves both, in separate cases.
- **Nothing in the artifacts addressed this pass as an instruction.**
