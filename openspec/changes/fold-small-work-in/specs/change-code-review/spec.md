## MODIFIED Requirements

### Requirement: Out-of-scope edits are reported as scope

An edit the change's stated scope does not cover SHALL be reported as a finding of kind `scope`, with the remedy of moving it to its own change or a backlog entry, and SHALL NOT be reported as a defect on that ground alone. It SHALL be `[MAJOR]` where it changes behaviour and `[MINOR]` where it does not.

An edit the project's conventions let a change fold in, made as they direct, SHALL NOT be reported as `scope`; one that falls short of any of their conditions SHALL be, with the remedy unchanged. The reviewer SHALL take those conditions from the project's conventions and SHALL NOT state them itself: a project whose conventions name no fold-in rule has none, and a second statement of the conditions would drift from the conventions'. A condition the reviewed diff cannot show, such as a pull request description not yet written, SHALL NOT be a finding. A folded-in edit SHALL be reviewed for correctness and for the project's conventions like the rest of the diff.

#### Scenario: A correct but unrelated edit

- **WHEN** the diff contains a correct, behaviour-preserving refactor of a module the change does not mention
- **THEN** it is reported as a `[MINOR]` `scope` finding with the move-out remedy, not as a defect, and alone it yields `CONDITIONALLY APPROVED`

#### Scenario: A folded-in edit made as the conventions direct

- **WHEN** the project's conventions state a fold-in rule, and the diff contains a typo fix in a file the change edits for its own work, in a commit of its own whose message says it is folded in
- **THEN** it is not reported as a `scope` finding

#### Scenario: A folded-in edit outside the change's files

- **WHEN** a commit whose message says it is folded in edits a file the change does not otherwise edit, where the project's fold-in rule requires the change's own files
- **THEN** it is reported as a `scope` finding with the move-out remedy

#### Scenario: A folded-in edit with a defect

- **WHEN** a folded-in commit meeting the project's fold-in conditions introduces a defect
- **THEN** the defect is reported as a `defect` finding, as it would be anywhere in the diff

#### Scenario: No fold-in rule in the project

- **WHEN** the project's conventions state no fold-in rule, and a commit whose message says it is folded in makes a correct edit the change's stated scope does not cover
- **THEN** it is reported as a `scope` finding, as any out-of-scope edit is
