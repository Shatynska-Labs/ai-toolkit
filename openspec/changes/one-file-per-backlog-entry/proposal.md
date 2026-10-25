## Why

The seeded backlog is one Markdown file, and in the projects that use it the file has outgrown what a person or a tool can read reliably. Eight projects carry one, about 330 entries in all; commerce-ops alone holds 95 entries in 1,534 lines across 14 workstreams. Every parallel session edits that one file, so their edits conflict. Its fields are free text, so tooling cannot read them. They also drift between projects:

- Fields are list items in some files and paragraphs in others.
- Priority and Workstream exist only in newer files.
- The empty value is written `nothing`, `none` or `nothing.`.

The operator wants to see backlogs and their links across projects on a board (2026-10-25). That needs entries a program can read without guessing, which the single file cannot give.

**Workstream**: `see-the-backlog-across-projects`, opened with this change's plan; this change is its first step.

## What Changes

- **BREAKING — the backlog becomes a directory.**
  - The backlog moves from `docs/backlog.md` to `docs/backlog/`.
  - Its rules move to `docs/backlog/README.md`.
  - Each entry becomes its own file, `docs/backlog/<name>.md`. The file's name is the entry's name and its only identifier.
- **An entry's values move into YAML frontmatter.**
  - The values sit in a fixed, flat subset of YAML: scalars, double-quoted free text and inline lists, with no nesting. Any YAML reader can read it, and so can a shell tool with no parser installed.
  - The reasons a value needs stay in the body as prose: why a fix or a change, the evidence for `high`, why the recording change did not do the work.
- **Waits on is split in two.** `waits_on` lists only names of entries or changes, so a dependency is an edge a program can follow. `waits_for` holds a checkable condition that is not a name, such as a person's answer or an event. `parked_until` holds a parked entry's condition.
- **Absent values are uniform.** An empty list is `[]`, an entry in no workstream has `workstream: none`, and an omitted key means its stated default.
- **New shipped tool: `scripts/backlog-migrate`.**
  - It converts a project's `docs/backlog.md` into `docs/backlog/` and deletes the old file.
  - It reads every shape found in the eight projects: list-item and paragraph fields, older entries without Priority, Kind or Workstream, and extra fields such as Must not undo.
  - It drops no entry text. Text it cannot map into a value stays in the entry's body under the field's label, and its report names each such case. The old preamble is replaced by the seeded README, and the report says so.
  - It is bash and awk, so it needs nothing installed.
- **`scripts/project-init` seeds `docs/backlog/README.md`.**
  - It writes the README where neither a `docs/backlog/` directory nor a `docs/backlog.md` file exists, and beside existing entry files in a `docs/backlog/` directory that lacks one.
  - Where only `docs/backlog.md` exists, it leaves that file unchanged and its report names `scripts/backlog-migrate`.
- **The seeded workstream README follows the move.** A step is *recorded* where `docs/backlog/` holds an entry of its name.
- **The workflow fragment names `docs/backlog/`** wherever it named `docs/backlog.md`. Its version goes from 11 to 12.
- **The `backlog` skill works on the directory.**
  - It reads the rules from `docs/backlog/README.md`.
  - It writes and edits entry files and reads `waits_on` and `waits_for` separately.
  - It refuses a project still on the single file and names `scripts/backlog-migrate`.
- **This repository migrates its own `docs/backlog.md`** with the new tool, and opens the workstream `see-the-backlog-across-projects`.

## Capabilities

### New Capabilities

- `backlog-migration`: `scripts/backlog-migrate` — what it converts, how each field of each older shape maps, what it refuses, and what it reports.

### Modified Capabilities

- `toolkit-structure`: *Documentation separation of concerns* — shipped tooling admits `scripts/seed/`, the texts the shipped tools write verbatim, and `AGENTS.md` says why they are not `rules/`.

- `project-bootstrap`:
  - *A backlog is seeded where none exists* — the seeded path, the README's statements, the entry file's frontmatter and body, and the report for a project still on the single file.
  - *A workstream register is seeded where none exists* — the recorded-status lookup names `docs/backlog/`.
- `session-workflow`: *A second change surfacing in a session is recorded in the backlog* — the fragment names `docs/backlog/`. The requirements on the apply pick-up, the archive re-read and workstreams change only by the path they name.
- `backlog-maintenance`:
  - Every operation now reads the directory and its README.
  - **record** writes an entry file.
  - **close** deletes one and edits the frontmatter of entries naming it.
  - **pick**, **sweep**, **audit** and **workstreams** read `waits_on` and `waits_for` separately.
  - A project on the single file is refused with a pointer to the migration tool.
  - *Entries in an older shape* narrows to entries missing a value, since migration normalises layout and absent values.

## Impact

- **Code and tests:**
  - `scripts/project-init`: the backlog seed and its report, and the workstream seed's lookup.
  - The new `scripts/backlog-migrate` and its test cases.
  - About 40 existing cases under `tests/cases/` that assert the single file's path or shape, plus `tests/coverage.md`.
- **Rules and skills:** `rules/development-workflow.md` (version 12), `skills/backlog/SKILL.md`, `skills/backlog/references/audit.md`, and `skills/project-init/SKILL.md`, which names the seeded file.
- **This repository's files:** `docs/backlog.md` becomes `docs/backlog/`. `docs/workstreams/README.md` follows the seed, and `docs/workstreams/see-the-backlog-across-projects.md` is new.
- **Consumers:**
  - Each of the eight projects migrates in a pull request of its own after this lands: it runs `scripts/backlog-migrate` and takes the version 12 fragment into its `AGENTS.md`.
  - Until `update-managed-block` lands, `project-init` cannot rewrite an existing managed block, so that fragment update is made by hand.
  - A project not yet migrated keeps working by its own rules, but the updated `backlog` skill refuses it.
- **Not in this change:** the board, `backlog-board`, which is the workstream's next step.
