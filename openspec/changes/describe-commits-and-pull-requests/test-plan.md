# Test plan: describe-commits-and-pull-requests

Written by `ai-toolkit:change-test-writer` before implementation. This file is not an artifact the OpenSpec schema knows about: it does not appear among `openspec instructions apply`'s context files and must be read on purpose.

Run every case this pass wrote, from the repository root:

```
bash tests/run.sh commits-and-pull-requests-skill-precedence commits-and-pull-requests-skill-names-no-commit-convention commits-and-pull-requests-skill-body-says-why commits-and-pull-requests-skill-folded-in-commit commits-and-pull-requests-skill-title-effect commits-and-pull-requests-skill-description-sections commits-and-pull-requests-skill-unrun-check commits-and-pull-requests-skill-description-revised commits-and-pull-requests-skill-fix-kind commits-and-pull-requests-skill-record-reference commits-and-pull-requests-skill-no-count-or-timing workflow-fragment-open-pr-binds-commits-and-pull-requests workflow-fragment-no-pull-request-format workflow-fragment-version-after-pr-binding project-foundation-pull-request-concern project-foundation-development-tooling-pull-requests-item
```

Each case is a file `tests/cases/<name>.sh`, selectable as `bash tests/run.sh <name>`. Each carries, in its header, every scan's tag and its classification; a failing scan reports its tag only (`[tag]`), never the target's text.

## Baseline

Full suite, `bash tests/run.sh` at commit b444278, before any case was written: **257 passed, 0 failed.**

## Situation and what each result establishes

Every case is a static read (third situation): it reads text and executes nothing it asserts. Each therefore carries a fixture-driven discriminator, run before the real read: a conforming fixture must pass, and for each scan a mutant (the satisfying lines removed for a require scan, a sample line added for a forbid scan) must fail by that scan's tag. Every discriminator was run and passed in this pass. As an additional check outside the suite, the eleven skill cases were run against a scratch toolkit root holding a skill assembled from their fixtures, and all passed — so the region extraction (frontmatter stripped, `references/*.md` appended) reads what it should.

Results at authoring (after this pass, before implementation): 1 passed, 15 failed.

| Case | At authoring | State |
|---|---|---|
| the eleven `commits-and-pull-requests-skill-*` | red: target absent | 2 — the skill does not exist; the scans over real content have not executed |
| `workflow-fragment-open-pr-binds-commits-and-pull-requests` | red: `[binding] [binding-title-description]` | 1 on real content (the anchor `open pr` was found; no binding after it) |
| `workflow-fragment-no-pull-request-format` | green | third-situation pass: says only that no format is present now; discriminated |
| `workflow-fragment-version-after-pr-binding` | red: version below 13 | 1 on real content (version 12) |
| `project-foundation-pull-request-concern` | red: `[pr-concern] [title-description] [template] [checked]` | 1 on real content |
| `project-foundation-development-tooling-pull-requests-item` | red: `[pr-item]` in both files; shape guard `[commit-item]` holds in both | 1 on real content |

The red-on-real-content cases establish, when they go green, that their checks discriminate on real content; no second record is owed then.

## Scenarios

27 `#### Scenario:` blocks across the three delta specs; 27 accounted for below.

### commit-and-pull-request-practice (ADDED, 11)

| # | Scenario | Covered by |
|---|---|---|
| 1 | A project template wins over the default sections | `commits-and-pull-requests-skill-precedence` |
| 2 | The commit convention is read, not assumed | `commits-and-pull-requests-skill-names-no-commit-convention` |
| 3 | A body does not narrate the diff | `commits-and-pull-requests-skill-body-says-why` |
| 4 | Folded-in work is identifiable from its commit | `commits-and-pull-requests-skill-folded-in-commit` |
| 5 | A multi-commit pull request is titled by its effect | `commits-and-pull-requests-skill-title-effect` |
| 6 | A description names its folded-in work | `commits-and-pull-requests-skill-description-sections` |
| 7 | An unrun check is not reported as passing | `commits-and-pull-requests-skill-unrun-check` |
| 8 | A description follows the pull request after review | `commits-and-pull-requests-skill-description-revised` |
| 9 | A fix names what it fixes | `commits-and-pull-requests-skill-fix-kind` |
| 10 | The record reports a re-read that changed nothing | `commits-and-pull-requests-skill-record-reference` |
| 11 | The pull request count is not restated | `commits-and-pull-requests-skill-no-count-or-timing` (negative half), `commits-and-pull-requests-skill-record-reference` `[last-pr]` (positive half) |

Every one of these scenarios is phrased as conduct (a session writes a message or description). Each case asserts the mechanical half — that the skill's text directs it; whether a session then does so is deliberately untested (conduct, verified by reading and by the skill's trigger checks).

### session-workflow (MODIFIED 5, ADDED 2)

| # | Scenario | Covered by |
|---|---|---|
| 12 | A rule outlives the defect that motivated it (MODIFIED requirement) | Uncovered: the scenario's text is identical to the main spec's; the delta introduces no behavior under it. Existing coverage, if any, predates this change. |
| 13 | The fragment carries no argument written for the library (MODIFIED) | Uncovered: unchanged by the delta, as 12. |
| 14 | An incident does not become a standing entry (MODIFIED) | Uncovered: unchanged by the delta, as 12. |
| 15 | An operational skill carries procedure, not obligation (MODIFIED) | Uncovered: unchanged by the delta, as 12. |
| 16 | A form skill carries defaults, not obligations (MODIFIED, new scenario) | Mechanical half: existing case `workflow-fragment-fold-in-named-in-pr` (the fragment, alone, obliges naming folded-in work in the description), and `workflow-fragment-no-pull-request-format` (the fragment carries no format, so no obligation moved into it either way). Deliberately untested: that the skill carries no obligation beyond form — no lexical rule separates an obligation from a default; verified by reading (task 2.2). |
| 17 | The binding names a shipped skill (ADDED) | `workflow-fragment-open-pr-binds-commits-and-pull-requests` |
| 18 | The fragment carries no pull request format (ADDED) | `workflow-fragment-no-pull-request-format`; its binding half by 17's case, its folded-in half by `workflow-fragment-fold-in-named-in-pr` |

### project-foundation (MODIFIED, 9)

| # | Scenario | Covered by |
|---|---|---|
| 19 | Non-goals are recorded even when scope is clear | Uncovered: unchanged by the delta (text identical to the main spec's). |
| 20 | Stack-specific ignore entries are a foundation deliverable | Uncovered: unchanged by the delta. |
| 21 | The quality layer is reached even when nobody raises it | Uncovered: unchanged by the delta; its WHEN clause does not name pull requests. Conversational. |
| 22 | The checklist names concerns, not tools | For the new concern only: `project-foundation-pull-request-concern` `[no-forge]`. The rest of the checklist is unchanged by the delta. |
| 23 | The pull request concern is decided on its own (new) | `project-foundation-pull-request-concern` |
| 24 | Recursive tools are kept out of the working-tree roots | Uncovered: unchanged by the delta (existing case `project-foundation-provisioning-worktree-roots` predates it). |
| 25 | A skipped decision is detectable after the fact | Uncovered: unchanged by the delta. |
| 26 | A decision absorbed into a shared section stays visible | For the added `Pull requests` item: `project-foundation-development-tooling-pull-requests-item` |
| 27 | A concern that does not apply is answered, not skipped | Uncovered: unchanged by the delta. |

## Assertion classification

Each case's header lists every scan with its classification; summarised:

- **Specified**: every scan whose property a delta requirement states — each tag in the `commits-and-pull-requests-skill-*` cases except `[points-to-reference]`; `[binding]`, `[binding-title-description]`, `[shipped]`; `[no-description-sections]`, `[no-title-rules]`; all of `project-foundation-pull-request-concern`'s tags; `[pr-item]`.
- **Derived**:
  - every lexical proxy — the words and co-occurrences chosen to stand for a stated property; each is named in its case's header. These may be reconsidered as derived assertions, never as repairs;
  - `commits-and-pull-requests-skill-record-reference` `[points-to-reference]` and the reference file's name `references/record-pull-request.md` (from proposal.md and design.md decision 6, not the spec, which says only "a reference file");
  - `workflow-fragment-version-after-pr-binding` in full (design.md decision 9, task 2.3; no scenario);
  - `project-foundation-development-tooling-pull-requests-item` `[commit-item]` (shape guard);
  - `commits-and-pull-requests-skill-names-no-commit-convention` `[no-named-convention]`'s strictness: any mention of a named convention trips it, including one offered as an example of what the skill does not choose. If the skill must mention one, reconsider this derived strictness rather than reword around it silently;
  - the anchors: "after the first line naming `open pr`" for the binding, "after the first line naming development tooling" for the item, the `**Pull requests**` label for the concern, and "fix" not "prefix" for the fix kind.
- **Deliberately untested**:
  - every scenario's conduct half (see above);
  - that the skill carries no obligation beyond form (16);
  - that the skill's example commit subjects carry no convention's type prefix;
  - the absence of a direction that pull request titles follow the commit convention in the skill — a forbid scan would trip on the required negated sentence;
  - every phrasing of timing or count rules beyond the plainest (`[no-count]`, `[no-pr-timing]`, `[no-commit-timing]` catch only those);
  - `skills/project-foundation/SKILL.md` carrying the concern itself (tasks.md 3.2 adds only the item there).

### Known weaknesses of the proxies

- `commits-and-pull-requests-skill-fix-kind`: scans only lines containing the word "fix"; a fix kind stated as a heading over list items that do not repeat the word would be missed (a false red, not a false green).
- `workflow-fragment-open-pr-binds-commits-and-pull-requests`: "under `open pr`" is read as "after the first mention of `open pr`" — a binding anywhere later in the fragment passes.
- `project-foundation-development-tooling-pull-requests-item`: the region runs to the end of the file, so an item in a later section passes. Where `[commit-item]` fails too, the list-item shape proxy is wrong for that file, not the item missing.
- `project-foundation-pull-request-concern` `[not-framed-as-convention]`: a negated mention ("not whether titles follow the commit convention") trips it.

## Obsolete tests

The change carries two `MODIFIED` deltas (session-workflow's "A rule states an action and a defect appears only as its reason"; project-foundation's "The foundation covers a fixed set of decisions including non-goals" and "Coverage is verifiable in the artifact, not only in the conversation"). Compared with the requirements under `openspec/specs/`, every one is purely additive: session-workflow gains the form-skill paragraph and one scenario; project-foundation gains the pull request concern, its separateness sentence, one scenario, and the `Pull requests` item. No existing statement is removed or reworded.

Searched within `tests/cases/**` only: for cases asserting the Development Tooling item list or its order, the commit-messages concern, a pinned fragment version, or the session-workflow clause text. Found `workflow-fragment-version-after-backlog-dir` (asserts version at least 12 — still holds at 13) and `project-foundation-testing-items` (Testing Strategy items — untouched). **No bearing test was found by this search**; that is not a finding that none exists. No earlier `test-plan.md` was supplied.

## Unresolved project questions

1. **`tests/coverage.md` was not written.** The dispatch asked for every scenario to be accounted for there, but it lies outside the test-path glob `tests/cases/**`, and this pass writes only within the glob and this manifest. Assumption taken: the scenario table above is the mapping; task 4.4 (implementation step) transcribes it into `tests/coverage.md`. No test depends on this.
2. **The case preamble.** The `bash` skill's floor is `set -euo pipefail`; this suite's cases use none, and their helpers rely on non-zero returns inside conditionals. Assumption taken: the project's existing case style wins (reported as a conflict, not resolved silently). All sixteen cases depend on it.
3. **The reference file's name.** The spec requires "a reference file"; `references/record-pull-request.md` is from proposal.md and design.md. `commits-and-pull-requests-skill-record-reference` depends on it.

## Missing shared arrangement

The dispatch named `tests/lib.sh` as the shared arrangement. Every case uses its `$TESTLIB`, `assert_file` and (the version case) `fragment_version`. The following is declared locally:

- **The line scanner and its discriminator** — `req`, `forbid`, `sc_hits`, `sc_check`, `sc_discriminate`, `sc_run`, `sc_body`, `skill_text` (and the `SC_*` arrays), declared identically in each of the fifteen scanning cases: every case listed under *Run every case* above except `workflow-fragment-version-after-pr-binding`.
  - Stands in for: a static-text scanner that can be run over a fixture and observed to fail without ending the case, plus frontmatter stripping and the skill-text region.
  - Near-miss in the shared arrangement: `assert_contains` — matches one fixed string over a whole file and exits on failure, so it can be neither discriminated over a mutant nor scoped to a line selection.
  - Found in test modules: `tests/cases/lib/line-scan.sh` and `tests/cases/lib/static-scan.sh`, and the local scanner in `tests/cases/project-foundation-testing-items.sh`, serve similar purposes. They are test modules, not shared arrangement, so they were not sourced.
  - Proposed home: `tests/lib.sh`, beside `fenced_line`.
- **`from_open_pr`**, in `workflow-fragment-open-pr-binds-commits-and-pull-requests`. Stands in for: the fragment's body from the first `open pr` mention. Used by that case only. No near-miss. No proposed home (single use).
- **`after_tooling`**, in `project-foundation-development-tooling-pull-requests-item`. Stands in for: a checklist from the first "development tooling" mention. Used by that case only. Near-miss: none in `tests/lib.sh`; the `@after:` region of `project-foundation-testing-items.sh`'s local scanner is the same idea, in a test module. Proposed home: with the scanner in `tests/lib.sh`, if it moves.
- **`at_least_13`**, in `workflow-fragment-version-after-pr-binding`. Stands in for: a version threshold check over a toolkit root, so decoy roots can discriminate it. Near-miss: `fragment_version` in `tests/lib.sh` reads the version but compares nothing; it is used as is. No proposed home (single use, threshold-specific).
