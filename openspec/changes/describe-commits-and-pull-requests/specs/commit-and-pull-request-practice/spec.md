## Purpose

Covers what the `commits-and-pull-requests` skill tells a session about writing commit messages and pull request titles and descriptions, so that what a reviewer and a later reader open says what changed, why, and what was verified.

## ADDED Requirements

### Requirement: A project's own conventions take precedence

The skill SHALL defer to the project it is used in wherever that project states a convention of its own: a commit-message convention, a pull request template the forge supplies, or anything its `AGENTS.md` or `CLAUDE.md` says about commits or pull requests. The skill's guidance SHALL be stated as the default that applies where the project is silent.

The skill SHALL NOT name a particular commit convention as the one to use. Which convention a project's commit messages follow is a decision the project's foundation records, and a skill naming one would make that decision for every project that installs it.

#### Scenario: A project template wins over the default sections

- **WHEN** the project has a pull request template and the skill's default description sections differ from it
- **THEN** the description follows the template, and the skill's guidance applies only to what the template leaves open

#### Scenario: The commit convention is read, not assumed

- **WHEN** a commit message is written in a project
- **THEN** its subject follows the convention that project states, and where the project states none, the skill does not supply a named one

### Requirement: A commit message's body says why

The skill SHALL direct that a commit message's body state why the change was made, and what a reader could not tell from the diff, rather than restating what the diff shows. A commit whose subject says everything needs no body.

The skill SHALL carry, as its example of a commit whose message the workflow fragment constrains, the fragment's rule that folded-in work's commit says it is folded in and names the backlog entry it takes. The rule is the fragment's; the skill states it at the point a commit message is written and adds no obligation to it.

#### Scenario: A body does not narrate the diff

- **WHEN** a commit's body is written
- **THEN** it states the reason for the change or what the diff cannot show, not a list of the edits the diff already shows

#### Scenario: Folded-in work is identifiable from its commit

- **WHEN** a commit carries folded-in work that takes a backlog entry
- **THEN** its message says the work is folded in and names the entry

### Requirement: A pull request's title states its effect, not a commit subject

The skill SHALL direct that a pull request's title state the effect of the pull request in plain words, for a reader who will not open the diff. The skill SHALL NOT direct that a pull request's title follow the project's commit convention or take its type prefix: a pull request spans several commits, often on different concerns, so no single commit subject describes it.

#### Scenario: A multi-commit pull request is titled by its effect

- **WHEN** a pull request carries commits of several kinds — a feature, a test correction and a documentation fix
- **THEN** its title states what the pull request achieves, rather than one commit's subject or a commit-convention prefix

### Requirement: A pull request's description carries what changed, why, what else, and what was verified

The skill SHALL direct that a pull request's description state, where the project's template does not settle it otherwise:

- **what** changed, at the level a reviewer needs before reading the diff;
- **why**, with a pointer to the change's record where the change has one;
- **what else** it carries — each piece of folded-in work, which the workflow fragment requires be named there, and any departure from the change's plan;
- **verification**: the checks actually run on the branch head, each with its result, and the review verdicts the change received.

The skill SHALL direct that a check not run be stated as not run, with the reason, and never be listed as passing. A description is read as evidence, and a check claimed but never run is the failure a reviewer cannot see from the diff.

The skill SHALL direct that the description be revised when the pull request changes after it was written, so that it describes the diff that merges rather than the first one pushed.

#### Scenario: A description names its folded-in work

- **WHEN** a pull request carries folded-in work
- **THEN** its description names each piece under what else it carries

#### Scenario: An unrun check is not reported as passing

- **WHEN** a verification step could not be run on the branch head
- **THEN** the description states that it was not run and why, rather than listing it with the passing checks

#### Scenario: A description follows the pull request after review

- **WHEN** commits are added to a pull request after its description was written, changing what it does
- **THEN** the description is revised to describe the diff as it now stands

### Requirement: The skill describes each kind of pull request the workflow produces

The skill SHALL describe the content of each kind of pull request the workflow fragment produces for a change:

- **the work** — the change's implementation, described as above;
- **a fix** — work re-entering at `build`'s review after an unhealthy deploy or an absent effect; its description names the change it fixes, the pull request that shipped the defect, and the defect;
- **the record** — the last of the change's pull requests; its description names the pull requests it records, the specification record it carries, the outcome of the backlog re-read and of the workstream re-read, including that nothing was affected where nothing was, and whether the effect was confirmed or the confirmation waived, with the waiver's class.

The record's content SHALL be held in a reference file the skill loads on demand, since a session needs it once per change.

#### Scenario: A fix names what it fixes

- **WHEN** a pull request carries a fix to a change whose earlier pull request merged
- **THEN** its description names that change, the earlier pull request and the defect

#### Scenario: The record reports a re-read that changed nothing

- **WHEN** the record's pull request is written for a change whose backlog re-read found no entry to update
- **THEN** its description states that the re-read was made and that no entry was affected, rather than omitting the re-read

### Requirement: The skill describes content, not when to commit or open a pull request

The skill SHALL cover what a commit message and a pull request say, as defaults of form a session meets where the project states nothing else; `session-workflow` classifies it as a form skill, which carries no obligation the fragment does not state. It SHALL NOT state when a commit is made, when a pull request is opened, or how many a change takes — those belong to the workflow fragment, and a second statement of them would drift from the first.

#### Scenario: The pull request count is not restated

- **WHEN** the skill describes the record's pull request
- **THEN** it names it as the workflow's last pull request for the change without restating the workflow's rule on how many pull requests a change takes or when each is opened
