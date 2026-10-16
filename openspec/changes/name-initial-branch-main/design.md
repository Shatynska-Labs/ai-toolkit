## Decision 1: `main` as the fallback, configuration first

Hardcoding `main` would override an operator who deliberately set `init.defaultBranch` to something else, and that setting is the operator's own statement of intent. Leaving git's default in place is the current defect. So the tool reads `init.defaultBranch` and uses it where set, and names `main` only where it is unset — the case in which git would otherwise pick `master` (or emit its "using 'master'" hint, depending on version).

`main` rather than another name because it is the default of the forge these rules assume (GitHub) and of the repositories this library is developed in.

## Decision 2: Always `git symbolic-ref` to the resolved name after `git init`

`git init -b <name>` needs git 2.28 — and so does `git init` honouring `init.defaultBranch`, which arrived in the same release. Relying on either would leave a pre-2.28 git on `master` even where the operator configured otherwise. So the tool resolves the name once — `git -C "$target" config --get init.defaultBranch` run after `git init`, so the lookup sees exactly the configuration the new repository sees and not that of an enclosing repository or the caller's directory, falling back to `main` — and always points `HEAD` at `refs/heads/<name>` with `git symbolic-ref`. On an unborn branch this is exact, needs no newer git, and is a no-op where git already chose the same name.

A `symbolic-ref` failure after a successful `git init` ends the run in `ERROR` naming the step. Re-running does not repair it — the repository is then `already present` and Decision 3 forbids touching its branch — so the report is the only signal. That is accepted: writing `HEAD` in a repository `git init` just created fails only where the filesystem itself does or where the configured name is not a valid ref, and the operator can rerun `git symbolic-ref` by hand.

## Decision 3: Existing repositories are out of scope

Renaming the branch of a repository the tool did not create would violate the tool's own guarantee that it never overwrites what the project already owns, and a repository with commits may have a remote tracking the old name. The requirement applies only on the path where the tool reports `repository: created`.

## Decision 4: The report does not name the branch

Adding the branch to the report would change the report contract every consumer greps, for a fact `git branch --show-current` already answers. Not done.

## Decision 5: A `.git` present before `git init` is never given a branch

The repository concern is evaluated by comparing the target with `git rev-parse --show-toplevel`, and that comparison can miss a repository that is there — a target reached through a symlink resolves to a different path, a corrupt `HEAD` fails the lookup. `git init` then reinitializes the existing repository, which was harmless before this change; with the branch step after it, the project's `HEAD` would be moved to an empty `main`. Code review reproduced this. The script therefore records whether `$target/.git` existed before `git init` and sets the initial branch only where it did not. Fixing the concern's detection itself is out of scope here: it changes what the report says, and this change keeps the report contract.

The configured name is checked with `git check-ref-format --branch` before it is written, because `git symbolic-ref` accepts names such as `-x` that are not valid branches, and a pre-2.28 `git init` never validates the setting.
