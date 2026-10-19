# test-plan: fold-small-work-in

Written by `change-test-writer` before implementation. This file is not an OpenSpec schema artifact: it does not appear among `openspec instructions apply`'s context files and must be read on purpose.

Run a single case from the repository root with the variables `tests/run.sh` exports:

```
TOOLKIT_ROOT="$PWD" TESTLIB="$PWD/tests/lib.sh" TESTDIR="$(mktemp -d)" bash tests/cases/<name>.sh
```

The full suite is `bash tests/run.sh`.

## Baseline

Full suite, before any test was written (2026-10-19, commit `fc24fc1`, clean tree): `bash tests/run.sh` — **128 passed, 0 failed**.

After this pass: 128 passed, 10 failed. The 10 failures are exactly the 10 new cases below; nothing that passed at baseline fails.

## What was written

Ten cases and one shared helper, all under `tests/cases/`:

- `tests/cases/lib/line-scan.sh` (helper, sourced, never run) — selects one paragraph (one line, per AGENTS.md) by selectors, runs require/forbid scans on it, and a discriminator that requires a conforming fixture to pass and one mutant per scan to be rejected by that scan's own tag. The paragraph-level sibling of `static-scan.sh`.
- `workflow-fragment-fold-in-conditions.sh`
- `workflow-fragment-fold-in-own-commit.sh`
- `workflow-fragment-fold-in-named-in-pr.sh`
- `workflow-fragment-second-change-excludes-folded.sh`
- `workflow-fragment-routing-recording-owed.sh`
- `workflow-fragment-apply-backlog-pickup.sh`
- `workflow-fragment-apply-pickup-names-no-field.sh`
- `change-code-reviewer-fold-in-exemption.sh`
- `change-code-reviewer-fold-in-reviewed.sh`
- `backlog-skill-record-fold-in.sh`

Every case is a static read (the third situation in `ai-toolkit:testing`): it never runs a session, a reviewer or the skill, so a pass reports that the text states the property, not that anything behaves so. Every case carries a fixture-driven discriminator: each check is run first over a conforming fixture (the text `design.md` decision 2 quotes, for the fragment cases) and over one mutant per scan, and must reject each mutant by that scan's own tag. All discriminators ran and passed at authoring.

## Red at authoring, and on which property

Recorded so the later green can be read against it. Scans not listed are green on the pre-change text and are established as able to fail only by their fixture.

| Case | Red on |
| --- | --- |
| `workflow-fragment-fold-in-conditions` | own-files, direct-tests, no-delta, no-decision, small, example-defect, example-test, example-docs, size. Green already: fold-in, rest-separate (the pre-change Scope paragraph already says "folded in" and "separate proposed change") |
| `workflow-fragment-fold-in-own-commit` | own-commit, message-says |
| `workflow-fragment-fold-in-named-in-pr` | name-it, pr-description |
| `workflow-fragment-second-change-excludes-folded` | scope-rule, not-folded, is-second-change |
| `workflow-fragment-routing-recording-owed` | owed, option. Green already: record-in-backlog, equals (forbid) |
| `workflow-fragment-apply-backlog-pickup` | target absent: no `**apply**` paragraph names `docs/backlog.md` |
| `workflow-fragment-apply-pickup-names-no-field` | target absent, as above |
| `change-code-reviewer-fold-in-exemption` | fold-defers-to-conventions, fold-not-scope, short-is-scope, no-rule-none, reads-commits. Green already: states-size, states-files (forbid) |
| `change-code-reviewer-fold-in-reviewed` | fold-reviewed, decision-visible, pr-not-finding |
| `backlog-skill-record-fold-in` | fold-test, from-workflow, no-entry, fold-test-first. Green already: states-size, states-files (forbid) |

Known weakness: `fold-in` in `workflow-fragment-fold-in-conditions` matches "folded in" whether the paragraph permits or forbids folding, so it does not discriminate on real content; the case's other scans carry the property.

## Scenario accounting

26 `#### Scenario:` blocks across the three delta specs; 26 accounted for below. "In part" means the case reaches the stated text, not the conduct.

### session-workflow — ADDED *Small adjacent work is folded into the change that found it* (4)

1. **A small defect in a file the change edits** — in part: `workflow-fragment-fold-in-conditions`, `workflow-fragment-fold-in-own-commit`; its "no backlog entry" half by `workflow-fragment-second-change-excludes-folded` (fragment) and `backlog-skill-record-fold-in` (skill).
2. **A defect in a file the change does not edit** — in part: `workflow-fragment-fold-in-conditions` (own-files, rest-separate).
3. **Small work that owes a delta** — in part: `workflow-fragment-fold-in-conditions` (no-delta, rest-separate).
4. **Folded-in work is named for the operator** — in part: `workflow-fragment-fold-in-named-in-pr`.

### session-workflow — ADDED *A change takes the backlog entries it can fold in* (3)

5. **An entry the change can fold in** — in part: `workflow-fragment-apply-backlog-pickup`. The deletion by the archive re-read is the existing `workflow-fragment-archive-backlog-reread` requirement.
6. **An entry outside the change's files** — in part: `workflow-fragment-apply-backlog-pickup` (selection by the fold-in conditions) with `workflow-fragment-fold-in-conditions` (own-files).
7. **Selection names no field** — `workflow-fragment-apply-pickup-names-no-field`; the existing `workflow-fragment-archive-reread-names-no-field` already forbids the capitalised field labels anywhere in the fragment.

### session-workflow — MODIFIED *A second change surfacing in a session is recorded in the backlog* (11)

8. **A blocking dependency survives the session ending** — uncovered: carried verbatim by the MODIFIED delta; session conduct no scan reaches. Accounting unchanged.
9. **An unrelated improvement is recorded rather than implemented** (revised) — in part: `workflow-fragment-second-change-excludes-folded` (the "scope rule does not fold it in" limit), `workflow-fragment-routing-recording-owed` (recording first, opening instead). "Not implemented in the session that found it" is conduct.
10. **A backlog entry is cited by name** — existing, unchanged: `workflow-fragment-backlog-no-entry-numbers`.
11. **The scope rule and the backlog are one obligation** (seam revised) — in part: `workflow-fragment-second-change-excludes-folded`. The reconciliation's prose has no fixed token.
12. **The backlog does not yet exist** — existing, unchanged: `workflow-fragment-backlog-not-created-by-fragment`.
13. **Entry rules are read from the backlog, not the fragment** — existing, unchanged: `workflow-fragment-backlog-rules-not-restated`, `workflow-fragment-backlog-no-entry-numbers`.
14. **An identified change is opened without a proposal** — existing, unchanged: `workflow-fragment-names-handoff`.
15. **A handoff is not left uncommitted on a branch the session leaves** — uncovered: carried verbatim; session conduct.
16. **An opened-and-left branch does not become the session's working branch** — existing, unchanged: `workflow-fragment-no-proposal-only-branch`.
17. **A deferral outlives the change that recorded it** — uncovered: carried verbatim; its reason clause is prose with no fixed token.
18. **Recording is stated as what is owed** (new) — `workflow-fragment-routing-recording-owed`.

### change-code-review — MODIFIED *Out-of-scope edits are reported as scope* (5)

19. **A correct but unrelated edit** — existing, unchanged: `change-code-reviewer-finding-vocabulary` (in part).
20. **A folded-in edit made as the conventions direct** — in part: `change-code-reviewer-fold-in-exemption` (fold-defers-to-conventions, fold-not-scope, reads-commits). The reviewer's verdict on a real diff is the cold-run check (tasks 2.2, 2.3).
21. **A folded-in edit outside the change's files** — in part: `change-code-reviewer-fold-in-exemption` (short-is-scope, states-files). Conduct: cold run.
22. **A folded-in edit with a defect** — in part: `change-code-reviewer-fold-in-reviewed` (fold-reviewed).
23. **No fold-in rule in the project** — in part: `change-code-reviewer-fold-in-exemption` (no-rule-none). Conduct: cold run.

### backlog-maintenance — MODIFIED *Record writes an entry the file can be relied on for* (3)

24. **A name already used by an archived change** — existing, unchanged: `backlog-skill-record`.
25. **An overlapping entry exists** — existing, unchanged: `backlog-skill-record`.
26. **Work the change can fold in** (new) — in part: `backlog-skill-record-fold-in`.

## Assertion classification

**Specified** (traces to a delta's SHALL or scenario):

- Fragment Scope: the three conditions and their phrases (only files the change edits for its own work, direct tests, no specification delta, no decision, small with its four examples), commit of its own, message says it is folded in, named in the pull request's description, the rest a separate proposed change.
- Fragment second-change opening: work the scope rule does not fold in is the second change.
- Fragment routing: recording in `docs/backlog.md` stated as owed, opening as the option.
- Fragment apply: reads `docs/backlog.md` before implementing, by the fold-in conditions, as folded-in work whose commit names the entry, deletion left to the archive re-read; names no entry field.
- Reviewer: fold-in edits per the conventions are not `scope`; falling short is; no fold-in rule means none; conditions not restated; folded-in edits reviewed for correctness; no-decision judged only where visible; a pull request description is not a finding.
- Skill record: the fold-in test, taken from the workflow, writing no entry where met, applied first; conditions not restated.

**Derived** (inferred; no requirement fixes them — each open to revision as a derived assertion):

- Every selector and co-occurrence rule (Q1): the paragraphs are found as lines opening `**Scope.**`, `**A second change surfacing.**`, the item opening "Where it **does not**", and the item naming `**apply**` and `docs/backlog.md`; in the agent and skill, terms are matched on one line.
- The phrase-level regexes and their tolerated variants (e.g. `message (says|states) … folded in`, `name (it|them)`, `(is owed|what is owed|the obligation)`).
- `either` on the routing item read as offering the two as equals.
- `fix` as a forbidden kind value on the pickup item (from `design.md` decision 5, not the spec).
- `git log --name-only` (from `design.md` decision 6 and task 2.1; the spec says only "the range's commits") (Q3).
- "Not stating the conditions" as the absence of `screen of diff` and `direct tests` / `their direct tests` from the agent and from the skill's record section.
- "First" in record as the first mention of folding preceding the first mention of `heading` in the record section.

**Deliberately untested**:

- Fragment version 8 to 9 (proposal and task 1.4). No scenario states it; `inlined-body-matches-fragment` reads the version dynamically and pinning 9 would break at the next bump.
- The cold-run fixture and its pass criteria in `agents/change-code-reviewer.checks.yaml` (task 2.2) — outside the test-path glob's subject; verified by the real-dispatch cold run (task 2.3).
- Record offering "no override the workflow does not state" — an absence with no token to scan.
- All session, reviewer and skill conduct named under each scenario above.
- Skill description and trigger fixtures unchanged (task 3.1) — a diff check, not a scenario.

## Obsolete tests

The change carries MODIFIED deltas, so this applies. Searched `tests/cases/*.sh` and `tests/cases/lib/*.sh` only; no earlier `test-plan.md` was supplied. Superseded behaviour, from comparing each delta with its requirement under `openspec/specs/`:

- session-workflow: the scope rule obliging *all* out-of-scope work to leave the change; branching and recording offered as equal alternatives ("either opened on a branch … or recorded").
- change-code-review: every out-of-scope edit being `scope`, with no fold-in exemption.
- backlog-maintenance: record writing an entry with no fold-in test first.

**None was found by this search** — this is not a claim that no such test exists. Searched for: `fold`, `separate proposed`, `second change`, `scope rule`, `either`, `branch of its own`, the backticked `` `scope` `` kind, and the record section's scans. The matches (`workflow-fragment-backlog-not-created-by-fragment`'s conforming fixture "record it in `docs/backlog.md`, or open the identified change"; `change-code-reviewer-finding-vocabulary`'s fixture "An edit out of scope is a `defect`") are fixture text inside discriminators, not assertions on the superseded behaviour.

### An existing test the planned text will fail (candidate for human confirmation)

Not superseded by any delta, but it collides with the text `design.md` decision 2 quotes:

- **Test**: `tests/cases/workflow-fragment-archive-reread-names-no-field.sh`, scan `[deletion-ground]`.
- **Delta**: session-workflow ADDED *A change takes the backlog entries it can fold in* (the apply sentence).
- **Evidence**: the case takes "the re-read line" to be every line matching `docs/backlog\.md` and `re-?read` and `archiv`, and fails it on `delet`. The planned apply sentence — "Before implementing, read `docs/backlog.md` for entries … ; the archive re-read deletes it." — is one line (one paragraph per line) carrying all four, so that case will go from green to red once task 1.3 lands. Simulated against the sentence alone; the fragment itself was not read.
- **Marking**: candidate for human confirmation, not a conclusion. Either the apply sentence is reworded so it does not state the deletion on the same line (a plan change, for `openspec-update-change`), or the existing case's line selection is judged superseded and revised by a human. This pass did not edit it. Task 1.3 names `workflow-fragment-backlog-rules-not-restated` as its verifier but not this case.

## Unresolved project questions

- **Q1 — Paragraph selection.** Nothing recorded fixes how a case finds a fragment rule. Assumed: one paragraph per line (AGENTS.md) and the paragraph openings `design.md` decision 2 quotes (`**Scope.**`, `**A second change surfacing.**`, "- Where it **does not**:", and the apply item containing `**apply**`). Depends on it: all seven `workflow-fragment-*` cases above; same-line co-occurrence in both `change-code-reviewer-fold-in-*` cases.
- **Q2 — Where shared helpers live.** `tests/README.md` documents only `tests/lib.sh`; `static-scan.sh` set the precedent of `tests/cases/lib/`. Assumed the same for `tests/cases/lib/line-scan.sh` (writing to `tests/lib.sh` is outside the glob). Depends on it: the seven fragment cases.
- **Q3 — Commit-reading mechanism.** The spec says "the range's commits"; the scan requires the literal `git log --name-only` from the design. Depends on it: `change-code-reviewer-fold-in-exemption` (reads-commits).
- **Q4 — Stack skill.** The behaviour under test is markdown prose with no runtime; the library carries no matching skill. `bash` covers authoring shell scripts, which is a near miss for prose and was not loaded; the cases were checked with ShellCheck (clean).
- **Q5 — `tests/coverage.md`.** Task 4.1 updates it; this pass did not, as it is outside the test-path glob.
