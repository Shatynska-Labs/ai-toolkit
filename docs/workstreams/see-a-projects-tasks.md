# `see-a-projects-tasks`

**Goal**: the operator sees all of one project's tasks on one board read from its repository, grouped by workstream with each step's status, with the tasks no workstream holds beside them, and with what is in work first, each change shown with its stage and against its workstream, so that the project's work stays findable without holding it in memory.

**Done when**: this library ships a tool that, run in a project on the directory shape, writes one HTML file opening with every task in flight, its stage and the workstream it belongs to, then showing each open workstream with its steps in order and each step's status, a step with no backlog entry among them as planned, and the entries naming no workstream in a group of their own; and a step's status on the board matches what the `backlog` skill's **workstreams** operation reports for it.

**Steps**:

1. `one-file-per-backlog-entry` — the backlog becomes one file per entry with its values as frontmatter, with a converter for the single-file shape.
2. `give-tasks-a-summary` — backlog entries and workstreams gain an optional one-line summary, expected of new ones, for a list to show.
3. `task-board` — a read-only tool that writes one self-contained HTML file for one project: what is in flight, its workstreams with their steps and statuses, and its entries that no workstream holds.
4. `group-tasks-into-workstreams` — the `backlog` skill groups entries that have no workstream into a new or existing workstream, and moves a task from one workstream to another, so the board's contents are changed by asking in a session.

- **Not in scope**: a board over several projects; a local server, any page that updates itself, or editing from the page; workstreams nested in workstreams; a tracker outside the repository (ClickUp, Linear, GitHub Projects), two-way or not; storing status in an entry; migrating each consuming project, which each does in a pull request of its own.
- **Open questions**: whether a checker refusing malformed frontmatter ships, and whether on its own or inside the board.
- **Opened**: 2026-10-25, by the operator, with the plan of `one-file-per-backlog-entry`.

## Decisions

**1. The entry model the board reads** is recorded in `one-file-per-backlog-entry`'s `design.md`.

**2. The board is seen through workstreams, for one project.** The operator, 2026-11-01. Tasks are grouped by workstream, and the board covers the project it is run in rather than several. This replaces the plan for a board across projects and the name `see-the-backlog-across-projects`. Running it once per project still gives a view of each.

**3. Revised with `task-board`. A task is a step, an entry, an open change, or a branch or open pull request in flight that matches none of those.** The operator, 2026-11-01. A workstream's group holds its steps, whether or not a backlog entry exists for them, so a step that is only a name shows as planned. An entry or change naming a workstream whose steps do not name it shows in that workstream's group as unplaced. Every other task shows in a group of its own, collapsed unless the project has no open workstream, so work is visible before its first pull request merges and nothing is left off the board.

**4. Bash, writing one HTML file.** The operator, 2026-11-01. A tool in `scripts/` written in bash and awk, like `project-init`, writes a self-contained file on each run, since using the library requires nothing installed. The page is a snapshot of the run that wrote it.

**5. Tasks are changed through the `backlog` skill, not from the page.** The operator, 2026-11-01. Editing from the page needs a local server, which overturns decision 4, so grouping entries into a workstream and moving a task are operations of the skill. Backlog.md and Beads were weighed as ready-made task managers and rejected: Backlog.md stores status and numbers its tasks where here status is derived and the name is the identity, and neither holds a workstream's Goal, Done when and Decisions. Editing from the page and nesting workstreams are left until the board has been used.

**6. Changes, workstreams and backlog entries are one view.** The operator, 2026-11-01, with `task-board`. A name is one task whichever of these it appears in, and the page opens with what is in flight, at what stage, and how each relates to a workstream, so the three need no separate reading. The stage is what the repository shows, and read from a change's branch, since its progress lives there.

**7. A summary is its own field, and nothing stands in for it.** The operator, 2026-11-01. A Goal cut to two lines read badly on real data, and first sentences of entries are too long, so a task with no summary shows its name alone. Every entity should have one; existing ones stay valid without it, so no project must fill them in at once.

**8. The page leads with what is active.** The operator, 2026-11-01. commerce-ops has 18 workstreams with 4 active, so the rest collapse into one row.
