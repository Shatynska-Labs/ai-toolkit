# Test plan: list-the-entry-fields

Derived by `ai-toolkit:change-test-writer` from the delta specs at plan commit `d9f752b`, before implementation. This file is not an artifact the OpenSpec schema defines; `openspec instructions apply` does not surface it.

## Running a case

`tests/run.sh` runs every case and has no per-case selection (see *Unresolved project questions*, Q1). A single case runs from the worktree root with the environment `run.sh` exports:

```
d=$(mktemp -d); TOOLKIT_ROOT=$PWD TESTLIB=$PWD/tests/lib.sh PROJECT_INIT=$PWD/scripts/project-init TESTDIR=$d bash tests/cases/<case>.sh; rm -rf "$d"
```

Every case below is named by its file stem under `tests/cases/`; substitute it for `<case>`.

## Baseline

Full suite, `bash tests/run.sh`, at `d9f752b` before any case was written: **185 passed, 0 failed**.

After writing: **190 passed, 10 failed**. The 10 failures are exactly the 10 new red cases below; the 5 new green cases are the `backlog-seeded-item-*` replacements. No existing case changed state.

## What the implementation must make pass

| Task | Cases that must go from failing to passing |
|---|---|
| 1.1 seeded backlog | `backlog-seeded-fields-are-a-list`, `backlog-seeded-absent-values`, `backlog-seeded-workstream-default-none` |
| 1.2 seeded workstream README | `workstreams-seeded-fields-are-a-list`, `workstreams-seeded-abandoned-item` |
| 2.1 skill | `backlog-skill-record-absent-value`, `backlog-skill-pick-no-workstream`, `backlog-skill-sweep-absent-value`, `backlog-skill-older-shape-earlier-nothing`, `backlog-skill-older-shape-paragraph-fields` |
| 3.1 `fenced_line` | `backlog-seeded-workstream-field` (existing; goes red at 1.1, back to green once `fenced_line` accepts the list marker) |

These must stay green throughout: `backlog-seeded-item-priority-values`, `backlog-seeded-item-kind-definition`, `backlog-seeded-item-priority-transitions`, `backlog-seeded-item-priority-no-low`, `backlog-seeded-item-priority-statements` (green at authoring, see below), and every existing case not listed under *Obsolete tests*.

Failure state at authoring: every red case fails on its asserted property, not on its machinery — the seeded cases on the paragraph layout or on `nothing` (state 1, the tool runs and produces the superseded shape); the `static-scan` cases with status 1 on the named scans; the two `line-scan` cases with status 2, no paragraph matching their selectors yet (target absent). The red-at-authoring record for the static reads: each is red on the property its scans name, as listed in its own header.

## Scenario accounting

46 scenarios in the delta specs (19 `project-bootstrap`, 27 `backlog-maintenance`), all `MODIFIED`. 46 accounted for below. "In part" means the case reads the stated text and not a session's conduct.

### project-bootstrap — A backlog is seeded where none exists (11)

| Scenario | Covered by |
|---|---|
| A project without a backlog receives the seeded file | Existing `backlog-seeded-new-project`, `backlog-seeded-adoption`, `backlog-seeded-structured-statements`; new statement (fields as one list) by `backlog-seeded-fields-are-a-list`; the Priority-line statements by `backlog-seeded-item-priority-statements` (replaces obsolete `backlog-seeded-priority-statements`) |
| An existing backlog is preserved exactly | Existing `backlog-existing-preserved`, `backlog-dangling-symlink-not-written-through` (unchanged by this delta) |
| The seeded file carries no numbering | Existing `backlog-seeded-no-entry-numbering` (unchanged) |
| The seeded entry shape carries the structured fields | Existing `backlog-seeded-structured-fields`, `backlog-seeded-workstream-field` (after task 3.1); all seven names and their order by `backlog-seeded-fields-are-a-list` (replaces obsolete `backlog-seeded-priority-field`) |
| A fix is distinguished from a change by what it owes | `backlog-seeded-item-kind-definition` (replaces obsolete `backlog-seeded-kind-definition`) |
| Priority's values and default are stated | `backlog-seeded-item-priority-values` (replaces obsolete `backlog-seeded-priority-values`) |
| The seeded file offers no low priority | `backlog-seeded-item-priority-no-low` (replaces obsolete `backlog-seeded-priority-no-low`) |
| The seeded file states how an entry leaves parked and high | `backlog-seeded-item-priority-transitions` (replaces obsolete `backlog-seeded-priority-transitions`) |
| Workstream's default is stated | `backlog-seeded-workstream-default-none` (revised THEN; replaces obsolete `backlog-seeded-workstream-default`) |
| The seeded entry's fields are a list | `backlog-seeded-fields-are-a-list` |
| An absent value reads as its field | `backlog-seeded-absent-values` |

### project-bootstrap — A workstream register is seeded where none exists (8)

| Scenario | Covered by |
|---|---|
| A project without a workstream register receives the seeded file | Existing `workstreams-seeded-new-project`, `workstreams-seeded-adoption`, `workstreams-seeded-statements`; revised shape statement by `workstreams-seeded-fields-are-a-list`; revised abandonment statement ("item after Opened") by `workstreams-seeded-abandoned-item` |
| An existing workstream register is preserved exactly | Existing `workstreams-existing-preserved`, `workstreams-dangling-symlink-not-written-through` (unchanged) |
| The seeded register carries no status field | Existing `workstreams-seeded-no-status-field` (reads `**<label>**` anywhere in the fence, so it holds in the list layout) |
| An abandoned workstream is archived, not deleted | Existing `workstreams-seeded-abandoned` (scenario text unchanged); `workstreams-seeded-abandoned-item` bears on it |
| A finished workstream is archived | Existing `workstreams-seeded-archive-on-done` (unchanged) |
| A step matching two sources takes the first status | Existing `workstreams-seeded-precedence` (unchanged) |
| Step order is not a dependency | Existing `workstreams-seeded-order-gates-nothing` (unchanged) |
| The seeded workstream's fields are a list | `workstreams-seeded-fields-are-a-list` |

### backlog-maintenance — Record writes an entry the file can be relied on for (7)

| Scenario | Covered by |
|---|---|
| A name already used by an archived change | Existing `backlog-skill-record` (unchanged), in part |
| An overlapping entry exists | Existing `backlog-skill-record`, in part; the revised absent value for Design with by `backlog-skill-record-absent-value` (`dw-absent-value`), in part |
| Work the change can fold in | Existing `backlog-skill-record-fold-in` (unchanged), in part |
| Record defaults Priority | Existing `backlog-skill-record-priority` (unchanged), in part |
| Record parks an entry only on the operator's word | Existing `backlog-skill-record-priority` (unchanged), in part |
| Record carries the change's workstream | `backlog-skill-record-absent-value`, in part (also existing `backlog-skill-record-workstream`, listed obsolete for one scan) |
| Record refuses a workstream that is not open | `backlog-skill-record-absent-value` (`ws-open-only`, `ws-absent-value`, `names-none`), in part — revised THEN |

### backlog-maintenance — Pick lists what can be taken now (11)

| Scenario | Covered by |
|---|---|
| A blocked entry is not offered | Existing `backlog-skill-pick` (unchanged), in part |
| A wait already satisfied but not updated | Existing `backlog-skill-pick` (unchanged), in part |
| Pick narrowed to files | Existing `backlog-skill-pick` (unchanged), in part |
| A parked entry is not offered as takeable | Existing `backlog-skill-pick-priority` (unchanged), in part |
| A parked entry whose condition holds | Existing `backlog-skill-pick-priority` (unchanged), in part |
| A parked entry still waiting | Existing `backlog-skill-pick-priority` (unchanged), in part |
| High entries come first | Existing `backlog-skill-pick-priority` (unchanged), in part |
| Pick lists a workstream's entries in step order | Existing `backlog-skill-pick-workstream` (unchanged), in part |
| A high step leads its workstream's group | Existing `backlog-skill-pick-workstream` (unchanged), in part |
| An unplaced entry is shown under its workstream | Existing `backlog-skill-pick-workstream` (unchanged), in part |
| An entry naming no workstream is grouped apart | `backlog-skill-pick-no-workstream`, in part |

### backlog-maintenance — Sweep performs the archive step's re-read (6)

| Scenario | Covered by |
|---|---|
| An entry finished without being named | Existing `backlog-skill-sweep` (unchanged), in part |
| Sweep after a squash merge | Existing `backlog-skill-sweep` (unchanged), in part |
| Sweep after the record has landed | Existing `backlog-skill-sweep` (unchanged), in part |
| A change fulfils a parked entry's condition | Existing `backlog-skill-sweep-priority` (unchanged), in part |
| A change removes a high entry's evidence | Existing `backlog-skill-sweep-priority` (unchanged), in part |
| Entries naming a workstream being archived | Existing `backlog-skill-sweep-workstream` (its scans still hold); revised THEN by `backlog-skill-sweep-absent-value`, in part |

### backlog-maintenance — Entries in an older shape are reported, not rewritten (3)

| Scenario | Covered by |
|---|---|
| Pick meets an entry with no Kind | Existing `backlog-skill-older-shape-unclassified` (unchanged), in part |
| Pick meets an entry with no Priority | Existing `backlog-skill-older-shape-priority-default` (unchanged), in part |
| An earlier absent value is read as the current one | `backlog-skill-older-shape-earlier-nothing`, in part; the requirement's added sentence on paragraph fields by `backlog-skill-older-shape-paragraph-fields` |

Uncovered: none. The unreachable half of every "in part" row is what a session does when it runs the operation, which no program here runs.

## Assertion classification

| Case | Specified | Derived | Deliberately untested |
|---|---|---|---|
| `backlog-seeded-fields-are-a-list` | seven fields as list items `- **Priority**` … `- **Re-checked**`, one per field, requirement order, no blank line between | fenced example is the shape; one line per item, so the seven occupy seven adjacent lines; the list follows a prose line (design decision 2) | — |
| `backlog-seeded-absent-values` | Waits on `nothing`; Design with and Workstream `none` | the field line found with or without `- `; Design with and Workstream must not carry the word `nothing` at all | — |
| `backlog-seeded-workstream-default-none` | recording change's workstream unless another goal; without the field is `none`; by name | exact phrases from design decision 2's item text | — |
| `backlog-seeded-item-*` (5) | as the obsolete case each carries (listed in its header) | as that case's, plus the reader accepting either layout | as that case's |
| `workstreams-seeded-fields-are-a-list` | Not in scope, Open questions, Decisions, Opened as consecutive list items after the steps, in order; `none` as absent value; Goal and Done when as paragraphs | one line per item; "after the steps" = after the `**Steps**` line; `none` bound to the three fields that can be empty, not Opened; none of the three may carry `nothing` | — |
| `workstreams-seeded-abandoned-item` | Abandoned is an item after Opened, with date and reason | stated in a paragraph outside the fence (design decision 2) carrying `item`, `after … Opened`, `date`, `reason` | — |
| `backlog-skill-record-absent-value` | Design with and Workstream take the file's absent value; open-workstream-only; default to the change's workstream; archived names checked; gated on the shape naming Workstream | section under a heading naming `record`; one-sentence co-occurrence scans; `none` named in the section (design decision 4) | record writes `nothing` where the preamble still says it (conduct) |
| `backlog-skill-pick-no-workstream` | no-workstream entries — absent value or earlier `nothing` — grouped as before | section under `pick`; one-sentence co-occurrence scans | not listed as a workstream named `none` nor as unplaced (conduct) |
| `backlog-skill-sweep-absent-value` | re-pointed or set to the file's absent value | section under `sweep`; one-sentence co-occurrence; forbid "set to `nothing`" (design decision 4) | that sweep presents the entries (conduct) |
| `backlog-skill-older-shape-earlier-nothing` | earlier `nothing` read as the absent value, not a name, unplaced or unclassified | one line of SKILL.md (whole file) carrying `nothing`, `earlier`/`older`, `absent value`/`none`, `workstream`, and `unclassified`/`unplaced`/`as a name` | that pick and workstreams read it so (conduct) |
| `backlog-skill-older-shape-paragraph-fields` | paragraph fields read the same as listed ones (requirement text) | one line carrying `paragraph`, `list` and `same`/`alike`/`either` | that an operation reads them so (conduct) |

Not derived into a case: task 2.2's edit to `skills/backlog/references/audit.md` (no modified requirement or scenario covers the audit report's wording; tasks.md says "verify by reading").

Discrimination: the five static-scan and line-scan cases run `scan_discriminate`/`line_discriminate` (one mutant per scan). The seeded-file cases execute the tool; the four new red ones check their own local parser against conforming and violating specimens before reading the tool's output, and the five `item-*` cases check that their reader finds a field in both layouts, so their green at authoring cannot come from a reader that reads nothing.

## Obsolete tests

Every entry is a **candidate for human confirmation** at `apply`, not a conclusion. Found by searching `tests/cases/**` for `**<label>**` extraction at line start, `fenced_line`, and `nothing` beside Design with or Workstream, guided by design.md decision 5. None was edited, deleted or disabled.

| Case | Superseded by | Evidence |
|---|---|---|
| `backlog-seeded-priority-field` | project-bootstrap *A backlog is seeded…*, MODIFIED — fields as a list (scenario *The seeded entry's fields are a list*) | declares its own `fenced_line` matching `index($0, "**" label "**") == 1`, which a `- **Priority**` item does not satisfy; its Priority-before-Kind order is asserted by `backlog-seeded-fields-are-a-list` |
| `backlog-seeded-priority-values` | same | extracts `/^\*\*Priority\*\*/` inside the fence; carried by `backlog-seeded-item-priority-values` |
| `backlog-seeded-kind-definition` | same | extracts `/^\*\*Kind\*\*/`; carried by `backlog-seeded-item-kind-definition` |
| `backlog-seeded-priority-transitions` | same | extracts `/^\*\*Priority\*\*/`; carried by `backlog-seeded-item-priority-transitions` |
| `backlog-seeded-priority-no-low` | same | extracts `/^\*\*Priority\*\*/`; carried by `backlog-seeded-item-priority-no-low` |
| `backlog-seeded-priority-statements` | same | extracts `/^\*\*Priority\*\*/` for the fold-in clause; carried by `backlog-seeded-item-priority-statements` |
| `backlog-seeded-workstream-default` | same requirement — layout, and absent value `none` (scenario *Workstream's default is stated*, revised THEN) | extracts `/^\*\*Workstream\*\*/` and requires the phrase ``An entry without this field is `nothing` ``; carried by `backlog-seeded-workstream-default-none` |
| `backlog-skill-record-workstream` | backlog-maintenance *Record writes an entry…*, MODIFIED — absent value is the file's (`none` in the seeded file) | scan `ws-or-nothing` requires `workstream[^.]*nothing\|nothing[^.]*workstream` in the record section; its other four scans still hold and are repeated in `backlog-skill-record-absent-value` |

**Disposition at `apply`: all eight confirmed obsolete and deleted.** Each asserts the paragraph layout, or `nothing`, which the modified requirements replace. Each is red against the implemented text for that reason alone. Each assertion that still holds is carried unchanged by its successor named above: the five `backlog-seeded-item-*` cases, `backlog-seeded-workstream-default-none`, and `backlog-skill-record-absent-value`, which repeats `backlog-skill-record-workstream`'s four surviving scans. No coverage is lost.

Searched and judged **not** obsolete:

- `backlog-seeded-workstream-field` — will fail at task 1.1 (it calls `tests/lib.sh`'s `fenced_line`, which does not accept `- `), but its assertion (Workstream between Design with and Recorded by) is not superseded; task 3.1's extension of `fenced_line` restores it, per design decision 5.
- `backlog-skill-sweep-workstream` — its header says "set to `nothing`", but its scans (`archiv`, `re-point`) assert nothing superseded. Its header comment is stale.
- `workstreams-seeded-no-status-field`, `workstreams-seeded-abandoned` — read `**<label>**` anywhere / the first `**Abandoned**` line; both hold under the list layout as far as this search can tell. Risk: if the seeded README puts a fenced `- **Abandoned**: …` line before the abandonment paragraph, `workstreams-seeded-abandoned` (`grep … | head -n1`) would read that line instead and fail; that would be an arrangement of the file, not a superseded assertion.

## Missing shared arrangement

The shared arrangement named by the dispatch is `tests/lib.sh` and `tests/cases/lib/` (`static-scan.sh`, `line-scan.sh`). The static and line scans used them unchanged. Three local declarations, all near-misses of `tests/lib.sh`'s `fenced_line`:

| Declared | In | Stands in for | Used by | Near-miss | Found in another test module | Proposed home |
|---|---|---|---|---|---|---|
| `fenced_item_line FILE LABEL` — line number of the first fenced line beginning `- **LABEL**` | `backlog-seeded-fields-are-a-list` | locating a list-form field in a fenced shape | `backlog-seeded-fields-are-a-list` | `fenced_line`: requires `**LABEL**` at column 1, so it cannot see a list item, nor require the marker | no | `tests/lib.sh`, as a strict mode of `fenced_line` (task 3.1 makes it accept the marker but optional; this case needs it required) |
| `fenced_field FILE LABEL` — the first fenced line beginning `**LABEL**` or `- **LABEL**`, as text | `backlog-seeded-absent-values`, `backlog-seeded-workstream-default-none`, `backlog-seeded-item-priority-values`, `backlog-seeded-item-kind-definition`, `backlog-seeded-item-priority-transitions`, `backlog-seeded-item-priority-no-low`, `backlog-seeded-item-priority-statements` (declared in each) | reading a field's definition whichever layout | those seven cases | `fenced_line`: returns a line number, not the line, and does not accept `- ` | no (the obsolete cases inline an awk equivalent of the paragraph-only form) | `tests/lib.sh`, beside `fenced_line` once task 3.1 lets it accept the marker (e.g. a `fenced_field` returning the line) |
| `fenced_prefixed_line FILE PREFIX LABEL` — line number of the first fenced line beginning `PREFIX**LABEL**` | `workstreams-seeded-fields-are-a-list` | requiring a field to be a paragraph (`""`) or a list item (`"- "`) | `workstreams-seeded-fields-are-a-list` | `fenced_line`: prefix fixed to none | no | `tests/lib.sh`; it generalises both `fenced_line` and `fenced_item_line` |

The specimen-checking functions (`check_list`, `check_shape`, `check`, `abandonment`) are each case's own assertion logic, not arrangement.

**Dispositions at `apply`:**
- `fenced_field` (in the two red backlog seeded cases and the five `item-*` cases): **kept local.** `AGENTS.md` records no shared test arrangement, so nothing can be promoted into one. Creating or recording one is a testing-strategy decision, not a step of this change, and the backlog's `record-this-repositorys-shared-test-arrangement` is the change that would make it. The seven identical copies are the cost, and that entry is where they would be consolidated.
- `fenced_item_line` (`backlog-seeded-fields-are-a-list`): **kept local.** It requires the `- ` marker, which is this one case's assertion, and no other case needs it.
- `fenced_prefixed_line` (`workstreams-seeded-fields-are-a-list`): **kept local**, for the same reason: one case, one assertion-bearing variant.
- `fenced_line` itself, extended in `tests/lib.sh` to accept a list marker (task 3.1), keeps `backlog-seeded-workstream-field` green.

## Unresolved project questions

- **Q1 — selecting one case.** `tests/run.sh` takes no argument and runs every case; the conventions name no way to run one. Assumed: the env-var invocation under *Running a case*, mirroring what `run.sh` exports. All cases above depend on it for individual selection, none for correctness.
- **Q2 — stack skill.** The library carries a `bash` skill and it was loaded. Its `set -euo pipefail` preamble is not used: every existing case omits it and asserts explicitly, and the new cases follow the project's style. Reported as a conflict, resolved in the project's favour.
- **Q3 — older-shape heading.** Design decision 4 places the new reading under *Entries in an older shape*, but no case establishes that SKILL.md has such a heading, so the two older-shape cases read the whole file. Assumed: whole-file reading, as `backlog-skill-older-shape-unclassified` does. Depends: `backlog-skill-older-shape-earlier-nothing`, `backlog-skill-older-shape-paragraph-fields`.
- **Q4 — "consecutive" and one line per item.** The requirement says "no blank line between"; the cases read it as one line per item with nothing else between, from AGENTS.md's rule that a list item is one line. Depends: `backlog-seeded-fields-are-a-list`, `workstreams-seeded-fields-are-a-list`.

No instruction addressed to the test author was found in the change's artifacts.
