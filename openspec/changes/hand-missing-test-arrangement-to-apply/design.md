## Context

See `proposal.md` for why. Four places carry the test-authoring flow today, and each is touched:

- `agents/change-test-writer.md` writes tests inside the dispatched test-path glob, with `<changeRoot>/test-plan.md` as the one write outside it. It reads the change's artifacts, `specsRoot`, the convention files, an earlier `test-plan.md`, and files within the glob — so a shared arrangement outside the glob (`tests/support/` beside a `tests/test_*.py` glob, say) is currently unreadable to it.
- `rules/test-plan.md` (version 2) tells an implementer to read the manifest before implementing.
- `rules/development-workflow.md` (version 8) is inlined into consuming projects. Its **derive tests** names the test command and test-path glob as the author's inputs; its **apply** names no step concerning the derived tests beyond making them pass.
- `agents/change-code-reviewer.md` traces scenarios to tests and audits tasks; it has no check on how tests take their arrangement.

`rules/project-foundation.md` and `skills/project-foundation/SKILL.md` carry a testing-strategy section with no named items.

## Goals / Non-Goals

**Goals:**

- A piece of arrangement first needed by a change reaches the shared arrangement in that change, or stays local by a recorded decision.
- No new test-to-test import is added by the writer, and one added by an implementer is caught at review.
- The writer's additive-only guarantee and its single write exception are unchanged.

**Non-Goals:**

- What a good shared arrangement looks like, how a kept double is marked in source, how a pointer to a shared type is spelled: `share-a-suites-test-arrangement` in `docs/backlog.md`, which `skills/testing` will carry.
- Clearing the test-to-test imports a project already has. The reviewer reports only imports the diff adds.
- A new field in the writer's `description`. See decision 5.

## Decisions

**1. The writer declares locally and lists; it never writes the shared arrangement.** Alternatives: widen the write glob to the shared arrangement (rejected — editing a shared double is editing every test that uses it, and breaks *this pass adds tests and never subtracts*); allow only *new* shared modules (rejected — telling new from changed needs a rule the writer can get wrong, and a second write exception turns a one-hole boundary into a judgment). Listing costs the implementer a step; it keeps the boundary checkable.

**2. "Test module" is defined by the two dispatched paths, not by file naming.** A test module is a file within the test-path glob that is not part of the shared arrangement. That is decidable by the writer from its dispatch and by the reviewer from the conventions file, with no runner-specific knowledge of what is "collected". Where the shared arrangement lies inside the glob (`tests/support/` under `tests/**`), the exclusion handles it. The writer, dispatched with no shared arrangement, treats every file in the glob as a test module, which is safe for it: it only declares more locally and lists it. The reviewer distinguishes two cases the writer need not: conventions that *state* the project has none, where every file in the glob is a test module, and conventions *silent* on it, where the import check is reported not run. Silence cannot be read as "none", because a project whose conventions predate this change may keep its shared arrangement inside the glob, and the reviewer would then report the very promotions the change requires.

**3. The writer may read the shared arrangement, but not through it.** The read bound exists so assertions are not shaped to the implementation. A shared double is test code the writer needs in order to use it, so reading it is admitted; following it to the port's implementation is not, and the double's own signature is what the writer relies on. If the double is unfaithful to the port, that is what review and the project's own suite catch — the writer does not audit it.

**4. Dispositions are recorded in `test-plan.md`, against each entry, by the implementer.** Alternatives: in `tasks.md` (rejected — it is planning, written before the manifest exists, and the writer cannot add tasks); as a marker in the test source (rejected — how a keep is spelled in source belongs to `share-a-suites-test-arrangement`, and the reviewer needs a record per manifest entry, not a search). The manifest is the one place both the writer's list and the implementer's answer can sit side by side, so the reviewer reads one file. Consequence: the implementer now writes to a file the writer owns. That is stated in `rules/test-plan.md`. A repeat writer pass replaces the manifest wholesale and drops recorded dispositions; promoted items will no longer be listed, since the shared arrangement now holds them, and a kept item reappears without its reason — the reviewer then reports it, so the loss is visible rather than silent.

**5. The writer's description does not change.** It names essential inputs only, as `change-test-authoring` requires, and sits at 980 of 1024 characters. The new input is optional, like the earlier `test-plan.md` path, which the description does not name either. The dispatcher learns of it where it learns the test command: the workflow's **derive tests** paragraph and the project's conventions. Keeping the description unchanged also keeps the recorded trigger check valid (`create-agent`: a description edit invalidates the trigger check; a body edit the cold-run check).

**6. Both reviewer checks are `[MAJOR]`, kind `test`.** An item neither promoted nor kept is an unfinished step of the change, the same weight as a task marked done that is not. A new test-to-test import is the coupling this change exists to stop. Neither is `[MINOR]`'s "breach that changes no behaviour": each was measured to let production faults through green suites. Kind `test` rather than a new kind, because both concern how tests are arranged and the kind set is fixed by the spec.

**7. The report gains an *arrangement audit* section** after the task audit, rather than folding into findings alone, so a clean audit is stated rather than inferred from the absence of findings — the same reason traceability and task audit are sections.

**8. Fragment versions.** `rules/development-workflow.md` goes 8 → 9 because its inlined body changes (`project-bootstrap`'s increment rule). `rules/test-plan.md` goes 2 → 3 by the same rule applied to an imported fragment. `rules/project-foundation.md` is a procedural checklist and carries no version.

**9. Foundation names three testing items, not one.** Adding only the shared arrangement as an item would leave the two inputs that already matter more (command, glob) unnamed beside it. Itemizing all three under *Testing Strategy* makes every input the writer is dispatched with checkable in the foundation artifact.

**10. Tests are derived as the workflow requires, and the cold-run checks carry the verification.** This repository's conventions name no test-derivation exemption, so `change-test-writer` is dispatched once the plan is committed (test command `tests/run.sh`, test-path glob `tests/cases/*.sh`). Coverage is the writer's to decide: most scenarios here concern how an agent behaves, which no test in `tests/` can run, though the suite can assert on rule text, as `tests/cases/inlined-body-matches-fragment.sh` already does. The dispatch carries no expected outcome. The agents' behaviour is verified by `create-agent`'s cold-run check, whose fixtures are extended to exercise each new writer and reviewer scenario. In this change only variant (a) of each agent is run — the mixed fixture exercising most of the new behaviour — by the operator's decision on 2026-10-19 to limit usage. The conditions the other variants isolate (conventions silent on the shared arrangement, stating none, recording no glob, no change name, nothing missing) are therefore stated in the bodies and in the static cases but not observed in a run; the fixtures keep them for a later one.

## Risks / Trade-offs

- [The implementer promotes an item and changes an assertion while moving the test] → the permission is bounded in the fragment, and the reviewer already reads every touched test file in full; an assertion change in a derived test is a `test` finding under existing rules.
- [A project with no shared arrangement gets a section listing items with nowhere to go] → the entry's proposed home says there is none, apply keeps each entry with that reason — and does the same where the conventions are silent, so nothing is promoted into a location the reviewer cannot check — and creating a shared arrangement is a testing-strategy decision outside the change.
- [The reviewer cannot tell a test module from the shared arrangement where the conventions file is silent] → the import check is reported not run with that reason, not guessed.
- [Existing consumers never revisit foundation, so the new item does not reach them] → the gap is surfaced, not prescribed: the writer raises an unresolved project question on every pass while the conventions are silent, and the reviewer reports its import check not run. The fragment does not direct sessions to record it, because `session-workflow` keeps one-time setup obligations out of the fragment, and the same argument was rejected there for creating a missing backlog.
- [Consumers on version 8 of the workflow block keep the old apply text] → reconciliation of a stale managed block is outside `project-init`'s scope today, as for every earlier version bump.

## Migration Plan

Consuming projects pick up the agents on plugin update; the workflow block updates when a project re-inlines it. A project whose conventions predate this change learns of the gap from the writer's unresolved project question and the reviewer's not-run line, and records its shared arrangement's location, or that it has none, under its testing strategy in `AGENTS.md` by hand. Until then its tests declare arrangement locally and the import check does not run. commerce-ops then edits its project-local `test-harness` skill — its own change.
