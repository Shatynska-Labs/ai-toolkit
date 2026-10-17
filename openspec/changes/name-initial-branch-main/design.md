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

## Decision 5: The branch step writes `HEAD` only into a `.git` that was absent or empty

The repository concern compares the target with `git rev-parse --show-toplevel`, and that check can miss a repository that is there. Each miss used to be harmless — `git init` reinitializes a repository without changing its branch — but the branch step added here would then move an existing project to an empty `main`. Code review found four such paths across three rounds: a target reached through a symlink, an empty `.git`, a `.git` with a missing or corrupt `HEAD`, and `GIT_DIR`/`GIT_WORK_TREE` inherited from a caller. The script therefore:

- records, before `git init`, whether `$target/.git` exists with any content, and sets the initial branch only where it did not. An empty `.git` directory gets the stated branch; anything else is left to git, because it may be a repository the check could not read;
- unsets `GIT_DIR`, `GIT_WORK_TREE`, `GIT_COMMON_DIR` and `GIT_INDEX_FILE` at start, so no git call reaches the caller's repository instead of the target;
- compares the toplevel with the target's physical path (`pwd -P`), so an existing repository behind a symlink is reported `already present`, while `Target:` keeps the path as given.

What the tool should do with a `.git` it cannot read, and why the repository check and an explicit `--git-dir` probe can disagree (an ownership refusal under `safe.directory` reports such a repository `created` and routes it to the new-project ending), are recorded in `docs/backlog.md` (`decide-unreadable-git-dir-handling`). Neither is introduced by this change.

The configured name is checked with `git -C "$target" check-ref-format --branch` before it is written, because `git symbolic-ref` accepts names such as `-x` that are not valid branches, and a pre-2.28 `git init` never validates the setting. Where the step fails, the reason names the manual command and says that a re-run then completes the remaining concerns.
