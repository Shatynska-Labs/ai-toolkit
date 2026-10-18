# project-foundation Specification

## Purpose

Defines what establishing a new project's foundation must cover and how completion is judged: the decisions that must be settled before normal development begins, coverage expressed as named artifact sections rather than as conversation order, persistence that survives a conversation spanning sessions, and the one exemption from the workflow's own test-authoring rule.

## Requirements

### Requirement: The foundation checklist is a portable fragment, not a skill's private content

The decisions a foundation must settle SHALL be recorded in a rule fragment readable independently of any agent harness. A skill MAY wrap that fragment to supply conversation quality, but SHALL NOT be the only place the checklist exists.

The fragment SHALL NOT be inlined into a project's conventions file. It describes a one-time procedure rather than a standing constraint, and inlining it would leave permanent instructions for work already finished.

#### Scenario: A non-skill-aware tool follows the same procedure

- **WHEN** a developer or agent without a skills primitive begins establishing a project's foundation
- **THEN** the checklist is readable as a document, and the decisions it requires are the same ones a skill-driven session would cover

#### Scenario: The checklist does not accumulate in projects

- **WHEN** a project has completed its foundation
- **THEN** its conventions file carries the standing workflow rules but not the foundation checklist itself — it does carry the settled testing-strategy and development-tooling decisions, in their own separate section, per *Settled decisions are surfaced into the project's permanent documentation* below

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

### Requirement: Decisions are classified by whether they can be proposed

Foundation discovery SHALL distinguish decisions that must be supplied by the person from decisions that may be proposed with reasoning and confirmed.

Project identity, problem, audience, scope, and non-goals SHALL be supplied — they are not derivable from anything available. Language, framework, architecture, testing strategy, and development tooling MAY be proposed with the reasoning stated, for confirmation or rejection.

Discovery SHALL NOT present the checklist as a fixed sequence of questions. Coverage is the obligation; interrogation order is not, and a mechanical sequence produces worse discovery than a conversation that reaches the same coverage.

#### Scenario: A technical decision is proposed rather than asked

- **WHEN** the project's identity, problem, and scope are established and a testing strategy has not been discussed
- **THEN** a strategy is proposed with the reasoning that led to it, for confirmation or rejection, rather than posed as an open question

#### Scenario: An identity decision is not invented

- **WHEN** the project's non-goals have not been stated
- **THEN** they are elicited rather than inferred, because nothing available makes them derivable

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

### Requirement: Decisions are persisted as they settle

Each decision SHALL be written into the change's artifacts as it settles, rather than accumulated and written once at the end.

A foundation conversation may span sessions. The workflow's own rule against relying on conversation context for what an artifact could hold applies to the conversation that establishes the project as much as to any later one.

#### Scenario: A conversation resumed in a new session loses nothing

- **WHEN** a foundation conversation is interrupted after several decisions are settled and resumed later with no conversation history
- **THEN** the settled decisions are readable from the change's artifacts, and only the unsettled ones remain open

### Requirement: Settled decisions are surfaced into the project's permanent documentation

A foundation's decisions SHALL NOT live only inside the OpenSpec change that establishes them. Once a decision settles, it SHALL also be written into the location a human or a fresh agent session actually reads, chosen by whether the decision needs to shape agent behavior automatically or is purely descriptive.

Identity, problem, audience, scope, non-goals, technology, and architecture SHALL be written into the project's `README.md` — descriptive decisions that inform without needing to auto-load into every agent turn. Testing strategy and development tooling SHALL be written into a named, project-specific section of `AGENTS.md`, distinct from any standing workflow block already inlined there — operationally load-bearing decisions (a test command, a test-path glob, a tooling choice) that a later change's test-authoring step depends on as inputs, and which only reach an agent automatically through the file this repository has empirically confirmed Claude Code auto-loads via its `CLAUDE.md` import.

The criterion is auto-load, not audience. A decision is not routed to `AGENTS.md` merely because an agent might someday consult it, and not routed to `README.md` merely because a human might read it — it is routed to `AGENTS.md` only if a future agent turn needs it without being told to go look, and to `README.md` otherwise.

#### Scenario: Descriptive decisions reach README.md

- **WHEN** identity, problem, audience, scope, non-goals, technology, or architecture settle
- **THEN** they are written into the project's `README.md`, created if absent or added as a clearly delimited section if the file already exists

#### Scenario: Operationally load-bearing decisions reach AGENTS.md

- **WHEN** testing strategy or development tooling settle
- **THEN** they are written into a named section of `AGENTS.md`, separate from the workflow's own managed block, so a later change's test-authoring step can read the test command and test-path glob without being told where to look

Foundation presupposes a project already bootstrapped by this workflow's own initialization step, which always creates `AGENTS.md` before foundation can run — unlike `README.md`, which bootstrap deliberately never writes. `AGENTS.md` being absent when foundation runs is therefore out of scope, not a case this requirement defines behavior for.

#### Scenario: A decision is not placed by which audience happens to value it

- **WHEN** a decision is descriptive and would also interest an agent, or operationally load-bearing and would also interest a human reader
- **THEN** it is placed by whether it must auto-load to shape a future agent turn, not by which audience happens to value it

#### Scenario: design.md remains the canonical record

- **WHEN** a decision has been surfaced into `README.md` or `AGENTS.md`
- **THEN** it is still recorded in the change's `design.md` under its named section — the surfaced copy is a projection for discoverability, not a replacement for the artifact coverage is checked against

### Requirement: Change authoring is delegated, not reimplemented

Foundation discovery SHALL produce its proposal, design, and task artifacts through the project's existing change-authoring mechanism rather than through a second implementation of artifact generation.

Its own contribution is coverage, classification, and a stop condition — not a competing way to write a change.

#### Scenario: Artifacts are produced by the existing mechanism

- **WHEN** foundation decisions are sufficiently settled to write the change
- **THEN** the established change-authoring path produces the artifacts, and foundation discovery supplies their content rather than generating them independently

### Requirement: The foundation change is exempt from test authoring

The workflow requires tests be derived from a change's specifications before implementation. The foundation change SHALL be exempt, and the exemption SHALL be stated explicitly rather than left to inference.

Test authoring requires the project's test command and test-path locations as inputs. Those are outputs of the foundation change, not inputs to it — foundation is the one change in a project's life for which test authoring is structurally impossible. Left unstated, an agent reaching this point either stalls on a missing input or produces a placeholder suite that asserts nothing.

#### Scenario: Test authoring is skipped for a stated reason

- **WHEN** the foundation change reaches the point where test authoring would normally run
- **THEN** the exemption is applied and its reason stated, rather than the step being attempted against an undefined test command or silently omitted

#### Scenario: The exemption does not extend past foundation

- **WHEN** the first change after foundation is prepared for implementation
- **THEN** test authoring applies normally, because the test command and locations the exemption depended on are now defined

### Requirement: Foundation completes at archival and remains complete

The foundation SHALL be complete when every required decision section is filled and the change is archived. Archival SHALL be the signal that a project has moved from establishment to normal development.

Foundation SHALL be treated as a historical change rather than as an invariant to be maintained. Nothing SHALL check whether a project still matches its foundation: a later architectural or tooling shift is a new change, not a foundation violation. Continuous reconciliation of a project against its foundation would be the workflow engine this design excludes.

#### Scenario: Lifecycle position is derived, not stored

- **WHEN** it must be determined whether a project has completed its foundation
- **THEN** the presence of the archived foundation change answers it, with no separate state file recording the project's phase

#### Scenario: A later architectural change is not a violation

- **WHEN** a project changes its architecture long after its foundation was archived
- **THEN** the change proceeds through the normal workflow, and the archived foundation is neither invalidated nor required to be updated

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
