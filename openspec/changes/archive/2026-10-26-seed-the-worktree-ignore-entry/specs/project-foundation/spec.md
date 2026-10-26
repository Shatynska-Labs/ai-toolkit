## MODIFIED Requirements

### Requirement: The foundation covers a fixed set of decisions including non-goals

Foundation discovery SHALL cover, at minimum: what the project is, what problem it solves, its intended audience, its initial scope, **its non-goals**, its language and framework, its architecture, its testing strategy, and its development tooling.

Non-goals SHALL be a first-class decision rather than an aspect of scope. A scope statement records what is intended; only an explicit non-goal records what was considered and rejected, which is what prevents the same question being reopened repeatedly and what constrains later scope growth.

The development tooling decision SHALL cover the project's quality layer by concern, not by tool: linting, formatting, type checking, build tooling, local hooks, the commit-message convention, secret handling, dependency updates and audit, the continuous-integration gate, toolchain pinning, branch protection, and the provisioning a new working tree needs before verification can be trusted. Provisioning SHALL include keeping every tool that recurses the tree without reading the ignore file — test collection, a linter, a container build context — out of the roots the workflow places working trees under (`.worktrees/`, and `.claude/worktrees/` by its Claude Code binding), whether or not the project's ignore file names them, so that one working tree's verification never runs, checks or ships another's copy of the code. The checklist SHALL name each concern without naming a tool, framework or service — those are the project's choices, and naming one would make a stack-agnostic checklist assume a stack.

The development tooling decision SHALL carry one deliverable that foundation itself builds, beyond a statement of intent: extending the project's ignore file with the exclusions its chosen stack requires. The rest of what the decision settles is built by a named owner, not by foundation — see *Development-tooling decisions have a named owner before foundation archives*. Initialization deliberately creates an ignore file carrying no stack assumption, because it cannot know the language. Foundation is the first point at which the language is known, so this is where that gap closes — and naming it here is what makes it closed rather than merely handed off.

#### Scenario: Non-goals are recorded even when scope is clear

- **WHEN** a project's scope has been stated
- **THEN** its non-goals are still recorded separately, rather than being treated as covered by the scope statement

#### Scenario: Stack-specific ignore entries are a foundation deliverable

- **WHEN** the project's language and framework have been decided
- **THEN** extending the ignore file with that stack's exclusions is recorded as a task of the foundation change, rather than left to be noticed later

#### Scenario: The quality layer is reached even when nobody raises it

- **WHEN** a foundation conversation has settled linting and formatting and the person has not mentioned hooks, commit messages, secrets, dependency updates, continuous integration or branch protection
- **THEN** each of those is still proposed with reasoning for confirmation or redirection, rather than left undiscussed because the tooling decision already reads as answered

#### Scenario: The checklist names concerns, not tools

- **WHEN** the development tooling checklist is read
- **THEN** it names each concern it requires without naming a particular linter, formatter, hook manager, build system or forge

#### Scenario: Recursive tools are kept out of the working-tree roots

- **WHEN** the provisioning concern is decided
- **THEN** the decision says how each chosen tool that recurses the tree without reading the ignore file is kept out of the working-tree roots, or that the stack has no such tool
