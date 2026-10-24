# Backlog

Changes this project has identified and not yet archived. Each entry is a change recorded here instead of being folded into the change that found it, or opened on a branch of its own.

An entry's heading is the change's name in kebab-case — the name its branch and change directory are expected to take, though the session that opens the change may rename it if the work turns out different. A fix takes the name as its branch's only. Refer to an entry only by that name.

The order of entries carries no meaning. What an entry waits on, how urgent it is, and which entries share a design with it, it states in its own fields.

Keep an entry short: what is needed and why, naming files, specifications and changes as pointers. Leave out line numbers, census tables and step-by-step plans; they go stale first, and the session that takes the entry up redoes them.

Delete an entry when its change is archived, when the operator takes it as a fix rather than a change, when a change makes it obsolete, or when the operator decides the change will not be made. When a change is archived, also update the entries it unblocked, unparked or made stale, and set their **Re-checked** date. Keep this file when it has no entries.

An entry takes this shape:

```
## `change-name`

What the change is and why it is needed, written for a session that has not seen the work that found it.

**Priority**: `high`, `normal`, or `parked until` a condition that can be checked, and why. `high` needs evidence of harm happening now — an incident, a measurement, an observation; `parked` is an entry that could be taken but is not worth taking until its condition holds, and is not folded into another change before then. When the condition holds the entry becomes `normal`, or `high` with evidence; when a `high` entry's evidence no longer holds it becomes `normal`. An entry without this field is `normal`.

**Kind**: `fix` or `change`, and why. A fix owes no specification delta, needs no decision from the operator, and fits one review sitting; anything else is a change, and says which delta it owes, which decision it needs, or that it is too large.

**Waits on**: `nothing`, or something that can be checked: a change by name, a person's answer, an event.

**Design with**: the entries that share a design with this one, by name, or `nothing`.

**Workstream**: the workstream this entry is a step of or serves, by name, or `nothing`. An entry recorded by a change in a workstream takes that workstream unless it serves another goal. An entry without this field is `nothing`.

**Recorded by**: the change that identified it, and why it was not done there.

**Re-checked**: the date the entry was last verified against the repository.
```

## `add-session-workflow-tooling`

`scripts/project-init` writes only the `rules/development-workflow.md` block, so `rules/development-workflow-database.md` reaches a project by `@` import or by hand, carrying a `version` nothing increments. The tool learns a workflow variant that writes the database binding as a second managed block, and reports version skew per block.

**Kind**: `change`. It owes a `project-bootstrap` delta for the second block and per-block skew.

**Waits on**: `nothing`. The open change `update-managed-block` must locate a block by its own marker rather than assume one per file, so the two are designed together.

**Design with**: `nothing`.

**Recorded by**: `consolidate-development-workflow` (proposal, *Follow-up*; design decision 3, which fixes the block composition), which produced the binding fragment and left the tooling out of scope.

**Re-checked**: 2026-10-18

## `seed-the-worktree-ignore-entry`

`rules/development-workflow.md` puts a change's working tree at `.worktrees/<name>`, and the ignore file `scripts/project-init` writes names no worktree root, because `project-bootstrap`'s "The minimal ignore file is enumerated, not described" fixes its entries. In a new project, sibling worktrees fill `git status`, and `git add -A` commits one as an embedded repository. The change adds the worktree roots to the enumerated set, amends `tests/cases/gitignore-enumerated-entries.sh`, and states that recursive tools which do not read the ignore file (test collection, linters, container build context) are scoped away from the roots.

**Kind**: `change`. It owes a `project-bootstrap` delta to the enumerated-ignore-file requirement.

**Waits on**: `nothing`.

**Design with**: `count-a-dangling-ignore-file-link-as-present`, which changes the same ignore-file step.

**Recorded by**: `consolidate-development-workflow`'s implementation review, round 2. The obligation lived in `rules/worktree-isolation.md`, which `project-init` never inlined, and that change folded the fragment away.

**Re-checked**: 2026-10-18

## `count-a-dangling-ignore-file-link-as-present`

`scripts/project-init` tests `.gitignore` with `-f`, so a dangling link reads as absent and the heredoc writes through it to wherever it points. The backlog step already tests `[ -e ] || [ -L ]` for this reason; the ignore file should match.

**Kind**: `fix`. No delta, no decision, one line and a test case.

**Waits on**: `nothing`.

**Design with**: `seed-the-worktree-ignore-entry`.

**Recorded by**: `seed-the-backlog`'s code review; outside that change's scope.

**Re-checked**: 2026-10-18

## `decide-unreadable-git-dir-handling`

`scripts/project-init` leaves undecided what happens to a `.git` git cannot open: a corrupt or missing `HEAD`, or a `.git` holding only non-repository content, is reinitialized by `git init` and reported as created, which can move the branch. A readable repository git refuses for `safe.directory` (common on WSL `/mnt/c`) is misreported the same way. One repository probe used for both the report and the mode would remove the disagreement. `initial-branch-missing-head-not-rewritten.sh` and `initial-branch-corrupted-head-not-rewritten.sh` need hardening alongside: the first asserts only `!= main`, and both guard with `git -C`, which can discover a repository above `$TESTDIR`.

**Kind**: `change`. It needs the operator's decision between refusing, reporting and leaving such a directory alone, and owes a `project-bootstrap` delta.

**Waits on**: `nothing`.

**Design with**: `nothing`.

**Recorded by**: `name-initial-branch-main` (design decision 5; `test-plan.md`, open questions), which kept to the branch name.

**Re-checked**: 2026-10-18

## `reconcile-commit-rule-with-spec`

`rules/development-workflow.md` directs a session to create commits, not propose them, and `openspec/specs/session-workflow/spec.md` still records the removed behaviour: the requirement at *A second change surfacing* directs "proposing a commit" on a handoff branch with a declined-commit path, and its scenario "A handoff is not left uncommitted on a branch the session leaves" expects "it has proposed a commit". Amend both to committing, and drop the declined path. Decide too whether the fragment's **Markdown prose** rule gets a requirement.

**Kind**: `change`. It owes a `session-workflow` delta, and the Markdown-prose question is the operator's.

**Waits on**: `nothing`.

**Design with**: `name-the-fragments-third-owner`, which amends the same specification.

**Recorded by**: the operator's instruction that agents commit without stopping, applied to the fragment directly without a change, which is why the spec was left behind.

**Re-checked**: 2026-10-18

## `name-the-fragments-third-owner`

`session-workflow`'s Purpose and its publication requirement name `session-workflow` and `project-bootstrap` as the workflow fragment's owners. `change-code-review` also governs one sentence of it, the content of `build`'s Claude Code binding, and an editor starting from `session-workflow` will not learn that. Name the third owner there.

**Kind**: `change`. It owes a `session-workflow` delta; too small to be a change alone, so it goes in with the next change amending that specification.

**Waits on**: `nothing`.

**Design with**: `reconcile-commit-rule-with-spec`.

**Recorded by**: `add-change-code-reviewer` (design decision 7 and Risks), which created the third owner and kept `session-workflow` out of its scope.

**Re-checked**: 2026-10-18



## `extend-dangling-reference-to-agent-names`

`tests/cases/workflow-fragment-no-dangling-reference.sh` scans the workflow fragment for `rules/` paths, fragment filenames and `@` imports, but not for an `ai-toolkit:` agent name with no file under `agents/`. That gap let `build`'s binding name a code reviewer that did not exist, and nothing would report a recurrence.

**Kind**: `change`. It owes a `session-workflow` delta to the publication requirement the case guards.

**Waits on**: `nothing`.

**Design with**: `nothing`.

**Recorded by**: `add-change-code-reviewer` (design decision 8), which split it out of its own backlog entry.

**Re-checked**: 2026-10-18

## `harden-build-binding-verdict-acts-case`

`tests/cases/workflow-fragment-build-binding-verdict-acts.sh` passes the binding to `awk -v`, which interprets backslash escapes, and its `has` helper matches act words as case-insensitive substrings, so "nonstop" satisfies "stop". Pass the text through `ENVIRON` or stdin, and match whole words.

**Kind**: `fix`. A test-only edit with no delta and no decision.

**Waits on**: `nothing`.

**Design with**: `nothing`.

**Recorded by**: `add-change-code-reviewer`'s code review, rounds 1 and 2; not applied there because a separate test author derived the case.

**Re-checked**: 2026-10-18

## `harden-the-test-runner`

`tests/run.sh` has no single-case selector, so running one case means exporting `TOOLKIT_ROOT`, `TESTLIB`, `PROJECT_INIT` and `TESTDIR` by hand. And it sets only `set -u`, where the `bash` skill's floor requires `set -euo pipefail`.

**Kind**: `fix`. Runner-only, no delta and no decision.

**Waits on**: `nothing`.

**Design with**: `describe-the-suite-as-it-is`.

**Recorded by**: `consolidate-development-workflow`'s `test-plan.md`, *Unresolved project questions*.

**Re-checked**: 2026-10-18

## `describe-the-suite-as-it-is`

`AGENTS.md` describes `tests/` as "a dependency-free harness exercising `scripts/`", but about half its cases never run `scripts/project-init`: they read `skills/`, `agents/` or `rules/` and assert what a file says. `tests/README.md` and `tests/coverage.md` carry the same description, so correcting one leaves the others to mislead. Decide whether static-read cases are in scope and say so in all of them, and settle whether an obsolete case is deleted or rewritten, which no convention records.

**Kind**: `change`. Both are the operator's decisions.

**Waits on**: `nothing`.

**Design with**: `harden-the-test-runner`.

**Recorded by**: `state-the-committed-artifact-situation`'s and `consolidate-development-workflow`'s `test-plan.md`, *Unresolved project questions*; outside both changes' Impact.

**Re-checked**: 2026-10-18

## `discriminate-every-scan-in-the-static-suite`

The four `tests/cases/testing-skill-*.sh` cases each run their check over the real tree and over one fixture built to be rejected, but one fixture trips several scans at once, so most scans would survive deletion undetected, and two negatives are green vacuously. First settle in the `testing` floor whether a case or a scan is "the check" a discriminator must falsify, then either build each fixture to trip exactly one scan or add a fixture per scan.

**Kind**: `change`. The floor question is a decision, and every consuming project meets it.

**Waits on**: `nothing`.

**Design with**: `record-the-discriminator-obligation-in-the-manifest`, which concerns the same discriminator bound.

**Recorded by**: `state-the-committed-artifact-situation`'s third code review; the accounting limit is stated in `tests/coverage.md`.

**Re-checked**: 2026-10-18

## `record-the-discriminator-obligation-in-the-manifest`

`change-test-authoring`'s manifest gains entries for what a fixture-driven discriminator falsifies, a check left without a discriminator, a discriminator written but not executable where it was authored, and a repeat pass carrying forward entries still outstanding. The carry-forward needs the earlier `test-plan.md`, an optional dispatch input the agent may not go looking for, so it either reaches the requirements bounding the agent's inputs or needs a dispatcher-facing signal. Key the exception to the check's state, not how the pass produced it.

**Kind**: `change`. It owes `change-test-authoring` deltas across several requirements, which six review rounds found too large to fold into the change that raised it.

**Waits on**: `nothing`.

**Design with**: `discriminate-every-scan-in-the-static-suite`.

**Recorded by**: `state-the-committed-artifact-situation` (proposal, *Non-Goals*; design decision 4).

**Re-checked**: 2026-10-18

## `share-a-suites-test-arrangement`

`skills/testing` gains guidance on a suite's shared test arrangement: where fixture builders live, when a bespoke one is warranted, how a keep is recorded, and how a pointer to a shared type is spelled so a later sweep can match it. Migration-sweep material goes in `skills/testing/references/`, which does not exist yet. `commerce-ops` has proved the body (`tests/support/`, a project-local skill, `docs/test-harness-sweeps.md`); promote its project-agnostic rules. `hand-missing-test-arrangement-to-apply` has since shipped how a derivation feeds a shared arrangement — the test writer's **Missing shared arrangement** manifest section and the promote-or-keep step in **apply** — so this entry covers what a good shared arrangement is, and how a kept double is marked in source, and refers to that section rather than restating it. Settle two things rather than inherit them: that consolidating a keep is its own change, since a test author only adds, and whether *a source comparison can only veto a migrate, execution only a keep* holds beyond Python.

**Kind**: `change`. Too large, and both questions are decisions.

**Waits on**: `nothing`.

**Design with**: `record-this-repositorys-shared-test-arrangement`.

**Recorded by**: `state-the-committed-artifact-situation` (proposal, *Non-Goals*; design decision 3, which folds this into `testing`).

**Re-checked**: 2026-10-19

## `evaluate-an-openspec-schema-for-our-artifacts`

`test-plan.md` and a reviewer's report are files the `spec-driven` schema does not know, so `openspec status` and `openspec instructions apply` never surface them, and `change-test-authoring` has to tell the agent to read `test-plan.md` deliberately. A custom or forked schema (OpenSpec documents `anvil`, which declares `test-plan.md`, `review.md` and `verify.md`) would surface them. Evaluate adopting or forking one, and what it costs every change; adding bespoke verdict files without a schema would bring back the ledger `consolidate-development-workflow` removed.

**Kind**: `change`. Adopting a schema is the operator's decision.

**Waits on**: `nothing`.

**Design with**: `nothing`.

**Recorded by**: `consolidate-development-workflow` (design decision 6; its archived `handoff.md`, the vocabulary survey).

**Re-checked**: 2026-10-18

## `oblige-removing-a-cold-run-worktree`

`agent-authoring` requires the cold-run check to run in an isolated git worktree and states no removal. The workflow's removal rules are keyed to a change, so a worktree carrying none falls outside them, and nothing obliges anyone to remove it. Add a removal clause to `agent-authoring`, or name what else takes the obligation.

**Kind**: `change`. It owes an `agent-authoring` delta.

**Waits on**: `nothing`.

**Design with**: `nothing`.

**Recorded by**: `add-session-workflow-fragments`, whose sixth review round found the collision.

**Re-checked**: 2026-10-18

## `record-this-repositorys-shared-test-arrangement`

This repository's `AGENTS.md` records no test command, test-path glob or shared test arrangement, so its own changes dispatch `change-test-writer` from values supplied by hand, and the arrangement audit's import check cannot run here. Record all three — `bash tests/run.sh`, `tests/cases/**`, and `tests/lib.sh` as the shared arrangement — then merge `tests/cases/lib/static-scan.sh` into `tests/lib.sh` (it lies inside the glob, so it is a test module) and move the scan helper `hand-missing-test-arrangement-to-apply`'s five cases each declare locally onto it. That change's `test-plan.md` lists the helper as kept for exactly this reason.

**Kind**: `change`. Moving the scan helpers edits existing tests beyond the bounded promotion permission, and which file is the shared arrangement is a testing-strategy decision.

**Waits on**: `nothing`.

**Design with**: `share-a-suites-test-arrangement`.

**Recorded by**: `hand-missing-test-arrangement-to-apply`, whose apply rule keeps every entry where the conventions record no shared arrangement.

**Re-checked**: 2026-10-19

## `run-the-remaining-arrangement-cold-runs`

`agents/change-test-writer.checks.yaml` and `agents/change-code-reviewer.checks.yaml` carry arrangement variants (b)–(d) and (b)–(e) that `hand-missing-test-arrangement-to-apply` did not run: conventions silent on the shared arrangement, stating none, recording no glob, no change name, and nothing missing. Run each and record any body revision it forces.

**Kind**: `fix`. No delta and no decision, unless a run fails — then the revision is a change of its own.

**Waits on**: `nothing`.

**Design with**: `nothing`.

**Recorded by**: `hand-missing-test-arrangement-to-apply` (design decision 10), which ran only variant (a) of each, by the operator's decision to limit usage.

**Re-checked**: 2026-10-19

## `enable-branch-auto-deletion`

A change's branch outlives its merged pull requests on the forge: `rules/development-workflow.md` removes it locally and on the remote only after the archive pull request merges, and a session can be refused that remote deletion, or end before it. GitHub's repository setting "Automatically delete head branches" (`delete_branch_on_merge`) removes a branch as each of its pull requests merges; the archive step's push recreates it, so the workflow is unaffected. Have `skills/project-init` offer to enable it, on the operator's confirmation since it changes a hosted repository: after step 5's first push in a new project, and in an adoption whose remote is already configured. Only a GitHub remote with `gh` authenticated; otherwise state that the setting is enabled by hand, without failing the run. `scripts/project-init` stays deterministic and touches no forge.

**Kind**: `change`. It owes a `project-bootstrap` delta to "A wrapper connects a remote only from a URL the operator supplies", whose wrapper today configures nothing on the hosted repository.

**Waits on**: `nothing`.

**Design with**: `nothing`.

**Recorded by**: the operator, after Basis's `add-identity-authentication` archive left other changes' merged branches on GitHub; it is this repository's work, not Basis's.

**Re-checked**: 2026-10-21

## `reconcile-the-status-row-verification-cell`

`session-workflow`'s *A session reports where its change stands before acting* requires the entering report to carry one further cell, the verification result, beyond the change, stage, task progress and committed state. `rules/development-workflow.md`'s row template and its example carry no such cell, so a session following the fragment prints a row the requirement calls incomplete. Decide which side is right, and bring the requirement or the fragment's row into line with it.

**Priority**: `normal`.

**Kind**: `change`. It owes a `session-workflow` delta, or a fragment edit and version increment, and the choice between them is the operator's.

**Waits on**: `nothing`. `add-workstreams`, archived 2026-10-24, gave the row its leading workstream cell and kept this disagreement as it found it.

**Design with**: `nothing`.

**Recorded by**: `add-workstreams`, whose plan review found the disagreement (2026-10-24); widening the row twice in one change was kept out of its scope.

**Re-checked**: 2026-10-24

## `count-a-fix-step-as-done`

A workstream step taken as a fix leaves no archived change, and its backlog entry is deleted when it is taken. By `docs/workstreams/README.md`'s status lookups it then reads as `planned` again, and **workstreams** names it as next. Work that is done reads as work to do, and a workstream whose Done when is "every step archived" can never be met while it holds a fix. commerce-ops's `adopt-workstreams` works around it locally: its `speed-up-the-test-suite` removes a fix step from Steps in the fix's own commit. Decide the rule for every project. Options: the seeded README directs that removal; a fix's merged pull request counts as `done`; or a workstream holds only changes.

**Priority**: `normal`.

**Kind**: `change`. It owes a `project-bootstrap` delta to *A workstream register is seeded where none exists*, and likely a `backlog-maintenance` delta to **workstreams**. The choice between the options is the operator's.

**Waits on**: `nothing`.

**Design with**: `nothing`.

**Workstream**: `nothing`.

**Recorded by**: commerce-ops's `adopt-workstreams` plan review (2026-10-24), which found four fix steps in one of its workstreams. The rule is the library's, not that project's.

**Re-checked**: 2026-10-24
