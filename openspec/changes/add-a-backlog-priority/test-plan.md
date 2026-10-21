# Test plan: add-a-backlog-priority

Derived by `ai-toolkit:change-test-writer` from the delta specs committed at `a2aab23`, before any implementation. This file is not an artifact the OpenSpec schema defines, so `openspec instructions apply` does not surface it; read it on purpose before implementing.

Test command: `bash tests/run.sh` (runs every `tests/cases/*.sh`). `run.sh` has no per-case filter, so a single case is selected by running it with the environment `run.sh` exports (unresolved question Q3):

```
TOOLKIT_ROOT="$PWD" TESTLIB="$PWD/tests/lib.sh" PROJECT_INIT="$PWD/scripts/project-init" TESTDIR="$(mktemp -d)" bash tests/cases/<case>.sh
```

Cases below are named by file; `<case>` is the file name without its directory.

## Baseline

Full suite, taken before any test was written: `bash tests/run.sh` at `a2aab23` on a clean tree — **143 passed, 0 failed**.

After this pass: **144 passed, 10 failed**. The 10 failures are exactly the new cases listed as red below; no existing case changed state.

## What the implementation must make pass

| Task | Cases that must go from failing to passing |
|---|---|
| 1.1 seeded backlog (`scripts/project-init`) | `backlog-seeded-priority-statements.sh`, `backlog-seeded-priority-field.sh`, `backlog-seeded-priority-values.sh`, `backlog-seeded-priority-no-low.sh`, `backlog-seeded-priority-transitions.sh` |
| 2.1 `skills/backlog/SKILL.md` | `backlog-skill-record-priority.sh`, `backlog-skill-pick-priority.sh`, `backlog-skill-sweep-priority.sh`, `backlog-skill-older-shape-priority-default.sh` |
| 2.2 `skills/backlog/references/audit.md` | `backlog-skill-audit-priority.sh` |
| 2.1 and 2.2 (must stay passing) | `backlog-skill-priority-not-restated.sh` |
| 1.2 this repository's `docs/backlog.md` | none — deliberately untested (below) |
| 4.1 | every case, with the obsolete candidate below resolved first |

**Expect task 1.1 to turn `backlog-seeded-structured-statements.sh` red.** It asserts the superseded wording; see *Obsolete tests*.

## Red at authoring

Every case below fails at authoring because the property it reads is absent from the current target, not because the case is broken. Each static-scan case's discriminator (`scan_discriminate`) ran first and passed: the conforming fixture was accepted and every per-scan mutant was rejected by its own scan, so each failure below is the check over `$TOOLKIT_ROOT`. The seeded cases execute `scripts/project-init` and read its output, so they owe no fixture; they were additionally run against a scratch file carrying `design.md` decision 5's text (outside the repository, by a stand-in for the tool) and all five passed, so they are satisfiable by the planned text.

- `backlog-seeded-priority-statements.sh` — red on `how urgent it is` (absent).
- `backlog-seeded-priority-field.sh` — red: no fenced `**Priority**` line.
- `backlog-seeded-priority-values.sh` — red: no fenced `**Priority**` line.
- `backlog-seeded-priority-no-low.sh` — red: no fenced `**Priority**` line (vacuity guard; the low-value regex has its own inline discriminator, which passed).
- `backlog-seeded-priority-transitions.sh` — red: no fenced `**Priority**` line.
- `backlog-skill-record-priority.sh` — red on all six scans.
- `backlog-skill-pick-priority.sh` — red on all eight scans.
- `backlog-skill-sweep-priority.sh` — red on all five scans.
- `backlog-skill-audit-priority.sh` — red on all six scans.
- `backlog-skill-older-shape-priority-default.sh` — red on `default-not-unclassified`.

`backlog-skill-priority-not-restated.sh` passes on its first run. It is a forbid scan over a target that already lacks the phrases, so its pass establishes nothing alone; its discriminator ran and rejected each of its four mutants by the right scan. It covers no scenario.

## Scenario accounting

31 scenarios in the delta specs (project-bootstrap 8, backlog-maintenance 23); 31 accounted for below, all covered by at least one named case, none uncovered. "In part" means the case reads the stated text and cannot reach what a session does when it runs the operation.

### project-bootstrap — A backlog is seeded where none exists (MODIFIED)

1. **A project without a backlog receives the seeded file** — `backlog-seeded-priority-statements.sh` (the statements this delta revises or adds), with the existing `backlog-seeded-new-project.sh`, `backlog-seeded-adoption.sh` and `backlog-seeded-structured-statements.sh` (one assertion of which is an obsolete candidate) for the statements carried through.
2. **An existing backlog is preserved exactly** — unchanged by this delta; existing `backlog-existing-preserved.sh`, `backlog-dangling-symlink-not-written-through.sh`. No new case.
3. **The seeded file carries no numbering** — unchanged; existing `backlog-seeded-no-entry-numbering.sh` also reads the new Priority text. No new case.
4. **The seeded entry shape carries the structured fields** — `backlog-seeded-priority-field.sh` (Priority), with existing `backlog-seeded-structured-fields.sh` (the other five labels, no Depends on).
5. **A fix is distinguished from a change by what it owes** — unchanged; existing `backlog-seeded-kind-definition.sh`. No new case.
6. **Priority's values and default are stated** — `backlog-seeded-priority-values.sh`.
7. **The seeded file offers no low priority** — `backlog-seeded-priority-no-low.sh`, in part: "so the entry is either parked with a condition or not recorded" is a session's conduct; the deletion ground it rests on stays asserted by `backlog-seeded-new-project.sh`.
8. **The seeded file states how an entry leaves parked and high** — `backlog-seeded-priority-transitions.sh`.

### backlog-maintenance — Record writes an entry the file can be relied on for (MODIFIED)

9. **A name already used by an archived change** — unchanged; existing `backlog-skill-record.sh`, in part.
10. **An overlapping entry exists** — unchanged; existing `backlog-skill-record.sh`, in part.
11. **Work the change can fold in** — unchanged; existing `backlog-skill-record-fold-in.sh`, in part.
12. **Record defaults Priority** — `backlog-skill-record-priority.sh`, in part.
13. **Record parks an entry only on the operator's word** — `backlog-skill-record-priority.sh`, in part.

### backlog-maintenance — Pick lists what can be taken now (MODIFIED)

14. **A blocked entry is not offered** — unchanged; existing `backlog-skill-pick.sh`, in part.
15. **A wait already satisfied but not updated** — unchanged; existing `backlog-skill-pick.sh`, in part.
16. **Pick narrowed to files** — unchanged; existing `backlog-skill-pick.sh`, in part.
17. **A parked entry is not offered as takeable** — `backlog-skill-pick-priority.sh` (`parked-not-takeable`, `parked-listed-apart`, `parked-with-condition`), in part.
18. **A parked entry whose condition holds** — `backlog-skill-pick-priority.sh` (`condition-holds-once-updated`, `names-what-fulfilled`), in part.
19. **A parked entry still waiting** — `backlog-skill-pick-priority.sh` (`waits-on-governs`), in part.
20. **High entries come first** — `backlog-skill-pick-priority.sh` (`high-first`, `group-by-highest`), in part.

### backlog-maintenance — Sweep performs the archive step's re-read (MODIFIED)

21. **An entry finished without being named** — unchanged; existing `backlog-skill-sweep.sh`, in part.
22. **Sweep after a squash merge** — unchanged; existing `backlog-skill-sweep.sh`, in part.
23. **Sweep after the record has landed** — unchanged; existing `backlog-skill-sweep.sh`, in part.
24. **A change fulfils a parked entry's condition** — `backlog-skill-sweep-priority.sh` (`parked-condition`, `condition-fulfilled`, `priority-as-file-directs`), in part.
25. **A change removes a high entry's evidence** — `backlog-skill-sweep-priority.sh` (`high-evidence`, `evidence-removed`, `priority-as-file-directs`), in part.

### backlog-maintenance — Audit verifies every entry independently and changes nothing without the operator (MODIFIED)

26. **An entry done by an unmentioning change** — unchanged; existing `backlog-skill-audit.sh`, in part.
27. **The report is not applied unasked** — unchanged; existing `backlog-skill-audit.sh`, in part.
28. **Two entries recorded for one change** — unchanged; existing `backlog-skill-audit.sh`, in part.
29. **A parked entry whose condition has fired** — `backlog-skill-audit-priority.sh`, in part. Its `high-evidence-holds`, `high-evidence-lapsed` and `priority-corrected` scans trace to the requirement text rather than to this scenario.

### backlog-maintenance — Entries in an older shape are reported, not rewritten (MODIFIED)

30. **Pick meets an entry with no Kind** — unchanged; existing `backlog-skill-older-shape-unclassified.sh`, in part (still valid: a field the file gives no default for is still reported unclassified).
31. **Pick meets an entry with no Priority** — `backlog-skill-older-shape-priority-default.sh`, in part.

## Assertion classification

**Specified** (traces to the delta specs):

- `backlog-seeded-priority-statements.sh`: urgency among what an entry states in its own fields; archive update names unparked entries and sets Re-checked; a parked entry is not folded into another change.
- `backlog-seeded-priority-field.sh`: the entry shape names Priority.
- `backlog-seeded-priority-values.sh`: values `high`, `normal`, `parked until`; `high` needs evidence of harm happening now; `parked` needs a condition that can be checked; absent is `normal`.
- `backlog-seeded-priority-no-low.sh`: no `low` value offered.
- `backlog-seeded-priority-transitions.sh`: parked→`normal` or `high` with evidence; `high` whose evidence no longer holds→`normal`; archive names unparked.
- `backlog-skill-record-priority.sh`: default, `normal`, evidence/condition, `high`/`parked` only on the operator's confirmation, applying only where the file's shape names Priority.
- `backlog-skill-pick-priority.sh`: every scan (see accounting 17–20).
- `backlog-skill-sweep-priority.sh`: every scan.
- `backlog-skill-audit-priority.sh`: every scan.
- `backlog-skill-older-shape-priority-default.sh`: a defaulted field is read as its default, not unclassified.

**Derived** (inferred; no stated requirement fixes it — reconsider rather than satisfy blindly if one blocks a sound implementation):

- Wording, all seeded cases: each statement is asserted by a literal phrase from `design.md` decision 5 (`how urgent it is`, `unblocked, unparked or made stale`, `not folded into another change`, `evidence of harm happening now`, `a condition that can be checked`, `An entry without this field is `normal``, `When the condition holds the entry becomes `normal``, `` `high` with evidence``, `evidence no longer holds it becomes `normal``). A faithful rewording fails.
- Placement, seeded cases: the Priority definition is one line of the fenced entry shape beginning `**Priority**` (Q2); urgency shares a line with `in its own fields`; the archive statement is the line carrying both `made stale` and `Re-checked`.
- Order, `backlog-seeded-priority-field.sh`: Priority precedes Kind (`design.md` decision 5, "between the description and **Kind**").
- Scope, `backlog-seeded-priority-no-low.sh`: only the Priority line is scanned for `low`, and the scan is word-bounded.
- Structure, skill cases: operations sit under headings naming `record`, `pick`, `sweep` (Q1); the audit brief and report sections are in `references/audit.md`.
- Operationalisation, skill cases: each specified statement is recognised by co-occurring tokens on one line — listed in each case's header comment. In particular `audit-priority`'s `unblocked or unparked` follows `tasks.md` 2.2's section name, and `older-shape-priority-default` requires `default` and `unclassified` on one line.
- `backlog-skill-priority-not-restated.sh` entirely: the skill states neither `harm happening now` nor `an entry without this field is` (`design.md` decisions 5 and 8, `tasks.md` 2.1). Covers no scenario.

**Deliberately untested**:

- What a session does when it runs record, pick, sweep or audit — orders, omits, proposes, waits for confirmation. Not reachable by a static scan; verified by reading, as the existing `backlog-skill-*` cases record.
- Pick naming a parked entry's satisfied wait beside it (requirement text): no scenario, and no token distinguishes it from the existing satisfied-wait scan.
- Task 1.2 — this repository's `docs/backlog.md` preamble matching the seeded text. No scenario states it; the task's own verification is a diff of the two preambles.
- `skills/backlog/SKILL.md`'s description and trigger fixtures being unchanged (`tasks.md` 2.1): verified by the task, not stated by a scenario.
- Close: unchanged by this delta (`design.md` decision 8).

## Obsolete tests

Each entry is a **candidate for human confirmation**, not a conclusion. Nothing was edited or deleted.

1. **`backlog-seeded-structured-statements.sh`** — two assertions: `assert_contains "$backlog" "unblocked or made stale"` and the check that the line matching `unblocked or made stale` also carries `Re-checked`.
   - Superseded by: project-bootstrap, MODIFIED *A backlog is seeded where none exists* — the statement "the entries it unblocked or made stale are updated" becomes "the entries it unblocked, unparked or made stale are updated" (`design.md` decision 5's archive sentence).
   - Evidence: the revised wording does not contain the substring `unblocked or made stale`, so both assertions fail once task 1.1 lands. The rest of that case (thirteen other statements) is unaffected and still bears on scenario 1. The replacement assertions are in `backlog-seeded-priority-statements.sh` and `backlog-seeded-priority-transitions.sh`.

Search: `tests/cases/*.sh` only, by the tokens of each superseded statement (`unblock`, `made stale`, `unclassified`, `waits on and`, `in its own fields`, `carries no meaning`, `priority`, `parked`). No earlier `test-plan.md` was supplied.

For the MODIFIED backlog-maintenance requirements — audit's report section "the entries now unblocked" becoming "now unblocked or unparked", sweep's outcome list gaining "unparked", and *Entries in an older shape* gaining the defaulted-field exception — **none was found by this search**. That is not a finding that no such test exists: a case asserting those statements in other words would not be reached by a token search. The nearest cases were read and judged not superseded: `backlog-skill-audit.sh` asserts no "now unblocked" token; `backlog-skill-sweep.sh` asserts nothing about the outcome list; `backlog-skill-older-shape-unclassified.sh` asserts `unclassified` is stated, which the revised requirement still requires for a field the file gives no default.

Not obsolete, noted: `backlog-seeded-structured-fields.sh` remains true but no longer names every field the revised scenario lists; `backlog-seeded-priority-field.sh` covers Priority. `workflow-fragment-archive-backlog-reread.sh` and `workflow-fragment-archive-reread-names-no-field.sh` assert `unblocked or made stale` in `rules/development-workflow.md`, which this change does not modify (the proposal states no fragment change), so they are unaffected.

## Unresolved project questions

- **Q1 — the skill's section structure.** Assumed: `skills/backlog/SKILL.md` keeps each operation under a heading naming it (`record`, `pick`, `sweep`), the assumption `add-backlog-skill`'s cases already make. Depending: `backlog-skill-record-priority.sh`, `backlog-skill-pick-priority.sh`, `backlog-skill-sweep-priority.sh`. A restructured file fails them as "target absent" rather than on a property.
- **Q2 — the seeded Priority definition's form.** Assumed: one line inside the fenced entry shape, beginning `**Priority**`, worded as `design.md` decision 5 (the form the Kind line takes, per `backlog-seeded-kind-definition.sh`). Depending: all five `backlog-seeded-priority-*.sh`.
- **Q3 — selecting one case.** `tests/run.sh` offers no filter and the convention files name no per-case selector. Assumed: the environment-prefixed command at the top of this file. Depending: every case named here.
- **Stack skill.** The `bash` skill exists and was loaded; no question.

## Missing shared arrangement

The dispatch named `tests/lib.sh` and `tests/cases/lib/` (`static-scan.sh`, `line-scan.sh`) as the shared arrangement. Nothing was written there. Local declarations:

1. **Fenced Priority-line extraction** — an inline `awk` assigning `priority=` in `backlog-seeded-priority-statements.sh`, `backlog-seeded-priority-values.sh`, `backlog-seeded-priority-no-low.sh`, `backlog-seeded-priority-transitions.sh`.
   - Stands in for: reading one labelled field line out of the seeded file's fenced entry shape.
   - Used by: those four cases.
   - Near-miss: `static-scan.sh`'s `scan_heading_section` reads a section under a heading, not a line inside a fence; `tests/lib.sh`'s `assert_contains` reads the whole file. Neither isolates a fenced line.
   - Found in a test module: the same extraction for `**Kind**` in `backlog-seeded-kind-definition.sh`, and the fenced-block extraction in `backlog-seeded-structured-fields.sh` (not imported; declared locally).
   - Proposed home: `tests/lib.sh`, as a `fenced_field_line FILE LABEL` helper.
   - Disposition: _(apply records promoted / kept and why)_

2. **`fenced_line` function** — declared in `backlog-seeded-priority-field.sh`.
   - Stands in for: the line number of a labelled field line in the fenced entry shape, to order Priority before Kind.
   - Used by: `backlog-seeded-priority-field.sh`.
   - Near-miss: none in the shared arrangement.
   - Found in a test module: no.
   - Proposed home: `tests/lib.sh`, beside entry 1 (the same helper with a line-number mode).
   - Disposition: _(apply records)_

3. **Run-the-tool prelude** — inline in all five `backlog-seeded-priority-*.sh`: make `$TESTDIR/work`, `cd` into it, run `$PROJECT_INIT`, assert exit 0 and that `docs/backlog.md` exists.
   - Stands in for: a freshly seeded backlog to read.
   - Used by: the five seeded cases.
   - Near-miss: `tests/lib.sh` supplies the assertions but no seeding helper.
   - Found in a test module: the same prelude in every existing `backlog-seeded-*.sh`.
   - Proposed home: `tests/lib.sh`, as a `seeded_backlog` helper printing the path.
   - Disposition: _(apply records)_

4. **Low-value regex and its specimen discriminator** — `low_re` and two specimen lines in `backlog-seeded-priority-no-low.sh`.
   - Stands in for: a word-bounded check that a line offers `low`.
   - Used by: `backlog-seeded-priority-no-low.sh`.
   - Near-miss: `static-scan.sh`'s forbid scan with a specimen does the same for a file or section, not for a line extracted from a tool's output.
   - Found in a test module: no.
   - Proposed home: none to propose — specific to this one case.
   - Disposition: _(apply records)_

5. **Conforming fixture trees** — the heredoc `SKILL.md` and `references/audit.md` in `backlog-skill-record-priority.sh`, `backlog-skill-pick-priority.sh`, `backlog-skill-sweep-priority.sh`, `backlog-skill-audit-priority.sh`, `backlog-skill-older-shape-priority-default.sh`, `backlog-skill-priority-not-restated.sh`.
   - Stands in for: the material `scan_discriminate` mutates.
   - Used by: those six cases.
   - Near-miss: none; `static-scan.sh` expects each case to supply its own.
   - Found in a test module: the pattern is every existing `backlog-skill-*.sh`; no fixture was copied.
   - Proposed home: none to propose — each fixture is shaped to its own scans.
   - Disposition: _(apply records)_
