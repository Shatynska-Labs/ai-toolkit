# Scenario coverage

Accounts for every `#### Scenario:` in the delta specs of the changes that have shaped this suite — `add-project-workflow`, which established it, `revise-development-workflow`, which added 13 scenarios across two capabilities, `consolidate-development-workflow`, which replaced the `session-workflow` accounting entirely, and `state-the-committed-artifact-situation`, which added 14 scenarios to `testing-practice` and carried 8 through unchanged — per `change-test-authoring`'s counting form: covered by a named case, or uncovered with a reason. See `README.md` for why this suite is written directly rather than through `change-test-writer`, and for the second, narrower exemption `revise-development-workflow` records there.

Most scenarios this suite cannot cover are of one kind, and it is worth naming once rather than repeating per row: the harness exercises `scripts/project-init`'s runtime behavior, while several requirements constrain the *prose* of a fragment the script copies without interpreting. A property of that prose is not observable by running the script, so it is verified by reading — except where it can be made mechanical, which `fragment-role-before-tool.sh` does for the role-before-tool constraint. That is a stated limit of what this harness can reach, not an omission.

## specs/project-bootstrap/spec.md (48 scenarios)

| Scenario | Status |
|---|---|
| A non-skill-aware tool can use it | Covered — `help-output.sh` |
| An explicit target is acted on and stated | Covered — `explicit-target-argument.sh` |
| An unusable target blocks | Covered — `unusable-target-blocks.sh` |
| The entry point is not buried inside a skill | Uncovered — static filesystem layout, not tool runtime behavior; verified by directory listing |
| No Claude Code environment is present | Uncovered here — caller-side behavior (the resolution chain lives in the skill, not the script, per the spec's own split); verified manually by task 6.3 |
| A caller cannot resolve any root | Uncovered here — caller-side; verified manually by task 6.3 |
| The executable bit is not relied upon | Covered — `executable-bit-not-relied-upon.sh` (and implicitly, every other case invokes via `bash`) |
| Fragments come from the copy the script belongs to | Covered — `self-location-conflicting-env.sh` |
| Explicit root reaches the working tree through the caller | Uncovered here — caller-side; verified manually by task 6.3 |
| A machine consumer can branch on the result | Covered — implicitly by every case's `assert_exit` against the documented codes |
| A command missing for an already-satisfied concern does not block | Covered — `command-absent-satisfied-proceeds.sh` |
| The fragment is read even when nothing will be written | Covered — `fragment-absent-block-present-blocks.sh` |
| Missing fragment blocks rather than degrades | Covered — `fragment-absent-blocks.sh` |
| A wrapper cannot find the tool | Uncovered here — caller-side; verified manually by task 6.2/6.3 |
| Empty directory takes the new-project path | Covered — `empty-directory-new-project.sh` |
| Existing repository takes the adoption path | Covered — `adoption-no-foundation-change.sh`, `existing-git-and-openspec.sh` |
| A subdirectory of an existing repository is not treated as already initialized | Covered — `subdirectory-of-existing-repo.sh` |
| Repeated execution is not destructive | Covered — `repeated-execution-idempotent.sh` |
| A partially initialized directory is completed, not refused | Covered — `existing-git-no-openspec.sh` |
| Existing specification tooling is skipped, not reinitialized | Covered — `existing-git-and-openspec.sh` |
| Failure midway leaves a reported, recoverable state | Covered — `delegated-init-failure.sh`, `recovery-after-failure.sh` |
| A delegated command's writes are attributed, not concealed | Covered — `adoption-agents-md-diff-only.sh` |
| An existing ignore file is preserved exactly | Covered — `existing-gitignore-preserved.sh` |
| An existing conventions file receives only the managed block | Covered — `existing-agents-md-appended.sh` |
| Created ignore file carries no stack assumption | Covered — `gitignore-enumerated-entries.sh` |
| A project's adopted version is readable | Covered — `managed-block-current-version.sh` for the version marker, `inlined-body-matches-fragment.sh` for the body, which is compared against the fragment byte-for-byte. The latter guards faithful inlining by the script; it cannot detect a project whose block has fallen behind the toolkit, because the script always re-inlines from the current fragment |
| Project content below the block survives | Covered — `existing-agents-md-appended.sh` |
| A project with only a CLAUDE.md | Covered — `claude-md-only.sh` |
| Rules written but not yet loadable are reported as such | Covered — `empty-directory-new-project.sh`, `import-line-reported.sh` |
| An existing block at a different version is reported, not rewritten | Covered — `managed-block-older-version.sh` |
| Rules remain meaningful without the toolkit installed | Covered — `fragment-role-before-tool.sh`, which asserts mechanically that no harness-specific name appears outside a binding paragraph. Was review-only until `revise-development-workflow` made it checkable |
| A non-default harness is selected | Covered — `tools-passthrough.sh` |
| Completion is verifiable rather than asserted | Covered — implicitly, every `SUCCESS` case asserts against the report's enumerated form |
| Nothing is committed without confirmation | Covered — `empty-directory-new-project.sh` (asserts no commit exists after a bare run) |
| Discovery is named, not started | Covered — `empty-directory-new-project.sh` (asserts no foundation change directory exists) |
| Behavior is identical on a system shipping an older bash | Uncovered by this suite — requires an actual bash 3.2 host, which this runner does not have; verified instead by hand-review for 4.x-only constructs (tasks 5.17, 5.19) and ShellCheck (5.16, 5.18) |
| A plausible wrong tool is excluded by name | Covered — `fragment-role-before-tool.sh` (asserts a negative binding is stated) |
| An excluded tool's own contract is what the exclusion rests on | Uncovered — the reason's *accuracy* against `agents/change-plan-reviewer.md` is a judgment, not a string match; verified by reading |
| A stage boundary names an observable rather than a stage | Uncovered — a property of the fragment's prose; verified by reading |
| An obligation dispatched against incomplete inputs is prevented, not merely discouraged | Uncovered — prose property; verified by reading |
| A missing precondition halts rather than annotates | Uncovered — prose property; verified by reading |
| An exemption stated in advance is not a gap noted at the gate | Uncovered — prose property; verified by reading |
| A gate does not foreclose a change that structurally cannot satisfy it | Uncovered — prose property; verified by reading, against `project-foundation`'s stated exemption |
| The bound is reached rather than exceeded | Uncovered — prose property; verified by reading |
| The bound survives the binding being absent | Uncovered — prose property; verified by reading |
| A non-revisable outcome exits rather than iterates | Uncovered — prose property; verified by reading |
| An edited fragment is distinguishable from the copy already adopted | Covered — `managed-block-older-version.sh`, which now reads the tool's version from the fragment via `fragment_version` rather than asserting a literal |
| A frontmatter-only edit does not consume a version | Uncovered — an obligation on a future author, not behavior `project-init` exhibits; verified by reading `rules/README.md` |

## specs/project-foundation/spec.md (33 scenarios)

All 33 are uncovered by `tests/cases/`, for the same reason: this directory exercises `scripts/project-init` only (per section 4's own scope note), and every foundation scenario describes conversational or skill behavior (`skills/project-foundation/`) with no deterministic script to run against it. Verified instead by: manual skill trigger-checks (task 8.5), and structural review of `skills/project-foundation/SKILL.md` and `rules/project-foundation.md` against the spec's requirements (section 6).

| Scenario | Verified by |
|---|---|
| A non-skill-aware tool follows the same procedure | Structural review — the checklist lives in a fragment, readable independently |
| The checklist does not accumulate in projects | Structural review — `rules/project-foundation.md` is `kind: procedural-checklist`, never inlined |
| Non-goals are recorded even when scope is clear | Structural review — `rules/project-foundation.md` states this explicitly |
| Stack-specific ignore entries are a foundation deliverable | Structural review — task 6.6 |
| The quality layer is reached even when nobody raises it | Structural review — `rules/project-foundation.md`'s named concerns, proposed as one set |
| The checklist names concerns, not tools | Structural review — `rules/project-foundation.md` names no particular tool |
| A technical decision is proposed rather than asked | Structural review — `skills/project-foundation/SKILL.md`'s classification |
| An identity decision is not invented | Structural review — same |
| A skipped decision is detectable after the fact | Structural review — the fixed `design.md` section set (task 6.5) |
| A decision absorbed into a shared section stays visible | Structural review — the `Identity` and `Development Tooling` named-item requirement (task 6.5; `require-code-quality-tooling-in-foundation` 1.5) |
| A concern that does not apply is answered, not skipped | Structural review — `rules/project-foundation.md`'s "not applicable" rule beside the section layout |
| Descriptive decisions reach README.md | Structural review — `rules/project-foundation.md`'s README.md routing |
| Operationally load-bearing decisions reach AGENTS.md | Structural review — `rules/project-foundation.md`'s AGENTS.md routing |
| A decision is not placed by which audience happens to value it | Structural review — `rules/project-foundation.md` states the auto-load criterion |
| design.md remains the canonical record | Structural review — `rules/project-foundation.md`: "in addition to — never instead of" |
| A conversation resumed in a new session loses nothing | Structural review — task 6.7's incremental-persistence instruction |
| Artifacts are produced by the existing mechanism | Structural review — task 6.7 |
| Test authoring is skipped for a stated reason | Structural review — `rules/project-foundation.md` (section 2) |
| The exemption does not extend past foundation | Structural review — same |
| Continuous integration that cannot reach a dependency fails | Structural review — `rules/project-foundation.md`'s fixed positions |
| A hook is not recorded as the gate | Structural review — same |
| Secrets are excluded by the ignore file | Structural review — same, and the ignore-entries deliverable |
| A hook stand-down names what decides it | Structural review — same |
| The policy is recorded without being applied | Structural review — `rules/project-foundation.md`'s branch-protection rule |
| Protection is applied with the operator's confirmation | Structural review — same |
| Protection decided against creates no application task | Structural review — same |
| Archived decisions are not left unbuilt | Structural review — `rules/project-foundation.md`'s successor-change rule |
| The test runner has an owner | Structural review — same |
| Foundation does not build the tooling itself | Structural review — same |
| Tooling already present needs no successor | Structural review — same |
| The successor is not exempt from test authoring | Structural review — same |
| Lifecycle position is derived, not stored | Structural review — no state file exists anywhere in this change |
| A later architectural change is not a violation | Structural review — `rules/project-foundation.md` states this explicitly |

## specs/toolkit-structure/spec.md delta (27 scenarios)

Of the 27, the one this change adds — "The increment rule has exactly one owner" — is uncovered: it asserts that a normative obligation is stated in exactly one capability, which is a property of two specification files rather than of anything `scripts/project-init` does. Verified by reading both, and by `rules/README.md` naming the owner.

The other 26 are uncovered by `tests/cases/` — every one describes repository layout, documentation content, or plugin-installation behavior, none of which `scripts/project-init` exercises at runtime. Verified instead by direct inspection (this session already confirmed several empirically: the plugin cache contents in section 1, `rules/README.md` and `AGENTS.md` content in section 7) and by `openspec validate --strict`, which confirms every `MODIFIED` header matches an existing requirement and no scenario already in `specsRoot` was dropped.

## specs/session-workflow/spec.md (65 scenarios)

Rewritten by `consolidate-development-workflow`. The three fragments the previous accounting described — `worktree-isolation.md`, `change-delivery.md` and `deferred-work.md` — no longer exist: their obligations are sections of `rules/development-workflow.md` v3, with the database binding beside it as `rules/development-workflow-database.md`. Six cases went with them; the per-scenario ledger is in that change's `test-plan.md`.

The deliverable is still markdown rather than an executable, so the scenarios divide the same way: a property of the finished files, or a description of what an agent following them would do.

**None covered in full.** That is a fact about the harness rather than a gap. This capability governs what a document must *say*, so every scenario carries a prose half a shell case cannot reach — the limit this file already records above.

**Twenty-two covered in part.** Twenty-one cases bear on this capability, of which nineteen cover at least one scenario:

`workflow-fragment-publication-set.sh`, `workflow-fragment-states-assumptions.sh`, `workflow-fragment-stage-vocabulary.sh`, `workflow-fragment-fixed-paths.sh`, `workflow-fragment-service-neutral.sh`, `workflow-fragment-worktree-root.sh`, `workflow-fragment-names-handoff.sh`, `workflow-fragment-commit-bypass.sh`, `workflow-fragment-no-mandated-ledger.sh`, `workflow-fragment-omits-setup-obligations.sh`, `workflow-fragment-confirmation-waiver.sh`, `workflow-fragment-trunk-return.sh`, `workflow-fragment-no-cold-run-exclusion.sh`, `workflow-fragment-deploy-is-only-path.sh`, `workflow-fragment-stage-names-are-current.sh`, `workflow-fragment-no-proposal-only-branch.sh`, `database-fragment-affordance-before-obligation.sh`, `database-fragment-per-working-tree.sh` and `database-fragment-frontmatter.sh`. Each names its unasserted half in the manifest.

Two cases bear on the capability and cover no scenario, which is recorded so their absence from the ledger is not read as absence from the suite: `database-fragment-migrate-is-not-seed.sh` asserts requirement text no scenario names, and `workflow-fragment-no-dangling-reference.sh` guards a property stated across requirements rather than in one.

**Forty-three uncovered**, for the two reasons this file already gives: most describe what a session *does* — report verification as not run rather than as a pass, wait for a confirmation rather than infer it, halt teardown on uncommitted work — and there is no program here to run them against; the rest are properties of prose that a token scan cannot tell from a mention.

One is worth naming individually, because it is untestable by any harness rather than by this one:

- **"A second publication does not arrive unowned"** constrains what this capability's own specification must own when a publication that does not exist is written. There is no artifact to assert against.

The code-review bound of three is deliberately untested rather than untestable: the fragment states a different bound — six rounds — for the plan-review loop, and no lexical scan tells which loop a number belongs to. This is the same shape as the declined namespace-release check the previous accounting recorded.

A note on what a case here may assert, learned by writing one that failed: the *transitions* are a closed set and may be asserted individually, but the derived state names may not. The requirement forbids the fragment enumerating them, so a case demanding a particular derived name would fail a compliant fragment. `workflow-fragment-stage-vocabulary.sh` reads the transition list and the derivation rule for that reason.

## specs/change-review/spec.md delta (13 scenarios)

`consolidate-development-workflow` renames the four recommended actions to `APPROVED`, `CONDITIONALLY APPROVED`, `FIX REQUIRED` and `REJECTED`. Four requirements name a verdict token and all four carry a delta.

**Six covered in part** by `review-verdict-vocabulary.sh`, which asserts that no superseded verdict name survives in a published agent or its recorded fixtures. It caught a real one: the cold-run fixture's planted instruction still demanded `PROCEED`, a verdict the rename removes, which would have made the check pass for the wrong reason.

**Seven uncovered.** They describe what a reviewer does with a verdict — which one a clean review reports, how severity maps to an action — and there is no program here to run them against.

## specs/change-test-authoring/spec.md delta (10 scenarios)

`consolidate-development-workflow` renames the artifact from `test-manifest.md` to `test-plan.md`. Six requirements name the filename and all six carry a delta.

**Three covered in part** by `test-plan-artifact-name.sh`, which asserts that a `rules/` fragment and an `agents/` contract each name `test-plan.md` and that no shipped asset still names the superseded file. It caught three survivals in a recorded fixture.

**Seven uncovered**, describing what the agent does with the artifact rather than what the artifact is called.

## specs/testing-practice/spec.md (22 delta scenarios)

`state-the-committed-artifact-situation` renames one requirement and modifies three: *The Skill States the Situations It Can Be Entered In* (13 scenarios), *Failure States Are Defined by What They Establish, Not by the Machinery That Produced Them* (5), and *Asserted Behavior Is Separated into Specified, Derived, and Deliberately Untested* (4).

**Ten covered, with a stated limit.** Mutation shows each case establishes its check can fail on the one property its attribution names, and 9 of the 13 scans across the four cases survive deletion undetected — so "covered" here means the scenario has a scan, not that the scan is itself discriminated. `docs/backlog.md`'s `discriminate-every-scan-in-the-static-suite` carries the gap. The four cases each read `skills/testing/SKILL.md` under a root it is given and runs its own check twice — once over `$TOOLKIT_ROOT`, once over a fixture it writes that the check must reject, naming which scan the rejection has to come from:

- `testing-skill-three-situations.sh` — the third situation, the separator, and the two-way phrasings it retires.
- `testing-skill-discriminator-obligation-placement.sh` — the obligation and the term stated where the obligation is, and the negative result's outcome.
- `testing-skill-failure-states-situation-conditioned.sh` — the enumeration conditioned on the situation rather than on the target's presence.
- `testing-skill-discriminator-bound.sh` — the bound stated by what a case falsifies, and no quantity.

**Twelve uncovered**, in two kinds. Six are scenarios the `MODIFIED` operation carries through verbatim — behaviour this change does not alter, and its scope clause owes no retrofit. Six are propositions the delta obliges without fixing any token to scan for; they are of the same kind this file names once above, a property of prose rather than of behaviour.

Full scenario-to-test mapping, assertion provenance and the two disclosures that pass recorded are in `state-the-committed-artifact-situation`'s `test-plan.md`, which archives with the change; this section is what survives it.

## specs/project-bootstrap/spec.md — initial branch (4 delta scenarios)

`name-initial-branch-main` adds *A repository the tool creates starts on a stated branch*. All four scenarios are covered, each case isolating git configuration under `$TESTDIR`:

- **No configured default yields main** — `initial-branch-unconfigured-main.sh`; the caller's-directory clause by `initial-branch-caller-config-ignored.sh`.
- **A configured default is honoured** — `initial-branch-configured-honoured.sh` on the installed git, and `initial-branch-pre-2-28-git-emulated.sh` with a fake `git` whose `init` ignores `init.defaultBranch`, which is the case that discriminates on a git 2.28 or newer.
- **A configured default in an enclosing repository is not read** — `initial-branch-enclosing-config-ignored.sh`.
- **An existing repository's branch is left alone** — `initial-branch-existing-unborn-untouched.sh` and `initial-branch-existing-with-commits-untouched.sh`.

The `ERROR` clause for a failed branch step is covered by `initial-branch-set-failure-errors.sh`, which assumes the mechanism `design.md` names (`git symbolic-ref`).

Code review found a target reached through a symlink bypassing the repository check; `initial-branch-existing-via-symlink-{cwd,arg}-untouched.sh` (branch) and `initial-branch-existing-via-symlink-{cwd,arg}-reported.sh` (`already present`) cover that path under the same scenario. `initial-branch-empty-dotgit-dir-initialized.sh` covers an empty `.git` taking the created path, and `initial-branch-invalid-configured-name-errors.sh` the `ERROR` clause for a configured name that is not a valid branch. Round 3 added `initial-branch-caller-git-dir-env-untouched.sh` (inherited `GIT_DIR` does not reach the caller's repository), `initial-branch-missing-head-not-rewritten.sh` and `initial-branch-corrupted-head-not-rewritten.sh` (a `.git` with content is not given a branch), and `target-line-symlink-as-given.sh` (`Target:` keeps the path as given).

## specs/project-bootstrap/spec.md and specs/session-workflow/spec.md — seeded backlog (16 delta scenarios)

`seed-the-backlog` adds *A backlog is seeded where none exists*, adds the backlog to *Each concern is checked independently and is safe to repeat*, and revises *A second change surfacing in a session is recorded in the backlog*. Its cases were derived by `ai-toolkit:change-test-writer`; the per-scenario accounting, and which assertions are derived from `design.md` rather than the specification, are in the change's `test-plan.md`.

- **A project without a backlog receives the seeded file** — `backlog-seeded-new-project.sh`, `backlog-seeded-adoption.sh`.
- **An existing backlog is preserved exactly** — `backlog-existing-preserved.sh`, and `backlog-dangling-symlink-not-written-through.sh` for a link that does not resolve.
- **The seeded file carries no numbering** — `backlog-seeded-no-entry-numbering.sh` (`add-backlog-skill` retired `backlog-seeded-no-numbering.sh`, whose scan for the word `number` anywhere failed the revised file's "line numbers").
- **Repeated execution is not destructive** — `repeated-execution-backlog.sh` for the backlog, `repeated-execution-idempotent.sh` for the rest.
- **A partially initialized directory is completed, not refused** — `partial-init-reports-backlog.sh`.
- **The backlog does not yet exist**, **A backlog entry is cited by name**, **Entry rules are read from the backlog, not the fragment** — `workflow-fragment-backlog-not-created-by-fragment.sh`, `workflow-fragment-backlog-no-entry-numbers.sh`, `workflow-fragment-backlog-rules-not-restated.sh`, each checked against a violating and a compliant fixture, plus the seeded-file cases above.

`workflow-fragment-fixed-paths.sh` lost its cite-by-number assertion, which the revised requirement forbids. `backlog-report-line-after-ignore-file.sh` and `backlog-write-failure-errors.sh` trace to `design.md` and `tasks.md` rather than to a scenario. The remaining session-workflow scenarios are unchanged by this delta and keep their accounting above.

## specs/change-code-review/spec.md (25 delta scenarios)

`add-change-code-reviewer` adds the `change-code-review` capability. Its scenarios describe what a code review establishes and what a session does with the verdict, so what a case can reach is the fixed vocabulary and sentence each outcome requires to exist in `agents/change-code-reviewer.md` or `rules/development-workflow.md`, not the review itself. 13 are covered in part, 12 uncovered. Each case runs its check over `$TOOLKIT_ROOT` and over a fixture it writes that the check must reject:

- `change-code-reviewer-verdict-set.sh` — the four verdicts.
- `change-code-reviewer-finding-vocabulary.sh` — the three severities and seven kinds.
- `change-code-reviewer-traceability-markers.sh` — the implementation and coverage marks, the reason-bearing `[Uncovered —` and `[Exempt —` forms included.
- `change-code-reviewer-no-edit-grant.sh` — no edit-capable tool in the grant (derived from the frontmatter in the change's design, not from the spec).
- `workflow-fragment-build-binding-verdict-acts.sh` — `build`'s binding names the act for each verdict.

The 12 uncovered scenarios are the reviewer's conduct on a dispatch — blocking, restoring, locating, judging a quoted instruction — which no program here runs; the cold-run check exercises them instead. Full scenario-to-test mapping is in `add-change-code-reviewer`'s `test-plan.md`, which archives with the change; this section is what survives it.

## establish-the-remote-and-the-first-commit (11 delta scenarios)

`establish-the-remote-and-the-first-commit` adds two `project-bootstrap` requirements on what the `project-init` skill does after a successful run, and one `session-workflow` requirement on the fragment's first-commit exception. Ten scenarios constrain prose a model follows, so each case checks that `skills/project-init/SKILL.md` or `rules/development-workflow.md` states the step, over `$TOOLKIT_ROOT` and over a fixture it writes that the check must reject; that a wrapper following the skill behaves so is checked by the change's cold run, not here. One is runtime behaviour of the script:

- `project-init-skill-commit-offer-lists-untracked.sh`, `project-init-skill-commit-offer-lists-staged.sh` — the commit offer lists untracked paths git does not exclude, and staged paths.
- `project-init-skill-declined-commit-states-gaps.sh` — a declined commit states the first commit and a remote outstanding.
- `project-init-skill-adoption-not-committed.sh` — an adoption's writes reach the trunk through a pull request.
- `project-init-skill-remote-connected-after-confirmation.sh`, `project-init-skill-rejected-push-not-forced.sh`, `project-init-skill-declined-remote-states-gap.sh`, `project-init-skill-existing-remote-left-alone.sh` — the remote step.
- `project-init-configures-no-remote.sh` — the script itself configures no remote.
- `workflow-fragment-first-commit-exception.sh`, `workflow-fragment-first-commit-by-observable.sh` — the exception sits beside the delivery rule and is identified by there being no commit before it, naming no class of commit.

Full scenario-to-test mapping is in the change's `test-plan.md`, which archives with it.

## add-backlog-skill (30 delta scenarios)

`add-backlog-skill` adds the `backlog-maintenance` capability (17 scenarios), modifies *A backlog is seeded where none exists* in `project-bootstrap` (5), and in `session-workflow` modifies *A rule states an action and a defect appears only as its reason* and adds *Archiving a change re-reads the backlog against it* (8). Its cases were derived by `ai-toolkit:change-test-writer`; the per-scenario accounting, the half of each scenario a case does not reach, and which assertions are derived rather than specified are in the change's `test-plan.md`. 9 are covered, 18 covered in part, 3 uncovered.

- **Seeded backlog** — `backlog-seeded-structured-statements.sh`, `backlog-seeded-structured-fields.sh`, `backlog-seeded-kind-definition.sh`, `backlog-seeded-no-entry-numbering.sh`, with `backlog-seeded-new-project.sh` (its `Depends on` assertion removed, as the revised shape no longer names it) and the existing preservation cases.
- **Archive re-read** — `workflow-fragment-archive-backlog-reread.sh`, `workflow-fragment-archive-reread-names-no-field.sh`.
- **The skill** — `backlog-skill-*.sh`, one or two per requirement (identity and absent-backlog share the first, restates-no-entry-rule and no-audit-cadence the second), each a static scan of `skills/backlog/SKILL.md` or `skills/backlog/references/audit.md` through `tests/cases/lib/static-scan.sh`, checked against a conforming fixture and one mutant per scan. What a session does when it runs an operation is not reachable by a scan.
- **Uncovered** — the three scenarios *A rule states an action…* carries over verbatim; their accounting above is unchanged.

## retire-the-claude-md-import-notice (1 MODIFIED requirement, 8 scenarios)

`retire-the-claude-md-import-notice` modifies *Workflow rules reach a project as a versioned managed block*: the import line is owed only where a shadowing file exists and the target's `CLAUDE.md` doesn't import `AGENTS.md`, and a version note replaces it where none exists. Of its eight scenarios, four are unchanged and keep their cases above (`managed-block-current-version.sh`, `existing-agents-md-appended.sh`, `claude-md-only.sh`, `managed-block-older-version.sh`). The rest:

- **Rules written but not yet loadable are reported as such** (revised) — `import-line-reported.sh`, `import-line-names-own-claude-md.sh`.
- **A shadowing file above the target is reported like one in it** — `shadowing-claude-md-above-target.sh`, `shadowing-claude-md-in-enclosing-repo.sh`.
- **The user's own instructions file does not shadow** — `home-dot-claude-does-not-shadow.sh`.
- **No CLAUDE.md yields a version note, not an instruction** — `no-shadowing-file-version-note.sh`, and `empty-directory-new-project.sh`, whose import assertion this change reversed.

From the requirement's definition of a shadowing file rather than a scenario: `shadowing-claude-local-md-in-target.sh`, `shadowing-dot-claude-in-target.sh`, `shadowing-claude-local-md-above-target.sh`, `shadowing-dot-claude-above-target.sh`, `shadowing-importing-claude-md-above-target.sh`, `home-root-claude-md-shadows.sh`, and `claude-md-import-states-nothing.sh`. The note cases check that no shadowing file exists above `$TESTDIR` first, and fail with that reason rather than reporting a script defect. Full mapping is in the change's `test-plan.md`.

## fold-small-work-in (26 delta scenarios)

`fold-small-work-in` adds *Small adjacent work is folded into the change that found it* (4) and *A change takes the backlog entries it can fold in* (3) to `session-workflow`, and modifies *A second change surfacing in a session is recorded in the backlog* there (11), *Out-of-scope edits are reported as scope* in `change-code-review` (5), and *Record writes an entry the file can be relied on for* in `backlog-maintenance` (3). Its cases were derived by `ai-toolkit:change-test-writer`; the per-scenario accounting and which assertions are derived rather than specified are in the change's `test-plan.md`. 15 scenarios are reached by the new cases, most in part, since each reads the stated text rather than a session's conduct; 8 carried over unchanged keep their existing cases; 3 are uncovered.

- **Fold-in rule and routing** — `workflow-fragment-fold-in-conditions.sh`, `workflow-fragment-fold-in-own-commit.sh`, `workflow-fragment-fold-in-named-in-pr.sh`, `workflow-fragment-second-change-excludes-folded.sh`, `workflow-fragment-routing-recording-owed.sh`.
- **Backlog pickup at apply** — `workflow-fragment-apply-backlog-pickup.sh`, `workflow-fragment-apply-pickup-names-no-field.sh`.
- **The reviewer's exemption** — `change-code-reviewer-fold-in-exemption.sh`, `change-code-reviewer-fold-in-reviewed.sh`. Whether the reviewer applies it is the cold-run check's to establish (`agents/change-code-reviewer.checks.yaml`), not a scan's.
- **Record's fold-in test** — `backlog-skill-record-fold-in.sh`.
- Each fragment case finds its paragraph through `tests/cases/lib/line-scan.sh`, and is checked against a conforming fixture and one mutant per scan.
- **Uncovered** — *A blocking dependency survives the session ending*, *A handoff is not left uncommitted on a branch the session leaves* and *A deferral outlives the change that recorded it*, carried over verbatim; their accounting is unchanged.

## add-a-backlog-priority (31 delta scenarios)

`add-a-backlog-priority` modifies *A backlog is seeded where none exists* in `project-bootstrap` (8 scenarios) and *Record writes an entry the file can be relied on for*, *Pick lists what can be taken now*, *Sweep performs the archive step's re-read*, *Audit verifies every entry independently and changes nothing without the operator* and *Entries in an older shape are reported, not rewritten* in `backlog-maintenance` (23). Its cases were derived by `ai-toolkit:change-test-writer`; the per-scenario accounting, and which assertions are derived rather than specified, are in the change's `test-plan.md`. 14 scenarios are reached by the new cases, the skill's in part, since each reads the stated text rather than a session's conduct; 17 carried over unchanged keep their existing cases; none is uncovered.

- **Seeded Priority** — `backlog-seeded-priority-statements.sh`, `backlog-seeded-priority-field.sh`, `backlog-seeded-priority-values.sh`, `backlog-seeded-priority-no-low.sh`, `backlog-seeded-priority-transitions.sh`. `backlog-seeded-structured-statements.sh` now asserts the revised archive statement, `unblocked, unparked or made stale`.
- **The skill** — `backlog-skill-record-priority.sh`, `backlog-skill-pick-priority.sh`, `backlog-skill-sweep-priority.sh`, `backlog-skill-audit-priority.sh`, `backlog-skill-older-shape-priority-default.sh`, and `backlog-skill-priority-not-restated.sh`, which forbids the skill restating the file's Priority rule and traces to `design.md` rather than to a scenario.

## add-workstreams (75 delta scenarios)

`add-workstreams` modifies two requirements in `project-bootstrap`, *Each concern is checked independently and is safe to repeat* and *A backlog is seeded where none exists*, and adds *A workstream register is seeded where none exists* there (19 scenarios in all). In `session-workflow` it modifies *A session reports where its change stands before acting* and adds *A change states the workstream it advances, and archiving re-reads it* (13). In `backlog-maintenance` it modifies seven requirements (the skill's identity, its seam, record, pick, close, sweep, audit) and adds *Workstreams reports where each workstream stands* (43). Its cases were derived by `ai-toolkit:change-test-writer`. The per-scenario accounting, which assertions are derived rather than specified, and the dispositions of the arrangement it declared locally are in the change's `test-plan.md`. 71 scenarios are covered. The skill's and the fragment's are covered in part, since each case reads the stated text rather than a session's conduct. 4 are uncovered.

- **The seeded register** — `workstreams-seeded-new-project.sh`, `workstreams-seeded-adoption.sh`, `workstreams-existing-preserved.sh`, `workstreams-dangling-symlink-not-written-through.sh`, `repeated-execution-workstreams.sh`, `partial-init-reports-workstreams.sh`, `workstreams-seeded-statements.sh`, `workstreams-seeded-no-status-field.sh`, `workstreams-seeded-precedence.sh`, `workstreams-seeded-order-gates-nothing.sh`, `workstreams-seeded-archive-on-done.sh`, `workstreams-seeded-abandoned.sh`. `workstreams-report-line-after-backlog.sh` and `workstreams-write-failure-errors.sh` trace to `design.md` and `tasks.md` rather than to a scenario.
- **The backlog's Workstream field** — `backlog-seeded-workstream-field.sh`, `backlog-seeded-workstream-default.sh`.
- **The fragment** — `workflow-fragment-status-row-workstream-first.sh`, `workflow-fragment-status-row-workstream-source.sh`, `workflow-fragment-draft-names-workstream.sh`, `workflow-fragment-archive-workstream-reread.sh`, `workflow-fragment-workstream-rules-not-restated.sh`, `workflow-fragment-backlog-routing-names-no-workstream.sh`.
- **The skill** — `backlog-skill-absent-workstream-register.sh`, `backlog-skill-workstream-rules-not-restated.sh`, `backlog-skill-identity-workstreams.sh`, `backlog-skill-record-workstream.sh`, `backlog-skill-pick-workstream.sh`, `backlog-skill-close-workstream.sh`, `backlog-skill-sweep-workstream.sh`, `backlog-skill-audit-workstream.sh`, `backlog-skill-workstreams-operation.sh`.
- **Uncovered** — *A session resumes a working tree left by another session*, *A session reports on the way out as well as the way in*, *An unprovisioned working tree's green is not reported as a result* and *The report is derived rather than recalled*, carried over verbatim. Their accounting is unchanged. The entering report's verification cell is deliberately unasserted: `reconcile-the-status-row-verification-cell` carries it.
