## Why

`scripts/project-update` replaces a block at a new major version and reports only the jump in numbers, so whatever that version asks a project to do by hand reaches nobody. `rules/workstreams.md` and `rules/development-workflow.md` are already at `2.0.0`, and each asks something the tool never says. This is step 3 of `keep-projects-on-the-current-workflow`, whose Done when requires the tool to list the manual steps a version asks for.

## What Changes

- Add `rules/changelog`: one record per version of a fragment above `1.0.0`, stating what that version changed and, for a major, what a project must do by hand.
- Record the two versions already shipped, `development-workflow` `2.0.0` and `workstreams` `2.0.0`.
- `scripts/project-update` prints, under the line of each block it replaces or converts, the records between the project's version and the one written: what a minor or major changed, and each thing a major asks by hand. A patch prints nothing. A block crossing variants counts as held at `1.0.0` of the variant it arrives at.
- The tool reports `BLOCKED` where `rules/changelog` is absent or holds a malformed record, and says so for each major a run crosses that has no record.
- A version rise now owes its changelog record in the same edit, and a test holds that across `rules/`.
- `rules/` gains a second file that is not a fragment.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `project-update`: prints what each version asks, and adds the changelog to what blocks a run.
- `project-bootstrap`: a fragment's version rise owes a changelog record.
- `toolkit-structure`: `rules/changelog` joins `rules/manifest` as a file in `rules/` that is not a fragment.

## Impact

- `rules/changelog` (new), `scripts/project-update`, `rules/README.md`, `AGENTS.md`, `tests/README.md`, `tests/coverage.md`.
- `tests/cases/rules-manifest-only-non-fragment.sh` asserts the state this change ends, so it is revised and recorded as obsolete in the test plan.
- `scripts/project-init` is unchanged: it writes the current text, so a new project has no version to catch up from.
- No fragment's body changes, so no fragment's version rises.

## Workstream

Serves `keep-projects-on-the-current-workflow`, of which it is step 3.
