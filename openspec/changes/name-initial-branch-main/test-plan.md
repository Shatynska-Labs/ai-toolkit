# Test plan: name-initial-branch-main

Derived by `ai-toolkit:change-test-writer` from the delta specs, and replaced wholesale on each pass. Commits on the branch: plan `f20e519`, first derived cases `575b038`, implementation `db9b963`, symlink cases `4f7f12f`, fix `e875edb`, round-2 cases `cc18757`, fix `89a8b40`. This file is not an artifact the OpenSpec schema knows about; it does not appear among `openspec instructions apply`'s context files and must be read on purpose.

## Selecting a case

`tests/run.sh` has no single-case selector; every case is a file named `tests/cases/<name>.sh`. One case runs alone from the worktree root as:

```
TESTDIR="$(mktemp -d)" TOOLKIT_ROOT="$PWD" TESTLIB="$PWD/tests/lib.sh" PROJECT_INIT="$PWD/scripts/project-init" bash tests/cases/<name>.sh
```

Every case isolates git configuration from the operator's own: `HOME` and `XDG_CONFIG_HOME` point into `$TESTDIR`, `GIT_CONFIG_NOSYSTEM=1`, and `GIT_CONFIG_GLOBAL`, `GIT_CONFIG_SYSTEM`, `GIT_CONFIG`, `GIT_CONFIG_COUNT`, `GIT_DIR` and `GIT_WORK_TREE` are unset (`initial-branch-caller-git-dir-env-untouched` then sets `GIT_DIR`/`GIT_WORK_TREE` on the tool's invocation alone, deliberately).

## Baseline

All runs are the full suite, `bash tests/run.sh`, on git 2.43.0.

- Pass 1, at `f20e519` before any case was added: 55 passed, 0 failed. After adding eight cases: 58 passed, 5 failed.
- Pass 2, at `db9b963` before the symlink cases: 63 passed, 0 failed. After adding two: 63 passed, 2 failed.
- Pass 3, at `e875edb` before its cases: 65 passed, 0 failed. After adding four: 66 passed, 3 failed.
- Pass 4, at `89a8b40` before its cases: 69 passed, 0 failed (55 pre-existing + 14 from passes 1–3). After adding four: 70 passed, 3 failed.

Cross-revision runs: each pass-3 and pass-4 case was also run against earlier revisions, each from a scratch `git archive` of that revision (scripts executed, not read). Results are in the state table below.

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
| "the tool SHALL NOT change the repository's current branch" (applied to repositories other than a satisfied target) | `initial-branch-caller-git-dir-env-untouched`; `initial-branch-corrupted-head-not-rewritten`; `initial-branch-missing-head-not-rewritten` |
| existing `project-bootstrap` requirement: the tool "SHALL state the target directory in its report" | `target-line-symlink-as-given` |

### State of each case

Every red cell is state 1: the code ran and produced a wrong value.

| Case | `f20e519` | `db9b963` | `e875edb` | `89a8b40` |
|---|---|---|---|---|
| `initial-branch-unconfigured-main` | red | green | green | green |
| `initial-branch-configured-honoured` | green | green | green | green |
| `initial-branch-enclosing-config-ignored` | red | green | green | green |
| `initial-branch-caller-config-ignored` | red | green | green | green |
| `initial-branch-pre-2-28-git-emulated` | red | green | green | green |
| `initial-branch-set-failure-errors` | red | green | green | green |
| `initial-branch-existing-unborn-untouched` | green | green | green | green |
| `initial-branch-existing-with-commits-untouched` | green | green | green | green |
| `initial-branch-existing-via-symlink-cwd-untouched` | green | red | green | green |
| `initial-branch-existing-via-symlink-arg-untouched` | green | red | green | green |
| `initial-branch-empty-dotgit-dir-initialized` | red | green | red | green |
| `initial-branch-invalid-configured-name-errors` | red | red | green | green |
| `initial-branch-existing-via-symlink-cwd-reported` | — | — | red | green |
| `initial-branch-existing-via-symlink-arg-reported` | — | — | red | green |
| `initial-branch-caller-git-dir-env-untouched` | red (no target `.git`) | red (caller HEAD → `main`) | red (caller HEAD → `main`) | **red (caller HEAD → `main`)** |
| `initial-branch-corrupted-head-not-rewritten` | green | green | green | green |
| `initial-branch-missing-head-not-rewritten` | — | red (HEAD → `main`) | — | **red (HEAD → `main`)** |
| `target-line-symlink-as-given` | green | green | green | **red (`Target:` is the resolved path)** |

"—" means not run against that revision.

Notes:

- **`initial-branch-caller-git-dir-env-untouched`**: with `GIT_DIR`/`GIT_WORK_TREE` in the caller's environment pointing at a repository on `feature`, the run moves *that* repository's HEAD to `main` at every implementation revision. At `f20e519` the target got no `.git` at all (the caller's environment redirected `git init` too).
- **`initial-branch-corrupted-head-not-rewritten`** (garbage HEAD content, as review round 3 specified) passes at every revision, including `db9b963`. Investigated: with garbage HEAD, git cannot open the repository, so `git symbolic-ref` itself fails and the run ends `ERROR` (`initial branch could not be set to main`) with HEAD untouched. The case is retained because it executes the behavior and does discriminate: a scratch fake `PROJECT_INIT` writing `ref: refs/heads/main` into HEAD directly made it fail. It cannot catch the defect through `git symbolic-ref`.
- **`initial-branch-missing-head-not-rewritten`** was added for that reason: a deleted HEAD file is a corruption `git init` repairs (recreating HEAD), after which the branch step writes `ref: refs/heads/main`. Red at `db9b963` and `89a8b40`. An empty HEAD and `ref: ` with no target behave like garbage (git cannot open, `ERROR`, untouched). A `.git` with its `objects/` directory removed behaves like a missing HEAD (rewritten to `main`, `SUCCESS`); no case is written for it, as it is not a HEAD corruption — see *Deliberately untested*.
- **`target-line-symlink-as-given`** was green until `89a8b40` ("resolve the target physically"), which now prints the resolved path. A regression introduced by that fix against the `Target:` contract `explicit-target-argument.sh` asserts for a plain path (that case stays green on Linux only because `/tmp` is not a symlink here).
- `initial-branch-invalid-configured-name-errors` and the pass-1 cases that were green before implementation were investigated in earlier passes and discriminate (see their rows and the classification).

## Assertion classification

| Case | Assertion | Classification |
|---|---|---|
| `initial-branch-unconfigured-main` | HEAD is `refs/heads/main` | specified (scenario) |
| `initial-branch-unconfigured-main` | precondition: `init.defaultBranch` not visible | derived (guard) |
| `initial-branch-configured-honoured` | HEAD is `refs/heads/trunk` with global `init.defaultBranch=trunk` | specified (scenario) |
| `initial-branch-enclosing-config-ignored` | HEAD is `refs/heads/main` with outer local `init.defaultBranch=outerbranch` | specified (scenario) |
| `initial-branch-enclosing-config-ignored` | precondition: outer's setting is visible from the target directory | derived (guard) |
| `initial-branch-caller-config-ignored` | HEAD is `refs/heads/main` when the caller's cwd repo sets `callerbranch` | specified (requirement text) |
| `initial-branch-existing-unborn-untouched`, `-with-commits-untouched` | `repository: already present`; HEAD still `refs/heads/develop` | specified (scenario) |
| `initial-branch-existing-via-symlink-{cwd,arg}-untouched` | HEAD still `refs/heads/develop` | specified (scenario) |
| `initial-branch-existing-via-symlink-{cwd,arg}-untouched` | the existing commit is still reachable from HEAD | derived |
| `initial-branch-existing-via-symlink-{cwd,arg}-reported` | `repository: already present`; HEAD still `refs/heads/develop` | specified (scenario THEN) |
| all four symlink scenario cases | precondition: the link resolves to the repository on `develop` | derived (guard) |
| `initial-branch-empty-dotgit-dir-initialized` | HEAD is `refs/heads/main` over an empty `.git` directory | specified (scenario + "Where the tool initializes"); that the tool initializes rather than refuses here is derived |
| `initial-branch-empty-dotgit-dir-initialized` | precondition: git does not recognise the empty `.git` | derived (guard) |
| `initial-branch-pre-2-28-git-emulated` | HEAD is `refs/heads/trunk` under an emulated pre-2.28 git | specified (requirement text); the emulation is derived |
| `initial-branch-pre-2-28-git-emulated` | precondition: the stub's `git init` produces `master` | derived (guard) |
| `initial-branch-set-failure-errors`, `initial-branch-invalid-configured-name-errors` | exit 1, `Outcome: ERROR` | specified (requirement text; exit code from `tests/README.md`) |
| same two | `Reason:` contains `branch` | derived (no wording fixed) |
| `initial-branch-invalid-configured-name-errors` | `-x` "cannot be set" | derived (`git symbolic-ref HEAD refs/heads/-x` succeeds on git 2.43; only `check-ref-format --branch` and modern `git init` reject it) |
| `initial-branch-invalid-configured-name-errors` | preconditions: stubbed init succeeds; `-x` rejected as a branch name | derived (guards) |
| `initial-branch-caller-git-dir-env-untouched` | caller repository (named by `GIT_DIR`) HEAD still `refs/heads/feature`, commit reachable | derived from "SHALL NOT change the repository's current branch" — that clause is stated for a satisfied target; applying it to a repository the tool was never pointed at is an inference, though an uncontroversial one |
| `initial-branch-caller-git-dir-env-untouched` | target has its own `.git` with HEAD `refs/heads/main` | specified (scenario "No configured default yields main" — the target is a fresh directory) |
| `initial-branch-corrupted-head-not-rewritten`, `initial-branch-missing-head-not-rewritten` | HEAD content is not `ref: refs/heads/main` after the run | derived — the delta spec's precondition is a repository "whose `HEAD` names a branch", which these are not; the expected handling is recorded as undecided in `docs/backlog.md`. Only the narrow "did not write main" property is asserted, per review round 3 |
| same two | precondition (garbage only): git cannot open the repository; (missing only): likewise | derived (guards) |
| `target-line-symlink-as-given` | the exact line `Target: <path as given>` | derived — the existing requirement says "state the target directory" and fixes no form; "as given" follows `explicit-target-argument.sh`'s established assertion |
| `target-line-symlink-as-given` | exit 0; the directory behind the link was initialized | specified (existing explicit-target scenario) |
| `initial-branch-unconfigured-main`, `-configured-honoured`, `-enclosing-config-ignored`, `-caller-config-ignored`, `-pre-2-28-git-emulated` | exit 0 and `repository: created` | specified |

Deliberately untested:

- **Report and outcome for a corrupted or missing HEAD** — undecided (`docs/backlog.md`), so not asserted.
- **A `.git` with `objects/` removed** (git cannot open it; `git init` repairs it; HEAD then rewritten to `main` with `SUCCESS` at `89a8b40`). Same unspecified class as the corrupted HEAD, but outside what review round 3 asked for; reported rather than written. Needs a decision whether it is in scope.
- `initial-branch-invalid-configured-name-errors` has no unstubbed variant (on git 2.43 `git init` rejects `-x` before the repository exists, outside the requirement's "after the repository was created" clause).
- The error cases do not assert `repository: created` alongside ERROR; no case asserts the report does not name the branch (Decision 4 is a non-change).

## Obsolete tests

Not applicable: the change carries only an `ADDED` delta, no `MODIFIED` or `REMOVED`.

## Unresolved project questions

1. `initial-branch-set-failure-errors` provokes the failure with a `git symbolic-ref` stub, assuming the mechanism in `design.md` Decision 2. Depends: that case.
2. Pre-2.28 git is emulated through `PATH`. Depends: `initial-branch-pre-2-28-git-emulated`, `initial-branch-invalid-configured-name-errors`.
3. Whether `-x` counts as "cannot be set". Depends: `initial-branch-invalid-configured-name-errors`.
4. Whether an empty `.git` is a target the tool initializes (decided by existing repository-concern rules, not this delta). Depends: `initial-branch-empty-dotgit-dir-initialized`.
5. What the tool should do with a `.git` git cannot open — corrupted or missing HEAD, missing `objects/` (`docs/backlog.md`). Depends: `initial-branch-corrupted-head-not-rewritten`, `initial-branch-missing-head-not-rewritten`.
6. The form of the `Target:` line (path as given vs resolved). Depends: `target-line-symlink-as-given`.
7. No single-case selector in `tests/run.sh`.
8. `tests/coverage.md` is outside the test-path glob; mapping the pass-3 and pass-4 cases there is for the implementation step.

## What the implementation must make pass

`bash tests/run.sh` green, specifically the three cases red at `89a8b40`: `initial-branch-caller-git-dir-env-untouched`, `initial-branch-missing-head-not-rewritten`, `target-line-symlink-as-given` — while every other case stays green.
