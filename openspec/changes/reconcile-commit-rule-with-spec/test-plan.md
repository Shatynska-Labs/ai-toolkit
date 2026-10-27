# Test plan: reconcile-commit-rule-with-spec

Written by `change-test-writer` from the delta spec at `specs/session-workflow/spec.md` (plan committed at 7c56865). This file is not an artifact the OpenSpec schema knows about; it will not appear among `openspec instructions apply`'s context files and must be read on purpose.

Run any case by name: `bash tests/run.sh <case-name>` from the worktree root.

## Baseline

Full suite, taken before any case was written: `bash tests/run.sh` — 243 passed, 0 failed.

After this pass: 246 passed, 2 failed. The two failures are the new `session-workflow-publication-names-third-owner` and `session-workflow-purpose-names-third-owner`, red as expected (see below). No existing case changed result.

## New cases

All five are static reads (the third situation in `testing`): each runs a fixture-driven discriminator first, one mutant per scan, requiring every scan to reject its own mutant with its own tag, then checks the real target.

| Case | Target | Result at authoring |
|---|---|---|
| `workflow-fragment-handoff-branch-committed` | `rules/development-workflow.md` | green (the fragment already carries the rule, per design.md Context) |
| `workflow-fragment-prose-one-line` | `rules/development-workflow.md` | green (same) |
| `workflow-fragment-prose-structure-exception` | `rules/development-workflow.md` | green (same) |
| `session-workflow-publication-names-third-owner` | `openspec/specs/session-workflow/spec.md`, requirement *The session obligations are published…* | red, state 1 on real content: scans `owner-code-review`, `binding-content`, `owner-rest` fail. Goes green when the delta merges at archive. Checked: the same scans pass over the delta's text substituted for the main spec. |
| `session-workflow-purpose-names-third-owner` | `openspec/specs/session-workflow/spec.md`, `## Purpose` | red, state 1 on real content: scans `code-review-named`, `binding-content` fail. Goes green when task 2.1 lands. |

The three fragment cases report only a failing scan's tag, never the fragment's text, so this pass did not read the fragment through test output.

## Scenario accounting

The delta has 19 scenarios: 6 under the first MODIFIED requirement, 11 under the second, 2 under the ADDED requirement. All 19 are accounted for below.

### MODIFIED: The session obligations are published in the workflow fragment and one binding fragment

| # | Scenario | Status | Cases |
|---|---|---|---|
| 1 | A session obligation is stated once | text unchanged by this delta; existing coverage stands | `workflow-fragment-publication-set` (existing) |
| 2 | A reader of a project's conventions finds no dangling reference | unchanged; existing coverage stands | `workflow-fragment-no-dangling-reference` (existing) |
| 3 | A fragment names only agents and skills the library ships | unchanged; existing coverage stands | `workflow-fragment-names-shipped-assets` (existing) |
| 4 | A project without a deploy is not served by a conditional | unchanged; existing coverage stands | `workflow-fragment-states-assumptions` (existing) |
| 5 | A second publication does not arrive unowned | **uncovered**: the text is unchanged by this delta, and this search of `tests/cases/**` found no existing case naming it. It concerns a publication that does not exist yet, so there is nothing to scan. Not derived here because this change does not touch it. | none |
| 6 | An editor learns every owner of the fragment's content from this capability | **covered** (new) | `session-workflow-publication-names-third-owner` |

### MODIFIED: A second change surfacing in a session is recorded in the backlog

| # | Scenario | Status | Cases |
|---|---|---|---|
| 7 | A blocking dependency survives the session ending | **uncovered**: unchanged by this delta; this search found no existing case naming it. Its observable is in a change's own artifacts at session end, not in a static text. Not derived here because this change does not touch it. | none |
| 8 | An unrelated improvement is recorded rather than implemented | unchanged; existing coverage stands | `workflow-fragment-backlog-dir-routing-owed`, `workflow-fragment-second-change-excludes-folded`, `workflow-fragment-backlog-dir-path` (existing) |
| 9 | A backlog entry is cited by name | unchanged; existing coverage stands | `workflow-fragment-backlog-dir-defers`, `workflow-fragment-backlog-dir-readme-states-rules` (existing) |
| 10 | The scope rule and the backlog are one obligation | unchanged; existing coverage stands | `workflow-fragment-second-change-excludes-folded` (existing) |
| 11 | The backlog does not yet exist | unchanged; existing coverage stands | `workflow-fragment-backlog-dir-defers` (existing) |
| 12 | Entry rules are read from the backlog, not the fragment | unchanged; existing coverage stands | `workflow-fragment-backlog-dir-defers`, `workflow-fragment-backlog-dir-readme-states-rules`, `workflow-fragment-backlog-dir-path` (existing) |
| 13 | An identified change is opened without a proposal | unchanged; existing coverage stands | `workflow-fragment-backlog-dir-handoff` (existing) |
| 14 | A handoff is not left uncommitted on a branch the session leaves | **covered** (new, revised THEN: "it has committed that branch already") | `workflow-fragment-handoff-branch-committed` |
| 15 | An opened-and-left branch does not become the session's working branch | unchanged; existing coverage stands | `workflow-fragment-backlog-dir-handoff` (existing) |
| 16 | A deferral outlives the change that recorded it | unchanged; existing coverage stands | `workflow-fragment-backlog-dir-readme-states-rules` (existing) |
| 17 | Recording is stated as what is owed | unchanged; existing coverage stands | `workflow-fragment-backlog-dir-routing-owed`, `workflow-fragment-backlog-dir-path` (existing) |

I mapped the "existing coverage stands" rows from each existing case's header comment. I did not re-derive them, because their text in the delta is the same as in the main spec. I checked this with a diff of the two requirements: the only changes are the seam paragraphs, the commit clause, the modification note, scenario 6 (new) and scenario 14's THEN.

### ADDED: Fragment prose is not hard-wrapped

| # | Scenario | Status | Cases |
|---|---|---|---|
| 18 | A session writing prose keeps a paragraph on one line | **covered**, mechanical half only (the fragment "has told it so") | `workflow-fragment-prose-one-line` |
| 19 | Markdown structure still takes its own line breaks | **covered**, mechanical half only (the direction excepts Markdown's own structure and lists no more) | `workflow-fragment-prose-structure-exception` |

Behavioural halves left uncovered: whether a session actually commits the branch, keeps a paragraph on one line, or breaks lines for a structure. Nothing executable produces that behaviour, so a shell case cannot observe it.

## Assertion classification

`workflow-fragment-handoff-branch-committed`. Lines are selected by `handoff`.
- `commit-branch` (require `commit (that|the|this|its) (handoff |new )?branch`): specified ("SHALL direct committing that branch"). The regex is a derived lexical proxy.
- `at-once` (require `at once|immediately|as soon as`): specified ("as soon as it is opened"). The regex is a derived proxy.
- `no-proposed-commit` (forbid `propos(e|es|ed|ing) (a )?commit`): specified ("The commit is made, not proposed").
- `no-declined-path` (forbid `declin|unsaved`): specified ("the fragment states no path for a declined one"). `unsaved` is derived from the superseded text ("report that the handoff is unsaved and stop").
- Line selection by `handoff`: derived (Q1).

`workflow-fragment-prose-one-line`. Lines are selected by `markdown prose|hard[- ]?wrap`.
- `negated` (require a negation before `hard-wrap`): specified ("Markdown prose is not hard-wrapped").
- `one-line` (require `single line|one line`): specified ("each paragraph is kept on a single line").
- That the direction is an imperative: **deliberately untested**. No lexical rule reliably separates an imperative from a declarative here.

`workflow-fragment-prose-structure-exception`. Same selection.
- `structure-exception` (require `markdown.?.?s own (line )?structure`): specified ("a line break is used only where Markdown's own structure requires one"). The wording is derived from the fragment phrase quoted in design.md decision 3.
- `no-enumeration` (forbid frontmatter / code block(s) / fenced / table(s) as whole words): specified ("SHALL NOT enumerate the structures it leaves alone beyond Markdown's own line structure"). The word list is derived from AGENTS.md's own enumeration, the likeliest source of drift.

`session-workflow-publication-names-third-owner`. Section: the requirement's heading in the main spec.
- `owner-bootstrap`, `owner-code-review`, `binding-content`, `owner-rest`: specified (scenario 6's THEN). The regexes are derived from the delta's wording. Each is matched independently, not as one sentence (derived).

`session-workflow-purpose-names-third-owner`. Section: `## Purpose`.
- `bootstrap-named`, `code-review-named` (whole-name, so `change-code-reviewer` does not satisfy it), `binding-content`: these trace to proposal.md, design.md decision 2 and task 2.1, not to a delta scenario. That makes them derived with respect to the delta, recorded here for that reason.

## Discriminators

Every scan in every new case is discriminated in the suite on each run. A conforming fixture must pass. Then, for each scan, one mutant must be rejected with status 1 and that scan's own tag: a require scan has its matches redacted, and a forbid scan has a specimen line added that trips it. All discriminators passed at authoring. None came back negative.

The two red cases are also observed failing on real content, on the properties named in the table above. The ordinary suite result is the confirmation when they go green.

## Obsolete tests

The superseded behaviour is in the second MODIFIED requirement: the fragment directed *proposing* a commit on the handoff branch, stated a declined path ("report that the handoff is unsaved and stop"), and scenario 14 expected "it has proposed a commit". The first MODIFIED requirement supersedes the seam sentence "This capability owns what the session-derived rules say" and "The seam is stated because both capabilities bear on one file".

I searched `tests/cases/**` for `propos… commit`, `declin`, `unsaved`, `handoff`, `change-code-review` and `owner`. No earlier `test-plan.md` was supplied.

- **None found by this search.** No case in `tests/cases/**` asserts a proposed handoff commit, a declined-commit path, or a two-owner seam. Matches on `declin` were `project-init-skill-declined-*` and the `workflow-fragment-fold-in-*`/`no-mandated-ledger` cases. On their names and match context they concern other requirements (project-init's commit offer, the fold-in rule), so I did not list them. `workflow-fragment-backlog-dir-handoff` reads the same lines but asserts nothing about committing. This is "none found by this search", not "none exists": tests outside `tests/cases/**`, and any mapping in an earlier change's `test-plan.md`, were not searched.

## Unresolved project questions

- **Q1 — lexical proxies and line selection for fragment rules.** The convention files do not say how a case should locate a rule in the fragment. I assumed the fragment keeps one paragraph per line (AGENTS.md's prose rule) and selected lines by a keyword (`handoff`; `markdown prose|hard-wrap`). This assumes the handoff commit direction sits on a line naming the handoff. Depends on it: `workflow-fragment-handoff-branch-committed`, `workflow-fragment-prose-one-line`, `workflow-fragment-prose-structure-exception`.
- **Q2 — the requirement-half case is red until archive, which conflicts with task 3.2.** Task 3.2 requires `bash tests/run.sh` to pass before archive. `session-workflow-publication-names-third-owner` reads the main spec, which takes the delta only at archive, so it stays red through 3.2. I assumed the case should read the main spec: after archive the change directory moves, so a case reading the delta would break. Depends on it: `session-workflow-publication-names-third-owner`. Either task 3.2's expectation or this case's target needs a decision. This is a planning-artifact question for `openspec-update-change`, not something this pass changed.
- **Q3 — stack skill.** `bash` was loaded. Existing cases carry no `set -euo pipefail` preamble: they are run by `tests/run.sh` and exit on an explicit status. The new cases follow that project style rather than the skill's preamble, and handle each check's status explicitly. All five pass `shellcheck`, with every `disable` naming its code and reason. No skill covers static-scan testing specifically. Depends on it: all five new cases.

## Missing shared arrangement

Dispatched shared arrangement: `tests/lib.sh`, `tests/cases/lib/static-scan.sh`. The two spec-reading cases use `static-scan.sh` unchanged. The shared arrangement was not written to.

- **`lscan` / `lselect` / `lcheck` / `ldiscriminate`** (with arrays `MODES`, `TAGS`, `RES`, `SPECS`), declared in each of `tests/cases/workflow-fragment-handoff-branch-committed.sh`, `tests/cases/workflow-fragment-prose-one-line.sh` and `tests/cases/workflow-fragment-prose-structure-exception.sh`.
  - Stands in for: a require/forbid scan over the lines of a file selected by a regex, with a mutant-per-scan discriminator. Failures report tags only.
  - Used by: `workflow-fragment-handoff-branch-committed`, `workflow-fragment-prose-one-line`, `workflow-fragment-prose-structure-exception`.
  - Near-miss in the shared arrangement: `static-scan.sh`. It scopes a scan only to the whole file, the frontmatter description, or a section under a heading named by a word. The rules under test have no heading of their own that this pass could name without reading the fragment. A whole-file scan would let a matching phrase elsewhere satisfy, or trip, the check. Its forbid failure also prints the matched text, which would have shown this pass the fragment's content.
  - Found in another test module: `tests/cases/lib/line-scan.sh` (used by `workflow-fragment-fold-in-own-commit.sh`) appears to offer a line-selected scan. It is not part of the dispatched shared arrangement, so it was not imported or read, and the arrangement was declared locally.
  - Proposed home: `tests/cases/lib/static-scan.sh` (a line-selector `WHERE` mode and a tags-only failure mode), or promoting `tests/cases/lib/line-scan.sh` into the named shared arrangement.

## Dispositions

- **Q2** — resolved: `session-workflow-publication-names-third-owner` keeps reading the main specification. During the work it is held at `held/` in this change directory, outside `tests/cases/`, so the work's pull request passes `bash tests/run.sh`; the archive commit moves it into `tests/cases/`, beside the record that makes it pass (tasks.md 3.2).
- **Missing shared arrangement, `lscan` / `lselect` / `lcheck` / `ldiscriminate`** — kept local in each of the three fragment cases. Reason: `AGENTS.md` records no shared test arrangement's location, so the fragment's rule keeps every entry; whether `tests/cases/lib/line-scan.sh` or `static-scan.sh` is shared arrangement is the decision `record-this-repositorys-shared-test-arrangement` holds. Each case was checked red against a fragment mutated to propose the handoff commit or to wrap prose, and restored with `git restore`.
