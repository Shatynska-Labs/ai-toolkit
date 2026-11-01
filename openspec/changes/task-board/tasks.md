## 1. Reading the project

- [x] 1.1 Create `scripts/task-board` with the shape of the other shipped tools (help, argument and `--output` handling, cleared git environment, report, exit codes) and verify the `--help`, named output, default output outside the project with `git status` unchanged, one page across working trees, not-a-repository, no-trunk, single-file backlog, nothing-to-show and unwritable-output cases pass
- [x] 1.2 Resolve the trunk, fetch, and extract the snapshot into a temporary directory, and verify the cases for a worktree on another branch, a failed fetch, no remote and uncommitted edits left as they were pass
- [x] 1.3 Gather the name sets from the snapshot, `git for-each-ref`, `git ls-remote` and `gh`, and verify the deleted-remote-branch, unlisted-remote-branches, no-`gh` and partly-read cases pass, the last with a stub `gh` answering exactly the limit

## 2. Deriving and placing

- [x] 2.1 Implement the status lookups in the order `rules/workstreams.md` states and verify a case passes for each lookup and each precedence pair
- [x] 2.2 Parse workstreams, entries and proposals, place each task once, and verify the placement cases pass: entry as step, step with another workstream's entry value, unplaced entry and change, no workstream, a workstream not open, a change on its branch naming a workstream, a proposal naming one not open, a step in two workstreams, a branch matching no task, branches that are not tasks, no readable steps, one unreadable step, no frontmatter

## 3. Rendering

- [x] 3.1 Render the page and verify the cases pass for active and other workstreams, nothing active, step order, the page's stated moment, the columns with and without a body, a click on a row, the order of tasks in no workstream, the in-flight count including unplaced tasks, the Done when on opening, last commit from a branch, level with the trunk and absent, summary present, quoted with an escape, and absent, Goal, no archived workstream, priority, `waits_on`, entry body, the open group in a project with no workstream, and the absence of any external reference or script
- [x] 3.2 Render the in-flight section first, newest first with its own columns, and on every task what exists under its name, and verify the cases pass for its ordering and columns, a step of two workstreams naming both, a summary shown there, a change in a workstream, a change with none, nothing in flight, one name in three concepts, and a change with no entry
- [x] 3.3 Derive each in-flight task's stage from its branch or the trunk and verify a case passes for each stage, including the unknown stage, a remote-only branch, an open and a merged pull request of one name, and the page's note that a session's report is finer
- [x] 3.4 Escape every repository value and verify the case for markup in an entry passes
- [x] 3.5 State the stale trunk, no remote, unlisted remote branches and unreached forge on the page and in the report, with the warning count in the report, and verify the unchecked mark appears only where the forge was not read in full

## 4. Documentation and verification

- [x] 4.1 Add the tool and its report contract to `tests/README.md`, and its cases to `tests/coverage.md`, and verify the contract matches the script's output
- [x] 4.2 Run ShellCheck on `scripts/task-board` and `bash tests/run.sh`, and verify both are clean
- [ ] 4.3 Run the tool on this repository and on commerce-ops, and verify each step's status matches the `backlog` skill's **workstreams** operation, that no entry is missing, and that commerce-ops takes under ten seconds
