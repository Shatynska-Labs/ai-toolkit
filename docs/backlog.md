# Backlog

Changes this repository has identified but not yet opened, the order to work them in, and what each depends on.

An entry is deleted when its change is archived. The working order is this file's own ordering, so deleting an entry closes the gap and no entry carries a position another entry's deletion would falsify. Delete this file when the last entry goes.

This is not `docs/deferred-work.md`. An entry there names something the repository has deliberately **not** done and is deleted when it stops being true; an entry here names work that will be done and is deleted when it ships. One is swept on being fixed and the other on being shipped, so an entry filed in the wrong file is either deleted early or kept forever.

Each entry names the change that argued it rather than repeating the argument.

## `add-session-workflow-tooling`

`scripts/project-init` learns a workflow variant so `rules/development-workflow-database.md` can be written as a second managed block, alongside the block it already writes for `rules/development-workflow.md`. It reports version skew per block rather than for one fragment.

Until it ships, the database binding reaches a project by `@` import or by hand-paste, and carries a `version` nothing increments.

**Argued in**: `consolidate-development-workflow` (proposal, *Follow-up*; and design decision 3, which fixes the three-block composition the tool writes).

**Depends on**: `consolidate-development-workflow` having produced the binding fragment. Interacts with `update-managed-block`, which must locate a block by its own marker rather than assume one block per file.

## `seed-the-worktree-ignore-entry`

`rules/development-workflow.md` v3 fixes a change's working tree at `.worktrees/<name>`, with `.claude/worktrees/` as the Claude Code binding, and neither root is named in the ignore file `scripts/project-init` writes. `project-bootstrap`'s requirement "The minimal ignore file is enumerated, not described" fixes the created file at exactly seven entries "and no others", and `tests/cases/gitignore-enumerated-entries.sh` asserts it.

So a freshly initialized project carries the working-tree rules and not the containment, and the window in which a forced clean at the project root destroys every session's unmerged work opens at initialization rather than closing there. v3 states neither the ignore entry nor the recursive-tool scoping, per `session-workflow`'s rule that a one-time setup obligation is recorded for the capability that owns project setup rather than added to a fragment every session reads. This entry is that record.

The change is two obligations, both one-time and neither a session's:

- **the ignore entry** — add the working-tree roots to the enumerated set, with a `project-bootstrap` delta amending the requirement and the test case that guards it. Without it, sibling trees fill `git status` and `git add -A` commits one as an embedded repository;
- **scoping every recursive tool** that does not read the ignore file — test collection, linters, type checkers, container build context — so it cannot descend into a working-tree root. Without it, one session's run includes every other session's source tree. Discharged once per tool, and again when a tool is added.

**Argued in**: `consolidate-development-workflow`'s implementation review, round 2. The gap is new to that change — the obligation lived in `rules/worktree-isolation.md` until then, and `project-init` never inlined that fragment.

**Depends on**: nothing. Independent of `add-session-workflow-tooling`.

## `extend-dangling-reference-to-agent-names`

`tests/cases/workflow-fragment-no-dangling-reference.sh` scans for `rules/` paths, fragment filenames and `@` imports; it does not scan for an `ai-toolkit:` agent name with no file behind it. That gap is why nothing in the suite reported `build`'s binding while it named a code reviewer that did not exist, and nothing would report its recurrence. It amends `session-workflow`'s publication requirement and its test case.

**Argued in**: the `add-change-code-reviewer` backlog entry, which carried it until `add-change-code-reviewer` split it out (its design, Decision 8).

**Depends on**: nothing.

## `reexamine-plan-gate-code-review-exclusion`

`plan`'s Claude Code binding in `rules/development-workflow.md` says not to use `/code-review` for the plan-review gate, because that command sounds general enough to reach for before any diff exists. With a real `change-code-reviewer` in place for `build`'s gate, re-examine whether that negative binding is still needed or should name the code reviewer instead.

**Argued in**: the `add-change-code-reviewer` backlog entry, split out by `add-change-code-reviewer` (its design, Decision 8).

**Depends on**: `add-change-code-reviewer` having archived, so the question is asked against a reviewer that is in use.

## `name-the-fragments-third-owner`

`session-workflow`'s Purpose and its publication requirement describe the workflow fragment as governed by `session-workflow` and `project-bootstrap`, with a stated seam. `change-code-review` now also governs one sentence of it — the content of `build`'s Claude Code binding. An editor starting from `session-workflow` will not learn that. The next change that modifies `session-workflow`'s publication requirement for its own reason names the third owner there; this is not worth a change of its own.

**Argued in**: `add-change-code-reviewer` (its design, Decision 7 and Risks).

**Depends on**: `add-change-code-reviewer` having archived.

## `harden-build-binding-verdict-acts-case`

`tests/cases/workflow-fragment-build-binding-verdict-acts.sh` passes the binding text to `awk -v`, which interprets backslash escapes, so a binding containing a backslash would be checked against altered text; and its `has` helper matches act words as case-insensitive substrings, so "nonstop" satisfies "stop". Correct against today's fragment, but weaker as a discriminator than it reads. Pass the text through `ENVIRON` or stdin and match whole words.

**Argued in**: `add-change-code-reviewer`'s code review, rounds 1 and 2. Not applied there because the case was derived by a separate test author.

**Depends on**: nothing.

## `evaluate-an-openspec-schema-for-our-artifacts`

OpenSpec supports custom schemas, and the `anvil` schema — listed in OpenSpec's own documentation table — declares artifacts this repository already produces: `review.md` carrying a machine-readable `VERDICT:` line, `test-plan.md`, and `verify.md` carrying `DECISION:`.

The value is not the two extra files. It is that a **schema-declared** artifact is surfaced by `openspec instructions apply` and `openspec status`, where a bespoke one is not. `change-test-authoring` currently has to oblige the agent to say out loud that `test-plan.md` "is not an artifact the OpenSpec schema knows about, so it must be read deliberately" — a defect a schema fixes rather than documents.

**Adding `review.md` and `verify.md` as bespoke files would not be worth it**, and `consolidate-development-workflow` established why: it removed a ledger that recorded verdicts, on the grounds that the commit of an approved plan already marks that a verdict cleared, and that the write cost falls on every change forever. A hand-written verdict file is that ledger under another name. What changes the arithmetic is the schema: the reviewer's report has to land somewhere regardless, and a declared artifact is where, at no extra obligation.

`verify.md` is the weakest of the three — a recorded `DECISION: PASS` is a claim about one commit and goes stale on the next.

So the change is: evaluate adopting or forking a schema, not adding files. Decide whether `test-plan.md` becomes schema-declared, whether the review's report gains a home, and what that costs in `.openspec.yaml` and in every change's shape.

**Argued in**: the vocabulary survey at `openspec/changes/consolidate-development-workflow/handoff.md`, and `consolidate-development-workflow`'s design decision 6.

**Depends on**: nothing, but best after `consolidate-development-workflow` lands, since it would reshape the artifacts that change is defining.

## `reconcile-commit-rule-with-spec`

`rules/development-workflow.md` now directs a session to create commits rather than propose them: `plan`'s **commit**, the handoff-branch commit and the `Throughout` commit rule all lost their "suggest" wording and their declined-commit paths. `openspec/specs/session-workflow/spec.md` still records the behaviour that was removed, so the fragment is out of conformance with its own recorded specification in two places:

- the requirement at *A second change surfacing* — "**The fragment SHALL direct proposing a commit on that branch as soon as it is opened**, and SHALL state what happens where that commit is declined: report that the handoff is unsaved and stop, as the plan-commit rule does" — names a declined path the fragment no longer states, and closes "It is proposed rather than made, per the fragment's commit rule", a justification that now points at the opposite rule;
- its scenario "A handoff is not left uncommitted on a branch the session leaves", whose **THEN** is "it has proposed a commit on that branch already".

The change amends both to require committing rather than proposing, and drops the declined-commit handling the fragment no longer carries. The stated reason survives the amendment unchanged — the session that opened the branch is not returning to it, so no later commit of its own carries the handoff — only the act it justifies changes.

While there, decide whether the fragment's new `**Markdown prose.**` rule wants a requirement of its own. The spec enumerates no `Throughout` item today, so the rule is unrecorded rather than contradicted, and recording it is a choice rather than a repair.

**Argued in**: the operator's direct instruction that agents commit without stopping, applied to the fragment as a fix. No change argued it, because the fix was made without one — which is why the spec was left behind and this entry exists.

**Depends on**: nothing. `tests/cases/workflow-fragment-names-handoff.sh` asserts neither behaviour, so the suite is green either way and stays green after the amendment.

## The suite's own gaps

Four questions test-writing passes have raised and not resolved, recorded here because each is a change rather than a deferral:

- `tests/run.sh` has **no single-case selector**, so running one case means an explicit four-variable invocation (`TOOLKIT_ROOT`, `TESTLIB`, `PROJECT_INIT`, `TESTDIR`; a recipe omitting `PROJECT_INIT` fails on `tools-passthrough.sh`, which is how the count was found to be wrong).
- The suite omits `set -euo pipefail`, which the `bash` skill's floor requires of a shell script in this repository.
- No convention records whether an obsolete case is **deleted or rewritten**. `consolidate-development-workflow` deleted six and said so; nothing makes that the rule.
- **`AGENTS.md` describes this suite as "a dependency-free harness exercising `scripts/`", and it has drifted.** Thirty of fifty-five cases now read `skills/`, `agents/` or `rules/` statically, asserting what a committed file *says* rather than what a script *does*. `state-the-committed-artifact-situation`'s task 4.2 took the practice as governing and wrote four more such cases; correcting the sentence was outside that change's announced Impact. Four places carry the same drift — `AGENTS.md`, `tests/README.md`, and `tests/coverage.md` twice — so correcting one leaves three, and a later author reads whichever they reach first and reasonably concludes a static-read case is out of scope.

**Argued in**: the first three in `consolidate-development-workflow`'s `test-plan.md`, under *Unresolved project questions*; the fourth in `state-the-committed-artifact-situation`'s `test-plan.md`, under the same heading.

## `share-a-suites-test-arrangement`

`testing` gains the second half of the volume problem: a suite's shared test arrangement — where its fixture builders live, when a new bespoke one is warranted, how a keep is recorded, and how a pointer to a shared type is spelled so a later sweep can match it structurally rather than by phrase. Bundled as `skills/testing/references/`, which that skill does not yet have, for the migration-sweep material a session reads only after deciding to run a sweep.

`commerce-ops` has already built and proved this body: a `tests/support/` package 241 of its 371 test files import, twenty standing rules in a project-local skill, and `docs/test-harness-sweeps.md` recording what each proof instrument can and cannot establish. Nine of the twenty are project-agnostic and are what this entry promotes; six are Python-specific and belong in `python/references/testing.md`; five are genuinely that project's own.

Two things this change must settle rather than inherit. **Where the consolidation happens**: `change-test-authoring`'s additive-only guarantee means a test author can never migrate a declaration onto a shared one, so the rule is *a keep is recorded* and *resolving keeps is its own change* — the shape `commerce-ops` reached by doing all thirteen consolidations as their own changes. **Whether the veto asymmetry generalises**: *a source comparison can only veto a migrate; execution can only veto a keep* was derived entirely from AST-diffing Python helpers, and whether it survives contact with a YAML or Markdown fixture builder is untested.

The keep-recording rule has three independent derivations, which is why it is promoted rather than merely borrowed: `commerce-ops`'s twenty rules, and — in `infrastructure` — both `GateBodyMixin` and `ScenarioTextFixtureMixin` in `.github/tests`, each recording in its own docstring why it does not import the sibling beside it.

**Argued in**: `state-the-committed-artifact-situation` (proposal, *Non-Goals*; and design decision 3, which settles that this material folds into `testing` rather than becoming a skill of its own).

**Depends on**: `state-the-committed-artifact-situation` having landed the third situation, since the fixture obligation is what a shared arrangement serves.

## `record-the-discriminator-obligation-in-the-manifest`

`change-test-authoring`'s manifest gains what `state-the-committed-artifact-situation` deferred: an entry for what a fixture-driven discriminator falsifies, one for a check the pass leaves without a discriminator, one for a discriminator written but not executable in the authoring environment, and a repeat pass's carry-forward of entries still outstanding. Of the four, the floor states two outright — (a) what a discriminator falsifies, and (c) the record for one written but not executable. It does not state (b), a check the pass leaves without a discriminator at all, which is reachable only by inference through the floor's *deliberately untested* classification; nor (d), the carry-forward, which is not a floor matter at all and is the reason this is not a one-requirement change — see the paragraph below. What is missing for (a) and (c) is the surface a reader sees; (b) and (d) need stating as well as siting.

It is a change of its own because it is not a one-requirement change, which six review rounds established rather than assumed. The carry-forward needs the earlier `test-plan.md`, and that path is an **optional** dispatch input the agent is forbidden to go looking for — so the clause is either unperformable on an ordinary repeat dispatch, or it reaches *The Change Is Supplied by Dispatch, Not Discovered* and *What the Agent May Read Is Bounded* to become performable. Conditioning it instead was tried and weakens the guarantee to "carried forward, or its possible existence recorded", which is defensible only alongside a dispatcher-facing signal that the input now decides whether recorded debt survives — and the agent's description, the one surface a dispatcher reads in time, does not name the input at all.

Two further findings from that review, worth not rediscovering: the exception must be keyed to the **check's state** rather than to how the pass produced it, since a green check discriminating on nothing is the case that announces itself least and a red-at-authoring trigger leaves it silent; and the unrunnable-discriminator record does not belong inside the baseline entry, whose specified content is the baseline or the reason none was taken.

**Argued in**: `state-the-committed-artifact-situation` (proposal, *Non-Goals*; and design decision 4, which records what was removed and why).

**Depends on**: `state-the-committed-artifact-situation` having landed the floor obligations this would give a surface to.

## `discriminate-every-scan-in-the-static-suite`

The four cases `state-the-committed-artifact-situation` added each run their check twice — once over the real tree, once over a fixture built to be rejected — which is that change's own fixture obligation, self-applied. It is discharged for **4 scans of 14** — counting a scan as one distinct failure accumulation (`grep -c 'problems="$problems'` across the four cases), which is stated because the review's own enumeration gave 13 and the two counts should agree before any of this is acted on. Settling the count is part of the work, not a preliminary to it. Mutation, run in that change's third code review and reproduced independently:

| Case | Scan the fixture attribution guards | Scans that survive deletion undetected |
|---|---|---|
| `testing-skill-three-situations.sh` | `can behave` | the two `executes the behaviour it asserts` scans, and the three-phrase stale loop |
| `testing-skill-discriminator-obligation-placement.sh` | `fixture-driven discriminator` | `not optional rigou?r`, `repair`, the baseline-section negative |
| `testing-skill-failure-states-situation-conditioned.sh` | the stale-phrase loop | `discriminates among none` |
| `testing-skill-discriminator-bound.sh` | `falsif` | the term-presence scan, the `[0-9%]` quantity scan |

One fixture trips several scans at once, so the `case "$fixture_reason"` attribution names one and its neighbours mask the rest. Two of the survivors — the baseline-section negative and the no-quantity negative — are green **vacuously**, and were at authoring; their deletion is invisible to the suite.

The table below is the review's enumeration and is one short of the accumulation count; the missing one is most likely the bullet-count scan in `testing-skill-three-situations.sh`, which no row names.

**The question this change must answer first, because no artifact of the change that created the gap answers it.** The floor's bound says a discriminator falsifies *the check* once, on the property the check exists to assert. If a **case** is the check, one fixture per case is right and nothing here is owed. If a **scan** is the check, thirteen fixtures are owed and the bound is satisfied only then. That ambiguity is what let four-of-thirteen ship. Settle it in the floor, not only in this suite — every consuming project meets the same question.

Two remedies were identified and neither was taken, pending that answer: require the attributed reason to be the *only* rejection reason, by building each fixture to trip exactly one scan; or add one fixture per scan.

**Argued in**: `state-the-committed-artifact-situation`'s third code review; the accounting limit is stated in `tests/coverage.md`, which survives that change's archiving, and in its `test-plan.md`, which does not.

## `decide-unreadable-git-dir-handling`

`scripts/project-init` does not specify what happens when the target holds a `.git` git cannot open (for example a corrupt `HEAD`): the repository concern reads as unsatisfied, `git init` reinitializes it, and the initial-branch step then treats it as created. Whether the tool should refuse, report, or leave such a directory alone is undecided. The same check also misreports a readable repository it is refused access to — `safe.directory` on a repository owned by another user, common on WSL `/mnt/c` — as `created`, routing it to the new-project ending; a single repository probe used for both the report and the mode would remove the disagreement. `name-initial-branch-main` code review also found: a `.git` with only non-repository content (an empty `hooks/`) is created on git's built-in default branch with `SUCCESS`; a missing `HEAD` is recreated by `git init` on the configured default, moving the branch. Two of its test cases need hardening as part of this change: `initial-branch-missing-head-not-rewritten.sh` asserts only `!= main` and passes when `HEAD` moved to `master` (assert it is not moved off `develop`, and add an `init.defaultBranch=main` variant), and its guards and those of `initial-branch-corrupted-head-not-rewritten.sh` use `git -C`, which can discover a repository above `$TESTDIR` (use `--git-dir` or `GIT_CEILING_DIRECTORIES`).

**Argued in**: `name-initial-branch-main` (design decision 5; `test-plan.md`, open questions).

**Depends on**: nothing.

## `state-recording-as-the-obligation`

`session-workflow`'s backlog requirement says the fragment "SHALL state that recording is the obligation and branching is the option". `rules/development-workflow.md`'s routing bullet offers the two as equals — "record it in `docs/backlog.md`, or open the identified change" — and nothing in the fragment states the clause.

**Argued in**: `seed-the-backlog`'s code review, which found the gap predates that change.

**Depends on**: nothing.

## `count-a-dangling-ignore-file-link-as-present`

`scripts/project-init` tests the ignore file with `-f`, so a dangling `.gitignore` link reads as absent and the heredoc writes through it to wherever it points. `seed-the-backlog` tests `docs/backlog.md` with `[ -e ] || [ -L ]` for exactly this reason; the ignore file should match.

**Argued in**: `seed-the-backlog`'s code review; outside that change's scope.

**Depends on**: nothing.
