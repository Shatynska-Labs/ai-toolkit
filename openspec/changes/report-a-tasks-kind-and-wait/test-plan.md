# Test plan: report-a-tasks-kind-and-wait

Written by `ai-toolkit:change-test-writer` against the plan committed at `fb0e700`, before any implementation. This file is not an artifact the OpenSpec schema knows about: `openspec instructions apply` does not list it, so it has to be read on purpose before implementing.

Every case is run from the worktree root as `bash tests/run.sh <case>`, the case being its file name under `tests/cases/` without `.sh`. Several cases may be named in one run.

## What the implementation must make pass

The 25 cases this pass added, all red now:

```
bash tests/run.sh \
  backlog-dir-seeded-structured-keys-need-and-type backlog-dir-seeded-fields-are-a-list-with-need \
  backlog-dir-seeded-need-values backlog-dir-seeded-need-step-not-must \
  backlog-dir-seeded-waits-for-types backlog-dir-seeded-untyped-condition-valid \
  backlog-skill-record-need backlog-skill-record-types-condition backlog-skill-pick-need-order \
  backlog-skill-audit-waits-for-type backlog-skill-older-shape-untyped-condition \
  task-board-entry-kind-and-need task-board-entry-waits-on-done task-board-entry-typed-condition \
  task-board-entry-unchecked-wait-warned \
  task-board-json-task-kind-need-typed-condition task-board-json-task-need-default \
  task-board-json-waits-on-done-blocked task-board-json-wait-cleared-by-merged-fix \
  task-board-json-condition-is-a-wait task-board-json-parked-after-the-wait \
  task-board-json-no-readiness-in-flight-or-done task-board-json-unchecked-named-wait \
  task-board-json-merged-fix-partial-read task-board-json-task-keys-kind-and-wait
```

By task: 1.1 makes the six `backlog-dir-seeded-*` cases pass; 2.1 makes `backlog-skill-record-need`, `-record-types-condition`, `-pick-need-order` and `-older-shape-untyped-condition` pass; 2.2 makes `backlog-skill-audit-waits-for-type` pass; 3.1 and 3.2 make the ten `task-board-json-*` cases pass; 3.3 makes the four `task-board-entry-*` cases pass. Three existing cases stand to fail once 1.1 and 3.2 land; they are listed under *Obsolete tests*, as candidates for confirmation.

## Baseline

Full suite, `bash tests/run.sh` from the worktree root at `fb0e700`, before any case was added: 676 cases, 675 passed, 1 failed. The failure is `command-absent-outstanding-blocks` (`expected exit code 2, got 0 (BLOCKED — specification tooling is outstanding and its command is missing)`). It bears on `scripts/project-init`'s handling of a missing `openspec`, not on this change, and was failing before this pass; it is environmental at a guess, and not investigated here.

After this pass: the 25 added cases fail, each for the reason stated under its row below; every discriminator inside them passed (each static case reached its check of the real file only after its fixture and every mutant or specimen were judged correctly). `shellcheck -x` is clean on all 25.

## Scenario accounting

98 scenarios in the three delta specs: 23 in `project-bootstrap`, 44 in `backlog-maintenance`, 31 in `task-board`. All deltas are `MODIFIED`. 26 scenarios are new; 2 kept their titles but changed in substance, and have new cases; 70 are carried over unchanged and keep their existing cases. All 98 are covered by at least one named case; none is uncovered. The skill's scenarios (`backlog-maintenance`) are covered in their mechanical half only — each case reads the stated text, not a session's conduct — as every earlier `backlog-skill-*` case is.

The red state of each new case at authoring: the `task-board-json-*` cases fail on the key's absence from the document (`KeyError`), the key-set case on the set; the `task-board-entry-*` cases on the row lacking what it should show; the static cases on each scan's own `[TAG]`, so the property named is the one that fails. These are records of a red run on a named property, to be read against the green run once the change lands.

### specs/project-bootstrap/spec.md — *The backlog's rules are written where none exist* (23)

| Scenario | Status |
|---|---|
| A project without a backlog receives the seeded file | Covered (unchanged) — `backlog-dir-seeded-new-project`, `backlog-block-new-project`, `backlog-dir-seeded-adoption`; the statements this change adds to "every statement listed above" are read by `backlog-dir-seeded-need-values`, `backlog-dir-seeded-waits-for-types`, `backlog-dir-seeded-untyped-condition-valid`, `backlog-dir-seeded-need-step-not-must` |
| An existing backlog is preserved exactly | Covered (unchanged) — `backlog-block-existing-preserved` |
| The seeded file carries no numbering | Covered (unchanged) — `backlog-dir-seeded-no-entry-numbering` |
| The seeded entry shape carries the structured fields | Covered (revised: eleven keys) — `backlog-dir-seeded-structured-keys-need-and-type`. Red: `the example's frontmatter lacks need` |
| A fix is distinguished from a change by what it owes | Covered (unchanged) — `backlog-dir-seeded-kind-definition` |
| Priority's values and default are stated | Covered (unchanged) — `backlog-dir-seeded-priority-values` |
| The seeded file offers no low priority | Covered (unchanged) — `backlog-dir-seeded-priority-no-low` |
| The seeded file states how an entry leaves parked and high | Covered (unchanged) — `backlog-dir-seeded-priority-transitions` |
| Workstream's default is stated | Covered (unchanged) — `backlog-dir-seeded-workstream-default` |
| The seeded entry's fields are a list | Covered (requirement revised: **Need** joins the list) — `backlog-dir-seeded-fields-are-a-list-with-need`. Red: the example body lacks `- **Need**` |
| An absent value reads as its field | Covered (unchanged) — `backlog-dir-seeded-absent-values`; `need`'s and `waits_for_type`'s absence by `backlog-dir-seeded-need-values` and `backlog-dir-seeded-untyped-condition-valid` |
| A single-file backlog is pointed to the migration tool | Covered (unchanged) — `backlog-dir-single-file-pointed-to-migrate` |
| A missing backlog fragment blocks every run | Covered (unchanged) — `backlog-fragment-absent-blocks-every-run` |
| The rules are added beside existing entries | Covered (unchanged) — `backlog-block-beside-existing-entries` |
| Project text beside the block survives | Covered (unchanged) — `backlog-block-project-text-survives` |
| A backlog path that is not a directory is not written through | Covered (unchanged) — `backlog-dir-not-a-directory-not-written-through` |
| Waits on holds only names | Covered (unchanged) — `backlog-dir-seeded-waits-on-names-only` |
| The frontmatter is flat | Covered (unchanged) — `backlog-dir-seeded-frontmatter-flat` |
| The seeded block makes `none` the end of a search | Covered (unchanged) — `backlog-block-none-ends-a-search` |
| Need's values and default are stated | Covered (new) — `backlog-dir-seeded-need-values` |
| A condition's types are stated | Covered (new) — `backlog-dir-seeded-waits-for-types` |
| A condition without a type stays valid | Covered (new) — `backlog-dir-seeded-untyped-condition-valid` |
| A step is not must for being a step | Covered (new) — `backlog-dir-seeded-need-step-not-must` |

### specs/backlog-maintenance/spec.md (44)

*Record writes an entry the file can be relied on for* (17)

| Scenario | Status |
|---|---|
| A name already used by an archived change | Covered (unchanged) — `backlog-skill-record`, `backlog-skill-dir-record-file` |
| Record refuses a name colliding with the rules' files | Covered (unchanged) — `backlog-skill-record-refuses-agents-claude` |
| An overlapping entry exists | Covered (unchanged) — `backlog-skill-record`, `backlog-skill-dir-record-names-and-conditions`, `backlog-skill-record-absent-value` |
| Work the change can fold in | Covered (unchanged) — `backlog-skill-record-fold-in` |
| Record defaults Priority | Covered (unchanged) — `backlog-skill-record-priority` |
| Record parks an entry only on the operator's word | Covered (unchanged) — `backlog-skill-record-priority`, `backlog-skill-dir-record-names-and-conditions` |
| Record carries the change's workstream | Covered (unchanged) — `backlog-skill-record-absent-value`, `backlog-skill-record-reads-goals` |
| Record refuses a workstream that is not open | Covered (unchanged) — `backlog-skill-record-absent-value` |
| Record keeps a condition out of waits_on | Covered (unchanged) — `backlog-skill-dir-record-names-and-conditions` |
| Record writes one file | Covered (unchanged) — `backlog-skill-dir-record-file`, `backlog-skill-record-places-entry` |
| An entry the change's workstream rules out finds another | Covered (unchanged) — `backlog-skill-record-reads-goals` |
| The absent value follows the read | Covered (unchanged) — `backlog-skill-record-reads-goals` |
| A recorded entry is placed or left with a reason | Covered (unchanged) — `backlog-skill-record-places-entry` |
| Placing one entry owes nothing for the others | Covered (unchanged) — `backlog-skill-record-places-entry`, `workstreams-block-placing-settled` |
| Record defaults Need | Covered (new, mechanical half) — `backlog-skill-record-need` |
| Record writes must only on the operator's word | Covered (new, mechanical half) — `backlog-skill-record-need` |
| Record types a condition | Covered (new, mechanical half) — `backlog-skill-record-types-condition` |

*Pick lists what can be taken now* (14)

| Scenario | Status |
|---|---|
| A blocked entry is not offered | Covered (unchanged) — `backlog-skill-dir-pick-wait`, `backlog-skill-pick` |
| A wait already satisfied but not updated | Covered (unchanged) — `backlog-skill-pick`, `backlog-skill-dir-pick-wait` |
| Pick narrowed to files | Covered (unchanged) — `backlog-skill-pick` |
| A parked entry is not offered as takeable | Covered (unchanged) — `backlog-skill-pick-priority`, `backlog-skill-dir-pick-wait` |
| A parked entry whose condition holds | Covered (unchanged) — `backlog-skill-pick-priority` |
| A parked entry still waiting | Covered (unchanged) — `backlog-skill-pick-priority` |
| High entries come first | Covered (unchanged) — `backlog-skill-pick-priority` |
| Pick lists a workstream's entries in step order | Covered (unchanged) — `backlog-skill-pick-workstream`; step order holding within one need by `backlog-skill-pick-need-order` |
| A high step leads its workstream's group | Covered (unchanged) — `backlog-skill-pick-workstream` |
| An unplaced entry is shown under its workstream | Covered (unchanged) — `backlog-skill-pick-workstream` |
| An entry naming no workstream is grouped apart | Covered (unchanged) — `backlog-skill-pick-no-workstream` |
| A condition not shown to hold blocks | Covered (unchanged) — `backlog-skill-dir-pick-wait` |
| Must comes before could | Covered (new, mechanical half) — `backlog-skill-pick-need-order` |
| Need does not make an entry takeable | Covered (new, mechanical half) — `backlog-skill-pick-need-order` |

*Audit verifies every entry independently and changes nothing without the operator* (9)

| Scenario | Status |
|---|---|
| An entry done by an unmentioning change | Covered (unchanged) — `backlog-skill-audit` |
| The report is not applied unasked | Covered (unchanged) — `backlog-skill-audit`, `backlog-skill-dir-audit-names` |
| Two entries recorded for one change | Covered (unchanged) — `backlog-skill-audit` |
| A parked entry whose condition has fired | Covered (unchanged) — `backlog-skill-audit-priority` |
| An entry names an archived workstream | Covered (unchanged) — `backlog-skill-audit-workstream` |
| An entry names an unknown name | Covered (unchanged) — `backlog-skill-dir-audit-names` |
| A condition without a type | Covered (new, mechanical half) — `backlog-skill-audit-waits-for-type` |
| A type without a condition | Covered (new, mechanical half) — `backlog-skill-audit-waits-for-type` |
| Audit leaves need alone | Covered (new, mechanical half) — `backlog-skill-audit-waits-for-type` (its `need-left-alone` check) |

*Entries in an older shape are reported, not rewritten* (4)

| Scenario | Status |
|---|---|
| Pick meets an entry with no Kind | Covered (unchanged) — `backlog-skill-dir-older-shape-missing-key`, `backlog-skill-older-shape-unclassified` |
| Pick meets an entry with no Priority | Covered (unchanged) — `backlog-skill-older-shape-priority-default` |
| An earlier absent value is read as the current one | Covered (unchanged) — `backlog-skill-older-shape-earlier-nothing` |
| Pick meets an untyped condition | Covered (new, mechanical half) — `backlog-skill-older-shape-untyped-condition` |

### specs/task-board/spec.md (31)

*The page carries what a task's entry states* (7)

| Scenario | Status |
|---|---|
| A parked entry | Covered (unchanged) — `task-board-entry-parked` |
| Markup in an entry | Covered (unchanged) — `task-board-markup-in-an-entry-body` |
| An entry without frontmatter | Covered (unchanged) — `task-board-entry-without-frontmatter` |
| Kind and need are shown | Covered (new) — `task-board-entry-kind-and-need` |
| A named wait already done | Covered (new) — `task-board-entry-waits-on-done` |
| A typed condition is shown | Covered (new) — `task-board-entry-typed-condition` |
| An unchecked named wait is warned of on the page | Covered (new) — `task-board-entry-unchecked-wait-warned` |

*The tool reports the board as JSON* (24)

| Scenario | Status |
|---|---|
| A document | Covered (unchanged) — `task-board-json-a-document` |
| The same reading as the page | Covered (unchanged) — `task-board-json-same-reading-as-the-page` |
| A value with quotes, backslashes and a tab | Covered (unchanged) — `task-board-json-hard-characters` |
| Markup stays as written | Covered (unchanged) — `task-board-json-markup-stays` |
| No origin | Covered (unchanged) — `task-board-json-no-origin` |
| A failed fetch | Covered (unchanged) — `task-board-json-failed-fetch` |
| A step of two workstreams | Covered (unchanged) — `task-board-json-step-of-two-workstreams` |
| A step with another workstream's entry value | Covered (unchanged) — `task-board-json-step-with-another-entry` |
| A workstream that is not open | Covered (unchanged) — `task-board-json-workstream-not-open` |
| A task with no workstream | Covered (unchanged) — `task-board-json-no-workstream` |
| Forge not reached | Covered (unchanged) — `task-board-json-forge-not-reached` |
| A blocked run | Covered (unchanged) — `task-board-json-blocked-run` |
| With an output | Covered (unchanged) — `task-board-json-with-output` |
| A usage error with --json | Covered (unchanged) — `task-board-json-usage-error` |
| A failed run | Covered (unchanged) — `task-board-json-failed-run` |
| Kind, need and a typed condition | Covered (new) — `task-board-json-task-kind-need-typed-condition` |
| Need's default | Covered (new) — `task-board-json-task-need-default` |
| A wait on a done name | Covered (new) — `task-board-json-waits-on-done-blocked` |
| A wait cleared by a merged fix | Covered (new) — `task-board-json-wait-cleared-by-merged-fix` |
| A condition is a wait | Covered (new) — `task-board-json-condition-is-a-wait` |
| Parked after the wait | Covered (new) — `task-board-json-parked-after-the-wait` |
| No readiness for a task in flight or done | Covered (new) — `task-board-json-no-readiness-in-flight-or-done` |
| A named wait the forge could not check | Covered (new) — `task-board-json-unchecked-named-wait` |
| A merged fix the partial read found | Covered (new) — `task-board-json-merged-fix-partial-read` |

`task-board-json-task-keys-kind-and-wait` covers the requirement's body (the seven keys, `schema_version` staying `1`), not a scenario.

## Assertion classification

Each case's header carries the same classification, line by line; this is the summary.

**Specified** — tracing to a scenario or to the requirement's own text:

- JSON: every value each `task-board-json-*` case asserts on `kind`, `need`, `waits_for`, `waits_for_type`, `parked_until`, `waits_on_done` and `readiness`, including the controls (a plain entry `ready`, a recorded entry with an unmet wait `blocked`, a planned step with no entry `ready`), which follow the requirement's readiness rule; `need` `should` for an entry with no key and `null` with no entry; `kind` `null` with no entry; an empty `waits_for_type` and `null` `waits_for` and `parked_until` where the entry has none; a value given as written (`kind: chore`, `need: maybe`), unchecked against the sets; `schema_version` `1`; the seven keys being present.
- Page: `fix` and `could` shown; `change` shown (kind on every entry); `should` not shown; an archived name marked done and an open one not; `decision` before the condition; a warning for the unchecked wait.
- Seeded block: the eleven keys in order and no Depends on; the four reasons as one list in the order Kind, Need, Priority, Recorded by; `need`'s three values, measures and default; **Need** among the reasons on a `must` or `could` entry; `waits_for_type` only beside `waits_for` and its five values with their meanings; the untyped reading; being a step not making an entry `must`.
- Skill: `need` set to the README's default `should`, `must` or `could` proposed with a reason from the Goal and written on confirmation; the type written beside `waits_for` where the README names it; `must`, `should`, `could` within a priority, highest-need placement, step order within one need, need never deciding takeability; audit checking and proposing types, listing a wrong or missing type and a type without a condition, and proposing no `need`; the untyped and no-`need` readings not being unclassified.

**Derived** — inferred, no stated requirement fixing them; each is for review:

- *Operationalisation of prose.* Every static scan's pattern (listed in its case's header) is one reading of a stated property; a rewording that keeps the property but avoids the pattern fails the case. The section each skill case reads (`record`, `pick`, the heading naming `missing` from tasks.md 2.1's *Entries missing a key*) and `skills/backlog/references/audit.md` as the brief's home follow the existing cases' assumptions.
- *The seeded example.* `backlog-dir-seeded-structured-keys-need-and-type` and `-fields-are-a-list-with-need` read the entry shape from a fenced example, as their predecessors did, and require the example to carry `need` and a `- **Need**` item (tasks.md 1.1 says both are added).
- *The page's marks.* "Marked done" is read as `done` following the name with only punctuation and space between (design.md decision 9's `(done)`); "with `decision` before it" as `decision` preceding "choice of model" in the row read as one line; the unchecked-wait warning as the row saying "checked" more often than a control row in the same run whose wait is done. The last is chosen because a partial read already marks every task with no change of its name (`merge not checked`); counting against a control is what isolates the wait's warning.
- *The JSON warning's wording.* One string in the task's `warnings` holds the name and reads `not checked` or `unchecked`.
- *The key set is exact* (`task-board-json-task-keys-kind-and-wait`), as the case it supersedes fixed the earlier one.
- *Fixture guards*: `forge` `full` in the merged-fix case, `forge` `partly` in the two partial-read cases, `Forge: partly read` on the page case.

**Deliberately untested:**

- A session's conduct under the skill — that record actually writes `should`, proposes before writing `must`, writes **Need** in the body, writes `[decision, answer]`; that pick orders by need; that audit proposes `[decision]` for a given condition. A static read cannot observe conduct; verified by reading, as for every `backlog-skill-*` case.
- The `forge` `none` variant of "not read in full" — the scenarios hold for any read short of full, and `partly` is the variant that can also find a merged fix; `none` is left to the code review.
- Key order inside a task object (design.md decision 8: after `waits_on`) — a JSON reader does not see it.
- The page's `Waits for` label and the comma-separated form of several types (design.md decision 9) — layout, not a stated requirement.
- That every new value on the page is escaped (tasks.md 3.3) — `task-board-markup-in-every-other-value` covers escaping generally; whether it is extended to the new fields is left to the implementer.
- The unquoting of an escaped `\"` inside `waits_for` (tasks.md 3.1) — the requirement says a value is given "as the entry writes it", which leaves open whether escapes are undone; asserting either would design that behaviour.

## Obsolete tests

Searched within `tests/cases/**` only, for: fixed key lists of an entry's frontmatter, the adjacency of the body's reasons, the JSON task's key set, `warnings` counts or `merge`/`checked` assertions in fixtures carrying `waits_on`, and negative assertions on a task's row (`hasnt`, `hasntre`, `status_is`) that a new tag, a `done` mark or a warning could trip. No earlier `test-plan.md` was supplied, so none was used as a mapping. Three were found; each is a **candidate for human confirmation**, not a conclusion, and none has been edited, deleted or disabled.

1. `bash tests/run.sh backlog-dir-seeded-structured-keys` — the whole case. Superseded by the `MODIFIED` *The backlog's rules are written where none exist* (project-bootstrap), scenario *The seeded entry shape carries the structured fields*, whose THEN now names eleven keys. Evidence: `KEYS=(priority parked_until kind waits_on waits_for design_with workstream recorded_by re_checked)` lacks `need` and `waits_for_type`, and `check_keys` fails with "the example carries a key the requirement does not name" on any other key; tasks.md 1.1 adds `need: should` to the example's frontmatter. Its replacement is `backlog-dir-seeded-structured-keys-need-and-type`.
2. `bash tests/run.sh backlog-dir-seeded-fields-are-a-list` — the whole case. Superseded by the same requirement's body, which now lists the reasons **Kind**, **Need**, **Priority**, **Recorded by**. Evidence: `check_list` requires `- **Priority**` on the line after `- **Kind**` (`[ "$p" -ne $((k + 1)) ]`); tasks.md 1.1 puts `- **Need**` between them. Its replacement is `backlog-dir-seeded-fields-are-a-list-with-need`.
3. `bash tests/run.sh task-board-json-keys-and-version` — one assertion: `jis tasks:a-step.@ '["body","closed_workstream","last_commit","merge_unchecked","name","parts","priority","stage","status","summary","unplaced","waits_on","warnings","workstreams"]'`. Superseded by the `MODIFIED` *The tool reports the board as JSON* (task-board), which adds seven keys to a task. Evidence: the exact-set assertion, derived in its own header ("the sets are exact"). Its other assertions (`schema_version` `1`, the document's, `trunk`'s, a workstream's and a step's key sets) are not superseded. `task-board-json-task-keys-kind-and-wait` asserts the new set.

Not superseded, but bearing on the implementation: `task-board-rows-with-and-without-a-body-line-up` requires a row with an entry and a row without one to have the same number of cells, so kind and need shown as tags must not add a cell only to entry rows. `task-board-forge-read-in-full-no-mark` forbids `not checked` on an entry's row under a full read, which the new warning respects as specified (it is given only where `forge` is not `full`).

## Missing shared arrangement

The dispatch names no shared test arrangement: this repository records no location for one (its backlog holds `record-this-repositorys-shared-test-arrangement`), so no entry below has a proposed home to name. The cases source `tests/lib.sh` (via `$TESTLIB`) and `tests/task-board-lib.sh`, which lie outside the test-path glob and which the dispatch named as the helpers existing cases source; everything else they need is declared in the case itself.

1. **JSON reader: `STDOUT`, `STDERR`, `board_json`, `jv`, `require_parser`, `doc`, `jis`** — declared in each of the ten `task-board-json-*` cases this pass added (`task-board-json-task-kind-need-typed-condition`, `-task-need-default`, `-waits-on-done-blocked`, `-wait-cleared-by-merged-fix`, `-condition-is-a-wait`, `-parked-after-the-wait`, `-no-readiness-in-flight-or-done`, `-unchecked-named-wait`, `-merged-fix-partial-read`, `-task-keys-kind-and-wait`). Stands in for: running `scripts/task-board --json` with its streams apart and reading a value of the document by path. Near-miss in `tests/task-board-lib.sh`: `board_in` runs the tool but sends both streams to one `$REPORT`, so the document cannot be parsed. Found in test modules: copied verbatim from `tests/cases/task-board-json-task-status.sh` (every earlier `task-board-json-*` case declares the same). Proposed home: none named.
2. **`entry_raw`** — declared in `task-board-json-task-kind-need-typed-condition` and `task-board-entry-kind-and-need`. Stands in for: writing an entry whose frontmatter is exactly the lines given. Near-miss: `tests/task-board-lib.sh`'s `entry` always writes `kind: change` as the first key, so an entry of another kind (`fix`, or a value outside the set) cannot be written without a duplicate key. Not found in a test module. Proposed home: none named.
3. **Scan machinery: `scan`, `sc_section`, `sc_text`, `sc_check`, `sc_mutate`, `sc_discriminate`, `sc_run`** — declared in `backlog-dir-seeded-need-values`, `backlog-dir-seeded-need-step-not-must`, `backlog-dir-seeded-waits-for-types`, `backlog-dir-seeded-untyped-condition-valid`, `backlog-skill-record-need`, `backlog-skill-record-types-condition`, `backlog-skill-pick-need-order`, `backlog-skill-audit-waits-for-type`, `backlog-skill-older-shape-untyped-condition`. Stands in for: scanning a section of a Markdown file for stated properties, with a mutant per scan proving it can fail. Found in a test module: `tests/cases/lib/static-scan.sh`, which lies inside the test-path glob and is named as shared arrangement by no convention file or the dispatch, so this pass did not source it; the local copy is a trimmed version of it (no `@description` region) whose `sc_run` takes the root to check, so the same machinery serves the seeded block under a `project-init` target as well as `$TOOLKIT_ROOT`. Proposed home: none named.
4. **`fenced_fm_keys`, `check_keys`** — declared in `backlog-dir-seeded-structured-keys-need-and-type`; **`fenced_fm_keys`, `fenced_item_line`, `check_list`** — declared in `backlog-dir-seeded-fields-are-a-list-with-need`. Stand in for: reading the seeded block's fenced example entry. Found in test modules: `tests/cases/backlog-dir-seeded-structured-keys.sh` and `tests/cases/backlog-dir-seeded-fields-are-a-list.sh`, revised here for the eleven keys and the four reasons. No near-miss outside the glob. Proposed home: none named.
5. **`need_left_alone`** — declared in `backlog-skill-audit-waits-for-type`. Stands in for: holding that every line of a file naming `` `need` `` negates it. Not found elsewhere; no near-miss. Proposed home: none named.

## Unresolved project questions

1. **Where the shared test arrangement is.** Neither `AGENTS.md`, `tests/README.md` nor `tests/coverage.md` names a shared test arrangement or states there is none; `tests/README.md` describes `tests/lib.sh` and `tests/task-board-lib.sh` as helpers, and `tests/cases/lib/static-scan.sh` describes itself as "shared machinery". Assumption taken: the two files outside the glob may be sourced; `tests/cases/lib/*` may not, being inside the glob. Depending on it: every case in *Missing shared arrangement* entries 1, 3 and 4.
2. **Stack skill.** The library carries `bash`, loaded for this pass. Following the project's existing cases rather than that skill's preamble, the new cases do not `set -euo pipefail` — no existing case does, and each failure exits through `die` or an assertion helper explicitly. Depending on it: all 25 cases.
3. **The page's form for a done name and a typed condition.** The specification says "marked done" and "with `decision` before it"; the cases read design.md decision 9's form tolerantly (see *Derived*). Depending on it: `task-board-entry-waits-on-done`, `task-board-entry-typed-condition`, `task-board-entry-unchecked-wait-warned`.

## Findings in the artifacts

No instruction addressed to the test author was found in the change's artifacts.
