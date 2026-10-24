## Why

The workflow's unit of work is a change, and a change is usually smaller than the goal it serves: a phase of a feature, or a test-suite speed-up, takes a sequence of changes, some still to be identified. Nothing records that sequence. An operator running several sessions on several such goals at once has to keep in their head which change belongs to which goal and what comes after it. A backlog entry a change records is detached from the goal that produced it, and a change opened from the backlog does not know it is a step of anything.

The case that surfaced this is commerce-ops (2026-10-24). Its operator runs about five sessions in parallel, across two or three goals at a time. They wrote hand-made plan documents per goal (`docs/keywords-seo-phase.md` and its siblings), and a `docs/roadmap.md` whose *In flight now* table had not been updated in two weeks, because no rule says when it is. Both mix what is decided with what is in progress, and nothing says which parts are still current or when a goal is finished.

## What Changes

- **A workstream**: a goal that takes more than one change, recorded as one file, `docs/workstreams/<name>.md`, with a goal, a checkable **Done when**, and an ordered list of **Steps**. Each step is named by the change it is expected to be. The file records the plan and never a step's status. A step's status (done, in flight, recorded, planned) is read from the repository: archived and open change directories, branches, backlog headings. A plan that holds no status cannot go stale when its work moves on.
- **A finished workstream is archived, not deleted**: once its Done when holds, or once the operator abandons it with a reason, the file moves to `docs/workstreams/archive/<date>-<name>.md` (operator, 2026-10-24).
- `scripts/project-init` seeds `docs/workstreams/README.md` where none exists. It states how a workstream is named, shaped, opened, kept and archived, as the seeded backlog states its own entry rules. An existing file is left byte-for-byte unchanged.
- The seeded `docs/backlog.md` entry shape gains **Workstream**: the workstream the entry is a step of, or `nothing`. It defaults to the workstream of the change that recorded it, so derived work stays attached. An entry without the field is `nothing`.
- The workflow fragment (`rules/development-workflow.md`, version 10 → 11):
  - a proposal states which workstream the change advances, or that it advances none;
  - the status row every session prints on entry and before stopping gains a first cell, the workstream (`none` where there is none), so the operator can tell which line of work each session belongs to;
  - the **archive** step re-reads the workstream the change advanced, places the entries attached to it among its steps, and archives the workstream once its Done when holds.
- `skills/backlog/SKILL.md`:
  - **record** sets Workstream;
  - **pick** groups takeable entries by workstream, in step order;
  - **sweep** and **audit** check that a named workstream exists and is not archived;
  - a sixth, read-only operation, **workstreams**, reports where each open workstream stands, step by step, from the repository.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `project-bootstrap`: *A backlog is seeded where none exists*: the entry shape names Workstream and its default. *Each concern is checked independently and is safe to repeat*: the workstream register is a concern. Added: *A workstream register is seeded where none exists*.
- `session-workflow`: *A session reports where its change stands before acting*: the row's first cell is the workstream. Added: *A change states the workstream it advances, and archiving re-reads it*.
- `backlog-maintenance`:
  - *The skill operates on the project it is invoked in*: six operations, and a missing workstream register.
  - *The skill restates neither the entry rules nor the workflow's obligations*: nor the workstream rules.
  - *Record writes an entry the file can be relied on for*, *Pick lists what can be taken now*, *Close removes an entry and every reference to it*, *Sweep performs the archive step's re-read* and *Audit verifies every entry independently and changes nothing without the operator* read and maintain Workstream.
  - Added: *Workstreams reports where each workstream stands*.

## Impact

- `scripts/project-init`: one more seeded file, and the backlog's seeded text. Existing files are untouched, so an adopting project adds both by hand.
- `rules/development-workflow.md`: body and version.
- `skills/backlog/SKILL.md` (body and description) and `skills/backlog/references/audit.md`.
- This repository's own `docs/backlog.md` preamble, its own `docs/workstreams/README.md`. `reconcile-the-status-row-verification-cell` is recorded in it during planning (design decision 13).
- `tests/coverage.md`, and new cases from the derived-tests step.
- Consumers: commerce-ops adopts it in a change of its own. That change brings its backlog preamble to the current seeded shape, opens its first workstreams from its phase plans, and reduces `docs/roadmap.md` to directions. It is not part of this change.
