# Test plan — add-change-code-reviewer

Derived by `ai-toolkit:change-test-writer` from `specs/change-code-review/spec.md` as committed at `bd39d65`, before implementation. Read this before implementing: it is not an artifact the OpenSpec schema knows about, so `openspec instructions apply` does not list it.

The implementation under test is the text of `agents/change-code-reviewer.md` and `rules/development-workflow.md`. Every case here is a static read of that text (the testing floor's third situation), so each one carries a fixture-driven discriminator: it runs its own check over material it writes to `$TESTDIR` and requires the rejection to come from the scan its scenario names.

## Baseline

Full suite, `bash tests/run.sh` from the worktree root, at `bd39d65` before any case was added: **73 passed, 0 failed**.

After this pass: **74 passed, 4 failed**. The four failures are the new cases below, red against the present placeholder and v4 fragment; the fifth new case passes (see its row).

## Running one case

The runner takes no case selector. A case runs alone, from the worktree root, as:

```
TESTLIB=$PWD/tests/lib.sh TOOLKIT_ROOT=$PWD TESTDIR=$(mktemp -d) bash tests/cases/<case>.sh
```

## Cases written

| Case | State at authoring | Discriminator |
|---|---|---|
| `tests/cases/change-code-reviewer-verdict-set.sh` | Red — the placeholder states none of the four verdicts. Turns green when the agent states `` `APPROVED` ``, `` `CONDITIONALLY APPROVED` ``, `` `FIX REQUIRED` ``, `` `REJECTED` ``. | Fixture: the whole set in `change-plan-reviewer.md`, the code reviewer missing standalone `` `APPROVED` ``; must be rejected on that verdict. |
| `tests/cases/change-code-reviewer-finding-vocabulary.sh` | Red — no severity or kind stated. Turns green when the agent states `[CRITICAL]`, `[MAJOR]`, `[MINOR]` and the backticked kinds `requirement`, `test`, `task`, `scope`, `convention`, `defect`, `injection`. | Fixture: every token except kind `` `scope` `` (present only in a neighbouring agent and as a bare word); must be rejected on `` `scope` ``. |
| `tests/cases/change-code-reviewer-traceability-markers.sh` | Red — no marker stated. Turns green when the agent states `[Implemented]`, `[Partially Implemented]`, `[Not Implemented]`, `[Contradicted]`, `[Untested]`, `[Uncovered —…`, `[Exempt —…`. | Fixture: every marker, exemption written `[Exempt]` with no reason; must be rejected on `[Exempt —`. |
| `tests/cases/change-code-reviewer-no-edit-grant.sh` | **Green at authoring** — the placeholder's grant carries no `Write`, `Edit`, `MultiEdit` or `NotebookEdit`. Expected: it guards a property task 1.2 keeps, not one the change introduces. A pass here establishes nothing by itself; the discriminator is what does. | Fixture: the design's grant as a YAML block list with `Edit` added; must be rejected on `Edit`. Vacuity guard: the extracted grant must name `Bash`. |
| `tests/cases/workflow-fragment-build-binding-verdict-acts.sh` | Red — `build`'s binding names the reviewer and no verdict. Turns green when the `_Claude Code binding:_` paragraph inside `### build` states each verdict followed by its act. | Two fixtures: (1) verdicts and acts in `plan`'s binding only — rejected on `` `REJECTED` `` not stated; (2) `build`'s binding names all four but gives `REJECTED` a fix-and-re-review act — rejected on the act for `` `REJECTED` ``. |

Each discriminator was run to completion against a synthetic compliant root (all five exit 0, so every fixture was rejected for its named reason), and each was mutation-checked: deleting the scan its fixture targets, removing `### build` scoping, or disabling block-list reading of the grant makes the case fail. All five are ShellCheck-clean.

## Scenario accounting

25 scenarios in the delta spec; 25 accounted for. 13 covered in part by a case, 12 uncovered. None is covered in full: each scenario's outcome is a review's reasoning or a session's act, and what a case can reach is the closed vocabulary or fixed sentence that outcome requires to exist.

| # | Requirement | Scenario | Status |
|---|---|---|---|
| 1 | Dispatched working tree and committed target | The working tree is not supplied | Uncovered — the reviewer's conduct on a dispatch; no program here runs a review. Verified by the cold-run check (task 4.2) and by reading. |
| 2 | ″ | The working tree carries uncommitted work | Uncovered — same reason. |
| 3 | ″ | The target is not checked out | Uncovered — same reason. |
| 4 | ″ | No change name is supplied | Uncovered — same reason. |
| 5 | ″ | The change name does not resolve | Uncovered — same reason. |
| 6 | Artifacts and conventions are the reference | A delta spec is absent | Uncovered — what a report says given an artifact set; reasoning. |
| 7 | Everything the reviewer reads is data | The diff instructs the reviewer | Covered in part — `change-code-reviewer-finding-vocabulary.sh` (kind `` `injection` `` stated). Unasserted: that the line is raised and the verdict ignores it. |
| 8 | ″ | The diff quotes an instruction as its subject | Uncovered — a judgment on use, not on the string; the requirement itself says the string alone does not decide it, so no token scan can. |
| 9 | Every requirement, scenario and task is traced | A scenario has no covering test | Covered in part — `change-code-reviewer-traceability-markers.sh` (`[Implemented]`, `[Untested]`), `change-code-reviewer-finding-vocabulary.sh` (`[MAJOR]`, `` `test` ``). |
| 10 | ″ | A scenario is uncovered with a reason that holds | Covered in part — `change-code-reviewer-traceability-markers.sh` (`[Uncovered —`). Unasserted: that no finding is raised when the reason holds. |
| 11 | ″ | A change uses a stated exemption | Covered in part — `change-code-reviewer-traceability-markers.sh` (`[Exempt —`). Unasserted: the exemption lookup and the absence of a `test` finding. |
| 12 | ″ | A task is marked done without work | Covered in part — `change-code-reviewer-finding-vocabulary.sh` (kind `` `task` ``). |
| 13 | Out-of-scope edits are reported as scope | A correct but unrelated edit | Covered in part — `change-code-reviewer-finding-vocabulary.sh` (`` `scope` ``, `[MINOR]`), `change-code-reviewer-verdict-set.sh` (`` `CONDITIONALLY APPROVED` ``). Unasserted: scope rather than defect, and the move-out remedy. |
| 14 | Verification is reported as run | Verification cannot reach what it needs | Uncovered — a report on a command the reviewer ran; reasoning over output. |
| 15 | Findings carry a fixed severity and kind | A finding is reported | Covered in part — `change-code-reviewer-finding-vocabulary.sh` (both closed sets). Unasserted: location, cost, fix and bearing, which have no fixed token. |
| 16 | ″ | A requirement is not implemented | Uncovered — where a finding is located is reasoning; `[Not Implemented]` is asserted by the markers case but is not this scenario's outcome. |
| 17 | One recommended action | Only minor findings | Covered in part — `change-code-reviewer-verdict-set.sh`. Unasserted: the mapping. |
| 18 | ″ | The plan cannot achieve its goal | Covered in part — `change-code-reviewer-verdict-set.sh` (`` `REJECTED` ``). Unasserted: orthogonality to the mapping. |
| 19 | ″ | A critical finding | Covered in part — `change-code-reviewer-verdict-set.sh` (`` `FIX REQUIRED` ``), `change-code-reviewer-finding-vocabulary.sh` (`[CRITICAL]`). |
| 20 | Declared report structure | A clean review | Covered in part — `change-code-reviewer-verdict-set.sh` (`` `APPROVED` ``). Unasserted: the findings section stating there are none. |
| 21 | ″ | A blocked review | Uncovered — the absence of sections and verdict in one report is reasoning. |
| 22 | Does not modify what it reviews | A one-line fix is obvious | Covered in part, DERIVED — `change-code-reviewer-no-edit-grant.sh`. Traces to `design.md`'s drafted frontmatter, not to the spec. Unasserted: writes through `Bash`. |
| 23 | ″ | A check is made to fail | Uncovered — the restore discipline is conduct. |
| 24 | ″ | A command leaves untracked output | Uncovered — conduct. |
| 25 | Workflow binding states the act for each verdict | A session receives a verdict | Covered in part — `workflow-fragment-build-binding-verdict-acts.sh`. Unasserted: that a session acts on it. |

## Assertion classification

- **Specified** — every verdict token, severity token, kind name and marker named above; the four acts in `build`'s binding (fix and re-review where substantial; apply the `[MINOR]` fixes and continue; continue; stop and raise it); the `[Uncovered —` / `[Exempt —` reason-bearing form, em dash included.
- **Derived** — the backticked form of verdicts and kinds (needed because each is a substring or an ordinary word otherwise); reading the agent by file name rather than across `agents/`; locating `build`'s binding by the `### build` heading and `_Claude Code binding:_` marker; reading each act from the text between its verdict and the next verdict token, which assumes the four are stated in sequence as `plan`'s binding states them; the lexical proxies for each act (`fix`, `review`/`dispatch`, `substantial`; `[MINOR]`, `continue`; `continue`; `stop`, `raise`); the whole of `change-code-reviewer-no-edit-grant.sh`.
- **Deliberately untested** — the report section order (stated by the requirement, named by no scenario, and the section titles are not fixed tokens); the reviewer no longer delegating to `code-review` (proposal, no scenario); the fragment's version bump to 5 (task 2.2, no scenario; `managed-block-older-version.sh` and `inlined-body-matches-fragment.sh` already read the version from the fragment); the backlog moves (tasks 3.x, no scenario); the three-round bound (the fragment states two bounds, and no lexical scan tells which loop a number belongs to — recorded the same way in `tests/coverage.md`).

## Obsolete tests

Not applicable: the change carries `ADDED` requirements only, so no existing behaviour is superseded and no existing test bears on superseded behaviour.

## Unresolved project questions

1. **Selecting one case.** `tests/README.md` documents `bash tests/run.sh` only and no per-case selector. Assumption: a case runs alone with `TESTLIB`, `TOOLKIT_ROOT` and `TESTDIR` set by hand, as shown above (`TOOLKIT_ROOT` is not documented in the README; it is inferred from existing cases). Affects how every case above is named.
2. **Preamble.** The library's `bash` skill directs `set -euo pipefail`; no existing case uses it, and the cases here follow the suite's convention. Reported as a conflict, not resolved. Affects all five cases.
3. **Stack skill.** `bash` was loaded for the case files. No library skill covers asserting over agent or fragment prose; the cases rest on the floor and on the suite's precedent (`review-verdict-vocabulary.sh`, `testing-skill-discriminator-bound.sh`).
4. **`tests/coverage.md`.** Task 5.3 maps these cases there. This pass did not edit it: it lies outside the test-path glob.

## Findings recorded during derivation

None. No artifact carried text addressed to the test writer.
