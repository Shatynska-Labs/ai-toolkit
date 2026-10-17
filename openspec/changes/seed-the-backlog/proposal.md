## Why

The workflow fragment tells a session to record out-of-scope work in `docs/backlog.md`, but nothing creates that file, so each project's first session invents its header, its entry shape and its rules — seven projects carry seven variants of the same file. The fragment also carries the entry rules itself, including a paragraph on entry numbers being unstable identifiers; numbering entries at all is what makes an agent cite or reorder by number, and the paragraph exists only to undo that.

## What Changes

- `scripts/project-init` creates `docs/backlog.md` where it is absent, in both the new-project and the adoption mode, with a fixed starting text that states what an entry is, how its heading is named, that entry order carries no meaning, when an entry is deleted, that the file is kept when empty, and the shape of an entry. An existing file is never touched. The report gains a `backlog:` line.
- `rules/development-workflow.md` shrinks: it keeps the routing rule and the reason the backlog sits outside a change, drops the create-if-absent clause, drops the entry-number paragraph, and points to the backlog file for how an entry is written and deleted. Entry numbers are mentioned nowhere. Its `version` increments.
- Tests: a case for the created file's content, one for an existing backlog preserved byte-for-byte, the repeated-run case extended to the backlog, and the fixed-paths case loses its number assertion.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `project-bootstrap`: the tool gains a backlog concern — created where absent, never overwritten — and owns the entry rules the created text states; the per-concern list names it.
- `session-workflow`: the backlog requirement no longer obliges the fragment to state the entry-number rule or the create-if-absent direction; it hands ownership of the entry rules to `project-bootstrap` and obliges the fragment to defer to the backlog file for them.

## Impact

- `scripts/project-init`, `tests/cases/`, `tests/README.md` (report contract), `tests/coverage.md`, `skills/project-init/SKILL.md`.
- `rules/development-workflow.md` (version 4 → 5); every adopting project sees a version skew on the next run, which the tool already reports.
- Existing projects' backlogs are untouched; their numbered headings and number paragraphs stay until edited by hand.
