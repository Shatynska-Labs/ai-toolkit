## MODIFIED Requirements

### Requirement: The foundation covers a fixed set of decisions including non-goals

Foundation discovery SHALL cover, at minimum: what the project is, what problem it solves, its intended audience, its initial scope, **its non-goals**, its language and framework, its architecture, its testing strategy, and its development tooling.

Non-goals SHALL be a first-class decision rather than an aspect of scope. A scope statement records what is intended; only an explicit non-goal records what was considered and rejected, which is what prevents the same question being reopened repeatedly and what constrains later scope growth.

The development tooling decision SHALL cover the project's quality layer by concern, not by tool: linting, formatting, type checking, build tooling, local hooks, the commit-message convention, what a pull request's title and description carry, secret handling, dependency updates and audit, the continuous-integration gate, toolchain pinning, branch protection, and the provisioning a new working tree needs before verification can be trusted. Provisioning SHALL include keeping every tool that recurses the tree without reading the ignore file — test collection, a linter, a container build context — out of the roots the workflow places working trees under (`.worktrees/`, and `.claude/worktrees/` by its Claude Code binding), whether or not the project's ignore file names them, so that one working tree's verification never runs, checks or ships another's copy of the code. The pull request concern SHALL be separate from the commit-message convention and SHALL NOT be framed as whether pull request titles follow it: a pull request spans several commits, often on different concerns, so the two are decided independently. The checklist SHALL name each concern without naming a tool, framework or service — those are the project's choices, and naming one would make a stack-agnostic checklist assume a stack.

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

#### Scenario: The pull request concern is decided on its own

- **WHEN** the development tooling checklist is read
- **THEN** it names a pull request concern — what a title and description carry, whether the forge supplies a template, and whether anything checks it — as an item separate from commit messages, and does not ask whether pull request titles follow the commit convention

#### Scenario: Recursive tools are kept out of the working-tree roots

- **WHEN** the provisioning concern is decided
- **THEN** the decision says how each chosen tool that recurses the tree without reading the ignore file is kept out of the working-tree roots, or that the stack has no such tool

### Requirement: Coverage is verifiable in the artifact, not only in the conversation

The foundation change's design artifact SHALL carry this fixed set of named sections, covering every decision the checklist requires:

```
## Identity
   - What it is
   - Problem it solves
   - Intended audience
## Scope
## Non-Goals
## Technology            language and framework
## Architecture
## Testing Strategy
   - Test command
   - Test-path glob
   - Shared test arrangement
## Development Tooling
   - Linting
   - Formatting
   - Type checking
   - Build tooling
   - Local hooks
   - Commit messages
   - Pull requests
   - Secrets
   - Dependency updates and audit
   - Continuous integration
   - Toolchain pinning
   - Branch protection
   - Provisioning
   - Ignore entries
   - Delivery
```

The mapping from decision to section is fixed here rather than chosen per project, and is stated in this requirement rather than in a design document, because the requirement outlives the change that introduces it and an obligation deferred to an archived file cannot be checked afterwards.

A section covering more than one decision SHALL carry a named item per decision it absorbs — as `Identity`, `Testing Strategy` and `Development Tooling` do — so that an unanswered decision remains individually visible rather than being concealed by a filled section covering several.

An item MAY be answered as not applicable, with the reason stated — type checking for a language without it, or branch protection decided against for a single-maintainer repository. A stated reason is an answer; an empty item is not.

An unfilled section, or a filled section with an unanswered named item, SHALL be an unmet gate. A gate that exists only inside a model's conversation is not a gate, because nothing outside that conversation can check it.

#### Scenario: A skipped decision is detectable after the fact

- **WHEN** a foundation change is inspected by someone who was not present for the conversation
- **THEN** each required decision is either answered under its named section or item, or visibly absent, without the conversation being available

#### Scenario: A decision absorbed into a shared section stays visible

- **WHEN** one section covers several decisions and only some of them were settled
- **THEN** the unsettled ones are individually identifiable as unanswered, rather than the section reading as complete because its other items are filled

#### Scenario: A concern that does not apply is answered, not skipped

- **WHEN** a development tooling item does not apply to the project
- **THEN** the item states that it does not apply and why, and the gate treats it as answered; an item left empty remains an unmet gate
