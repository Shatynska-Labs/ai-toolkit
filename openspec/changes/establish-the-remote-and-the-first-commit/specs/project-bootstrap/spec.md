## ADDED Requirements

### Requirement: A wrapper offers the direct initial commit only to a repository without one, and shows what it holds

A wrapper SHALL offer to create a commit directly on the repository's current branch only where the run ended in `SUCCESS` and the repository rooted at the target had no commit — the new-project mode. That commit is the repository's first, and the only one the workflow lets reach the trunk without a pull request. The wrapper SHALL take the mode from the tool's report, which names a different next step in each, rather than re-deriving it.

Before asking for confirmation, the wrapper SHALL show the operator every path the commit would contain: every path already staged, and every untracked path not excluded by git's standard exclusions — not only the paths the tool wrote. A wholly untracked directory MAY be shown as one entry. A target may already hold the project's own files when it is initialized, and a confirmation given for "what the tool just did" is not a confirmation of those.

Where the operator declines the commit, the wrapper SHALL state that the repository's first commit and a remote are both outstanding, and that the workflow's first pull request needs both.

In the adoption mode the wrapper SHALL NOT offer to commit the tool's writes onto the repository's current branch, and SHALL state that they reach the trunk through a pull request like any other change. Where the adopted repository has no remote configured, it SHALL also state that a remote is needed before that pull request can be opened.

#### Scenario: The commit offer lists files the tool did not write

- **WHEN** a new-project run succeeds in a target that already held a file of the project's own, not excluded by the ignore file
- **THEN** the wrapper's offer names that file among the paths the commit would include, before asking for confirmation

#### Scenario: A file staged before the run is listed

- **WHEN** a new-project run succeeds in a target whose repository has no commit and a file already staged
- **THEN** the wrapper's offer names that file among the paths the commit would include

#### Scenario: A declined commit leaves both gaps stated

- **WHEN** the operator declines the initial commit
- **THEN** no commit and no remote exist, and the wrapper states that the first commit and a remote are both outstanding

#### Scenario: An adoption is not committed onto the trunk

- **WHEN** an adoption run succeeds
- **THEN** the wrapper offers no commit onto the current branch and states that the tool's writes reach the trunk through a pull request

### Requirement: A wrapper connects a remote only from a URL the operator supplies

After the initial commit has been made in the new-project mode, where the repository has no remote configured, the wrapper SHALL ask the operator for the URL of a hosted repository the operator has created. The wrapper SHALL NOT create a hosted repository, and SHALL NOT choose its forge, owner, name or visibility: each is a judgment about the project, not a deterministic step.

Where the operator supplies a URL and confirms, the wrapper SHALL add it as the remote `origin` and push the current branch to it with its upstream set. Pushing is outward-facing, so the wrapper SHALL NOT push before that confirmation.

Where the push fails — the hosted repository is not empty, the URL is unreachable, access is refused — the wrapper SHALL report the failure as git stated it, SHALL state that `origin` now names the supplied URL, and stop. It SHALL NOT force the push, and SHALL NOT fetch, merge or rebase the remote's content to make the push succeed; correcting the remote and pushing are the operator's. Re-running the tool does not return to this step, since the repository then has a commit.

Where the operator declines or supplies no URL, the wrapper SHALL state that the workflow's first pull request needs a remote with the trunk pushed to it, and continue to naming the next step.

Where a remote is already configured, the wrapper SHALL leave it unchanged and SHALL NOT ask for one.

The tool itself SHALL NOT configure a remote or push. The remote step is the wrapper's, because it needs the operator's answer and a network, and the tool is deterministic and asks nothing.

#### Scenario: A supplied URL is connected and pushed after confirmation

- **WHEN** the initial commit has been made, no remote is configured, and the operator supplies a URL and confirms
- **THEN** `origin` names that URL and the current branch is pushed to it with its upstream set

#### Scenario: A rejected push is reported, not forced

- **WHEN** the push to the supplied URL is rejected because the hosted repository already has commits
- **THEN** the wrapper reports the rejection, states that `origin` names the supplied URL, and stops, and neither force-pushes nor merges the remote's history

#### Scenario: Declining leaves the gap stated

- **WHEN** the operator declines to supply a URL
- **THEN** no remote is configured, and the wrapper states that the first pull request needs a remote with the trunk pushed to it

#### Scenario: An existing remote is left alone

- **WHEN** the repository already has a remote configured when the initial commit is made
- **THEN** the wrapper does not ask for a URL and the configured remote is unchanged

#### Scenario: The tool configures no remote

- **WHEN** `scripts/project-init` runs to `SUCCESS` in an empty directory
- **THEN** the created repository has no remote configured
