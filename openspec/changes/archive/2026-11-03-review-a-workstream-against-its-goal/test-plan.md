# Test plan: review-a-workstream-against-its-goal

Run a case with `bash tests/run.sh <case>` from the working tree root. Every name below is such a case, without its `.sh`. This file is not an artifact the OpenSpec schema knows about, so `openspec instructions apply` does not list it: read it on purpose before implementing.

## Baseline

Full, taken before any test was written, at `0b6ec06`: `bash tests/run.sh` gave 659 passed, 0 failed, in 5m06s. All 17 cases below are new, so any other failure after implementation comes from the change or from a test the obsolete search missed.

`shellcheck -x` is clean on all 17 new cases.

## New cases and what each must see

All 17 fail today. For each, the fixture-driven discriminators ran and passed (every scan's mutant was rejected by that scan's own tag, and every order or placement check rejected its falsifying fixture), so each run reached the real target and failed there. The red runs are the record that each check discriminates on real content; the fixtures stay in the suite as the lasting discriminators. The state-2 cases have exercised their scans only on fixtures so far.

| Case | Task | Red at authoring | Target |
|---|---|---|---|
| `workstream-reviewer-description-names-inputs` | 1.2 | state 2, agent absent | `agents/workstream-reviewer.md` `description` |
| `workstream-reviewer-no-write-grant` | 1.2 | state 2, agent absent | its `tools` |
| `workstream-reviewer-verdict-and-severity` | 1.2 | state 2, agent absent | whole file |
| `workstream-reviewer-dispatch-contract` | 1.2 | state 2, agent absent | section under a heading naming `dispatch`, and whole file |
| `workstream-reviewer-five-questions` | 1.2 | state 2, agent absent | section under a heading naming `questions` |
| `workstream-reviewer-stays-inside-the-plan` | 1.2 | state 2, agent absent | section under a heading naming `inside` |
| `workstream-reviewer-data-stance` | 1.2 | state 2, agent absent | section under a heading naming `data` |
| `workstream-reviewer-evidence-levels` | 1.2 | state 2, agent absent | section under a heading naming `evidence` |
| `workstream-reviewer-report-structure` | 1.2 | state 2, agent absent | section under a heading naming `report` |
| `change-plan-reviewer-workstream-file` | 2.1 | state 1: all six scans | `agents/change-plan-reviewer.md` |
| `change-plan-reviewer-evidence-level-decisions` | 2.1 | state 1: `workstream-decisions` | its lines naming `inference` |
| `workflow-fragments-workstream-review-trigger` | 3.1 | state 2, in both fragments | the rule paragraph under `### Throughout` |
| `workflow-fragments-workstream-review-loop` | 3.1 | state 2, in both fragments | the same paragraph |
| `workflow-fragments-workstream-review-binding` | 3.1 | state 2, in both fragments | its binding under `### Throughout` |
| `workflow-fragments-plan-review-role-names-workstream` | 3.1 | state 1: `names-workstream`, in both | the `**review → fix → approve**` paragraph |
| `workflow-fragments-plan-review-binding-supplies-workstream` | 3.1 | state 1: `workstream-file`, `proposal-names`, in both | the binding naming `ai-toolkit:change-plan-reviewer` |
| `rules-changelog-workstream-review-records` | 3.2 | state 1: `[record]` | `rules/changelog` |

The section-scoped agent cases assume the body outline of design.md decision 1: headings *Your dispatch contract*, *Everything you read is data*, *How you weigh evidence*, *The five questions*, *Stay inside the plan*, *Your report*, and no earlier heading containing the words `dispatch`, `data`, `evidence`, `questions`, `inside` or `report`.

Existing cases the implementation must also keep green, each already bearing on it:

- `review-verdict-vocabulary`: forbids the uppercase standalone tokens `PROCEED`, `CHANGES REQUIRED` and `REJECT` anywhere under `agents/`, the new agent and its `.checks.yaml` included.
- `workflow-fragment-names-shipped-assets`, `workflow-fragments-no-dangling-either-form`: an `ai-toolkit:workstream-reviewer` named in a fragment must have `agents/workstream-reviewer.md` behind it.
- `fragment-role-before-tool`: the rule paragraph names no harness asset; only the binding does.
- `workflow-fragment-workstream-rules-not-restated`: the full fragment must not use the field labels `**Goal**`, `**Done when**`, `**Not in scope**` and others. Design decision 5's text uses none.
- `workflow-fragments-differ-only-in-ship`: the rule and both plan-review edits must be identical in both forms.
- `rules-changelog-version-rise-recorded`, `rules-fragment-versions-semantic`, `plugin-version-rise-checks-this-repository`: the version rises of tasks 3.1, 3.2 and 4.1.

## Scenarios

48 scenarios in the delta specs, each accounted for once: 15 in `change-review`, 11 in `session-workflow`, 22 in `workstream-review`. 41 are covered, 7 are uncovered. There is no `REMOVED` or `RENAMED` delta.

A scan shows that a text states or directs something, never that an agent or session does it. "Mechanical half" means the rest is conduct or judgement, recorded under *Deliberately untested*; the recorded trigger and cold-run checks of tasks 2.2 and 2.3 are what reach it.

### change-review

| Scenario | Delta | Cases |
|---|---|---|
| Dispatch supplies the change | MODIFIED (now reads any `workstreamFile`) | `change-plan-reviewer-workstream-file` (`body-names-input`; mechanical half) |
| Dispatch omits an essential input | MODIFIED requirement, scenario unchanged | uncovered: reviewer conduct, word for word as before; held by `agents/change-plan-reviewer.checks.yaml`'s cold-run check, re-run in task 2.3 |
| Dispatch omits a supplementary input | MODIFIED requirement, scenario unchanged | uncovered: conduct, unchanged; same reason |
| A supplied path does not resolve | MODIFIED requirement, scenario unchanged | uncovered: conduct, unchanged; same reason |
| The description carries the contract | MODIFIED requirement, scenario unchanged, input set widened | `change-plan-reviewer-workstream-file` (`description-names-input`) |
| Working directory is not inherited | MODIFIED requirement, scenario unchanged | uncovered: conduct, unchanged; same reason |
| A conclusion rests on inference | MODIFIED requirement (level 2 gains a workstream's Decisions) | `change-plan-reviewer-evidence-level-decisions` (mechanical half) |
| A conclusion rests on recorded rationale | MODIFIED requirement, scenario unchanged | uncovered: conduct; the revision does not touch the first level |
| Proposal and design disagree | MODIFIED requirement, scenario unchanged | uncovered: conduct; the revision does not touch it |
| Absent documentation is not a design flaw | MODIFIED requirement, scenario unchanged | uncovered: conduct; the revision does not touch it |
| A change contradicts a workstream Decision | ADDED | `change-plan-reviewer-workstream-file` (`body-names-input`, `overturned-decision`; mechanical half) |
| A change overturns a Decision openly | ADDED | `change-plan-reviewer-workstream-file` (`overturned-decision`; mechanical half) |
| A workstream's own defect is not this review's | ADDED | `change-plan-reviewer-workstream-file` (`quality-elsewhere`; mechanical half) |
| The proposal names a workstream that was not supplied | ADDED | `change-plan-reviewer-workstream-file` (`not-supplied-unverified`; mechanical half) |
| The change advances no workstream | ADDED | `change-plan-reviewer-workstream-file` (`advances-none`; mechanical half) |

### session-workflow

| Scenario | Cases |
|---|---|
| Opening a workstream | `workflow-fragments-workstream-review-trigger` (`opening`) |
| A step is added | `workflow-fragments-workstream-review-trigger` (`step-added`) |
| A burst of placements | `workflow-fragments-workstream-review-trigger` (`burst-one-review`) |
| What a step does changes | `workflow-fragments-workstream-review-trigger` (`step-does`) |
| A Decision or Not in scope is revised | `workflow-fragments-workstream-review-trigger` (`decision-revised`, `not-in-scope-revised`) |
| The operator leaves a defect | `workflow-fragments-workstream-review-loop` (`substance-operator`, `commit-on-word`, `say-so`) |
| An edit that leaves the plan alone | `workflow-fragments-workstream-review-trigger` (`rename-none`, `reorder-none`, `knows-none`, `takes-none`) |
| A workstream is archived | `workflow-fragments-workstream-review-trigger` (`archive-none`, `takes-none`) |
| The loop is bounded | `workflow-fragments-workstream-review-loop` |
| The plan review is given the workstream | `workflow-fragments-plan-review-role-names-workstream`, `workflow-fragments-plan-review-binding-supplies-workstream` |
| The rule holds in both forms | `workflow-fragments-workstream-review-trigger`, `-loop`, `-binding` (each holds both forms to the same scans); the existing `workflow-fragments-differ-only-in-ship` |

All ADDED. The requirement's binding sentence and its placement under **Throughout** are held by `workflow-fragments-workstream-review-binding` and by the Throughout extraction in all three cases. "States no workstream field" is held, for the full fragment, by the existing `workflow-fragment-workstream-rules-not-restated`.

### workstream-review

| Scenario | Cases |
|---|---|
| Dispatch supplies the workstream | `workstream-reviewer-description-names-inputs` (mechanical half) |
| Dispatch omits an essential input | `workstream-reviewer-dispatch-contract` (`essential`, `blocked`; mechanical half) |
| Dispatch omits a step's artifacts | `workstream-reviewer-dispatch-contract` (`supplementary`, `unverified`, `not-not-applicable`; mechanical half) |
| A step has no artifact yet | `workstream-reviewer-dispatch-contract` (`step-from-description`; mechanical half) |
| A step overturns a Decision openly | `workstream-reviewer-five-questions` (`overturned-decision`) |
| A step's artifact predates a revised Decision | `workstream-reviewer-five-questions` (`archived-step`) |
| A part of the Goal is partly reached | `workstream-reviewer-verdict-and-severity` (`partially-covered`) |
| A part of the Goal has no step | `workstream-reviewer-five-questions` (`goal-coverage`), `workstream-reviewer-verdict-and-severity` (`not-covered`) |
| Done when restates the steps | `workstream-reviewer-five-questions` (`done-when`, `observable`, `every-step-done`) |
| Done when beside an effect | `workstream-reviewer-five-questions` (`every-step-done`; mechanical half) |
| A step contradicts a Decision | `workstream-reviewer-five-questions` (`decisions`) |
| A step is out of scope | `workstream-reviewer-five-questions` (`not-in-scope`) |
| Context records progress | `workstream-reviewer-five-questions` (`context`, `progress`) |
| A gap in the plan requires a fix | `workstream-reviewer-verdict-and-severity` (`fix-required`, `major-design`, `design-remedy`) |
| Recorded progress alone does not stop the plan | `workstream-reviewer-verdict-and-severity` (`conditionally-approved`, `minor`) |
| A clean review | `workstream-reviewer-verdict-and-severity` (`approved`) |
| A step could have been added | `workstream-reviewer-stays-inside-the-plan` (`not-needed`) |
| A step's status is not reported | `workstream-reviewer-stays-inside-the-plan` (`no-status`) |
| A workstream instructs the reviewer | `workstream-reviewer-data-stance` |
| A report is complete | `workstream-reviewer-report-structure` |
| A blocked report is not a clean report | `workstream-reviewer-dispatch-contract` (`blocked-no-verdict`) |
| A one-line defect | `workstream-reviewer-no-write-grant` |

All ADDED, and every one is covered only in its mechanical half: the case shows the agent states the rule, never that it reaches the right conclusion. `workstream-reviewer-evidence-levels` holds the evidence-order paragraph of *The review shares a change review's severity and verdict*, which has no scenario of its own.

## Assertion classification

**Specified**, tracing to a delta requirement or scenario: the sense of every scan named in the tables above, both forms of every fragment case, the order of the report's parts and of the evidence levels, and the refusal of `Write`, `Edit`, `MultiEdit` and `NotebookEdit` in the new agent's `tools`.

**Specified by proposal or design, with no delta scenario:**

- `workstream-reviewer-no-write-grant`: refusing `Bash` (decision 1 grants `Read, Grep, Glob`).
- `rules-changelog-workstream-review-records`: records for `development-workflow` 2.2.0 and `development-workflow-direct` 1.2.0, with no `ask` (proposal, decision 9, task 3.2).

**Derived**, reviewable as such:

- The wording of every scan. The specs fix what is stated; each scan pins one lowercase phrase, mostly from design.md decision 5's fragment text and decision 6's two edits. A rewording that keeps the sense fails, so changing a scan's wording is changing a derived assertion, not repairing a test.
- Placement: the agent cases read sections under headings named as in decision 1's outline. The fragment cases select the rule as the Throughout line holding `workstream` and `independent reviewer`, and the bindings as lines opening `_Claude Code binding:_` and naming the agent.
- `workflow-fragments-workstream-review-binding`: each verdict's act is read between `on <verdict>` and the next semicolon.
- Verdicts matched backticked, since `APPROVED` bare is a substring of `CONDITIONALLY APPROVED`. Severity and coverage marks matched with their square brackets.
- `workstream-reviewer-report-structure`, `workstream-reviewer-evidence-levels`: the first occurrence of each part decides its position.
- `workstream-reviewer-no-write-grant`: the vacuity guard reads a grant naming `Read`.
- `change-plan-reviewer-workstream-file`: `not-supplied-unverified` reads `workstream` and `unverified` in one sentence. `[MAJOR — coherence]` is left unscanned because the agent already carries it.
- `change-plan-reviewer-evidence-level-decisions`: a line naming `inference` names a workstream's decisions in one sentence.

**Deliberately untested:**

- How either reviewer reasons: which severity a given defect takes, which verdict a set of findings yields, whether a gap is found, how a Goal is split into parts, whether an instruction is ignored, whether a blocked review really withholds its verdict, whether only supplied paths are read. This is model behaviour with no program to run. Tasks 2.2 and 2.3's trigger and cold-run checks are the test of it. Decision 10's fixture must return `FIX REQUIRED` naming both gaps, which is the change's Done when.
- The spec's severity mapping as prose (`[Partially Covered]`, `[Not Covered]` and an unobservable Done when as `[MAJOR — design]`; Decision or Not in scope as `[MAJOR — coherence]`; progress as `[MINOR]`). A scan would have to guess how the mapping is worded. The tokens are held; the pairing is verified by reading and by the cold run.
- In `change-plan-reviewer`: that the workstream file is not counted in the artifact set, and that its Goal does not widen what the change is assessed against. Their wording is open, and a scan cannot tell a statement from its negation. Conduct, reached by task 2.3's cold run with a `workstreamFile`.
- The seven uncovered `change-review` scenarios: the MODIFIED delta keeps each one word for word, they are conduct, and no existing case covers them.
- That a session dispatches the review at the right commits and acts on the verdict. Conduct.
- The trigger behaviour of the new description against `change-plan-reviewer` and the `backlog` skill. That is task 2.2 and 2.3's trigger checks.
- The plugin rise to `2.2.0` (task 4.1). `plugin-version-rise-checks-this-repository` holds it.

## Obsolete tests

**None was found by this search.** That does not establish that none exists. The search covered `tests/cases/*.sh` only. It looked for the phrases the `change-review` MODIFIED deltas supersede ("neither is required", the second level reachable "only where `specsRoot` was supplied", the dispatch reading "the supplied artifact paths and `specsRoot`") and for the plan-review role text decision 6 rewrites ("complete artifact set", "still being written"). It also looked for any case naming `change-plan-reviewer`, `specsRoot` or evidence levels. Only `change-code-reviewer-verdict-set` and `change-code-reviewer-finding-vocabulary` name `change-plan-reviewer`, both as a fixture file in their own temporary tree. Neither reads the shipped plan reviewer. `workflow-fragment-build-binding-verdict-acts` reads only `### build`. None asserts the superseded behaviour.

`manifest-alternative-and-versions` no longer pins fragment versions; `match-backlog-entries-to-a-workstream` retired those pins. `rules-changelog-placement-records` asserts records for 2.1.0 and 1.1.0, which stay in `rules/changelog`. Neither is affected.

The search was made without reading the implementation. A test failing after implementation should be read against this paragraph first. No earlier `test-plan.md` was dispatched, so none was used as a mapping.

## Unresolved project questions

1. **The stack skill.** `testing` and `bash` both loaded, so no stack skill was missing. `bash` asks for `set -euo pipefail`, but no case in this suite sets it, since each relies on `tests/lib.sh`'s exiting assertions and explicit status checks. The new cases follow the suite. This is a conflict reported, not resolved. Depends on it: all 17 cases.
2. **How `change-plan-reviewer` writes its evidence hierarchy.** I did not read the agent. Assumption: some line naming `inference` names the levels, so after task 2.1 it names a workstream's decisions in one sentence. If the hierarchy is a list with `inference` on its own line, the case fails on wording, and its selector is a derived assertion to reconsider. Depends on it: `change-plan-reviewer-evidence-level-decisions`.
3. **The new agent's headings.** Assumption: decision 1's outline, used verbatim as headings. Depends on it: the six section-scoped `workstream-reviewer-*` cases.
4. **One case per scenario, or several scenarios per case.** The suite does both. Assumption: scenarios sharing one passage share a case, and a scan's tag names the scenario half it holds. Depends on it: every multi-scenario case above.

The dispatch named the shared arrangement and the conventions record no further location, so no question is raised about where a shared arrangement lives.

## Missing shared arrangement

The dispatch named `tests/lib.sh` and `tests/cases/lib/line-scan.sh`, `static-scan.sh` and `plugin-version-rise.sh`. None was edited. `scan`, `scan_run`, `scan_text`, `scan_check`, `scan_discriminate`, `line_select`, `line_scan`, `line_check`, `line_discriminate` and `line_run` are used as shipped. Six local declarations:

### `tools_of`, `check`, `fixture_agent`, `expect_granted`

- **Declared in:** `workstream-reviewer-no-write-grant.sh`.
- **Stands in for:** reading an agent's frontmatter `tools` grant and refusing a writing tool.
- **Tests:** `workstream-reviewer-no-write-grant`.
- **Near-miss:** none in the shared arrangement. `static-scan.sh` reads `@description` but no other frontmatter key.
- **Found in test module:** `change-code-reviewer-no-edit-grant.sh` holds the same `tools_of`.
- **Proposed home:** `tests/cases/lib/static-scan.sh` for `tools_of`; the rest stay local.

### `in_order` (two variants)

- **Declared in:** `workstream-reviewer-evidence-levels.sh`, `workstream-reviewer-report-structure.sh`.
- **Stands in for:** checking that phrases first occur in a stated order within a section.
- **Tests:** those two cases.
- **Near-miss:** `static-scan.sh`'s scans test presence only. `scan_text` is reused for the extraction.
- **Found in test module:** no.
- **Proposed home:** `tests/cases/lib/static-scan.sh`, as one `scan_order REL WHERE PHRASE...`.

### `throughout_of`, `check_throughout_both_forms`

- **Declared in:** `workflow-fragments-workstream-review-trigger.sh`, `workflow-fragments-workstream-review-loop.sh`, `workflow-fragments-workstream-review-binding.sh`.
- **Stands in for:** holding line scans over the `### Throughout` section of both workflow fragments, with a fixture showing a paragraph elsewhere is not read.
- **Tests:** those three cases.
- **Near-miss:** `line_run` in `line-scan.sh`, which reads one whole file and exits.
- **Found in test module:** no. `split_ship` in `workflow-fragments-differ-only-in-ship.sh` extracts a section the same way.
- **Proposed home:** `tests/cases/lib/line-scan.sh`, as a `line_run` taking a section and several files.

### `check_both_forms`

- **Declared in:** `workflow-fragments-plan-review-role-names-workstream.sh`, `workflow-fragments-plan-review-binding-supplies-workstream.sh`.
- **Stands in for:** holding one set of line scans over both workflow fragments.
- **Tests:** those two cases.
- **Near-miss:** `line_run`, which reads one file.
- **Found in test module:** `workflow-fragments-binding-restates-no-rule.sh` and the other `match-backlog-entries-to-a-workstream` fragment cases, identical.
- **Proposed home:** `tests/cases/lib/line-scan.sh`.

### `changelog_records`, `check`, `record`, `expect`

- **Declared in:** `rules-changelog-workstream-review-records.sh`.
- **Stands in for:** reading `rules/changelog`'s records with each one's count of `ask` lines.
- **Tests:** `rules-changelog-workstream-review-records`.
- **Near-miss:** none in the shared arrangement.
- **Found in test module:** `rules-changelog-placement-records.sh`, identical apart from the pairs.
- **Proposed home:** `tests/lib.sh` for `changelog_records`; the rest stay local.

### Fixture agent and fragment files

- **Declared in:** each case, as a heredoc under `$TESTDIR`.
- **Stands in for:** the conforming text each discriminator mutates.
- **Tests:** all 17.
- **Near-miss:** none.
- **Found in test module:** no.
- **Proposed home:** none. Each fixture is specific to its scans.

## Disposition of the local declarations

All six entries above are **kept** local. The fixture files are kept for the reason their entry gives. The other five are kept for one reason: this repository's conventions record no location for a shared arrangement, and the backlog entry `record-this-repositorys-shared-test-arrangement` is where that decision belongs, not this change. `tools_of` and `changelog_records` now have copies in three test files each, which that entry should weigh.
