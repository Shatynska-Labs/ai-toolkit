# Test plan: oblige-removing-a-cold-run-worktree

Written by `ai-toolkit:change-test-writer` before implementation. This file is not an artifact the OpenSpec schema knows about: it does not appear among `openspec instructions apply`'s context files and must be read on purpose.

Run any case alone with `bash tests/run.sh <case-name>` from the repository root.

## Baseline

Full suite, taken before any case was written: `bash tests/run.sh` — 236 passed, 0 failed.

## Situation

Every case is a static read of prose (the third situation in `testing`): it asserts that `skills/create-agent/references/cold-run-check.md` or `skills/create-agent/SKILL.md` states the obligation, not that a session performs it. Each case is a fixture-driven discriminator through `tests/cases/lib/static-scan.sh`: it first runs every scan over a conforming fixture it writes, then over one mutant per scan, requiring each mutant rejected by that scan's own tag, and only then reads the toolkit.

At authoring all four cases are red on real content (status 1, not the target-absent status 2): the discriminators passed, the section under the heading naming `isolation` in `cold-run-check.md` exists and was read, and no scan matched. Red, per property:

- `cold-run-check-worktree-removed-after-outcome` — all nine scans: `after-outcome`, `pass-fail-abort`, `before-complete`, `from-checkout`, `branch-deleted`, `harness-nothing`, `forced`, `branch-command`, `return-to-checkout`.
- `cold-run-check-aborted-run-worktree-removed` — `abort-removed`.
- `cold-run-check-revised-body-fresh-worktree` — `removed-before-revised`, `fresh-worktree`, `populated`.
- `create-agent-skill-isolation-names-removal` — `names-removal`.

## Scenarios (9 in the delta; 9 accounted for)

Delta: `specs/agent-authoring/spec.md`, MODIFIED *Cold runs are isolated when the agent can write*. Compared against `openspec/specs/agent-authoring/spec.md`: the delta adds one paragraph and three scenarios; the six existing scenarios and the five existing paragraphs are carried byte-for-byte.

| # | Scenario | Disposition | Tests |
|---|---|---|---|
| 1 | Drafted agent is copied into the worktree before the run | Uncovered — carried verbatim; this change introduces no behavior in it | — |
| 2 | Write-capable agent is cold-run in a worktree | Uncovered — carried verbatim | — |
| 3 | Payload path is rewritten to the isolated root | Uncovered — carried verbatim | — |
| 4 | A body without absolute-path discipline cannot escape the isolation | Uncovered — carried verbatim | — |
| 5 | Read-only path outside the worktree does not abort | Uncovered — carried verbatim | — |
| 6 | Isolation limits are stated | Uncovered — carried verbatim | — |
| 7 | The worktree is removed once the outcome is read | Covered in part (stated text, not conduct) | `cold-run-check-worktree-removed-after-outcome` |
| 8 | An aborted run's worktree is removed | Covered in part | `cold-run-check-aborted-run-worktree-removed` |
| 9 | A revised body runs in a fresh worktree | Covered in part | `cold-run-check-revised-body-fresh-worktree` |

Supporting, traced to `tasks.md` 1.3 and the proposal rather than to a scenario: `create-agent-skill-isolation-names-removal`.

**Why 1–6 are uncovered.** They are carried unchanged, so they state no behavior this change introduces, and deriving them now would mean writing checks against prose that already exists — green at authoring, against wording this pass may not read. A search of `tests/cases/**` (for `worktree`, `isolat`, `create-agent`, `cold-run-check`) found no existing case covering any of them, and `tests/coverage.md` carries no `agent-authoring` section: their lack of coverage predates this change and is reported, not closed, here.

**"Covered in part" for 7–9.** Each scenario's WHEN/THEN is a session's conduct during a cold run, which no program here executes. What a case reaches is that the authoring standard states it; whether a session following the standard removes the worktree is the cold-run check's to establish, not a scan's.

## Assertion classification

Every scan reads the section under the first heading naming `isolation` in `skills/create-agent/references/cold-run-check.md` (anchor DERIVED from `tasks.md` 1.1's *Isolation for write-capable agents*), and matches within one paragraph — one line, per `AGENTS.md`'s one-paragraph-per-line rule. The regexes are DERIVED operationalisations of the requirement's words; the property each names is classified below.

`cold-run-check-worktree-removed-after-outcome`:

- `after-outcome` — SPECIFIED: removal follows the outcome being read.
- `pass-fail-abort` — SPECIFIED: whether the run passed, failed or was aborted (`pass[^.]*fail[^.]*abort`, one sentence).
- `before-complete` — SPECIFIED: before the agent is reported complete.
- `from-checkout` — SPECIFIED: removal made from the authoring checkout.
- `branch-deleted` — SPECIFIED: any branch created with the worktree is deleted (matched on `delet` + `branch`).
- `harness-nothing` — SPECIFIED by the requirement paragraph, not the scenario: a worktree the harness already removed needs nothing further (`harness.*removed.*nothing`).
- `forced` — DERIVED from `tasks.md` 1.1 / design decision 4: contents discarded is stated as `git worktree remove --force` (or `-f`).
- `branch-command` — DERIVED from `tasks.md` 1.1: `git branch -D`.
- `return-to-checkout` — DERIVED from `tasks.md` 1.1: return (or go back) to the authoring checkout from the `cd <wt>` before removing.

`cold-run-check-aborted-run-worktree-removed`:

- `abort-removed` — SPECIFIED: an aborted run's worktree is removed (a sentence naming both `remov` and `abort`).

`cold-run-check-revised-body-fresh-worktree`:

- `removed-before-revised` — SPECIFIED: the failing run's worktree is removed before the revised body runs.
- `fresh-worktree` — SPECIFIED: the revised body runs in a fresh or new worktree.
- `populated` — SPECIFIED: that worktree is populated as for the first run.

`create-agent-skill-isolation-names-removal`:

- `names-removal` — DERIVED in full, from `tasks.md` 1.3: some paragraph of `skills/create-agent/SKILL.md` names the worktree or isolation together with its removal. Whole file read, since no artifact fixes the summary's heading.

Deliberately untested:

- That removal is "as a finished run's would be" for an aborted run beyond the two sharing the statement — the when and how are asserted once, in the after-outcome case.
- The rationale sentence (the workflow's removal rules are keyed to a change) — explanatory text with no token the requirement fixes as obligatory.
- Any session's actual conduct — the cold-run check's.

## Obsolete tests

None, on two grounds stated separately. The delta supersedes nothing: comparing it with the requirement under `openspec/specs/agent-authoring/spec.md`, every existing sentence and scenario is carried unchanged and the change only adds, so no existing behavior is superseded and no test can bear on superseded behavior. Separately, a search of `tests/cases/**` for cases bearing on the requirement at all (`worktree`, `isolat`, `create-agent`, `cold-run-check`) found none: the matches are `workflow-fragment-*` cases on `rules/development-workflow.md`, which this change leaves untouched (proposal: "Nothing in `rules/development-workflow.md` changes"), and two agent cases on `agents/`. `workflow-fragment-no-cold-run-exclusion` forbids the fragment from carrying a cold-run exclusion; this change moves the cold-run worktree's removal into `agent-authoring`, consistent with that case, which stays in force. No earlier `test-plan.md` was supplied.

## Unresolved project questions

- **Stack skill.** The library carries a `bash` skill but this pass's cases are written in the existing `tests/cases/*.sh` idiom and take all machinery from `tests/cases/lib/static-scan.sh`; no project convention says whether a case must also be checked with the `bash` skill. Assumption: `shellcheck` clean (task 3.2) is the bar; all four cases pass it. Depends: all four cases.
- **Section anchor.** `tasks.md` names the heading *Isolation for write-capable agents*; the cases select the first heading whose text contains the word `isolation`. Assumption: no earlier heading in `cold-run-check.md` contains that word (the scan found a non-empty section, but this pass did not read the file to confirm which). Depends: the three `cold-run-check-*` cases.
- **SKILL.md summary heading.** No artifact names it, so `create-agent-skill-isolation-names-removal` reads the whole file. Assumption: any paragraph naming worktree or isolation together with removal is the summary. Depends: `create-agent-skill-isolation-names-removal`.

## Missing shared arrangement

Nothing declared locally. Every case takes its arrangement from the dispatched shared arrangement: `tests/lib.sh` (`assert_file`) and `tests/cases/lib/static-scan.sh` (`scan`, `scan_run`). The shared arrangement held everything these cases needed, with no near-miss.

**Disposition (apply):** no entries to promote or keep; nothing was declared locally.
