## Context

See `proposal.md` for why, and `see-a-projects-tasks`, decision 9, for the application this serves. `scripts/task-board` runs one awk program that gathers, derives and renders HTML in one pass, and its rows are built as strings.

## Goals / Non-Goals

**Goals:**

- One derivation behind both outputs, so a task cannot read differently in them.
- A document a reader can rely on, with a version to check.

**Non-Goals:**

- Anything of `dev-task-board` itself.
- Several projects in one document. A reader runs the tool once per project.
- A schema file. The requirement is the contract until a second reader needs more.
- Showing `--json` data on the page, or changing the page.

## Decisions

### 1. Same program, a second renderer

`board.awk` keeps gathering and placing as it does. Its `BEGIN` branches at the end: with `TB_FORMAT=json` it prints the document instead of the page. The `FLIGHT` stage and proposal reading in bash runs in both.

*Alternative:* a second awk program over intermediate files. Rejected: it needs every array serialised, which is more code than the renderer.

### 2. Escaping is one function

Warnings are held as text and rendered by each output, and are counted before rendering, so the page and the document state one number. `jstr(s)` escapes `\`, `"` and control characters and leaves other bytes alone, so UTF-8 passes through. A control character other than tab and newline becomes `\u00XX`. An entry's `body` is its text from the file, with newlines, not the page's paragraphs, so `read_entry` keeps both.

### 3. Status words differ from the page's, and the trunk has a state

`trunk.state` has three values because the page states three things, and a boolean would claim or deny a fetch that never ran for a repository with no `origin`. JSON carries `in_flight`, where the page says `in flight`: a value a program compares should hold no space, and the page's word is a label.

### 4. `written_at` is UTC, `last_commit` an integer

A reader computes elapsed time itself, since a page's bare `6 d` is stale the moment it is written.

### 5. Standard error holds the report, and the document is printed whole

The report lines stay as they are, and one function prints them to the stream `--json` selects. Arguments are scanned for `--json` before anything is reported, so the stream does not depend on their order. `--output --json` is read as the refusal rather than as a file named `--json`; any other value of `--output` is taken as it is today. The document is written to a file under the temporary directory and printed once awk has succeeded, so a failure leaves standard output empty.

## Risks / Trade-offs

- **A version number that nothing enforces.** → A case fixes the current value and the key set, so a change to either has to touch it.
- **Awk building JSON by hand can emit an invalid document.** → Cases parse the output where `python3` or `jq` is present, with a fixture holding each hard character; where neither is, they say so.
- **Text that is not UTF-8 would make the document invalid**, since `jstr` leaves bytes alone. → Assumed away: the repositories this reads hold UTF-8, and a reader that cannot parse a project says so for that project alone.
- **The two renderers can drift.** → A case compares status, stage and placement of the two outputs.
