## Why

`change-test-writer` may write only inside the dispatched test-path glob, so when a scenario needs a builder, fixture, fake or stub the project's shared test arrangement lacks, it declares that arrangement inside the test file it is writing — and nothing downstream ever moves it. Across many changes those local copies drift from the interface they stand in for (two production faults in a consuming project passed green suites because every local double agreed with the same wrong caller), and later derivations import them from one another's test files (87 test modules imported by 152 other test files in the same project), so the clean-up afterwards costs a hand-made pull request per source module. The cheap point to fix a missing piece of arrangement is the change that first needed it, while its author and its tests are both in hand.

## What Changes

- **`change-test-writer` names what is missing rather than reaching for it.** It gains an optional, read-only dispatch input: the path or paths of the project's shared test arrangement. Where a scenario needs arrangement that is not there, it still declares it locally, so the tests run and fail for the right reason; it never imports arrangement from another test module; and it lists each local declaration in a new manifest section, **Missing shared arrangement** — the name, what it stands in for, the tests using it, any near-miss in the shared arrangement and why it would not do, and a proposed home. Where the dispatch names no shared arrangement, the section says so rather than being omitted.
- **The implementation step promotes each listed item in the same change.** It adds the item to the shared arrangement, or extends the near-miss, and moves the derived tests onto it — or records a *keep*: a reason the item stays local. The rule states outright that this edit to derived tests is permitted, and bounds it: only where the tests take the arrangement from changes, never what they assert.
- **`change-code-reviewer` checks the hand-off.** Every listed item is promoted or carries a recorded keep, and the diff adds no import of one test module's names into another. Both are read from the diff and the manifest.
- **The input becomes a project convention.** Like the test command and the test-path glob, the shared arrangement's location — or the statement that the project has none — is recorded under the project's testing strategy, and the workflow's **derive tests** paragraph names it among what the test author needs. A project whose conventions are silent on it is told so by the writer's unresolved project question and the reviewer's not-run report.

Rejected, and kept rejected: widening the writer's write glob to the shared arrangement. Editing a shared double changes what every test using it arranges, which is editing existing tests by another route, and it would break the property dispatchers rely on — *this pass adds tests and never subtracts*. Telling a new shared module from a changed one would need a rule that is easy to get wrong. The single named exception to the write glob stays `<changeRoot>/test-plan.md`.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `change-test-authoring`: the dispatch contract gains the optional shared-arrangement input; the read bound admits it without opening a route to implementation source; the writer never imports arrangement from another test module; the manifest gains the **Missing shared arrangement** section; the test-plan fragment names that section and its disposition.
- `change-code-review`: the review audits the manifest's missing-arrangement items and the diff's test-to-test imports, and the severity scale places both.
- `session-workflow`: the workflow fragment's **derive tests** names the shared arrangement among the test author's inputs, and **apply** promotes or keeps each listed item, with the edit to derived tests permitted and bounded.
- `project-foundation`: the testing strategy records the test command, the test-path glob and the shared test arrangement's location, or that the project has none.

## Impact

- `agents/change-test-writer.md` — the dispatch contract, *What you may read*, *The pass is additive only*, *The manifest*. The description is unchanged: it names essential inputs only, and this input is optional.
- `agents/change-code-reviewer.md` — *What you check*, *Severity*.
- `agents/change-test-writer.checks.yaml`, `agents/change-code-reviewer.checks.yaml` — cold-run fixtures extended to exercise the new behaviour; the trigger fixtures stand, since neither description changes.
- `rules/test-plan.md` (version 2 → 3), `rules/development-workflow.md` (version 8 → 9, since its inlined body changes).
- `rules/project-foundation.md`, `skills/project-foundation/SKILL.md` — the testing-strategy section of the checklist.
- **Related backlog entry**: `share-a-suites-test-arrangement` puts guidance on what a good shared arrangement is into `skills/testing`. This change covers how a derivation feeds one; that entry, taken later, can reference this change's manifest section. They are not merged.
- **Consumer**: commerce-ops, which recorded this decision under its own backlog entry `promote-the-remaining-local-doubles-into-the-harness` and will update its project-local `test-harness` skill once the toolkit ships it. Not part of this change.
