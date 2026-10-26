## MODIFIED Requirements

### Requirement: The session obligations are published in the workflow fragment and one binding fragment

The obligations this capability governs SHALL be published in the two places named below, and in no further place a session must read alongside them to act correctly:

- `rules/development-workflow.md` — the workflow fragment, which states every obligation service-neutrally alongside the spec-driven gates it already carries, and which `scripts/project-init` inlines into a consuming project's conventions file;
- `rules/development-workflow-database.md` — the binding fragment, which binds the workflow fragment's provisioning and namespace obligations to a containerized relational database.

The workflow fragment SHALL state a role and name its binding beneath it, as it already does for the agents and the working-tree location it binds to Claude Code. The binding fragment SHALL NOT restate an obligation the workflow fragment states; it names the service, the naming form and the operations that reach the stated end state.

**The fragment SHALL name its unit of work before stating any rule about it.** The unit is a change, and every rule below is a rule about a change's life; a document that never says so leaves a reader to infer it from the rules themselves.

**It SHALL state what falls outside that unit and what happens to it.** Work too small to be a change skips `plan` — there is nothing to specify — and does not skip `ship`, since nothing reaches production except by merging. Unstated, the reader has two readings and neither is written down: that trivial work carries the whole process, or that it escapes the delivery rules too.

The qualifier SHALL sit in the opening rather than inside a rule. It governs whether the document applies at all, and a scope condition met halfway through has already been read as unconditional by anyone who stopped earlier.

**The workflow fragment SHALL assume a remote, pull requests, continuous integration, and that merging to the trunk deploys, and SHALL state no conditional for their absence.** Pull requests imply the forge whose merged-state report the teardown gate reads; naming it separately in the assumptions states twice what the gate states once. Every project these rules are written for has all of them. A conditional for a shape no consumer has is paid for by every reader of every project that does have one, and it is the class of text that made the previous publication expensive.

A project of a shape these assumptions do not fit is served by a publication of its own rather than by a conditional here. A second publication is written when there is something to write it for; a conditional is carried forever whether or not anything needs it.

Where such a publication is written, **this capability owns it alongside the others**, and states each shared obligation once while naming which publications it binds — the arrangement it already holds for the workflow fragment and the binding fragment. Stated, because the argument against keeping two publications of one rule set is that both must be maintained, and that argument applies to this pair the moment it exists rather than being answered by the pair having been anticipated.

Neither fragment SHALL name a `rules/` path, a sibling fragment, or an import. In a consuming project the conventions file is a copy and no `rules/` directory is read, so a sentence naming a fragment file names something the reader cannot open.

Where a binding is itself a fragment rather than a tool name written inline, the workflow fragment SHALL refer to it by where the reader will find it — an adjacent section of the same conventions file, where the project carries one — and not by a path. The reference SHALL be conditioned on the project carrying that binding, since until the installing tool writes a second block the section exists only where someone pasted it, and an unconditional reference points at nothing in every project initialised in the interval. Otherwise the two clauses above cannot both be satisfied for the case this requirement exists to introduce, and a project holding the workflow fragment alone would carry a service-neutral obligation with no stated way to learn that a binding exists at all.

Neither fragment SHALL name an `ai-toolkit:` agent or skill that this library does not ship. A consuming project reaches the library's agents and skills only through the installed plugin, so a name with no `agents/<name>.md` or `skills/<name>/SKILL.md` behind it is a dispatch that finds nothing — the same dangling reference as a path the reader cannot open, met at the gate that needs it.

`project-bootstrap` owns how the workflow fragment reaches a project and what shape it takes there — the managed block, the version and its increment condition, that a role is named before a tool, that the gates form an ordered sequence with checkable preconditions, and that an automatic dispatch loop is bounded, what happens on reaching the bound, and which outcomes exit the loop rather than consume a round. This capability owns what the session-derived rules say, and MAY fix the numeric value of a bound for a loop it states — `project-bootstrap` requires that a bound exist and fixes no number.

Where this capability states a loop, it SHALL state the value, what happens on reaching the bound, **and** the outcomes that exit it — all three of what `project-bootstrap` requires of every loop the rules state, since a loop introduced here would otherwise arrive carrying only the part this capability remembered. The seam is stated because both capabilities bear on one file, and an unstated seam is resolved by whoever amends it first.

#### Scenario: A session obligation is stated once

- **WHEN** an obligation this capability governs is amended
- **THEN** it is amended in the workflow fragment, and the binding fragment changes only where the amendment touches the service, the naming form or the operations

#### Scenario: A reader of a project's conventions finds no dangling reference

- **WHEN** a session reads the workflow fragment's body as inlined in a project's conventions file
- **THEN** every reference resolves within that document, and no sentence names a file that exists only in this library

#### Scenario: A fragment names only agents and skills the library ships

- **WHEN** either fragment's body names an agent or skill as `ai-toolkit:<name>`
- **THEN** the library ships an agent or a skill of that name, and a name it does not ship is reported rather than passing unnoticed

#### Scenario: A project without a deploy is not served by a conditional

- **WHEN** a project that does not deploy on merge needs these rules
- **THEN** it is served by a publication of its own, and the workflow fragment states its assumptions plainly rather than branching on them

#### Scenario: A second publication does not arrive unowned

- **WHEN** a publication for another project shape is written
- **THEN** this capability owns it alongside the workflow fragment and the binding fragment, and states each shared obligation once naming which publications it binds

