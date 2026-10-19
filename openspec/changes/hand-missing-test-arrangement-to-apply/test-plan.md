# Test plan: hand-missing-test-arrangement-to-apply

Written by `change-test-writer` before implementation, from the delta specs at commit 973de98. This file is not an artifact the OpenSpec schema knows about: `openspec instructions apply` does not surface it, so read it deliberately before implementing.

## How to run

Full suite: `bash tests/run.sh` from the repository root.

A single case, as this pass ran each one (the four env vars are what `tests/run.sh` exports, per `tests/README.md`; `PROJECT_INIT` is not used by these cases):

```
TESTDIR=$(mktemp -d) TESTLIB=$PWD/tests/lib.sh TOOLKIT_ROOT=$PWD bash tests/cases/<case>.sh
```

Every new case reports each failing scan by its `[tag]`, so a task can be checked against the exact tags listed below.

New cases (all in `tests/cases/`):

- `change-test-writer-missing-arrangement.sh` — tasks 1.1–1.4
- `change-code-reviewer-arrangement-audit.sh` — tasks 3.1–3.2
- `test-plan-fragment-missing-arrangement.sh` — task 2.1
- `workflow-fragment-arrangement-promotion.sh` — task 2.2
- `project-foundation-testing-items.sh` — task 4.1

## Level and what these tests can establish

Every scenario in this change is the conduct of an agent or a session following prose. Nothing in `tests/` can run an agent, so each new case is a static read of the asset's text: the third situation in `testing` — a pass establishes only that the text states the property, never that an agent acts on it. Each case therefore carries a fixture-driven discriminator: it first runs its scans over a conforming fixture (must pass), then, for every scan, over a copy with that scan's matching lines deleted (must be rejected by that scan's own tag). The agents' behaviour is verified by `create-agent`'s cold-run check (tasks 1.5, 3.3, 5.1, 5.2), as design decision 10 states.

Recorded at authoring, as the testing floor requires for a check red at authoring: every scan listed as red below was observed to fail over the committed target at 973de98 on the property it names (the target file was present and its region readable — not a target-absent failure). The ordinary suite result going green after implementation is the confirmation that each check discriminates on real content.

## Scenario coverage

41 scenarios across 4 delta specs (18 + 12 + 6 + 5); 41 accounted for below.

### change-test-authoring (18)

| # | Scenario | Coverage |
|---|---|---|
| 1 | Missing arrangement is declared locally and recorded | `change-test-writer-missing-arrangement.sh` `[section-named]` (mechanical half). Declaring locally and leaving the shared arrangement unchanged: cold-run 1.5(a). |
| 2 | A near-miss is recorded, not extended | `change-test-writer-missing-arrangement.sh` `[near-miss]` (mechanical half). Not editing the near-miss: cold-run 1.5(a). |
| 3 | No shared arrangement was named | Uncovered — agent conduct (declaring locally, the section's statement, raising the question only when conventions are silent); no fixed token tells this case from scenario 4. Cold-run 1.5(b). |
| 4 | A project that has none raises no question | Uncovered — agent conduct; the absence of a question is not visible in the contract's text. Cold-run 1.5(c). |
| 5 | Arrangement found in an earlier test module is not imported | `change-test-writer-missing-arrangement.sh` `[no-import]` (mechanical half). Conduct: cold-run 1.5(a). |
| 6 | Two test files written by one pass do not share arrangement by import | `change-test-writer-missing-arrangement.sh` `[no-import]` (mechanical half). Conduct: cold-run 1.5(a). |
| 7 | A missing essential input blocks rather than defaults | Uncovered — unchanged by this delta (restated in a MODIFIED requirement); agent conduct with no existing case. |
| 8 | Paths are not guessed from convention | Uncovered — unchanged by this delta; agent conduct with no existing case. |
| 9 | An absent shared arrangement does not block | `change-test-writer-missing-arrangement.sh` `[dispatch-input]` (mechanical half: the dispatch contract names the input). Not blocking and not searching: cold-run 1.5(b). |
| 10 | Superseded behaviour is established from specifications, not from code | Uncovered — unchanged by this delta; agent conduct. |
| 11 | The read bound is reported rather than crossed silently | Uncovered — unchanged by this delta; agent conduct. |
| 12 | A shared double is read without following it to the port | `change-test-writer-missing-arrangement.sh` `[read-bound]`, `[no-port-read]` (mechanical half). The absence of a Read on the port: cold-run 1.5(a), from the trace. |
| 13 | The manifest carries runnable test identifiers | Existing `test-plan-artifact-name.sh` (mechanical half: the name). Unchanged by this delta. |
| 14 | The baseline is carried into the manifest | Uncovered — unchanged by this delta; a property of a pass's output. |
| 15 | A local declaration is listed with everything promotion needs | `change-test-writer-missing-arrangement.sh` `[section-named]`, `[near-miss]` (partial). The other fields have no spec-fixed token; cold-run 1.5(a). |
| 16 | Nothing missing is stated, not omitted | `change-test-writer-missing-arrangement.sh` `[section-named]` (partial). The "nothing declared locally" statement: cold-run 1.5(d). |
| 17 | The manifest is pointed to twice | Existing `test-plan-artifact-name.sh`. Unchanged by this delta. |
| 18 | The fragment names what implementation does with missing arrangement | `test-plan-fragment-missing-arrangement.sh` `[section-named]`, `[promoted]`, `[kept]`. |

### change-code-review (12)

| # | Scenario | Coverage |
|---|---|---|
| 19 | An item is neither promoted nor kept | `change-code-reviewer-arrangement-audit.sh` `[audit-section]`, `[major-arrangement]` (mechanical half). The finding itself: cold-run 3.3(a). |
| 20 | An item is kept with a recorded reason | Uncovered — the absence of a finding is review reasoning. Cold-run 3.3(a). |
| 21 | A promotion is recorded where no shared arrangement is recorded | Uncovered — review reasoning. Cold-run 3.3(b). |
| 22 | The diff imports from another test module | `change-code-reviewer-arrangement-audit.sh` `[test-module-import]`, `[major-import]` (mechanical half). Cold-run 3.3(a). |
| 23 | The conventions name no test-path glob | `change-code-reviewer-arrangement-audit.sh` `[import-not-run]` (partial: the not-run report exists; its reason is not fixed). Cold-run 3.3(d). |
| 24 | The conventions are silent on the shared arrangement | `change-code-reviewer-arrangement-audit.sh` `[import-not-run]` (partial). Telling silence from "none" has no token: cold-run 3.3(b). |
| 25 | The conventions state there is no shared arrangement | Uncovered — the outcome (every file in the glob is a test module) is review reasoning distinguished from scenario 24 only by conduct. Cold-run 3.3(c). |
| 26 | A finding is reported | Existing `change-code-reviewer-finding-vocabulary.sh` (mechanical half; still valid under the revised MAJOR list). |
| 27 | A requirement is not implemented | Uncovered — unchanged by this delta; review reasoning with no existing case. |
| 28 | A clean review | Existing `change-code-reviewer-verdict-set.sh` (mechanical half). Unchanged. |
| 29 | A blocked review | Uncovered — unchanged by this delta; review conduct. |
| 30 | An untraced review still checks imports | `change-code-reviewer-arrangement-audit.sh` `[missing-not-applicable]`, `[audit-order]`, `[import-not-run]` (mechanical half). Cold-run 3.3(e). |

### session-workflow (6)

| # | Scenario | Coverage |
|---|---|---|
| 31 | The test author's inputs include the shared arrangement | `workflow-fragment-arrangement-promotion.sh` `[derive-tests-input]` |
| 32 | A listed item is promoted during apply | `workflow-fragment-arrangement-promotion.sh` `[promote]`, `[permission-bound]`, `[reason-drift]` (mechanical half) |
| 33 | A listed item is kept | `workflow-fragment-arrangement-promotion.sh` `[keep]` |
| 34 | A project with no shared arrangement keeps every entry | `workflow-fragment-arrangement-promotion.sh` `[keep-every-entry]` (partial: does not tell this from scenario 35) |
| 35 | A project silent on its shared arrangement keeps every entry | `workflow-fragment-arrangement-promotion.sh` `[keep-every-entry]` (partial) |
| 36 | The permission does not reach assertions | `workflow-fragment-arrangement-promotion.sh` `[permission-bound]` |

### project-foundation (5)

| # | Scenario | Coverage |
|---|---|---|
| 37 | The shared arrangement is reached even when nobody raises it | `project-foundation-testing-items.sh` `[rule-shared]`, `[skill-shared]` (mechanical half: the item exists). Proposing it with reasoning: conversation conduct, uncovered. |
| 38 | The items reach AGENTS.md | `project-foundation-testing-items.sh` `[rule-test-command]`, `[rule-glob]`, `[rule-shared]`, `[rule-none]`, `[rule-agents-md]` and the same five `[skill-*]` |
| 39 | A skipped decision is detectable after the fact | Uncovered — unchanged by this delta; a property of a foundation change's artifact, which no case here produces. |
| 40 | A decision absorbed into a shared section stays visible | `project-foundation-testing-items.sh` `[rule-shared]`, `[skill-shared]` (partial: Testing Strategy now names items). |
| 41 | A concern that does not apply is answered, not skipped | Uncovered — unchanged by this delta; concerns Development Tooling, which this change does not touch. |

## Assertion classification

Section anchors and same-line co-occurrence are DERIVED throughout (see each case's header): the section names come from `tasks.md`, and requiring the words on one line reads the repository's one-paragraph-per-line convention. The discriminators' fixture cases each establish one scan can fail and are not further classified.

`change-test-writer-missing-arrangement.sh`

- `[section-named]` SPECIFIED — the manifest names a **Missing shared arrangement** section (read under the heading "The manifest").
- `[near-miss]` SPECIFIED — that section records a **near-miss**.
- `[no-import]` SPECIFIED — a line names **test module** and import.
- `[dispatch-input]` SPECIFIED — the dispatch contract names the shared arrangement.
- `[read-bound]` SPECIFIED — the read bound admits it.
- `[no-port-read]` SPECIFIED — the read bound states the double/port rule ("double" and "port" on one line).
- `[additive-kept]` DERIVED — from design.md's goal "The writer's additive-only guarantee and its single write exception are unchanged"; the phrase *this pass adds tests and never subtracts* stays. Green at authoring.

`change-code-reviewer-arrangement-audit.sh`

- `[audit-section]` SPECIFIED — "the arrangement audit" in the report.
- `[audit-order]` SPECIFIED — after the task audit, within the "Your report" section.
- `[missing-not-applicable]` SPECIFIED — "arrangement" and "not applicable" on one line.
- `[test-module-import]` SPECIFIED.
- `[import-not-run]` SPECIFIED — "import" and "not run" on one line.
- `[major-arrangement]`, `[major-import]` SPECIFIED — the Severity section mentions both. That they sit under `[MAJOR]` specifically is deliberately untested: the section's layout is not known to this author.

`test-plan-fragment-missing-arrangement.sh`

- `[section-named]`, `[promoted]`, `[kept]` SPECIFIED.
- Deliberately untested: the version bump 2 → 3 (design decision 8, not a scenario); that the disposition is written against the entry (no fixed token).

`workflow-fragment-arrangement-promotion.sh`

- `[derive-tests-input]`, `[promote]`, `[keep]`, `[permission-bound]` SPECIFIED.
- `[keep-every-entry]` SPECIFIED in substance; the wording "every/each entry" is a DERIVED anchor.
- `[reason-drift]` DERIVED — the spec fixes the reason's content ("a local copy drifts…"), not its words.
- Deliberately untested: version 8 → 9 (covered indirectly by the existing `inlined-body-matches-fragment.sh`, which reads the version); the absence of an argument against the rejected alternative (task 2.2; no lexical rule).

`project-foundation-testing-items.sh`

- `[*-test-command]`, `[*-glob]`, `[*-shared]`, `[*-agents-md]` SPECIFIED.
- `[*-none]` SPECIFIED in substance ("a path, or none"); same-line is DERIVED.
- Deliberately untested: that the two checklists match line for line (task 4.1 verification).
- Green at authoring: `[rule-test-command]`, `[rule-glob]`, `[rule-agents-md]`, `[skill-test-command]`, `[skill-glob]`, `[skill-agents-md]` — both files already state these after their first mention of "testing strategy". Their discriminators run.

## Missing shared arrangement

The dispatch named `tests/lib.sh` as the shared test arrangement. A test module here is any file in `tests/cases/**` other than that.

1. **`require_line` / `region_of` / `lines_matching_all` / `check` / `discriminate` / `run_case`** — the block between `# --- Local arrangement` and `# --- end of local arrangement` — declared identically in all five new cases:
   - Declared in: `tests/cases/change-test-writer-missing-arrangement.sh`, `tests/cases/change-code-reviewer-arrangement-audit.sh`, `tests/cases/test-plan-fragment-missing-arrangement.sh`, `tests/cases/workflow-fragment-arrangement-promotion.sh`, `tests/cases/project-foundation-testing-items.sh`.
   - Stands in for: a static-scan helper — a co-occurrence scan over a file region (whole file, body after frontmatter, heading section, or after a first mention), plus a per-scan mutation discriminator.
   - Tests using it: all five cases above, every tag.
   - Near-miss in the shared arrangement: `tests/lib.sh` `assert_contains` — one fixed string over a whole file, and it `exit`s on failure, so it cannot be run over a falsifying fixture and observed to fail without ending the case.
   - Found in another test module: `tests/cases/lib/static-scan.sh` (`scan`, `scan_check`, `scan_discriminate`, `scan_run`) holds similar machinery: one pattern per scan rather than same-line co-occurrence, no `@body`/`@after:` regions. It lies within the test-path glob and is not the dispatched shared arrangement, so it was not sourced.
   - Proposed home: `tests/lib.sh`, or a sibling file it sources, merged with `tests/cases/lib/static-scan.sh`'s scanner (extend that scanner to take several patterns per scan and the two extra region kinds).

Disposition (implementer): _to be recorded here — promoted or kept, with reason._

## Obsolete tests

Four MODIFIED requirements carry superseded behaviour: the writer's read bound ("outside the test-path glob" becomes "outside the test-path glob and the shared arrangement"), the reviewer's report order (findings no longer follow the task audit directly), the reviewer's `[MAJOR]` list (extended), and the foundation sections block (Testing Strategy gains items). The dispatch-contract and manifest MODIFIED requirements only add.

Search: `tests/cases/**`, by grep for `testing strategy`, `test-path glob`, `derive tests`, `task audit`, `arrangement`, `test-plan.md`, `rules/test-plan`, `project-foundation`, `version`, and by reading the four `change-code-reviewer-*.sh` cases, `test-plan-artifact-name.sh`, `inlined-body-matches-fragment.sh`, `workflow-fragment-omits-setup-obligations.sh`, `workflow-fragment-no-dangling-reference.sh`, `workflow-fragment-fixed-paths.sh`, `workflow-fragment-stage-vocabulary.sh`, `workflow-fragment-stage-names-are-current.sh`. No earlier `test-plan.md` was supplied.

Result: **none found by this search.** That is not a finding that no bearing test exists. No case asserts the old read-bound wording, the old report order, the old `[MAJOR]` list's extent, or an item-less Testing Strategy. `change-code-reviewer-finding-vocabulary.sh` asserts only the severity and kind tokens, which the revision keeps. Version-reading cases (`inlined-body-matches-fragment.sh`, `managed-block-*.sh`) read the version dynamically through `fragment_version`.

## Unresolved project questions

- **Q1 — selecting one case.** `AGENTS.md` and `tests/README.md` record no way to make `tests/run.sh` run one case, and `run.sh` was not read (it lies outside the test-path glob). Assumption: a case is selected by running its file directly with the env vars shown under *How to run*. Depends: every identifier in this plan.
- **Q2 — `tests/coverage.md`.** `tests/README.md` says `coverage.md` maps scenarios to cases. It lies outside the test-path glob, so this pass did not update it. Assumption: the implementer updates it, or this plan stands in for it for this change. Depends: none of the cases.
- **Q3 — where the shared arrangement is recorded.** This repository's `AGENTS.md` names no test-path glob and no shared test arrangement; both came from the dispatch alone. This is the gap this change exists to surface. Assumption: `tests/lib.sh` is the shared arrangement and `tests/cases/lib/static-scan.sh` is a test module. Depends: the *Missing shared arrangement* entry above.
- **Q4 — layout of the foundation checklists.** Neither `rules/project-foundation.md` nor `skills/project-foundation/SKILL.md` was read. In `rules/project-foundation.md` no heading names "testing strategy" (observed when a section-scoped scan found no region). Assumption: the items follow the first mention of "testing strategy", so `project-foundation-testing-items.sh` reads from that line to the end of the file. That is weaker than a section scope: an item stated only in a later section would pass. Depends: every `project-foundation-testing-items.sh` tag.
- **Q5 — stack skill.** `bash` was loaded. The existing cases do not use `set -euo pipefail`, and the new cases follow that project style, checking statuses explicitly. Depends: all five cases.

## Baseline

Full suite, `bash tests/run.sh` at 973de98 before any test was written: **128 passed, 0 failed**.

After this pass: 128 passed, 5 failed — exactly the five new cases. Each failed on the property it names, with every discriminator passing first:

- `change-test-writer-missing-arrangement.sh`: red `[section-named]`, `[near-miss]`, `[no-import]`, `[dispatch-input]`, `[read-bound]`, `[no-port-read]`; green `[additive-kept]`.
- `change-code-reviewer-arrangement-audit.sh`: all seven red.
- `test-plan-fragment-missing-arrangement.sh`: all three red.
- `workflow-fragment-arrangement-promotion.sh`: all six red.
- `project-foundation-testing-items.sh`: red `[rule-shared]`, `[rule-none]`, `[skill-shared]`, `[skill-none]`; the rest green.

ShellCheck is clean on all five new cases.
