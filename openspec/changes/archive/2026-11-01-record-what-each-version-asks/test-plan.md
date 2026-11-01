# Test plan: `record-what-each-version-asks`

Written by `change-test-writer` from the delta specs, before implementation. This file is not an artifact the OpenSpec schema knows, so `openspec instructions apply` does not list it: read it on purpose.

Run any case with `bash tests/run.sh <case>` from the worktree root.

## Baseline

Full suite, before any case was written, at `acc42c8`: 606 passed, 0 failed. Implementation is not to break any of them, except the one obsolete entry below.

New cases at the end of this pass: 19 written, 19 failing, each for the reason in *What each case establishes today*. ShellCheck is clean on all 19.

## What each case establishes today

| State | Cases |
|---|---|
| State 1: the tool ran and produced the wrong result | every `project-update-changelog-*` case |
| State 2: the target is absent, `rules/changelog` does not exist | `rules-changelog-version-rise-recorded`, `rules-changelog-second-non-fragment` |

Silence alone would pass today, so each case asserting that nothing prints also holds a control that prints, and it is the control that is red: `project-update-changelog-patch-prints-nothing`, `-crossing-no-record`, `-block-not-written`. No case passed on its first run.

Beyond the red run, in a scratch directory and not in the suite: with the line comparison neutralised, every sub-run of every tool case reached its intended state (`replaced`, `converted`, `edited`, `ahead`, `malformed`, `current`, `absent`, `ERROR`), so the fixtures hold; the two static cases passed over a copy of `rules/` given a valid changelog; `rules-manifest-only-non-fragment` failed over that copy with `[only-one]`. No case was run against an implementation, so the lines' assertions are unverified until task 2.2 lands.

## Scenarios

38 scenarios in the delta specs, 38 accounted for: 14 ADDED and 9 MODIFIED in `project-update`, 5 in `project-bootstrap`, 10 in `toolkit-structure`. 25 are covered: 18 by new cases (16 tool, 2 static) and 7 by existing cases whose scenario text is unchanged. 13 are uncovered, each unchanged text with its reason below.

### `project-update`, ADDED: *A run says what each version it crossed asks*

| Scenario | Case | Task |
|---|---|---|
| A major prints what it changed and what it asks | `project-update-changelog-major-prints-asks` | 2.2 |
| A minor prints what changed | `project-update-changelog-minor-prints-changed` | 2.2 |
| A patch prints nothing | `project-update-changelog-patch-prints-nothing` | 2.2 |
| Every version crossed is printed, oldest first by number | `project-update-changelog-versions-oldest-first` | 2.2 |
| A conversion counts as coming from 1.0.0 | `project-update-changelog-conversion-from-floor` | 2.2 |
| A direct block reads its own records | `project-update-changelog-direct-reads-its-own` | 2.2 |
| A crossing prints the records of the variant it arrives at | `project-update-changelog-crossing-arrival-records` | 2.2 |
| A crossing onto a variant with no record prints none | `project-update-changelog-crossing-no-record` | 2.2 |
| A block not written prints no record | `project-update-changelog-block-not-written` | 2.2 |
| A second run prints nothing | `project-update-changelog-second-run` | 2.2 |
| A major without a record says so | `project-update-changelog-major-without-record` | 2.2 |
| A recorded major does not hide an unrecorded one | `project-update-changelog-recorded-major-not-hiding` | 2.2 |
| Help describes the changelog lines | `project-update-changelog-help` | 2.3 |
| The shipped records are printed for a project below them | `project-update-changelog-shipped-records` | 1.1, 2.2 |

One case covers no scenario, from design decision 3: `project-update-changelog-printed-before-a-failure` (task 2.2).

### `project-update`, MODIFIED: *Every run ends in one of three outcomes, and the exit code agrees*

| Scenario | Case | Note |
|---|---|---|
| A missing changelog blocks | `project-update-changelog-missing-blocks` | new, task 2.1 |
| A malformed changelog record blocks | `project-update-changelog-malformed-blocks` | new, task 2.1 |
| A missing fragment blocks | `project-update-fragment-missing-blocks` | existing, text unchanged |
| An edited block still succeeds, and is named | `project-update-attention-edited` | existing, text unchanged |
| Several records to attend to are named in manifest order | `project-update-attention-order` | existing, text unchanged |
| A fragment without a semantic version blocks | `project-update-fragment-invalid-blocks` | existing, text unchanged |
| No hash command blocks | `project-update-hash-command-absent-blocks` | existing, text unchanged |
| A failed write reports what was written | `project-update-write-failure-reports-written` | existing, text unchanged |
| Nothing to attend to | `project-update-no-attention` | existing, text unchanged |

### `project-bootstrap`, MODIFIED: *The fragment's version increments when its body changes*

| Scenario | Case or reason |
|---|---|
| A version rise carries its changelog record | `rules-changelog-version-rise-recorded`, task 1.1 |
| An edited fragment is distinguishable from the copy already adopted | Uncovered by this pass: text unchanged, the change adds nothing to it. No case carries the title. |
| A frontmatter-only edit does not consume a version | Uncovered by this pass: text unchanged. No case carries the title; it binds an author's edit, not a state a check can read. |
| Which part rises is decided by what the project must do | Uncovered by this pass: text unchanged. No case carries the title; `rules-fragment-versions-semantic` holds the form only. |
| A legacy version reads as older | Uncovered by this pass: text unchanged. No case carries the title. |

### `toolkit-structure`, MODIFIED: *One directory level for every asset type*

| Scenario | Case or reason |
|---|---|
| The manifest is the one file in rules/ that is not a fragment | `rules-changelog-second-non-fragment`, task 1.1; revised text |
| Placing a new skill | Uncovered by this pass: text unchanged, and the change adds no skill. |
| Skill placed too deep is undiscoverable | Uncovered by this pass: text unchanged. |
| Agent invocation name carries no grouping | Uncovered by this pass: text unchanged. |
| Names are unique per directory | Uncovered by this pass: text unchanged. |
| Placeholders for unpopulated directories | Uncovered by this pass: text unchanged. |
| A placeholder is not mistaken for an asset | Uncovered by this pass: text unchanged. |
| A non-`.md` file beside an agent is not an asset | Uncovered by this pass: text unchanged. |
| A procedural fragment is not inlined into a project | Uncovered by this pass: text unchanged. |
| The increment rule has exactly one owner | Uncovered by this pass: text unchanged. |

For these the search was for each title as `Scenario:` in `tests/cases/**`. `tests/coverage.md` lies outside the dispatched glob and was not read, so a case it maps to one of them under another name would not have been found here.

## Assertion classification

Every case's header states this as well.

| Case | Specified | Derived | Deliberately untested |
|---|---|---|---|
| `-major-prints-asks` | The `changed` and `by hand` lines, their form and order; SUCCESS; no `Attention:` | `changed` verbatim with a colon, backticks and quotes; asks in non-alphabetical order | |
| `-minor-prints-changed` | The `changed` line, no `by hand` line | | |
| `-patch-prints-nothing` | No line from the record | Control: a minor in the same run prints | |
| `-versions-oldest-first` | Order; nothing at or below held, above written, or of another fragment; numeric order | Records out of order in the file; a patch inside a wider range | |
| `-conversion-from-floor` | The 2.0.0 lines beneath each converted line | A 1.5.0 record prints too: the floor is 1.0.0 | |
| `-direct-reads-its-own` | Only the direct record prints | | |
| `-crossing-arrival-records` | Every non-patch record of the arrival variant; the line names both | Full's 1.2.0 prints with the block held at direct 1.5.0; direct's record does not | |
| `-crossing-no-record` | Nothing for the block, replaced or converted | Control: a workstreams minor prints in each run | |
| `-block-not-written` | Edited, ahead, malformed, current print nothing; `Attention:` unaffected | `absent` added from "a block it did not replace or convert"; control prints; the arrangement of `ahead` and `current` (question 2) | `not writable` and `single file` |
| `-second-run` | First holds the lines, second none | | |
| `-major-without-record` | One line beneath; SUCCESS. Exact text from design decision 5 (question 1) | A minor gap is quiet; a major equal to the held version owes no line | |
| `-recorded-major-not-hiding` | Both lines, in version order, either way round | | |
| `-help` | Help states what was crossed changed and asks by hand | Read as the words `changed`, `by hand`, `rules/changelog` | |
| `-shipped-records` | A `2.0.0 by hand` line beneath each | | The records' wording, which the operator reviews (design decision 6) |
| `-missing-blocks` | BLOCKED, 2, project unchanged | Also with every block current; the reason names the changelog | |
| `-malformed-blocks` | Twelve malformed forms: BLOCKED, 2, project unchanged | The bad record names a fragment the run does not cross; the reason names the changelog; a well-formed file succeeds | An empty `changed:` or `ask:`, an unknown key, and two records of one version: no stated requirement |
| `-printed-before-a-failure` | | All of it, from design decision 3: on ERROR the written block's lines are in the report | The lines of the block whose write failed |
| `rules-changelog-version-rise-recorded` | One record per version above 1.0.0; every major from 2.0.0; every record names a fragment at no higher a version | "That fragment" is `rules/<name>.md`; numeric comparison | Form of a record, which the tool's validation holds, and the shipped run exercises |
| `rules-changelog-second-non-fragment` | `manifest` and `changelog` the only non-fragments; `.md` files declare `kind` | "Neither" read as the two entries, first line not `---`, as the older case read it | |

`--workflow` and the report's other lines keep their existing cases. No case tests `rules/README.md` or `AGENTS.md` prose from task 1.2: no scenario states it.

### Static checks and their fixtures

Both `rules-changelog-*` cases are static reads. Each runs its check over fixture directories first, one for each property, and each fixture was observed to fail with its own tag while the real target is still red: `absent`, `one-record` (missing and duplicated), `every-major`, `names-fragment`, `no-higher` (with `1.10.0` over `1.9.0`, so a lexical compare fails); and `present`, `no-frontmatter`, `only-two`, `kind`. Recorded per `testing`: each is red on `rules/changelog` being absent, and its later green is read against that.

## Obsolete tests

Candidates for human confirmation, never conclusions. None was edited, deleted or disabled.

| Test | Superseding delta | Evidence |
|---|---|---|
| `bash tests/run.sh rules-manifest-only-non-fragment` | `toolkit-structure`, MODIFIED *One directory level for every asset type*, scenario *The manifest is the one file in rules/ that is not a fragment*: `manifest` and `changelog` are now the only non-fragment files | The header asserts "`manifest` is the one file that is neither", and `check_rules` tags any non-`.md` entry but `manifest` as `[only-one]`. Over a copy of `rules/` holding a valid changelog it fails with `[only-one] rules/ holds another non-.md entry: changelog` |

This case turns red the moment task 1.1 adds `rules/changelog`, and stays so until task 1.2 revises it. Once revised it asserts what `rules-changelog-second-non-fragment` asserts, so one of the two then duplicates the other.

For the other MODIFIED deltas no superseded test was found by this search, which covered `tests/cases/**` for the requirements' names, for cases walking `rules/` or building their own, and for cases comparing report lines exactly. That is "none was found by this search", not "none exists":

- `project-update`, *Every run ends in one of three outcomes*: the delta adds a precondition and removes nothing. Every `project-update` case takes its toolkit by `cp -R` of the whole `rules/` or from the repository, so each will hold the shipped changelog; no case builds a `rules/` of its own for this tool.
- `project-bootstrap`, *The fragment's version increments*: the delta adds an obligation and removes nothing.
- `project-update-older-bash` compares a report under two bash versions, and `project-update-self-location` sets `7.7.7`, which will print no-record lines. Neither assertion bears on those lines as far as read, but neither was run against an implementation.

No REMOVED or RENAMED delta exists.

## Unresolved project questions

1. **The no-record line's exact text.** The spec says a line "stating that no record says what `M.0.0` asks"; design decision 5 gives `M.0.0: no record of what this version asks`. Assumption: the design's text, exactly. Depends: `project-update-changelog-major-without-record`, `project-update-changelog-recorded-major-not-hiding`.
2. **"A block below a recorded major version" that is `ahead` or `current`.** A block cannot be both current and below the fragment's version unless the record is above the fragment's own, which the tool permits and `rules-changelog-version-rise-recorded` forbids in the shipped file. Assumption: arranged that way, as the only reading where both hold. Depends: `project-update-changelog-block-not-written`.
3. **A trailing `---` in `rules/changelog`.** The spec says `---`-separated; design decision 1 shows one after the last record, decision 6 shows none. Assumption: fixtures write separators only between records, so nothing here requires or forbids a trailing one, and the tool must accept the form fixtures use. Depends: every case writing a changelog.
4. **The help's wording.** Assumption: the words in the `-help` row. Depends: `project-update-changelog-help`.
5. **Bash 3.2.** `project-update-older-bash` covers it where that bash is available; no new case runs the changelog lines under it. No assumption beyond the existing case's.

## Missing shared arrangement

`tests/lib.sh` and `tests/run.sh` were read and not changed. Everything below is declared locally, and proposed for `tests/lib.sh`, except where a row says it is a case's own.

**Set U**, the 17 tool cases: `project-update-changelog-major-prints-asks`, `-minor-prints-changed`, `-patch-prints-nothing`, `-versions-oldest-first`, `-conversion-from-floor`, `-direct-reads-its-own`, `-crossing-arrival-records`, `-crossing-no-record`, `-block-not-written`, `-second-run`, `-major-without-record`, `-recorded-major-not-hiding`, `-help`, `-shipped-records`, `-missing-blocks`, `-malformed-blocks`, `-printed-before-a-failure`, each with the prefix `project-update-changelog`. Each declares its own copy.

| Declared name | Declared in | Stands in for | Used by | Near-miss in shared | Found in | Proposed home |
|---|---|---|---|---|---|---|
| `PROJECT_UPDATE` | Set U | The path of the tool under test | Set U | None; `run.sh` exports only `PROJECT_INIT` | `project-update-stale-replaced` | `tests/run.sh` export |
| `require_update` | Set U | Target-absent guard | Set U | None | `project-update-stale-replaced` | `tests/lib.sh` |
| `sha256_of` | Set U | Digest of stdin | Set U | None | `project-update-stale-replaced` | `tests/lib.sh` |
| `frag_key` | Set U, `rules-changelog-version-rise-recorded`, `rules-changelog-second-non-fragment` | Reader of any fragment's frontmatter | Those | `fragment_version`, which reads `development-workflow.md`'s version only | `project-update-stale-replaced`, `rules-manifest-only-non-fragment` | `tests/lib.sh` |
| `records`, `target_of`, `fversion` | Set U | Manifest reader; `fversion` reads any fragment's version | Set U | `fragment_version`, as above | `project-update-stale-replaced` | `tests/lib.sh` |
| `put_block_at`, `put_block` | Set U | A project's untouched block | Set U | None | `project-update-choice-later-switch`; here `put_block` calls `put_block_at` instead of repeating it | `tests/lib.sh` |
| `put_others` | Set U | Every record's block current but those named | Set U | None | Generalised from `project-update-choice-later-switch`'s, which fixes two records | `tests/lib.sh` |
| `tree_sum` | Set U | Comparison of a project's whole tree | Set U | `assert_unchanged`, which reads one file | `project-update-stale-replaced` | `tests/lib.sh` |
| `assert_tree` | `-help`, `-missing-blocks`, `-malformed-blocks` | As above | Those | As above | `project-update-stale-replaced` | `tests/lib.sh` |
| `assert_outcome` | Set U | Exit code and stated outcome agreeing | Set U | `assert_exit`, which reads the code only | `project-update-stale-replaced` | `tests/lib.sh` |
| `git_fixture` | Set U | A committed project | `-conversion-from-floor`, `-crossing-no-record` | None | `project-update-stale-replaced` | `tests/lib.sh` |
| `toolkit_copy`, `set_version` | Set U | A toolkit copy, and a fragment at a chosen version | Set U | None | `project-update-stale-replaced` | `tests/lib.sh` |
| `V12_BLOCK` | `-conversion-from-floor`, `-crossing-no-record` | A workflow block from before 1.0.0 | Those | None | `project-update-stale-replaced` | `tests/lib.sh` |
| `edit_inside` | `-block-not-written` | A project's edit inside a block | That case | None | `project-update-stale-replaced` | `tests/lib.sh` |
| `changelog_copy` | Set U | A toolkit copy whose `rules/changelog` is stdin | Set U | None | New | `tests/lib.sh` |
| `beneath`, `assert_beneath` | Set U | The indented lines beneath a record's line | Set U | `assert_contains`, which cannot say where a line stands or that nothing else does | New | `tests/lib.sh` |
| `refuse_text` | Set U | The report holding no such text | Set U | None | New | `tests/lib.sh` |
| `check`, `arrange`, `variant`, `good` | `-crossing-no-record`, `-block-not-written`, `-missing-blocks`, `-malformed-blocks` | Each case's own sub-runs | Those | None | New | None: a case's own loop |
| `changelog_records`, `version_above` | `rules-changelog-version-rise-recorded` | Reader of the changelog, and numeric comparison | That case | None | New | `tests/lib.sh` if the tool's cases come to need them |
| `check_rules`, `expect`, `mkfx` | both `rules-changelog-*` cases | The static check and its fixtures | Those | None | Shape from `rules-manifest-only-non-fragment` | None: a case's own |
| `record`, `with` | `rules-changelog-version-rise-recorded` | Changelog fixture builders | That case | None | New | None: a case's own |

## Dispositions at apply

Every entry under *Missing shared arrangement* is **kept** local. It repeats what the existing `project-update-*` cases declare locally, and promoting that shared family is a change of its own across all of them rather than work of this one.

`rules-manifest-only-non-fragment` was revised, as task 1.2 states, to allow `changelog`; it and `rules-changelog-second-non-fragment` now overlap, and the revised case keeps the original's fixtures.

`project-update-changelog-printed-after-a-partial-conversion` was added at `build`'s review, from its finding that a README conversion failing after writing its block lost the version's lines.
