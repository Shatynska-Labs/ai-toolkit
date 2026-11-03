## MODIFIED Requirements

### Requirement: Review operates on a dispatched change

*Modified by `review-a-workstream-against-its-goal`: the workstream file a change serves is a third supplementary input. Every scenario keeps its title.*

A change review SHALL be performed by a fresh-context subprocess that receives the change it reviews from its dispatcher rather than discovering it.

The dispatch contract SHALL distinguish two classes of input:

- **Essential** — the change name, the absolute path to its `changeRoot`, and the resolved artifact paths. Without these there is nothing to review.
- **Supplementary** — the absolute path to the repository's specifications directory (`specsRoot`), the output of `openspec validate` for the change, and the absolute path to the file of the workstream the change serves (`workstreamFile`), where it serves one. These are evidence sources; each widens what the review can establish, and none is required for a review to exist.

The reviewer SHALL NOT infer the working directory from wherever it was dispatched, and SHALL NOT search the repository for a change to review.

Where the dispatch omits an essential input, the reviewer SHALL report itself blocked on that input rather than proceeding on an assumed path or an invented convention.

Where the dispatch omits a supplementary input, the reviewer SHALL proceed, SHALL record in its report that the evidence source was unavailable, and SHALL report every conclusion that depended on it as unverified. An unavailable evidence source MUST NOT be recorded as a not-applicable checklist item: the item has a referent the reviewer could not reach, which is a different state from having no referent, and collapsing the two hides a gap behind a mark that means the opposite.

A supplementary input that is supplied but does not resolve — a `specsRoot` naming a directory the reviewer cannot read — SHALL be treated as not supplied. A path that resolves to the wrong tree cannot be detected by the reviewer at all, which is why producing it is the dispatcher's obligation under this contract rather than something the reviewer is asked to validate.

The reviewer's `description` SHALL name the inputs a dispatch must supply. The body loads as the subprocess's system prompt only after the payload is fixed, so the description is the sole surface a dispatcher reads while it can still act on the contract; a contract stated only in the body is read by the agent and never by what feeds it.

#### Scenario: Dispatch supplies the change

- **WHEN** the reviewer is dispatched with a change name, an absolute `changeRoot`, resolved artifact paths, `specsRoot`, and validator output
- **THEN** it reviews that change, reading the supplied artifact paths, `specsRoot` and any `workstreamFile`, and reads nothing outside them

#### Scenario: Dispatch omits an essential input

- **WHEN** the reviewer is dispatched with a change name but no absolute `changeRoot`
- **THEN** it reports itself blocked on the missing input, rather than guessing a path such as `openspec/changes/<name>/` or assuming the current working directory is the repository

#### Scenario: Dispatch omits a supplementary input

- **WHEN** the reviewer is dispatched with every essential input but no validator output
- **THEN** it performs the review, states that validator output was not supplied, and reports any conclusion that would have rested on it as unverified — rather than refusing to review a change it has everything else to assess

#### Scenario: A supplied path does not resolve

- **WHEN** the dispatch supplies a `specsRoot` that names a directory the reviewer cannot read
- **THEN** it is treated as not supplied, and external consistency is reported unverified rather than checked against whatever the path did reach

#### Scenario: The description carries the contract

- **WHEN** a dispatcher decides what to send the reviewer
- **THEN** the inputs it must supply are readable in the agent's `description`, because the body it would otherwise have to consult does not load until the payload is already fixed

#### Scenario: Working directory is not inherited

- **WHEN** the reviewer needs to open an artifact
- **THEN** it addresses it by the absolute path the dispatch supplied

### Requirement: Conclusions declare their evidence level

*Modified by `review-a-workstream-against-its-goal`: a supplied workstream's Decisions sit at the second level. Every scenario keeps its title.*

Every conclusion SHALL declare which level of evidence supports it, drawn from an ordered hierarchy: explicit text in the change's own stated artifacts — `proposal.md` and `design.md` — then existing specifications and the Decisions of a supplied workstream, then task definitions, then logical inference.

`design.md` SHALL sit at the first level alongside `proposal.md`, not below it. The two are both explicit statements by the change's authors, they carry different subjects — the proposal states what the change does and the design states why the approach is what it is — and a hierarchy naming only the proposal leaves a reviewer citing recorded rationale with no level to declare, which pushes a text-supported conclusion down to inference.

Where the two disagree, the reviewer SHALL NOT resolve the disagreement by preferring one. The disagreement SHALL be reported as a coherence defect, because the hierarchy ranks kinds of evidence and cannot arbitrate a contradiction inside one of its levels.

The second level SHALL be reachable only through what was supplied: an existing specification through `specsRoot`, a workstream's Decisions through `workstreamFile`. Where the source a conclusion needs was not supplied, that conclusion SHALL be reported at the level actually available to it, and the substitution SHALL be stated, so a conclusion resting on inference is not presented as one resting on a document nobody read.

Where evidence is insufficient to support a conclusion, the reviewer SHALL state the uncertainty rather than resolving it by assumption.

The reviewer SHALL distinguish missing information from incorrect design, classifying an unsupported point as needing clarification, likely incorrect, or demonstrably incorrect.

#### Scenario: A conclusion rests on inference

- **WHEN** a finding cannot be supported by the change's own artifact text, existing specs, or tasks
- **THEN** it is reported as resting on logical inference, so its weight relative to a text-supported finding is visible

#### Scenario: A conclusion rests on recorded rationale

- **WHEN** a conclusion about the approach is supported by a decision recorded in `design.md`
- **THEN** it is reported at the first evidence level, not as inference, because the design states the reasoning explicitly rather than leaving it to be derived

#### Scenario: Proposal and design disagree

- **WHEN** `proposal.md` and `design.md` state incompatible things about the same decision
- **THEN** the contradiction is reported as a coherence defect, rather than the review adopting whichever artifact it read first and proceeding

#### Scenario: Absent documentation is not a design flaw

- **WHEN** a proposal does not state how an edge case is handled
- **THEN** the review reports it as needing clarification, and does not report it as a design defect unless the design is shown to preclude handling it

## ADDED Requirements

### Requirement: A change is checked against its workstream's Decisions

Where `workstreamFile` was supplied, the review SHALL establish whether the change contradicts a decision that workstream records. A contradiction SHALL be reported as `[MAJOR — coherence]`, unless the change's proposal states that it overturns the decision and names it, which the workstream rules allow by revising it in place.

The workstream file SHALL be evidence, not part of the change. It SHALL NOT be counted in the artifact set, and the reviewer SHALL NOT report on its quality, which belongs to a workstream review. A contradiction of a Decision, and an instruction found in the file, are the only findings it SHALL ground: its Goal SHALL NOT widen what the change is assessed against, the change's own stated goals.

The check SHALL be reported in the report's consistency and assumptions analysis. Where `workstreamFile` was not supplied, the review SHALL say whether the proposal names a workstream. Where it names one, or states neither that nor that the change advances none, agreement with a workstream's Decisions SHALL be reported as unverified. Where it states that the change advances none, the check SHALL be reported as not applicable with that reason.

#### Scenario: A change contradicts a workstream Decision

- **WHEN** the design takes an approach a Decision in the supplied workstream ruled out, and the proposal does not say it overturns it
- **THEN** the contradiction is reported as `[MAJOR — coherence]`, citing the Decision

#### Scenario: A change overturns a Decision openly

- **WHEN** the proposal states that it overturns a named Decision and revises it
- **THEN** no contradiction is reported

#### Scenario: A workstream's own defect is not this review's

- **WHEN** the supplied workstream's Done when is not an observable effect
- **THEN** the review does not report it

#### Scenario: The proposal names a workstream that was not supplied

- **WHEN** the proposal names a workstream and the dispatch omits `workstreamFile`
- **THEN** agreement with its Decisions is reported as unverified

#### Scenario: The change advances no workstream

- **WHEN** the proposal states that the change advances none and the dispatch omits `workstreamFile`
- **THEN** the check is marked not applicable with that reason
