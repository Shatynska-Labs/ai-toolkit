## Why

`scripts/project-init` creates a repository with a bare `git init`, so its initial branch is whatever git defaults to on the machine running it. Where `init.defaultBranch` is unset, that is `master`. The `basis` project was initialized this way on 2026-10-16 and came out on `master`, while its forge and the workflow rules this tool inlines assume a trunk named `main`; the branch had to be renamed by hand before the first commit.

Nothing in `project-bootstrap` states which branch a created repository starts on, so the outcome differs from machine to machine — the inconsistency the tool exists to prevent.

## What Changes

- A repository the tool creates starts on the branch named by the operator's `init.defaultBranch` where one is configured, and on `main` where none is.
- A repository that already exists is not touched: its current branch, born or unborn, is left as it is.
- The report contract is unchanged: `repository: created` still reports the concern.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `project-bootstrap`: adds a requirement stating the initial branch of a repository the tool creates.

## Impact

- `scripts/project-init` — the repository-creation step.
- `openspec/specs/project-bootstrap/spec.md` — one added requirement.
- `tests/cases/` — cases for the added requirement; `tests/coverage.md` maps them.
- `rules/development-workflow.md` — unchanged.
