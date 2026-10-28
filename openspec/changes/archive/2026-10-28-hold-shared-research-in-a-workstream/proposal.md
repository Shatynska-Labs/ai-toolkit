## Why

In commerce-ops (2026-10-27) the operator opened three related workstreams in one session. Most of what that session established is shared by several steps and decided before any step's proposal exists: a map of where column knowledge is duplicated across 15 files, the measured size of the current UI and the case for and against moving it to React, a field model (a fixed key versus an editable label), how batching works without a cohort entity, and which engine mechanisms the new approach reuses. That is a workstream's initial research.

The seeded `docs/workstreams/README.md` gives it nowhere to live: "Keep a workstream short: its goal, what finishes it and its steps. Lasting decisions belong in a document or a change's design that the file points to." Both places it leaves fail:

- **A change's design or handoff** belongs to one step. Research shared by several steps is copied into each or missed by all but one, and it is archived with the first step to finish while later steps still need it.
- **A separate document under `docs/`** is what the operator used to do, and `docs/` became a heap of documents whose relation to any goal was unclear. Nothing ties a research document to the workstream it served, or retires it when that workstream is archived.

The workstream file is already the one place every step of the goal points to, and it is archived whole when the goal is met. It is the natural home for what its steps share.

**Workstream**: none. This change advances no open workstream.

## What Changes

- **A workstream holds what its steps share, besides its plan.** Two optional sections after the field list: `## Context` for research, findings and the options considered with why one was chosen, and `## Decisions` for decisions that shape more than one step or were taken before any step's proposal existed.
- **The boundary with a step's design is stated.** A decision that shapes one step belongs in that step's design; one that shapes several belongs in the workstream, and a step's design points to it rather than copying it.
- **What it holds is never progress.** Context and Decisions say what is known and decided about the goal, never that a step is done, in flight or merged.
- **What it holds is current.** A change in the workstream that overturns something it holds revises it in place and names itself, in its plan commit or at the latest at its archive. The file's history keeps what was held before.
- **The edit rule widens** to cover context and decisions added or revised.
- **The `Decisions` list item is replaced by the `## Decisions` section**, and an answered open question is recorded there. "Keep a workstream short" is removed.
- **This repository's own README follows the seeded text**, and its two open workstreams move their `Decisions` pointer into a `## Decisions` section; the step description and backlog entry that name "the document Decisions names" are reworded.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `project-bootstrap`: *A workstream register is seeded where none exists* replaces the "kept short" statement with what a workstream holds besides its plan, its boundary with a step's design, that it is not progress, and that it is revised in place; widens the edit statement; and replaces the `Decisions` field with `## Context` and `## Decisions` sections in the shape.

## Impact

- `scripts/project-init` (the seeded workstream heredoc only).
- This repository's `docs/workstreams/README.md`, `complete-the-workstream-loop.md` and `see-the-backlog-across-projects.md`, and the backlog entry `docs/backlog/review-a-workstream-against-its-goal.md`.
- `tests/coverage.md`, the derived cases, and the existing cases that pin the old wording: `workstreams-seeded-statements`, `workstreams-seeded-fields-are-a-list`, `workstreams-seeded-no-status-field`.
- No change to the workflow fragment, which defers to the README and keeps its version, or to the `backlog` skill, which quotes none of the changed rules. Both "not restated" cases stay green.
- Consumers: `project-init` leaves an existing README untouched, so each project adopts the new text by hand. Moving research documents already under its `docs/` into the workstreams they served is each project's own adoption work.
