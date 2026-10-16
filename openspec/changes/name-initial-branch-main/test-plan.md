# Test plan: name-initial-branch-main

Derived by `ai-toolkit:change-test-writer` from the delta specs at plan commit `2cd4a9c`, before implementation, and replaced wholesale by a second pass at `08d6555` (implementation committed) after code review found the symlink gap. This file is not an artifact the OpenSpec schema knows about; it does not appear among `openspec instructions apply`'s context files and must be read on purpose.

## Selecting a case

`tests/run.sh` has no single-case selector; every case is a file named `tests/cases/<name>.sh`. One case runs alone from the worktree root as:

```
TESTDIR="$(mktemp -d)" TOOLKIT_ROOT="$PWD" TESTLIB="$PWD/tests/lib.sh" PROJECT_INIT="$PWD/scripts/project-init" bash tests/cases/<name>.sh
```

Every case isolates git configuration from the operator's own: `HOME` and `XDG_CONFIG_HOME` point into `$TESTDIR`, `GIT_CONFIG_NOSYSTEM=1`, and `GIT_CONFIG_GLOBAL`, `GIT_CONFIG_SYSTEM`, `GIT_CONFIG`, `GIT_CONFIG_COUNT`, `GIT_DIR` and `GIT_WORK_TREE` are unset.

## Baseline

- First pass, full suite at `2cd4a9c` before any case was added: 55 passed, 0 failed. After adding eight cases, before implementation: 58 passed, 5 failed (git 2.43.0).
- Second pass, full suite at `08d6555` before the symlink cases were added: all 63 passed (the dispatched statement that the implementation is committed; the eight first-pass cases are green on it). After adding the two symlink cases: 63 passed, 2 failed — the two new cases, both state 1 (HEAD is `refs/heads/main`, not `refs/heads/develop`).
- The two symlink cases were also run once against the pre-implementation script (`git show 2cd4a9c:scripts/project-init` into a scratch copy, executed, not read): both pass. The defect is introduced by the implementation, not pre-existing.

## Scenarios (4 in `specs/project-bootstrap/spec.md`, 4 accounted for)

| Scenario | Delta | Covered by |
|---|---|---|
| No configured default yields main | ADDED | `initial-branch-unconfigured-main` |
| A configured default is honoured | ADDED | `initial-branch-configured-honoured`; `initial-branch-pre-2-28-git-emulated` |
| A configured default in an enclosing repository is not read | ADDED | `initial-branch-enclosing-config-ignored` |
| An existing repository's branch is left alone | ADDED | `initial-branch-existing-unborn-untouched` (without commits); `initial-branch-existing-with-commits-untouched` (with commits); `initial-branch-existing-via-symlink-cwd-untouched` (run from inside a symlink to the repository); `initial-branch-existing-via-symlink-arg-untouched` (target argument is a symlink to the repository) |

No scenario is uncovered.

### Requirement text with no scenario of its own, also covered

| Requirement clause | Covered by |
|---|---|
| "SHALL NOT rely on `git init --initial-branch` or on `git init` honouring `init.defaultBranch` ... the resulting branch SHALL be the same on an older git" | `initial-branch-pre-2-28-git-emulated` |
| "read as the created repository sees it, not as ... the caller's working directory sees it" | `initial-branch-caller-config-ignored` |
| "Where the initial branch cannot be set ... the run SHALL end in `ERROR` with a reason naming that step" | `initial-branch-set-failure-errors` |

### State of each case

| Case | At `2cd4a9c` (no implementation) | At `08d6555` |
|---|---|---|
| `initial-branch-unconfigured-main` | red, state 1 (`master`) | green |
| `initial-branch-configured-honoured` | green (see below) | green |
| `initial-branch-enclosing-config-ignored` | red, state 1 (`master`) | green |
| `initial-branch-caller-config-ignored` | red, state 1 (`master`) | green |
| `initial-branch-pre-2-28-git-emulated` | red, state 1 (`master`) | green |
| `initial-branch-set-failure-errors` | red, state 1 (exit 0) | green |
| `initial-branch-existing-unborn-untouched` | green | green |
| `initial-branch-existing-with-commits-untouched` | green | green |
| `initial-branch-existing-via-symlink-cwd-untouched` | green (scratch run) | **red, state 1 (`main`)** |
| `initial-branch-existing-via-symlink-arg-untouched` | green (scratch run) | **red, state 1 (`main`)** |

### Cases that passed before implementation (investigated)

- `initial-branch-configured-honoured` passes on git 2.43 because git itself honours `init.defaultBranch`; the property it cannot discriminate on a modern git is discriminated by `initial-branch-pre-2-28-git-emulated`, which was red.
- The four `initial-branch-existing-*-untouched` cases exercise a path that already existed, so a pass before implementation is the expected result. The two non-symlink ones were run once against a scratch fake `PROJECT_INIT` forcing `HEAD` to `main` and failed; the two symlink ones fail against the real implementation at `08d6555`. Each therefore discriminates. No fake is in the suite.

## Assertion classification

| Case | Assertion | Classification |
|---|---|---|
| `initial-branch-unconfigured-main` | HEAD is `refs/heads/main` | specified (scenario) |
| `initial-branch-unconfigured-main` | precondition: `init.defaultBranch` not visible | derived (vacuity guard on isolation) |
| `initial-branch-configured-honoured` | HEAD is `refs/heads/trunk` with global `init.defaultBranch=trunk` | specified (scenario) |
| `initial-branch-enclosing-config-ignored` | HEAD is `refs/heads/main` with outer local `init.defaultBranch=outerbranch` | specified (scenario) |
| `initial-branch-enclosing-config-ignored` | precondition: outer's setting is visible from the target directory | derived (vacuity guard) |
| `initial-branch-caller-config-ignored` | HEAD is `refs/heads/main` when the caller's cwd repo sets `callerbranch` and the target is passed as an argument | specified (requirement text) |
| `initial-branch-existing-unborn-untouched`, `initial-branch-existing-with-commits-untouched` | report contains `repository: already present`; HEAD still `refs/heads/develop` | specified (scenario) |
| `initial-branch-existing-via-symlink-{cwd,arg}-untouched` | HEAD of the real repository still `refs/heads/develop` after a run reaching it through a symlink | specified (scenario: "the target is already the root of a repository" holds whatever path names it) |
| `initial-branch-existing-via-symlink-{cwd,arg}-untouched` | the existing commit is still reachable from HEAD | derived (follows from HEAD being unchanged; guards against a reinit that moves HEAD back to `develop` but orphaned) |
| `initial-branch-existing-via-symlink-{cwd,arg}-untouched` | precondition: the link resolves to the repository on `develop` | derived (guard) |
| `initial-branch-existing-via-symlink-{cwd,arg}-untouched` | the `repository: already present` report line | deliberately untested — repository-concern detection through a symlink is outside this change's scope (coordinator's direction); only the branch outcome is this change's |
| `initial-branch-pre-2-28-git-emulated` | HEAD is `refs/heads/trunk` under a git stub whose `init` rejects `-b`/`--initial-branch` and ignores `init.defaultBranch` | specified (requirement text); the stub's emulation of pre-2.28 git is derived |
| `initial-branch-pre-2-28-git-emulated` | precondition: the stub's `git init` produces `master` despite config | derived (guard) |
| `initial-branch-set-failure-errors` | exit 1, `Outcome: ERROR` | specified (requirement text; exit code from the CLI contract in `tests/README.md`) |
| `initial-branch-set-failure-errors` | `Reason:` line contains `branch` (case-insensitive) | derived — "a reason naming that step" fixes no wording |
| `initial-branch-unconfigured-main`, `-configured-honoured`, `-enclosing-config-ignored`, `-caller-config-ignored`, `-pre-2-28-git-emulated` | exit 0 and `repository: created` | specified (the requirement applies only on the created path; Decision 4 keeps the report contract unchanged) |

Deliberately untested:

- **A `.git` that exists but is not recognised as a repository (e.g. a corrupted `HEAD`) must not have its `HEAD` rewritten.** Raised by code review. Not written: the scenario's precondition is a repository "whose `HEAD` names a branch", which a corrupted `HEAD` does not satisfy, and nothing in the delta spec states what the tool must do with a `.git` it cannot read — refuse, report, or leave alone. Any assertion here would be a derived constraint the implementer never agreed to. Needs a decision: either a spec revision via `openspec-update-change` stating the expected outcome, or an explicit instruction to add a derived case.
- The error case does not assert that `repository: created` is still reported alongside the ERROR (covered generally by `delegated-init-failure`); no case asserts the report does not name the branch (Decision 4 is a non-change).

## Obsolete tests

Not applicable: the change carries only an `ADDED` delta, no `MODIFIED` or `REMOVED`.

## Unresolved project questions

1. **The initial-branch failure is provoked through a `git symbolic-ref` stub.** `initial-branch-set-failure-errors` assumes the implementation sets the branch with `git symbolic-ref` (`design.md` Decision 2, `tasks.md` 1.1); the requirement names no mechanism. Depends: `initial-branch-set-failure-errors`.
2. **Pre-2.28 git is emulated, not run**, and the emulation assumes git is invoked through `PATH`. Depends: `initial-branch-pre-2-28-git-emulated`.
3. **No single-case selector in `tests/run.sh`**; the invocation under *Selecting a case* reproduces `run.sh`'s environment by hand. Depends: none.
4. **`tests/coverage.md` is outside the test-path glob** `tests/cases/*.sh`; mapping the two symlink cases there is for the implementation step.
5. **Corrupted-`.git` behavior is unspecified** (see *Deliberately untested*). Depends: none written.

## What the implementation must make pass

`bash tests/run.sh` green, specifically the two cases currently red at `08d6555`: `initial-branch-existing-via-symlink-cwd-untouched` and `initial-branch-existing-via-symlink-arg-untouched` — while the other eight `initial-branch-*` cases and all 55 pre-existing cases stay green.
