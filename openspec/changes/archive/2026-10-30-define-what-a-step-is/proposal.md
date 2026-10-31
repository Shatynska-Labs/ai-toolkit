## Why

The seeded workstream rules read a step's status from the repository by the step's name, but they assume every step is a change and belongs to exactly one workstream. Neither holds in practice, and each gap gives a wrong answer:

- **A step taken as a fix reads as planned.** A fix leaves no archived change, and its backlog entry is deleted once it is taken, so by the seeded status lookups it falls back to `planned`. The **workstreams** operation then names finished work as next, and a Done when of "every step is archived" can never hold while the workstream holds a fix. commerce-ops works around this locally: its `speed-up-the-test-suite` removed a fix step from Steps in the fix's own commit, which also erases the step from the plan the workstream's retrospective will read.
- **A change can be a step of two open workstreams.** In commerce-ops, `serve-a-subject-other-than-a-launch` is step 1 of both `purchase-order-process` and `unit-economics-beyond-the-launch`. The status row's workstream cell reads "the open workstream whose steps name the change", which is singular, so the row is ambiguous for that change. The archive re-read does not say which workstream places its entries, and with a retrospective at the archive (`complete-the-workstream-loop`, decision 3) neither would its lessons.

Both are rules about what a step is, in the same paragraphs of `rules/workstreams.md`, so they are settled in one change.

**Workstream**: `complete-the-workstream-loop`. This change takes over its steps `count-a-fix-step-as-done` and `name-a-shared-step-once`, merged into one step under this change's name.

## What Changes

- **A fix's merged pull request counts as done.** A step is done where the trunk holds an archived change of its name, or where no change of its name exists on the trunk and a pull request from a branch of its name has merged: a step taken as a fix. A session that cannot reach the forge says so rather than reading such a step as planned.
- **"Every step is done" replaces "every step is archived".** The Done when paragraph and the shape's Done when line read "done" wherever they read "archived", so a workstream holding a fix can finish.
- **A change is a step of one workstream only.** Another workstream whose goal also needs it does not list it among its steps. A step of that workstream that cannot start before the change names the change in its backlog entry's `waits_on`, recording that entry first where the step has none.
- **The workstreams rules rise to `2.0.0`.** A project whose workstreams list one change in two of them must edit a workstream file by hand.
- **This repository follows.** Its `docs/workstreams/AGENTS.md` block is brought to the new fragment. `complete-the-workstream-loop` merges its first two steps into this change, and its Done when reads "every step is done".

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `project-bootstrap`: *A workstream register is seeded where none exists* gains a fix's merged pull request as a source of `done`, the rule that a change is a step of one workstream only, and "done" in place of "archived" for what may stand beside the Done when's effect.

## Impact

- `rules/workstreams.md`: its body and its version.
- This repository's `docs/workstreams/AGENTS.md` (via `scripts/project-update`) and `docs/workstreams/complete-the-workstream-loop.md`.
- `tests/coverage.md` and the derived cases. `workstreams-seeded-done-when-statement.sh` and `workstreams-seeded-done-when-shape.sh` assert "every step is archived", and that assertion in each goes obsolete.
- No change to the workflow fragment: with one workstream per change, its status row's singular cell and its archive re-read are already unambiguous. The `backlog` skill takes the status lookups from the rules file and already reads pull requests from the forge; only its **close** operation's wording changes, so that it no longer invites removing a step taken as a fix.
- Consumers: `scripts/project-update` replaces an unedited block. commerce-ops then lists `serve-a-subject-other-than-a-launch` in one of its two workstreams and makes the other's dependent step wait on it, as work too small to be a change. Its removed fix step may be restored.
- Backlog: the entries `count-a-fix-step-as-done` and `name-a-shared-step-once` are closed when this change is archived.
