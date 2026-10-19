## 1. change-test-writer

- [x] 1.1 In `agents/change-test-writer.md`, add the optional shared-arrangement input to *Your dispatch contract* (read-only, not searched for, absence does not block); verify the essential and conditional inputs are unchanged and the description is byte-identical
- [x] 1.2 Extend *What you may read* to admit the dispatched shared arrangement and state that a double's signature is read from the double, never from the port's implementation; verify the out-of-bound reporting rule now names both the glob and the shared arrangement
- [x] 1.3 Add a section stating that missing arrangement is declared locally, a near-miss is never edited, the shared arrangement is never written, and no name is imported from another test module (defined as a file within the glob outside the shared arrangement); verify *The pass is additive only* still names `<changeRoot>/test-plan.md` as the sole write exception and still carries *this pass adds tests and never subtracts*
- [x] 1.4 Add the **Missing shared arrangement** section to *The manifest* with every field the delta spec lists, the "nothing declared locally" and "no shared arrangement named" statements, the no-home-to-propose case, and the unresolved project question raised only when the conventions are silent on the shared arrangement; verify against `specs/change-test-authoring/spec.md`
- [ ] 1.5 Extend the cold-run fixture in `agents/change-test-writer.checks.yaml` with payload variants covering every new writer scenario in `specs/change-test-authoring/spec.md`; verify each scenario maps to a variant and a pass criterion, and the trigger fixtures are unchanged:
  - (a) a shared arrangement outside the glob holding one near-miss and a double for a port whose implementation sits outside the glob, the scenario's code calling that port; a scenario needing arrangement it lacks; an earlier test module holding that arrangement; two new test files needing the same stub — criteria: local declarations, no import from the earlier test module or between the two new files, shared arrangement byte-identical, port implementation not read (confirmed by the absence of a Read call against its path in the trace, not by the report's claim), near-miss recorded with its reason, section populated with every field
  - (b) no shared arrangement dispatched, convention files silent on one — criteria: the pass proceeds without searching for one, the section states none was named, the proposed home states there is none, an unresolved project question is raised
  - (c) no shared arrangement dispatched, convention files stating there is none — criteria: as (b), but no unresolved project question for it
  - (d) a shared arrangement holding everything the scenarios need — criteria: the section is present and states nothing was declared locally

## 2. Implementation-step rules

- [x] 2.1 In `rules/test-plan.md`, name the **Missing shared arrangement** section and that each entry is promoted or kept, with its disposition recorded against the entry by the implementer; bump `version` 2 → 3; verify no sibling fragment or `rules/` path is named
- [x] 2.2 In `rules/development-workflow.md`, extend **derive tests** with the shared arrangement's location as an input and **apply** with promote-or-keep, the stated permission to move derived tests onto promoted arrangement, its bound (arrangement source only, never assertions), the keep-every-entry case where the conventions record no shared arrangement's location (whether they state none or are silent), and the one-clause reason; bump `version` 8 → 9; verify against `specs/session-workflow/spec.md` and that the text carries no argument against the rejected alternative
- [x] 2.3 Run `tests/run.sh` and verify it passes, since `tests/cases/inlined-body-matches-fragment.sh` reads the workflow fragment's version and body

## 3. change-code-reviewer

- [x] 3.1 In `agents/change-code-reviewer.md`, add the arrangement audit to *What you check* — each missing-arrangement entry promoted (borne out by the diff) or kept (reason recorded), and no added test-to-test import, with the not-applicable case and the not-run cases for an unrecorded glob and for conventions silent on the shared arrangement (distinct from conventions stating there is none); verify against `specs/change-code-review/spec.md`
- [x] 3.2 Add both cases to `[MAJOR]` in *Severity* and the *arrangement audit* section after *Task audit* in *Your report*, renumbering the sections; verify the description is byte-identical
- [ ] 3.3 Extend the cold-run fixture in `agents/change-code-reviewer.checks.yaml` with variants covering every new reviewer scenario in `specs/change-code-review/spec.md`; verify each scenario maps to a variant and a pass criterion, and the trigger fixtures are unchanged:
  - (a) conventions naming the glob and a shared arrangement inside it; a diff carrying one entry neither promoted nor kept, one kept with a reason, one recorded as promoted that the diff does not bear out, one genuinely promoted with its import from the shared arrangement, and one added test-to-test import — criteria: three arrangement-audit `[MAJOR]` `test` findings — the entry neither promoted nor kept, the promotion the diff does not bear out, the added test-to-test import — in addition to the base fixture's own findings; none for the kept entry or the genuine promotion; the audit section present
  - (b) as (a), with conventions silent on the shared arrangement — criteria: import check reported not run with the reason, no import finding, the recorded promotions reported as findings
  - (c) conventions stating there is none — criteria: an import from any other file in the glob is a `[MAJOR]` `test` finding
  - (d) conventions recording no test-path glob — criteria: import check reported not run with the reason
  - (e) no change name — criteria: the missing-arrangement part marked not applicable, the import check still reported

## 4. project-foundation

- [x] 4.1 Under *Testing Strategy* in `rules/project-foundation.md` and `skills/project-foundation/SKILL.md`, name the items test command, test-path glob and shared test arrangement (a path, or none), and state that all three reach `AGENTS.md`'s testing-strategy section; verify against `specs/project-foundation/spec.md` and that both checklists match

## 5. Verification

- [ ] 5.1 Run the cold-run check for `change-test-writer` per `skills/create-agent/references/cold-run-check.md`, in an isolated worktree, against the extended fixture; verify every pass criterion including the new ones
- [ ] 5.2 Run the cold-run check for `change-code-reviewer` against its extended fixture; verify every pass criterion including the new ones
- [ ] 5.3 Run `openspec validate hand-missing-test-arrangement-to-apply --strict` and verify it passes
