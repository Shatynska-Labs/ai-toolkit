# Test plan: establish-the-remote-and-the-first-commit

Written by the test-authoring pass before implementation. The OpenSpec schema does not know about this file, so `openspec instructions apply` does not list it. Read it deliberately before implementing.

## Runner-selectable identifiers

`bash tests/run.sh` takes no selection argument. It runs every case and prints `ok <name>` or `FAIL <name>` for each, so the identifier below is the case name, which is the file `tests/cases/<name>.sh`. To run one case on its own (this is an assumption, see Q2):

```
TESTLIB="$PWD/tests/lib.sh" TOOLKIT_ROOT="$PWD" PROJECT_INIT="$PWD/scripts/project-init" TESTDIR="$(mktemp -d)" bash tests/cases/<name>.sh
```

## Baseline

Full suite, taken before any case was written, from the working tree root at commit `279fb05`: `bash tests/run.sh` gave **90 passed, 0 failed**, exit 0.

After the 11 new cases were added: **91 passed, 10 failed**. The 10 failures are exactly the 10 static cases below. Each one fails on the property it asserts, not on a vacuity guard, and the 90 baseline cases still pass.

## Scenarios: 11 in the delta specs, 11 accounted for

| # | Delta spec, requirement | Scenario | Covered by | State at authoring |
|---|---|---|---|---|
| 1 | project-bootstrap, A wrapper offers the direct initial commit only to a repository without one... | The commit offer lists files the tool did not write | `project-init-skill-commit-offer-lists-untracked` | red: no listing of untracked paths not excluded by git |
| 2 | same | A file staged before the run is listed | `project-init-skill-commit-offer-lists-staged` | red: staged paths are not named |
| 3 | same | A declined commit leaves both gaps stated | `project-init-skill-declined-commit-states-gaps` | red |
| 4 | same | An adoption is not committed onto the trunk | `project-init-skill-adoption-not-committed` | red |
| 5 | project-bootstrap, A wrapper connects a remote only from a URL the operator supplies | A supplied URL is connected and pushed after confirmation | `project-init-skill-remote-connected-after-confirmation` | red: all three sub-checks fail |
| 6 | same | A rejected push is reported, not forced | `project-init-skill-rejected-push-not-forced` | red: all three sub-checks fail |
| 7 | same | Declining leaves the gap stated | `project-init-skill-declined-remote-states-gap` | red |
| 8 | same | An existing remote is left alone | `project-init-skill-existing-remote-left-alone` | red |
| 9 | same | The tool configures no remote | `project-init-configures-no-remote` | green, as expected (see below) |
| 10 | session-workflow, A repository's first commit is the one commit that reaches the trunk directly | The first commit is accounted for | `workflow-fragment-first-commit-exception` | red: no first-commit statement |
| 11 | same | A later commit cannot claim the exception | `workflow-fragment-first-commit-by-observable` | red: no first-commit exception stated |

Uncovered scenarios: none. Every scenario has a case. Several have a behavioural half that is deliberately left untested; it is listed under each case below.

### What each state establishes

- **Cases 1-8, 10, 11** are static reads of prose: the skill, which a model follows, and the fragment. They are red because the asserted property is absent, and each one names that property in its failure message. Red records which property is missing; it does not show that the prose drives a model correctly. Going green as the change lands shows each check discriminates on real content.
- **Case 9** runs `scripts/project-init`. The tool exists and this change does not touch it, so green on the first run is the expected result, not an alarm. It shows the current tool configures no remote.

### Fixture-driven discriminators

Every static case runs its check over a falsifying fixture it writes itself, built to carry a named near-miss. It requires the fixture to be rejected for the reason the case exists to assert. This runs **before** the committed file is checked, so it already executes while the main check is red, and it passed in every case.

As an extra check outside the suite, each of the ten checks was also run against a compliant scratch skill and fragment, and all ten passed. So no check fails unconditionally.

| Case | Near-miss the fixture carries |
|---|---|
| commit-offer-lists-untracked | offer lists only the tool's writes; "untracked" appears with no exclusion |
| commit-offer-lists-staged | offer lists untracked paths only; "stage" appears but not "staged" |
| declined-commit-states-gaps | decline names the initial commit but not the remote |
| adoption-not-committed | pre-change shape: commit offered in both modes |
| remote-connected-after-confirmation | origin added and pushed, but no upstream |
| rejected-push-not-forced | rejection reported with origin named, merge ruled out, then `git push --force` |
| declined-remote-states-gap | decline acknowledged, gap not named |
| existing-remote-left-alone | existing remote noticed, then replaced via `set-url` |
| first-commit-exception | exception stated in a different section from the delivery rule |
| first-commit-by-observable | observable stated together with the class "initialization commit" |

## Assertion classification

Static cases scan `skills/project-init/SKILL.md` as a whole file, line by line. That works because this repository writes one paragraph per line. Fragment cases scan the body of `rules/development-workflow.md` with the frontmatter stripped.

- **project-init-skill-commit-offer-lists-untracked**
  - SPECIFIED: untracked paths are named together with git's exclusions.
  - DERIVED: the anchors `untracked` and `ignor|exclu` must sit on one line.
  - DELIBERATELY UNTESTED: that the listing comes before the confirmation, and that a wrapper actually names a pre-existing file. This is behaviour, covered by the cold run in task 4.2.
- **project-init-skill-commit-offer-lists-staged**
  - SPECIFIED: staged paths are named in the offer.
  - DERIVED: the word `staged` must appear on a line with `commit`.
  - DELIBERATELY UNTESTED: the behaviour, for the same reason as above.
- **project-init-skill-declined-commit-states-gaps**
  - SPECIFIED: a declined commit is stated to leave both the first commit and a remote outstanding.
  - DERIVED: `declin`, `(first|initial) commit` and `remote` must sit on one line.
  - DELIBERATELY UNTESTED:
    - that no commit or remote exists afterwards (behaviour);
    - the clause "the first pull request needs both", which is in the requirement but not in this scenario's outcome.
- **project-init-skill-adoption-not-committed**
  - SPECIFIED: an adoption's writes are stated to reach the trunk through a pull request.
  - DERIVED: `adopt` and `pull request` must sit on one line.
  - DELIBERATELY UNTESTED:
    - that no commit is offered in an adoption: a prohibition and an instruction both name the commit, so a scan cannot tell them apart;
    - the adoption case with no remote, which the requirement states but no scenario carries.
- **project-init-skill-remote-connected-after-confirmation**
  - SPECIFIED: the remote `origin` is named; the push sets the upstream; a URL and a confirmation are asked for.
  - DERIVED: the anchors `\borigin\b`, `push` with `upstream|--set-upstream|-u`, and `URL` with `confirm`.
  - DELIBERATELY UNTESTED:
    - that the push waits for confirmation;
    - that the skill never creates a hosted repository or chooses its forge, owner, name or visibility. This is requirement text with no scenario.
    - Both are left to reading and to the cold run in task 4.2.
- **project-init-skill-rejected-push-not-forced**
  - SPECIFIED: a failed push is stated to leave `origin` naming the URL; forcing is prohibited; merging and rebasing are prohibited.
  - DERIVED: `push`, `reject|fail` and `origin` on one line; `force` next to a negation; `merg|rebas` next to a negation. A negation on the same line is weaker than an actual prohibition and is verified by reading.
  - DELIBERATELY UNTESTED: that the wrapper stops, and that it reports git's own words.
- **project-init-skill-declined-remote-states-gap**
  - SPECIFIED: declining is stated to leave the first pull request needing a remote with the trunk pushed to it.
  - DERIVED: `URL`, a decline token, `pull request`, `remote` and `push` on one line. `URL` is what separates this paragraph from the declined-commit one.
  - DELIBERATELY UNTESTED: that no remote is configured afterwards, and that the wrapper continues to the next step.
- **project-init-skill-existing-remote-left-alone**
  - SPECIFIED: an existing remote is stated to be left alone, with no URL asked for.
  - DERIVED: `already` and `remote` must sit on one line with `unchanged|leave|left|alone|not ask|skip`.
  - DELIBERATELY UNTESTED: that the remote is in fact unchanged (behaviour).
- **project-init-configures-no-remote**
  - SPECIFIED: a run in an empty directory ends in SUCCESS and leaves no remote.
  - DERIVED: "no remote" is read as two things: `git remote` succeeds with empty output, and `.git/config` has no `[remote` section.
  - DELIBERATELY UNTESTED: that nothing was pushed. With no remote, a push has nowhere this case could observe.
- **workflow-fragment-first-commit-exception**
  - SPECIFIED: the body states that the first commit reaches the trunk directly, beside the pull-request delivery rule.
  - DERIVED:
    - "beside" is read as within two lines of the first line matching `trunk through pull request`, which task 3.1 quotes;
    - the statement is located as a line containing both `first commit` and `direct`.
  - DELIBERATELY UNTESTED: "and that no other commit does", which is in the requirement but not in the scenario's outcome.
- **workflow-fragment-first-commit-by-observable**
  - SPECIFIED: the commit is identified by there being no commit before it, and none of setup, initialization, bootstrap or tooling is named. The four class words come from the scenario.
  - DERIVED:
    - the exception's statement is taken to be each sentence (split on `.`) that names the first commit and `direct`;
    - the observable is matched as `no commit ... before` or `no earlier/prior/previous/preceding commit`.
  - DELIBERATELY UNTESTED: class words outside the scenario's four.

## Obsolete tests

Not applicable. Every delta in both specs is `ADDED`; the change has no `MODIFIED` or `REMOVED` delta.

Related but not obsolete: version-coupled cases such as `managed-block-current-version` and `inlined-body-matches-fragment` read the version through the `fragment_version` helper. They do not hardcode 6, so the version change from 6 to 7 should not break them. This conclusion comes from reading those cases and was not run against version 7.

## Unresolved project questions

- **Q1. Is there a stack skill for this suite's idiom?** I loaded `bash` and followed the idiom of the existing static cases. Nothing is unresolved here beyond that.
- **Q2. How is a single case run?** `tests/run.sh` has no per-case selection. The environment variable names `TESTLIB`, `TOOLKIT_ROOT`, `PROJECT_INIT` and `TESTDIR` come from `tests/README.md` and from use in existing cases. The values in the single-case command above are assumed; the runner sets them, and I did not read it because it is outside the test-path glob. Every case's identifier depends on this. The full-suite command is authoritative.
- **Q3. Should `tests/coverage.md` be updated?** `tests/README.md` says that file maps scenarios to cases. It is outside the dispatched glob, so this pass did not touch it. Assumption: the implementer or the dispatcher updates it from this manifest. All 11 cases depend on this.
- **Q4. The skill's internal structure is not known.** Reading `skills/project-init/SKILL.md` would mean reading the implementation, so I did not. As a result the static cases scan the whole file by paragraph rather than the step sections. Assumption: the skill keeps one paragraph per line, as `AGENTS.md` requires. All eight `project-init-skill-*` cases depend on this. If a step's prose is split across lines, a co-occurrence check could fail a compliant skill. If so, record a change to a derived assertion; do not weaken a check.
- **Q5. `handoff.md` was not read.** It is in the change directory but was not among the dispatched artifact paths. No case depends on it.

## What implementation must make pass

All 10 red cases above, with no change to the test files:

- tasks 2.1 and 2.2: cases 1-8;
- task 3.1: cases 10 and 11;
- case 9 must stay green.

The 90 baseline cases must stay green as well.
