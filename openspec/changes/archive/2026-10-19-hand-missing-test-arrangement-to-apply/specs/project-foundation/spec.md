## ADDED Requirements

### Requirement: The testing strategy names the test author's inputs

The testing-strategy section SHALL carry three named items, each a visible gap until answered: the **test command**, the **test-path glob**, and the **shared test arrangement** — where the project's tests take builders, fixtures, fakes and stubs from, as a path, or the statement that the project has none.

These are what a later change's test author is dispatched with. The test command and the test-path glob are already required to reach `AGENTS.md`; naming them as items makes their coverage checkable in the artifact rather than implied by the section having been written. The shared test arrangement is added beside them because a test author dispatched without it declares every piece of arrangement locally, and the implementation step then has nowhere named to promote it to.

"None" is an answer and an empty item is a gap, as for every other item. A project that answers "none" is not obliged to create a shared arrangement by foundation; its later changes' tests declare arrangement locally and the test plan records it.

#### Scenario: The shared arrangement is reached even when nobody raises it

- **WHEN** a foundation conversation has settled the test runner and the person has not mentioned shared fixtures or doubles
- **THEN** the shared test arrangement item is still proposed with reasoning for confirmation or redirection, rather than left unanswered

#### Scenario: The items reach AGENTS.md

- **WHEN** the testing strategy settles
- **THEN** the test command, the test-path glob and the shared test arrangement — a path, or that there is none — are written into `AGENTS.md`'s testing-strategy section

## MODIFIED Requirements

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
