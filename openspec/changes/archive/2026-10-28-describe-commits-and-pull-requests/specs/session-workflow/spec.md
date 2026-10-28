## MODIFIED Requirements

### Requirement: A rule states an action and a defect appears only as its reason

**A rule SHALL state what to do, and reasoning SHALL appear only where it changes what a reader does.** The fragment is inlined into a consuming project's conventions file and read by every session there, so its length is paid for on every read — brevity is the reason for the obligations below, not itself an obligation whose satisfaction anyone can test.

Three kinds of text SHALL NOT appear in the fragment, because each is written for this library rather than for the project holding the file: an argument against an alternative the fragment does not adopt, a statement about what other project shapes would need, and a justification for the fragment's own structure. Where such reasoning is worth keeping, it belongs in the change that decided it.

**Where this rule and a requirement obliging the fragment to state a particular reason conflict, the obliged reason wins.** A requirement that names a reason has decided that the reason changes what a reader does; brevity governs what is left. Unstated, the conflict is resolved by whoever edits last, which is how six mandated statements were dropped in a single compression pass.

Where such reasoning is additionally published so a session can seek it out — a skill, say — that publication SHALL carry reasoning only: an instruction, a gate, an exemption, or an edge case whose answer differs SHALL stay in the fragment, because a separately published document is loaded when something judges it relevant and there is no guarantee that happens at the moment it is needed. The fragment SHALL remain sufficient on its own. This binds any such publication when one is written; none exists today.

**A skill that performs an operation is not such a publication.** A skill MAY carry the procedure for carrying out an obligation the fragment states — how to search, what to compare, what to report — and procedures of its own for work no obligation requires, where they are operations a session invokes on demand. It SHALL NOT carry an obligation on a session that the fragment does not state, nor an edge case of a fragment obligation whose answer differs; each of those stays in the fragment, so that a session that never loads the skill still meets every obligation. `backlog-maintenance`'s `backlog` skill is one such skill.

**A skill describing the form of a commit message or a pull request is not such a publication either.** Form — what a title says, which sections a description carries, how each kind of pull request a change produces is described — is a default the skill supplies, not an obligation on the session: a session that never loads the skill still meets every obligation the fragment states, including naming folded-in work in the pull request's description, and only the default form is lost. The skill SHALL NOT carry an obligation beyond form, nor restate when a commit is made or a pull request opened. `commit-and-pull-request-practice`'s `commits-and-pull-requests` skill is one such skill.

The distinction is stated because the clause above reads, unscoped, as forbidding any skill that touches what the fragment governs — and an operation is exactly what a session wants to find by description at the moment it needs it, which is the case a publication of the fragment's reasoning is not.

Each session-derived rule in the workflow fragment, and each rule in the database binding fragment, SHALL be phrased as an action to take. A defect, incident, or current shortcoming MAY appear only as the reason a stated action matters, never as a standing entry of its own.

Each rule SHALL be phrased so that its durable half is the instruction and its perishable half is the consequence. A rule built around a defect goes stale when the defect is fixed and, until someone notices, contradicts the fix.

A rule SHALL NOT be omitted on the grounds that the defect motivating it is being fixed, where the instruction survives the fix. The instruction and the damage are separable, and only the damage expires.

#### Scenario: A rule outlives the defect that motivated it

- **WHEN** the defect a rule cites as its reason is subsequently fixed, or is enforced more strictly
- **THEN** the rule's instruction is unchanged and still correct, and only the consequence it names is out of date

#### Scenario: The fragment carries no argument written for the library

- **WHEN** a rule is written into the fragment
- **THEN** it states what to do and, where reasoning changes what a reader does, states it in as few words as carry it — and carries no argument against a rejected alternative, no account of what another project shape would need, and no justification for the fragment's own structure

#### Scenario: An incident does not become a standing entry

- **WHEN** an incident from a consuming project is used as evidence for a rule
- **THEN** it appears as the reason that rule's action matters, and no rule consists of the incident alone

#### Scenario: An operational skill carries procedure, not obligation

- **WHEN** a skill offers a procedure for an obligation the fragment states
- **THEN** the fragment states the obligation and every edge case whose answer differs, and a session that never loads the skill meets the obligation from the fragment alone

#### Scenario: A form skill carries defaults, not obligations

- **WHEN** a session writes a pull request without having loaded `commits-and-pull-requests`
- **THEN** it has met every obligation the fragment states for that pull request, and what it lacks is only the skill's default form

## ADDED Requirements

### Requirement: Writing a pull request is bound to a skill, not stated in the fragment

The workflow fragment SHALL carry, under `ship`'s `open pr` step, a Claude Code binding naming `ai-toolkit:commits-and-pull-requests` as what a session uses to write a pull request's title and description.

The fragment SHALL NOT itself state a pull request's title or description format. The fragment is inlined into every adopting project's conventions file and carried in every session there, while a pull request is written a few times per change; guidance about its form is loaded where it is used. The fragment's existing obligation to name folded-in work in the pull request's description is a constraint, not a format, and stays.

#### Scenario: The binding names a shipped skill

- **WHEN** the workflow fragment's `open pr` step is read
- **THEN** it carries a Claude Code binding naming `ai-toolkit:commits-and-pull-requests`, and the library ships `skills/commits-and-pull-requests/SKILL.md`

#### Scenario: The fragment carries no pull request format

- **WHEN** the workflow fragment is read for what a pull request's title or description contains
- **THEN** it finds the binding and the obligation to name folded-in work, and no list of title rules or description sections
