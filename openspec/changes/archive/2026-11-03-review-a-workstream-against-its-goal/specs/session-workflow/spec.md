## ADDED Requirements

### Requirement: A workstream is reviewed when it is opened and when its plan changes

The workflow fragment SHALL direct, under **Throughout**, that an independent reviewer checks that a workstream's steps reach what it is for, agree with what it has decided and leave out what it leaves out, and that what finishes it can be observed, before the commit that opens it, and before a commit whose edit adds or removes a step, changes what a step does, or changes what the workstream is for, what finishes it, what it leaves out or what it has decided. It SHALL state that a commit holding several such edits takes one review; that an edit renaming or reordering steps, or adding to what the workstream knows, takes none; that the commit archiving a workstream takes none; and that the rule holds whether or not the edit belongs to a change. It adds no stage to a change.

The loop SHALL be bounded at six rounds; on reaching the bound, the session reports where the loop stands and what is outstanding, and asks before continuing. A conditional pass SHALL be permission conditional on the fixes it names, applied without a further round. A reviewer judging the concept unsound SHALL exit the loop at once, and the session raises it. A fix that changes the plan's substance rather than its wording SHALL be the operator's to decide, since which goals are worth tracking and how is their judgement; where the operator decides to leave a defect, the session SHALL commit on that word and say so, which exits the loop.

The fragment SHALL state the role, and name `ai-toolkit:workstream-reviewer` in a Claude Code binding beneath it that states what the session does on each of the four verdicts. It SHALL state no workstream field, deferring to `docs/workstreams/AGENTS.md` as this capability already requires.

The fragment's **review → fix → approve** SHALL direct supplying, with a change's artifact set, the workstream its proposal names, and the plan's binding SHALL name that as what `ai-toolkit:change-plan-reviewer` is given.

#### Scenario: Opening a workstream

- **WHEN** a session is about to commit a new workstream
- **THEN** the fragment has directed reviewing it first

#### Scenario: A step is added

- **WHEN** a session places a recorded entry among a workstream's steps
- **THEN** the fragment has directed reviewing the workstream before that edit is committed

#### Scenario: A burst of placements

- **WHEN** one commit places several entries among a workstream's steps
- **THEN** it takes one review

#### Scenario: What a step does changes

- **WHEN** an archive's re-read revises what a step does
- **THEN** the fragment has directed reviewing the workstream before that edit is committed

#### Scenario: A Decision or Not in scope is revised

- **WHEN** a change overturns a Decision and revises it, or Not in scope is revised
- **THEN** the fragment has directed reviewing the workstream before that edit is committed

#### Scenario: The operator leaves a defect

- **WHEN** the reviewer returns `FIX REQUIRED` and the operator decides to leave the defect
- **THEN** the session commits on that word and says so

#### Scenario: An edit that leaves the plan alone

- **WHEN** an edit reorders steps or adds to what the workstream knows
- **THEN** no review is owed

#### Scenario: A workstream is archived

- **WHEN** a commit moves a workstream to its archive
- **THEN** no review is owed

#### Scenario: The loop is bounded

- **WHEN** a session reads the fragment's rule
- **THEN** it finds the six-round bound, what happens on reaching it, and the outcomes that exit the loop

#### Scenario: The plan review is given the workstream

- **WHEN** a session dispatches a change's plan review and the proposal names a workstream
- **THEN** the fragment has directed supplying that workstream's file

#### Scenario: The rule holds in both forms

- **WHEN** either workflow fragment is read
- **THEN** it holds this rule in the same words, and the fragments still differ only as *The two workflows differ only in what states ship* states
