## MODIFIED Requirements

### Requirement: The foundation covers a fixed set of decisions including non-goals

Foundation discovery SHALL cover, at minimum: what the project is, what problem it solves, its intended audience, its initial scope, **its non-goals**, its language and framework, its architecture, its testing strategy, and its development tooling.

Non-goals SHALL be a first-class decision rather than an aspect of scope. A scope statement records what is intended; only an explicit non-goal records what was considered and rejected, which is what prevents the same question being reopened repeatedly and what constrains later scope growth.

The development tooling decision SHALL cover the project's quality layer by concern, not by tool: linting, formatting, type checking, build tooling, local hooks, the commit-message convention, secret handling, dependency updates and audit, the continuous-integration gate, toolchain pinning, branch protection, and the provisioning a new working tree needs before verification can be trusted. The checklist SHALL name each concern without naming a tool, framework or service — those are the project's choices, and naming one would make a stack-agnostic checklist assume a stack.

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
## Development Tooling
   - Linting
   - Formatting
   - Type checking
   - Build tooling
   - Local hooks
   - Commit messages
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

A section covering more than one decision SHALL carry a named item per decision it absorbs — as `Identity` and `Development Tooling` do — so that an unanswered decision remains individually visible rather than being concealed by a filled section covering several.

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

## ADDED Requirements

### Requirement: Three development-tooling positions are fixed rather than chosen

Three positions SHALL be recorded as stated, not offered as options, because each is what makes the corresponding item a control rather than a convenience:

- **Continuous integration is the authority, and fails rather than skips.** A verification step that cannot reach a dependency it requires SHALL fail the run. A skip a check declares for itself — a platform it does not apply to, an optional dependency — is a decision, not a gate that failed to run.
- **A local hook is not a gate.** A hook exists only in a working copy where someone installed it, so its silence is not a pass and no completion claim rests on it. Hooks are recorded as a fast local mirror of checks the continuous-integration gate enforces.
- **Secrets are kept out of version control by the ignore file**, not by vigilance at commit time, so committing one takes an override rather than an oversight. The ignore-file deliverable SHALL include the chosen stack's secret-bearing paths alongside its build and dependency exclusions; secret scanning, where chosen, is recorded as a second line rather than a replacement.

Where a project records a hook that stands down for some class of change — documentation only, for example — the item SHALL also record what decides membership of that class, since a stand-down nobody can predict is a gate that silently varies.

#### Scenario: Continuous integration that cannot reach a dependency fails

- **WHEN** the continuous-integration item is recorded
- **THEN** it states that the gate is the authority and that a step unable to reach what it requires fails the run rather than skipping

#### Scenario: A hook is not recorded as the gate

- **WHEN** local hooks are recorded
- **THEN** the record states that they are not an authority, and every check a hook runs that a change must pass is also named among the continuous-integration gate's checks

#### Scenario: Secrets are excluded by the ignore file

- **WHEN** the stack-specific ignore entries are written
- **THEN** they include the stack's secret-bearing paths, rather than leaving secrets to be caught at commit time

#### Scenario: A hook stand-down names what decides it

- **WHEN** local hooks are recorded as standing down for some class of change
- **THEN** the record also states what decides whether a given change belongs to that class

### Requirement: Foundation decides branch protection and does not apply it

Foundation SHALL decide and record the project's branch-protection policy: which continuous-integration checks are required, whether changes reach the trunk only through pull requests, and whether administrators are bound by it. Foundation SHALL NOT apply that policy to a forge.

Where a policy is decided, applying it SHALL be a task of the change that introduces continuous integration, performed once the required checks have reported at least once, and confirmed by the operator before it is made — changing a forge's settings is outward-facing, and a required check that has never reported cannot be selected. Where branch protection is decided against, with its reason recorded, no application task exists.

Foundation is where this decision belongs because nothing earlier can make it: initialization runs before a remote, a stack or any continuous-integration check exists, and is deterministic by design, so it has neither the inputs nor the latitude to decide a forge policy.

#### Scenario: The policy is recorded without being applied

- **WHEN** foundation settles branch protection
- **THEN** the policy is recorded under its named item, and no forge setting has been changed by foundation

#### Scenario: Protection is applied with the operator's confirmation

- **WHEN** the change that introduces continuous integration reaches the task that applies a decided branch-protection policy
- **THEN** the required checks have already reported, and the operator has confirmed the change before the forge setting is made

#### Scenario: Protection decided against creates no application task

- **WHEN** the branch-protection item is answered as not applicable, with its reason
- **THEN** neither the successor's handoff nor the change introducing continuous integration carries a task to apply branch protection

### Requirement: Development-tooling decisions have a named owner before foundation archives

Foundation SHALL remain a decision-only change: it SHALL NOT build the tooling it decides, beyond extending the ignore file. Before the foundation change is archived, every decided development-tooling item not already present in the project — and the test runner the testing strategy decides, if it is not already present — SHALL have a named owner: a successor change, opened as the workflow opens a second change surfacing: a branch of its own carrying a `handoff.md` that names each item it must build, the test runner where it is among them, the branch-protection task where a policy was decided, and the `## Development Tooling` and `## Testing Strategy` sections of the project's `AGENTS.md` as where the decisions are recorded. The handoff SHALL NOT point at the foundation change's `design.md` as its source, since that file moves when foundation archives.

The foundation change's `Development Tooling` section SHALL name that successor under its `Delivery` item. Where every decided item is already present in the project, `Delivery` SHALL say so, and no successor is opened.

The successor SHALL NOT inherit foundation's test-authoring exemption. It is the first change for which the project's test command and test-path glob are decided, and test authoring applies to it as to any later change.

#### Scenario: Archived decisions are not left unbuilt

- **WHEN** a foundation change whose tooling is not yet present in the project is archived
- **THEN** a successor change already exists on its own branch with a handoff naming each item to build and pointing at `AGENTS.md` for the decisions, and the foundation's `Delivery` item names it

#### Scenario: The test runner has an owner

- **WHEN** the testing strategy decides a test runner the project does not yet have
- **THEN** the successor's handoff names installing it, so the first change subject to test authoring has a runner to run against

#### Scenario: Foundation does not build the tooling itself

- **WHEN** foundation's tooling decisions settle
- **THEN** the foundation change's tasks extend the ignore file and open the successor, and contain no task that writes linter, formatter, hook, continuous-integration or dependency-update configuration

#### Scenario: Tooling already present needs no successor

- **WHEN** foundation is run for a project whose decided tooling already exists
- **THEN** the `Delivery` item records that, and no successor change is opened

#### Scenario: The successor is not exempt from test authoring

- **WHEN** the successor change is prepared for implementation
- **THEN** test authoring applies to it normally, against the test command and test-path glob foundation recorded
