## Why

The seeded backlog gives each of an entry's seven fields its own paragraph, so every entry carries six blank lines that say nothing. In commerce-ops, whose hundred entries were brought to the seeded shape on 2026-10-24, that is several hundred lines of a file already too long to scan. The operator asked for the fields without blank lines, and for the workstream template to match (2026-10-24).

The same reading showed a wording fault. Every empty field reads `nothing`, which suits one field only: an entry *waits on nothing*, but *Workstream: nothing* and *Design with: nothing* read oddly. They should read *none*. The status row and a proposal already say `none` for a change in no workstream.

**Workstream**: none.

## What Changes

- **The fields become a list.** The seeded `docs/backlog.md` entry shape gives its fields as one Markdown list, `- **Priority**: …` to `- **Re-checked**: …`, with no blank line between them. Lines without a list marker would render as one run-on paragraph wherever the file is read as Markdown.
- **The workstream template does the same.** The seeded `docs/workstreams/README.md` shape does this for the fields after the steps: Not in scope, Open questions, Decisions and Opened. Goal and Done when stay paragraphs, and Steps stays a numbered list.
- **An empty field reads `none`, except Waits on.** Design with, Workstream, Not in scope, Open questions and Decisions give their absent value as `none`. Waits on keeps `nothing`.
- **The `backlog` skill reads both forms.**
  - It writes `none` where the file says so.
  - It reads an earlier `nothing` in those fields as the absent value.
  - It reads fields written as paragraphs the same as listed ones, so no existing backlog breaks.
- **This repository's own files follow the seeded text:** the `docs/backlog.md` preamble and its entries, and `docs/workstreams/README.md`.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `project-bootstrap`: *A backlog is seeded where none exists* and *A workstream register is seeded where none exists* change the fields' layout and absent values.
- `backlog-maintenance`:
  - *Record writes an entry the file can be relied on for* and *Sweep performs the archive step's re-read* write the file's absent value, `none` in the seeded file.
  - *Pick lists what can be taken now* groups an entry naming no workstream apart, whichever word it carries.
  - *Entries in an older shape are reported, not rewritten* reads the earlier value and layout.

## Impact

- `scripts/project-init` (both seeded heredocs), `skills/backlog/SKILL.md` (body only; description unchanged), `skills/backlog/references/audit.md`.
- This repository's `docs/backlog.md` and `docs/workstreams/README.md`.
- The existing cases asserting the old layout or `nothing` (8 seeded-backlog cases found by trial, and `backlog-skill-record-workstream`), `tests/lib.sh`'s `fenced_line` and its description in `tests/README.md`, and `tests/coverage.md`.
- The workflow fragment is unchanged: it names no entry field.
- Consumers: commerce-ops reformats its preamble, entries and workstreams in a follow-up pull request after this merges.
