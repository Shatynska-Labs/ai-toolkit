# Test plan: name-initial-branch-main

Derived by `ai-toolkit:change-test-writer` from the delta specs at plan commit `2cd4a9c`, before implementation. This file is not an artifact the OpenSpec schema knows about; it does not appear among `openspec instructions apply`'s context files and must be read on purpose.

## Selecting a case

`tests/run.sh` has no single-case selector; every case is a file named `tests/cases/<name>.sh`. One case runs alone from the worktree root as:

```
TESTDIR="$(mktemp -d)" TOOLKIT_ROOT="$PWD" TESTLIB="$PWD/tests/lib.sh" PROJECT_INIT="$PWD/scripts/project-init" bash tests/cases/<name>.sh
```

Every case isolates git configuration from the operator's own: `HOME` and `XDG_CONFIG_HOME` point into `$TESTDIR`, `GIT_CONFIG_NOSYSTEM=1`, and `GIT_CONFIG_GLOBAL`, `GIT_CONFIG_SYSTEM`, `GIT_CONFIG`, `GIT_CONFIG_COUNT`, `GIT_DIR` and `GIT_WORK_TREE` are unset.

## Baseline

Full suite, `bash tests/run.sh` at `2cd4a9c` before any case was added: 55 passed, 0 failed (matches the dispatched baseline).

After adding the cases, before implementation: 58 passed, 5 failed (git 2.43.0). The 55 pre-existing cases still pass.

## Scenarios (4 in `specs/project-bootstrap/spec.md`, 4 accounted for)

| Scenario | Delta | Covered by | State before implementation |
|---|---|---|---|
| No configured default yields main | ADDED | `initial-branch-unconfigured-main` | Red: code ran, HEAD is `refs/heads/master` (state 1) |
| A configured default is honoured | ADDED | `initial-branch-configured-honoured`; `initial-branch-pre-2-28-git-emulated` | First passes (see below); second red: HEAD is `refs/heads/master` (state 1) |
| A configured default in an enclosing repository is not read | ADDED | `initial-branch-enclosing-config-ignored` | Red: HEAD is `refs/heads/master` (state 1) |
| An existing repository's branch is left alone | ADDED | `initial-branch-existing-unborn-untouched` (without commits); `initial-branch-existing-with-commits-untouched` (with commits) | Both pass: the existing-repository path already exists |

No scenario is uncovered.

### Requirement text with no scenario of its own, also covered

| Requirement clause | Covered by | State before implementation |
|---|---|---|
| "SHALL NOT rely on `git init --initial-branch` or on `git init` honouring `init.defaultBranch` ... the resulting branch SHALL be the same on an older git" | `initial-branch-pre-2-28-git-emulated` | Red: HEAD is `refs/heads/master` (state 1) |
| "read as the created repository sees it, not as ... the caller's working directory sees it" | `initial-branch-caller-config-ignored` | Red: HEAD is `refs/heads/master` (state 1) |
| "Where the initial branch cannot be set ... the run SHALL end in `ERROR` with a reason naming that step" | `initial-branch-set-failure-errors` | Red: exit 0, not 1 (state 1) |

### Cases that pass before implementation (fourth-state alarm, investigated)

- `initial-branch-configured-honoured` passes because git 2.43 itself honours `init.defaultBranch` on `git init`: the behavior already exists on this machine's git. It is retained as the scenario's direct statement; the property it cannot discriminate on a modern git is discriminated by `initial-branch-pre-2-28-git-emulated`, which is red.
- `initial-branch-existing-unborn-untouched` and `initial-branch-existing-with-commits-untouched` pass because the `already present` path exists and currently leaves the branch alone. These execute the behavior (the target already exists), so a pass is the expected result.
- All three were run once, in a scratch directory, against a fake `PROJECT_INIT` that forces `HEAD` to `refs/heads/main`; each failed, so each discriminates. That fake was deleted; nothing of it is in the suite.

## Assertion classification

| Case | Assertion | Classification |
|---|---|---|
| `initial-branch-unconfigured-main` | HEAD is `refs/heads/main` | specified (scenario) |
| `initial-branch-unconfigured-main` | precondition: `init.defaultBranch` not visible | derived (vacuity guard on isolation) |
| `initial-branch-configured-honoured` | HEAD is `refs/heads/trunk` with global `init.defaultBranch=trunk` | specified (scenario) |
| `initial-branch-enclosing-config-ignored` | HEAD is `refs/heads/main` with outer local `init.defaultBranch=outerbranch` | specified (scenario) |
| `initial-branch-enclosing-config-ignored` | precondition: outer's setting is visible from the target directory | derived (vacuity guard: without it a correct and an incorrect read are indistinguishable) |
| `initial-branch-caller-config-ignored` | HEAD is `refs/heads/main` when the caller's cwd repo sets `callerbranch` and the target is passed as an argument | specified (requirement text) |
| `initial-branch-existing-*-untouched` | report contains `repository: already present`; HEAD still `refs/heads/develop` | specified (scenario) |
| `initial-branch-pre-2-28-git-emulated` | HEAD is `refs/heads/trunk` under a git stub whose `init` rejects `-b`/`--initial-branch` and ignores `init.defaultBranch` | specified (requirement text); the stub's emulation of pre-2.28 git is derived (a model of old git, not old git itself) |
| `initial-branch-pre-2-28-git-emulated` | precondition: the stub's `git init` produces `master` despite config | derived (guard) |
| `initial-branch-set-failure-errors` | exit 1, `Outcome: ERROR` | specified (requirement text; exit code from the CLI contract in `tests/README.md`) |
| `initial-branch-set-failure-errors` | `Reason:` line contains `branch` (case-insensitive) | derived — "a reason naming that step" fixes no wording; `branch` is the weakest token any such reason would plausibly carry |
| `initial-branch-unconfigured-main`, `-configured-honoured`, `-enclosing-config-ignored`, `-caller-config-ignored`, `-pre-2-28-git-emulated` | exit 0 and `repository: created` | specified (the requirement applies only on the created path; Decision 4 keeps the report contract unchanged) |

Deliberately untested: the error case does not assert that `repository: created` is still reported alongside the ERROR (the report contract's completed-concern behavior is covered generally by `delegated-init-failure`), and no case asserts the report does *not* name the branch (Decision 4 is a non-change, verified by reading the diff).

## Obsolete tests

Not applicable: the change carries only an `ADDED` delta, no `MODIFIED` or `REMOVED`.

## Unresolved project questions

1. **How the initial-branch step fails is observable only through a `git symbolic-ref` stub.** `initial-branch-set-failure-errors` makes any `git` invocation containing `symbolic-ref` fail. This assumes the implementation sets the branch with `git symbolic-ref`, as `design.md` Decision 2 and `tasks.md` 1.1 state; an implementation using another mechanism (e.g. writing `HEAD` directly, or `git update-ref`) would satisfy the requirement and still fail this case. The requirement itself names no mechanism. Depends: `initial-branch-set-failure-errors`.
2. **Pre-2.28 git is emulated, not run.** `initial-branch-pre-2-28-git-emulated` models old git as "`init` ignores `init.defaultBranch` and rejects `-b`/`--initial-branch`". It assumes the implementation invokes git through `PATH` (as every existing case's stubs already assume). Depends: `initial-branch-pre-2-28-git-emulated`.
3. **No single-case selector in `tests/run.sh`.** The project records no way to run one case; the invocation under *Selecting a case* reproduces `run.sh`'s environment by hand. Depends: none (selection only).
4. **`tests/coverage.md` is not updated by this pass.** It lies outside the test-path glob `tests/cases/*.sh`; mapping the new cases there is `tasks.md` 2.3, for the implementation step.

## What the implementation must make pass

`bash tests/run.sh` green, specifically the five currently red cases: `initial-branch-unconfigured-main`, `initial-branch-enclosing-config-ignored`, `initial-branch-caller-config-ignored`, `initial-branch-pre-2-28-git-emulated`, `initial-branch-set-failure-errors` — while `initial-branch-configured-honoured`, `initial-branch-existing-unborn-untouched`, `initial-branch-existing-with-commits-untouched` and all 55 pre-existing cases stay green.
