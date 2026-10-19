# Handoff: hand the test arrangement a derivation lacks to the implementer

## Why this was identified

`change-test-writer` may write only inside the dispatched test-path glob, plus its manifest. Most suites keep their shared test arrangement outside that glob: builders, fixtures, fakes and stubs in a module the runner imports but never collects (`tests/support/`, `testutils/`, `spec/support/`, a `conftest` the project treats as shared). When a scenario needs arrangement that module lacks, the writer does the only thing open to it: it declares the arrangement inside the test file it is writing. That is correct by its own contract, since a deriving author writes tests, not the harness. Nothing downstream picks the declaration up, though, so it stays where it was written.

The consequences compound over many changes. Measured in commerce-ops on 2026-10-18:

- **Copies drift from the real interface.** Each derivation models the collaborator only as far as its own scenarios need. Two production faults passed green suites because every local double agreed with the same wrong caller: an admin page cast a store to the wrong port, and a page read a method the catalog port does not have.
- **Test modules become each other's libraries.** A later derivation finds the arrangement it needs in an earlier test file and imports it from there, under its private name. A census by import, counting each `from <test module> import …`, found 87 test modules imported by 152 other test files. Each import couples the importer to a module that can be rewritten or deleted for reasons of its own.
- **The clean-up costs more than prevention would have.** Moving that arrangement into the shared module afterwards is being done one source module per pull request, by hand, each with a full suite run. Re-exports through third modules surface only when the suite fails, because an import census cannot see them.

## What was decided, and what was rejected

Decided in commerce-ops on 2026-10-18. The proposal should restate it as its own decision, with the reasoning, rather than cite it.

**Rejected: widening the writer's write glob to the shared arrangement.** The shared module is code that existing tests depend on. Editing a shared double changes what every test using it arranges, which is editing existing tests by another route. That breaks the property dispatchers rely on: *this pass adds tests and never subtracts*. Adding a new shared module would be purely additive, but the writer cannot tell "new" from "changed" without a rule that is easy to get wrong. Keep the glob as it is.

**Taken: the writer names what is missing, and the implementer promotes it in the same change.**

1. **`change-test-writer`** gains an optional dispatch input: the path(s) of the project's shared test arrangement, read-only. Where a scenario needs arrangement that is not there, the writer:
   - still declares it locally, so the tests run and fail for the right reason;
   - never imports arrangement from another test module, only from the shared arrangement or its own file, since cross-module test imports are the second failure above;
   - lists each local declaration in a new manifest section, **Missing shared arrangement**, recording: its name; what it stands in for (the port, collaborator or value); the tests using it; whether the shared arrangement already holds a near-miss (and why the near-miss would not do); and a proposed home.

   Where the dispatch names no shared arrangement, the section says so rather than being omitted.
2. **The implementation step**, through `rules/test-plan.md` and `rules/development-workflow.md`'s **apply**, promotes each listed item in the same change. It adds the item to the shared arrangement, or extends the existing near-miss, and moves the derived tests onto it. Where it does not promote an item, it records a reason the item stays local: a *keep*.
   - **State the permission outright.** This is the implementer editing derived tests, so the rule must say these edits are allowed. Otherwise an implementer reading "never edit an existing test" either won't touch them, or will touch them and the edit looks like weakening at review.
   - **The edit is bounded.** Only the arrangement's source changes (its import, or a constructor adapter). The tests' assertions do not change.
3. **`change-code-reviewer`** checks two things:
   - every item in the manifest's Missing shared arrangement section was promoted or carries a recorded keep;
   - the diff adds no import of one test module's names from another test module.

   Both can be read from the diff and the manifest, so the reviewer needs no judgement of significance.

## What bears on it

- **`share-a-suites-test-arrangement`** (`docs/backlog.md`) puts guidance on a shared arrangement into `skills/testing`: where builders live, when a bespoke one is warranted, how a keep is recorded and how a pointer to a shared type is spelled. That entry covers what a good shared arrangement is; this change covers how a derivation feeds it. Design them together, or take this one first and let that one reference its manifest section. Do not merge them: that entry is large and carries two open decisions of its own.
- **Assets this change edits:**
  - `agents/change-test-writer.md`: the dispatch contract, *What you may read*, *The pass is additive only* and *The manifest*;
  - `agents/change-test-writer.checks.yaml`;
  - `agents/change-code-reviewer.md` and its `.checks.yaml`;
  - `rules/test-plan.md`;
  - `rules/development-workflow.md` (**derive tests** names what the dispatch carries; **apply** names the promotion).

  Agent edits follow `create-agent`'s standard, including its trigger check and cold-run check.
- **The new input belongs to the project's conventions,** like the test command and the test-path glob. `project-foundation`'s testing-strategy step and the workflow's **derive tests** paragraph should say a project names its shared arrangement path, or states that it has none.
- **Consumers.** commerce-ops records this decision in its own backlog, under `promote-the-remaining-local-doubles-into-the-harness`, and will edit its project-local `test-harness` skill once the toolkit ships the change. Name it as a consumer, not as part of this change.

## What it must not undo

- The additive-only guarantee and its wording in the writer's report: *this pass adds tests and never subtracts*.
- The single named exception to the write glob, `<changeRoot>/test-plan.md`. The shared arrangement does not become a second exception.
- The read bound against implementation source. The shared arrangement is test code and may be read, but reading it is no route to the implementation: a shared double mirrors a port's signature, and the writer reads that signature from the double, never from the port's implementation.
- The manifest being replaced wholesale on a repeat pass, and `rules/test-plan.md` remaining the second, redundant pointer to it.
- A change declaring no specification deltas still owes no new tests, and so has no missing arrangement to hand on.
