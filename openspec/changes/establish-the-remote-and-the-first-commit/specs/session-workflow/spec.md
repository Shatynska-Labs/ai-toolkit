## ADDED Requirements

### Requirement: A repository's first commit is the one commit that reaches the trunk directly

The workflow fragment SHALL state, where it states that every change reaches the trunk through pull requests, that a repository's first commit reaches the trunk directly, and that no other commit does. A pull request needs a branch to merge into, and before the first commit there is none.

The fragment SHALL identify that commit by the observable that defines it — the repository has no commit before it — and SHALL NOT name it by a class a later commit could claim, such as setup, initialization, bootstrap or tooling commits. The exception is stated so that a session reading a project's history, which begins with a commit no pull request carried, finds that commit accounted for rather than in breach; stated by class, it would read as permission for any later direct push of the same kind.

This is a statement of where an existing rule applies, not a setup obligation, so `A one-time setup obligation does not belong in the fragment` does not exclude it: a session acts on it each time it reads a history and decides whether a direct commit was a breach.

#### Scenario: The first commit is accounted for

- **WHEN** a session reads the fragment in a project whose history begins with a commit made directly on the trunk
- **THEN** the fragment's delivery rule states that a repository's first commit reaches the trunk directly, so the commit is not read as a breach

#### Scenario: A later commit cannot claim the exception

- **WHEN** the fragment's statement of the exception is read
- **THEN** it identifies the commit by there being no commit before it, and names no class of commit — setup, initialization, bootstrap or tooling — that a later commit could belong to
