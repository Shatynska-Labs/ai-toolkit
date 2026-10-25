# `see-the-backlog-across-projects`

**Goal**: the operator sees every project's backlog and workstreams, and the links between their entries, on one board read from the repositories, so that work running in parallel sessions across several projects stays findable without holding it in memory.

**Done when**: this library ships a board that, run over two repositories on the directory shape, renders both projects' entries, workstreams and the links between entries, with each step's status derived from the repository.

**Steps**:

1. `one-file-per-backlog-entry` — the backlog becomes one file per entry with its values as frontmatter, with a converter for the single-file shape.
2. `backlog-board` — a read-only board over one or more repositories: entries, workstreams, derived status and the links between entries, served locally or written as one HTML file.

- **Not in scope**: a tracker outside the repository (ClickUp, Linear, GitHub Projects), two-way or not; storing status in an entry; migrating each consuming project, which each does in a pull request of its own.
- **Open questions**: in what language the board is written, given `AGENTS.md`'s rule that using the library requires nothing installed; whether a checker refusing malformed frontmatter ships, and whether on its own or inside the board.
- **Decisions**: `one-file-per-backlog-entry`'s `design.md`.
- **Opened**: 2026-10-25, by the operator, with the plan of `one-file-per-backlog-entry`.
