## Why

The seeded `docs/workstreams/README.md` asks a workstream's Done when for "a condition that can be checked against the repository, the forge or production". "Every step is archived" meets that wording, but it proves only that the step list was worked through, not that the Goal holds; a list missing a step meets it all the same. Three of commerce-ops's four open workstreams use that form. Its `purchase-order-process`, whose Done when is a staging observation of the Goal, shows the stronger one.

**Workstream**: `complete-the-workstream-loop`, step 3.

## What Changes

- **The seeded shape asks for an effect.** The Done when line of the seeded workstream shape asks for an observable effect of the Goal, with every step being archived beside it where that is wanted.
- **The seeded prose says why.** A new paragraph says that what finishes a workstream is an observable effect of its Goal: what to look at, what provokes it where something must, and what result means the Goal holds. Every step being archived may stand beside the effect but never in its place.
- **This repository's own `docs/workstreams/README.md` follows the seeded text.** Its two open workstreams already name an effect, so neither is edited.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `project-bootstrap`: *A workstream register is seeded where none exists* adds a statement about what finishes a workstream, and changes the Done when in the workstream shape.

## Impact

- `scripts/project-init` (the seeded workstream heredoc only).
- This repository's `docs/workstreams/README.md`.
- `tests/coverage.md` and the derived cases.
- No change to the workflow fragment, which defers to the README, or to the `backlog` skill, which reads no Done when's content.
- Consumers: `project-init` leaves an existing README untouched, so commerce-ops adopts the text and revises its three workstreams itself, as work too small to be a change.
