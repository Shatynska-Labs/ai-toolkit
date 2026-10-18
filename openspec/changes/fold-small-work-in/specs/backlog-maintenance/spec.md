## MODIFIED Requirements

### Requirement: Record writes an entry the file can be relied on for

The **record** operation SHALL write one entry in the shape the file states. Where the session invoking it is in a change, record SHALL first test the work against the fold-in rule the project's workflow states, where it states one, taking the test from the workflow rather than stating it; where the work meets it, record SHALL say so and write no entry unless the operator still wants one. Before writing, it SHALL check the entry's name against the backlog's headings, the project's open and archived change directories, and its branches, and SHALL not write a name already used by any of them. It SHALL set Kind by the file's own definition and state the reason. It SHALL search the existing entries for ones touching the same files, specifications or capabilities and present each as a Design with candidate, writing into Design with only the candidates the session or operator confirms share a design, or `nothing`. A shared pointer is evidence of a shared design, not the same thing. It SHALL set Re-checked to the day the entry is written.

The fold-in test, the name check and the overlap search are the operation's procedure, not entry rules or obligations: the workflow states when work is folded in, the file states that an entry is named and may name entries to design with, and record is how the skill makes those statements hold for the entry it writes.

#### Scenario: A name already used by an archived change

- **WHEN** record is asked to write an entry whose name matches an archived change's directory
- **THEN** it does not write the entry under that name and asks for another

#### Scenario: An overlapping entry exists

- **WHEN** record writes an entry naming a file another entry also names
- **THEN** record presents that other entry as a Design with candidate, and names it in Design with only once it is confirmed to share a design

#### Scenario: Work the change can fold in

- **WHEN** record is invoked during a change for a small correction in a file that change edits, owing no delta and no decision, in a project whose workflow states a fold-in rule
- **THEN** record says the work can be folded in and writes no entry unless the operator still wants one
