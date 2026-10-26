# Test plan: seed-the-worktree-ignore-entry

Written by `change-test-writer` before implementation. Tests are named as `bash tests/run.sh <case>` selects them, run from the repository root. This pass added three cases and edited, deleted or disabled no existing test.

## Baseline

Full suite, taken before any case below was written: `bash tests/run.sh` — **236 passed, 0 failed**. Every failure reported below is therefore attributable to the new cases.

## Scenario accounting

Seven scenarios across the two delta specs (2 in `specs/project-bootstrap/spec.md`, 5 in `specs/project-foundation/spec.md`; both deltas are `MODIFIED` and restate their requirement's full scenario list). Seven accounted for below.

### project-bootstrap — The minimal ignore file is enumerated, not described

| Scenario | Account |
| --- | --- |
| Created ignore file carries no stack assumption (revised: three categories become four) | Covered — `gitignore-four-categories` |
| Created ignore file ignores the working-tree roots (added) | Covered — `gitignore-working-tree-roots` |

### project-foundation — The foundation covers a fixed set of decisions including non-goals

| Scenario | Account |
| --- | --- |
| Non-goals are recorded even when scope is clear | Uncovered — text identical to the requirement under `specsRoot`; this change does not alter it. Keeps its existing `tests/coverage.md` account (Structural review). |
| Stack-specific ignore entries are a foundation deliverable | Uncovered — unchanged by this delta, as above. |
| The quality layer is reached even when nobody raises it | Uncovered — unchanged by this delta, as above. |
| The checklist names concerns, not tools | Uncovered as a scenario — unchanged by this delta. The new provisioning text is held to it by the `[no-tool]` scan in `project-foundation-provisioning-worktree-roots` (see below); the rest of the checklist keeps its Structural review account. |
| Recursive tools are kept out of the working-tree roots (added) | Covered, mechanical half only — `project-foundation-provisioning-worktree-roots`. The conversational half is deliberately untested (below). |

### Why a test for the foundation scenario at all

`tests/coverage.md` accounts every older foundation scenario as "Structural review", on the ground that foundation behaviour is conversational. That ground holds for this scenario's WHEN/THEN — a decision taken in conversation — and that half is left untested. But the requirement also places a checkable obligation on a file: the provisioning concern of `rules/project-foundation.md` must carry the two roots and the recursive-tool boundary, and design.md decision 2 says this is the whole point of the change's foundation half ("an obligation stated only in `project-bootstrap` would repeat what lost it the first time: a statement no actor reads"). If task 2.1 is skipped, nothing else in the suite notices. The suite already sets the precedent of a mechanical-half static check on this same fragment (`project-foundation-testing-items`), and the shared `tests/cases/lib/line-scan.sh` supplies the paragraph scanner and its fixture discriminator, so the case costs no new machinery. A test is therefore warranted for the mechanical half and not for the conversational half.

## Cases and assertion classification

### `gitignore-four-categories`

Runs `scripts/project-init` in an empty directory and reads the created `.gitignore` (second situation: the behaviour is executed).

- `[headings]` SPECIFIED — category headings are exactly `# Environment`, `# OS`, `# Editors`, `# Working trees` ("only the four enumerated categories").
- `[entries]` SPECIFIED — entry lines are exactly the nine enumerated ("exactly these entries and no others").
- `[stack]` SPECIFIED property (no dependency directory, build output or cache); the marker list (`node_modules`, `__pycache__`, `target/`, `venv`, `.venv`, `dist/`, `build/`) is DERIVED, carried over from `gitignore-enumerated-entries`.
- DERIVED reading: a `#` line is a heading, blank lines separate, every other line is an entry. Order and blank-line layout deliberately not asserted (design.md decision 3).

Red at authoring, state 1 (code ran, wrong value), on `[headings]`: the created file has no `# Working trees`. `[entries]` has not yet executed, because `[headings]` exits first; it executes once the heading lands.

### `gitignore-working-tree-roots`

Same arrangement.

- `[root-worktrees]` SPECIFIED — a line reading `.worktrees/`.
- `[root-claude-worktrees]` SPECIFIED — a line reading `.claude/worktrees/`.
- DERIVED reading: "contains" is a whole-line match, since an ignore entry is a line.

Red at authoring, state 1, on `[root-worktrees]` (the loop exits at the first missing root; `[root-claude-worktrees]` executes once the first passes).

### `project-foundation-provisioning-worktree-roots`

Static read of `rules/project-foundation.md` (third situation), on the lines whose lowercased text contains `provisioning` (DERIVED anchor).

- `[root-worktrees]` SPECIFIED — names `.worktrees/`.
- `[root-claude-worktrees]` SPECIFIED — names `.claude/worktrees/`.
- `[recursive]` SPECIFIED (tools that recurse the tree); operationalised as `recurs` — DERIVED.
- `[ignore-file]` SPECIFIED (that do not read the ignore file); operationalised as `ignore` — DERIVED.
- `[no-tool]` SPECIFIED property ("The checklist SHALL name each concern without naming a tool"; task 2.1 "naming no tool"); the forbidden list (`pytest`, `jest`, `vitest`, `eslint`, `ruff`, `docker`) is DERIVED and not exhaustive.

Fixture-driven discriminator: run on every execution by `line_run` before the real check — the conforming fixture must pass, and one mutant per scan must be rejected with that scan's own tag. Observed passing at authoring (the case reached the real check, which returned status 1, not a discriminator failure).

Red at authoring on `[root-worktrees]`, `[root-claude-worktrees]`, `[recursive]` and `[ignore-file]`: the provisioning lines carry none of them yet. `[no-tool]` holds today.

Known weakness: each scan is satisfied by any line mentioning provisioning, not necessarily the same line. The author did not read the fragment and so cannot narrow the selector without guessing its wording.

### Deliberately untested

- That a foundation conversation actually decides, for each chosen recursive tool, how it is kept out of the roots, or records that the stack has none (the scenario's THEN). Conversational, with no deterministic artifact before a project runs foundation; verified by reading `skills/project-foundation/SKILL.md` and `rules/project-foundation.md`.
- project-bootstrap: "the tool SHALL NOT write any of it" (no scoping configuration for test runners, linters or container builds). No scenario states it, and its negation is open-ended (no finite set of files to assert absent). Verified by reading `scripts/project-init`'s diff.
- design.md decision 4 (the report stays silent about an existing ignore file's content) and the never-overwrite guarantee: not stated by a delta scenario; the latter is already covered by `existing-gitignore-preserved`.
- tasks.md 2.1's "the checklist's item list and `design.md` section list are unchanged": not a scenario; verified by reading.

## Obsolete tests (candidates for human confirmation)

- **`gitignore-enumerated-entries`** — candidate, superseded by `gitignore-four-categories`. Disposition: retired at implementation; `tests/coverage.md` points at the new case.
  - Superseding delta: project-bootstrap `MODIFIED` *The minimal ignore file is enumerated, not described*, scenario *Created ignore file carries no stack assumption*, whose THEN changed from "only the three enumerated categories" (under `specsRoot`) to "only the four enumerated categories".
  - Evidence: its header names that scenario (`# Scenario: Created ignore file carries no stack assumption.`); its entry loop asserts exactly the seven three-category entries (`'.env' '.env.*' '!.env.example' '.DS_Store' 'Thumbs.db' '.idea/' '.vscode/'`) and nothing of `# Working trees`. It still passes against both the old and new behaviour, because it asserts presence, not "only" — so it is not wrong, but it no longer covers the scenario as revised. The proposal plans to amend it (proposal *What Changes*, last bullet). Left untouched by this pass; amending or retiring it is the implementation step's or a human's decision, and `tests/coverage.md` should then point the scenario at `gitignore-four-categories`.
- Searched `tests/cases/**` for every other case reading `.gitignore` (`existing-gitignore-preserved`, `gitignore-dangling-symlink-not-written-through`, `repeated-execution-idempotent`, `empty-directory-new-project`, `command-absent-satisfied-proceeds`, `help-output`): each asserts existence, absence, or unchanged-across-runs, none the created content, so none bears on the superseded text. For the project-foundation delta, the only superseded text is the provisioning sentence the delta extends; no case in `tests/cases/**` mentions the provisioning concern of `rules/project-foundation.md`, so none was found by this search (the search covered the glob only; no earlier `test-plan.md` was supplied).

## Missing shared arrangement

Shared arrangement named by the dispatch: `tests/lib.sh` and `tests/cases/lib/` (`line-scan.sh`, `static-scan.sh`). Nothing was declared locally: the two ignore-file cases use `assert_file` from `tests/lib.sh` and plain `grep`/`sort`; the foundation case uses `line_select`, `line_scan` and `line_run` from `tests/cases/lib/line-scan.sh` unmodified. No near-miss was found and nothing was taken from another test module.

## Unresolved project questions

- **No stack skill for the shell suite beyond `bash`.** `ai-toolkit:bash` was loaded; no further question.
- **Status of `tests/cases/lib/`.** Earlier cases (`project-foundation-testing-items`) describe `tests/cases/lib/static-scan.sh` as "a test module rather than shared arrangement" and decline to source it, while `line-scan.sh`'s own header and this dispatch treat `tests/cases/lib/` as shared. Assumption taken: the dispatch is authoritative and `line-scan.sh` is shared arrangement. Depends on it: `project-foundation-provisioning-worktree-roots`. Neither `AGENTS.md` nor `tests/README.md` records which reading holds.

## What the implementation step must make pass

`bash tests/run.sh gitignore-four-categories gitignore-working-tree-roots project-foundation-provisioning-worktree-roots` — tasks 1.1 (the first two) and 2.1 (the third) — with the full suite staying green (task 4.1).
