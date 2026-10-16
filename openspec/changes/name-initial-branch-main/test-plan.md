# Test plan: name-initial-branch-main

Derived by `ai-toolkit:change-test-writer` from the delta specs, and replaced wholesale on each pass. Commit references are to the rebased branch: plan `f20e519`, first derived cases `575b038`, implementation `db9b963`, symlink cases `4f7f12f`, fix `e875edb`. This file is not an artifact the OpenSpec schema knows about; it does not appear among `openspec instructions apply`'s context files and must be read on purpose.

## Selecting a case

`tests/run.sh` has no single-case selector; every case is a file named `tests/cases/<name>.sh`. One case runs alone from the worktree root as:

```
TESTDIR="$(mktemp -d)" TOOLKIT_ROOT="$PWD" TESTLIB="$PWD/tests/lib.sh" PROJECT_INIT="$PWD/scripts/project-init" bash tests/cases/<name>.sh
```

Every case isolates git configuration from the operator's own: `HOME` and `XDG_CONFIG_HOME` point into `$TESTDIR`, `GIT_CONFIG_NOSYSTEM=1`, and `GIT_CONFIG_GLOBAL`, `GIT_CONFIG_SYSTEM`, `GIT_CONFIG`, `GIT_CONFIG_COUNT`, `GIT_DIR` and `GIT_WORK_TREE` are unset.

## Baseline

All runs are the full suite, `bash tests/run.sh`, on git 2.43.0.

- Pass 1, at the plan commit (`f20e519`) before any case was added: 55 passed, 0 failed. After adding eight cases: 58 passed, 5 failed.
- Pass 2, at the implementation (`db9b963`) before the symlink cases: 63 passed, 0 failed. After adding two symlink cases: 63 passed, 2 failed.
- Pass 3, at the fix (`e875edb`) before this pass's cases: 65 passed, 0 failed (55 pre-existing + 10 `initial-branch-*`). After adding four cases: 66 passed, 3 failed.

Cross-revision runs: each pass-3 case was also run against `db9b963` and `f20e519`, each from a scratch `git archive` of that revision (scripts executed, not read). Results are in the state table below.

## Scenarios (4 in `specs/project-bootstrap/spec.md`, 4 accounted for)

| Scenario | Delta | Covered by |
|---|---|---|
| No configured default yields main | ADDED | `initial-branch-unconfigured-main`; `initial-branch-empty-dotgit-dir-initialized` |
| A configured default is honoured | ADDED | `initial-branch-configured-honoured`; `initial-branch-pre-2-28-git-emulated` |
| A configured default in an enclosing repository is not read | ADDED | `initial-branch-enclosing-config-ignored` |
| An existing repository's branch is left alone | ADDED | `initial-branch-existing-unborn-untouched`; `initial-branch-existing-with-commits-untouched`; `initial-branch-existing-via-symlink-cwd-untouched`; `initial-branch-existing-via-symlink-arg-untouched`; `initial-branch-existing-via-symlink-cwd-reported`; `initial-branch-existing-via-symlink-arg-reported` |

No scenario is uncovered.

### Requirement text with no scenario of its own, also covered

| Requirement clause | Covered by |
|---|---|
| "SHALL NOT rely on `git init --initial-branch` or on `git init` honouring `init.defaultBranch` ... the resulting branch SHALL be the same on an older git" | `initial-branch-pre-2-28-git-emulated` |
| "read as the created repository sees it, not as ... the caller's working directory sees it" | `initial-branch-caller-config-ignored` |
| "Where the initial branch cannot be set ... the run SHALL end in `ERROR` with a reason naming that step" | `initial-branch-set-failure-errors`; `initial-branch-invalid-configured-name-errors` |

### State of each case

Every red cell is state 1: the code ran and produced a wrong value.

| Case | `f20e519` (no impl) | `db9b963` (impl) | `e875edb` (fix) |
|---|---|---|---|
| `initial-branch-unconfigured-main` | red (`master`) | green | green |
| `initial-branch-configured-honoured` | green (git 2.43 honours config itself) | green | green |
| `initial-branch-enclosing-config-ignored` | red (`master`) | green | green |
| `initial-branch-caller-config-ignored` | red (`master`) | green | green |
| `initial-branch-pre-2-28-git-emulated` | red (`master`) | green | green |
| `initial-branch-set-failure-errors` | red (exit 0) | green | green |
| `initial-branch-existing-unborn-untouched` | green | green | green |
| `initial-branch-existing-with-commits-untouched` | green | green | green |
| `initial-branch-existing-via-symlink-cwd-untouched` | green | red (`main`) | green |
| `initial-branch-existing-via-symlink-arg-untouched` | green | red (`main`) | green |
| `initial-branch-empty-dotgit-dir-initialized` | red (`master`) | green | **red (`master`)** |
| `initial-branch-invalid-configured-name-errors` | red (exit 0, SUCCESS) | red (exit 0, SUCCESS) | green |
| `initial-branch-existing-via-symlink-cwd-reported` | not run | not run | **red (report lacks `repository: already present`)** |
| `initial-branch-existing-via-symlink-arg-reported` | not run | not run | **red (report lacks `repository: already present`)** |

Notes:

- `initial-branch-empty-dotgit-dir-initialized` was green on `db9b963` and is red on `e875edb`: the fix ("never set the branch of a `.git` that existed before init") also skips the branch step when the pre-existing `.git` is an empty directory, so the repository the tool creates there starts on `master`. This is a regression introduced by the fix.
- `initial-branch-invalid-configured-name-errors` passed on its first run at `e875edb`, which raised the fourth-state alarm. Investigated by running it against `db9b963` and `f20e519`: red on both, so it discriminates. It passes at `e875edb` because of the fix's own validation (reason: `repository: initial branch could not be set to '-x'; ...`).
- The two `-reported` cases assert repository-concern detection through a symlink. Pass 2 left that line out on the coordinator's direction; pass 3 adds it because the scenario's THEN states it ("the repository is reported `already present`"). Making them pass means changing how the repository concern is detected, not only the branch step.
- Pass-1 cases that were green before implementation also discriminate: `initial-branch-configured-honoured` is discriminated on modern git by `initial-branch-pre-2-28-git-emulated`; the two non-symlink `existing-*-untouched` cases were run once against a scratch fake `PROJECT_INIT` forcing `HEAD` to `main` and failed. No fake is in the suite.

## Assertion classification

| Case | Assertion | Classification |
|---|---|---|
| `initial-branch-unconfigured-main` | HEAD is `refs/heads/main` | specified (scenario) |
| `initial-branch-unconfigured-main` | precondition: `init.defaultBranch` not visible | derived (vacuity guard on isolation) |
| `initial-branch-configured-honoured` | HEAD is `refs/heads/trunk` with global `init.defaultBranch=trunk` | specified (scenario) |
| `initial-branch-enclosing-config-ignored` | HEAD is `refs/heads/main` with outer local `init.defaultBranch=outerbranch` | specified (scenario) |
| `initial-branch-enclosing-config-ignored` | precondition: outer's setting is visible from the target directory | derived (guard) |
| `initial-branch-caller-config-ignored` | HEAD is `refs/heads/main` when the caller's cwd repo sets `callerbranch` and the target is an argument | specified (requirement text) |
| `initial-branch-existing-unborn-untouched`, `initial-branch-existing-with-commits-untouched` | report contains `repository: already present`; HEAD still `refs/heads/develop` | specified (scenario) |
| `initial-branch-existing-via-symlink-{cwd,arg}-untouched` | HEAD of the real repository still `refs/heads/develop` | specified (scenario) |
| `initial-branch-existing-via-symlink-{cwd,arg}-untouched` | the existing commit is still reachable from HEAD | derived (guards against a re-init that leaves the commit orphaned) |
| `initial-branch-existing-via-symlink-{cwd,arg}-untouched` | the report line | deliberately untested in these two (pass-2 scope); now asserted by the `-reported` pair |
| `initial-branch-existing-via-symlink-{cwd,arg}-reported` | report contains `repository: already present`; HEAD still `refs/heads/develop` | specified (scenario THEN) |
| all four symlink cases | precondition: the link resolves to the repository on `develop` | derived (guard) |
| `initial-branch-empty-dotgit-dir-initialized` | HEAD is `refs/heads/main` after a run over an empty `.git` directory, no configured default | specified (scenario "No configured default yields main", with the requirement's "Where the tool initializes the repository"); that the tool initializes rather than refuses here is derived, because the delta spec does not itself say an empty `.git` leaves the repository concern unsatisfied |
| `initial-branch-empty-dotgit-dir-initialized` | precondition: git does not recognise the empty `.git` as a repository | derived (guard) |
| `initial-branch-pre-2-28-git-emulated` | HEAD is `refs/heads/trunk` under a git stub whose `init` rejects `-b`/`--initial-branch` and ignores `init.defaultBranch` | specified (requirement text); the emulation of pre-2.28 git is derived |
| `initial-branch-pre-2-28-git-emulated` | precondition: the stub's `git init` produces `master` despite config | derived (guard) |
| `initial-branch-set-failure-errors`, `initial-branch-invalid-configured-name-errors` | exit 1, `Outcome: ERROR` | specified (requirement text; exit code from the CLI contract in `tests/README.md`) |
| `initial-branch-set-failure-errors`, `initial-branch-invalid-configured-name-errors` | `Reason:` line contains `branch` (case-insensitive) | derived, because "a reason naming that step" fixes no wording |
| `initial-branch-invalid-configured-name-errors` | that `-x` is a branch that "cannot be set" | derived. `git symbolic-ref HEAD refs/heads/-x` succeeds on git 2.43; only `git check-ref-format --branch -x` (and modern `git init`) reject it. The case reads the requirement as "a name git rejects as a branch name cannot be set" |
| `initial-branch-invalid-configured-name-errors` | preconditions: stubbed `git init` succeeds despite the invalid setting; `git check-ref-format --branch -x` rejects `-x` | derived (guards) |
| `initial-branch-unconfigured-main`, `-configured-honoured`, `-enclosing-config-ignored`, `-caller-config-ignored`, `-pre-2-28-git-emulated` | exit 0 and `repository: created` | specified (the requirement applies on the created path; Decision 4 keeps the report contract unchanged) |

Deliberately untested:

- **A `.git` that exists but holds a corrupted repository (e.g. a garbage `HEAD`).** The scenario's precondition is a repository "whose `HEAD` names a branch", which this does not satisfy, and the delta spec does not say whether the tool should refuse, report, or leave it alone. No case written. Needs a spec decision (`openspec-update-change`) or an explicit instruction to add a derived case.
- `initial-branch-invalid-configured-name-errors` uses the old-git stub only. Without it, git 2.43's own `git init` rejects `-x`, so the failure happens in the repository-creation step, which the requirement's "after the repository was created" clause does not cover. No unstubbed variant is written.
- The error cases do not assert that `repository: created` is still reported alongside the ERROR (covered generally by `delegated-init-failure`); no case asserts the report does not name the branch (Decision 4 is a non-change).

## Obsolete tests

Not applicable: the change carries only an `ADDED` delta, no `MODIFIED` or `REMOVED`.

## Unresolved project questions

1. **`initial-branch-set-failure-errors` provokes the initial-branch failure with a `git symbolic-ref` stub.** It assumes the mechanism named in `design.md` Decision 2 and `tasks.md` 1.1; the requirement itself names no mechanism. Depends: `initial-branch-set-failure-errors`.
2. **Pre-2.28 git is emulated, not run**, and the emulation assumes git is invoked through `PATH`. Depends: `initial-branch-pre-2-28-git-emulated`, `initial-branch-invalid-configured-name-errors`.
3. **Whether `-x` counts as "cannot be set"** (see classification). Depends: `initial-branch-invalid-configured-name-errors`.
4. **Whether an empty `.git` directory is a target the tool initializes.** The existing `project-bootstrap` spec's repository-concern rules decide this, not this delta. Depends: `initial-branch-empty-dotgit-dir-initialized`.
5. **No single-case selector in `tests/run.sh`**; the invocation under *Selecting a case* reproduces `run.sh`'s environment by hand.
6. **`tests/coverage.md` is outside the test-path glob** `tests/cases/*.sh`; mapping the four pass-3 cases there is for the implementation step.
7. **Corrupted-`.git` behavior is unspecified** (see *Deliberately untested*).

## What the implementation must make pass

`bash tests/run.sh` green, specifically the three cases red at `e875edb`: `initial-branch-empty-dotgit-dir-initialized`, `initial-branch-existing-via-symlink-cwd-reported`, `initial-branch-existing-via-symlink-arg-reported`. The other eleven `initial-branch-*` cases and all 55 pre-existing cases must stay green.
