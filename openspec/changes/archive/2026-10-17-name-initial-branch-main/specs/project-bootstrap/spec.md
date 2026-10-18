## ADDED Requirements

### Requirement: A repository the tool creates starts on a stated branch

Where the tool initializes the repository in a target whose `.git` was absent or empty before the run, the repository's `HEAD` SHALL name the branch given by the operator's `init.defaultBranch` configuration where that is set, and `refs/heads/main` where it is not. The tool SHALL NOT leave the initial branch to git's built-in default, which differs between git versions and machines.

Where the repository concern is already satisfied, the tool SHALL NOT change the repository's current branch, whether or not that branch has commits. Where the target holds a `.git` with any content that the repository concern does not recognise as a repository, the tool SHALL NOT write that repository's `HEAD` itself; what it should do with such a directory otherwise is outside this requirement.

The step SHALL NOT rely on `git init --initial-branch` or on `git init` honouring `init.defaultBranch`, both of which need git 2.28; the resulting branch SHALL be the same on an older git. The configuration SHALL be read as the created repository sees it, not as an enclosing repository or the caller's working directory sees it.

Where the initial branch cannot be set after the repository was created, the run SHALL end in `ERROR` with a reason naming that step.

#### Scenario: No configured default yields main

- **WHEN** the tool creates a repository and `init.defaultBranch` is not set in any git configuration the run can see
- **THEN** the created repository's `HEAD` is `refs/heads/main`

#### Scenario: A configured default is honoured

- **WHEN** the tool creates a repository and `init.defaultBranch` is set to a name other than `main`
- **THEN** the created repository's `HEAD` names that branch, not `main`

#### Scenario: A configured default in an enclosing repository is not read

- **WHEN** the tool creates a repository in a subdirectory of an existing repository whose own local configuration sets `init.defaultBranch`, and no global or system configuration sets it
- **THEN** the created repository's `HEAD` is `refs/heads/main`

#### Scenario: An existing repository's branch is left alone

- **WHEN** the tool runs where the target is already the root of a repository whose `HEAD` names a branch other than `main`, with or without commits
- **THEN** the repository is reported `already present` and its `HEAD` still names that branch after the run
