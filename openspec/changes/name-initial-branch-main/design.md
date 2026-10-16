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

## Decision 5: Resolve the target physically, and never give a branch to a repository that was already there

`git rev-parse --show-toplevel` returns a physical path, while the target was resolved with a logical `pwd`. Through a symlink the two differ, so an existing repository was classed as absent: `git init` reinitialized it, the report said `created`, the run took the new-project path, and — once this change added the branch step — `HEAD` was moved to an empty `main`. Code review reproduced it. The target is now resolved with `pwd -P`, so the repository concern sees the repository, which the spec scenario "An existing repository's branch is left alone" requires (`already present`). `Target:` consequently prints the physical path; it is still the absolute target directory the report contract names.

As a second guard, the script records whether `$target/.git` was a valid repository before `git init` (`git --git-dir=… rev-parse --git-dir`) and sets the initial branch only where it was not. An empty or leftover `.git` directory is not a repository: `git init` creates one in it, and it gets the stated branch like any other created repository. A `.git` whose repository git cannot open at all (a corrupt `HEAD`) is not specified by this change and is recorded in `docs/backlog.md` (`decide-unreadable-git-dir-handling`).

The configured name is checked with `git -C "$target" check-ref-format --branch` before it is written, because `git symbolic-ref` accepts names such as `-x` that are not valid branches, and a pre-2.28 `git init` never validates the setting. It runs in the target so the check, like the lookup, sees what the created repository sees.
