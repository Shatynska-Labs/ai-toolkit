## Why

The workflow leaves no path for small adjacent work. **Scope** sends every improvement noticed along the way to a separate proposed change, with no size threshold. **A second change surfacing** offers only recording or opening. `change-code-reviewer` reports any edit outside the stated scope as a `scope` finding, so work a session does fold in is pushed back out at review. In commerce-ops the backlog grew from 62 to 95 entries in under three weeks; at least ten entries said outright that they were recorded rather than folded in, and an audit judged about seventeen of them fixes needing no delta and no decision (`add-backlog-skill`'s archived `handoff.md`, sections 1 and 4).

The backlog entry `state-recording-as-the-obligation` names a gap in the same clause: `session-workflow` requires the fragment to state that recording is the obligation and branching the option, and the fragment's routing bullet offers the two as equals.

## What Changes

- `rules/development-workflow.md`, **Scope**: a fold-in rule. Work noticed along the way is folded in where it touches only files the change edits for its own work, or their direct tests; owes no specification delta and no decision from the operator; and is small. It takes a commit of its own whose message says it is folded in, and is named in the pull request's description. Everything else is still a separate proposed change.
- **A second change surfacing** applies only to what Scope does not fold in, and its routing for an independent change states recording as the obligation and opening as the option (folds in `state-recording-as-the-obligation`).
- **apply**: before implementing, read `docs/backlog.md` for entries the fold-in conditions admit for this change and take each as folded-in work, naming the entry in its commit. The archive re-read deletes the entry.
- Fragment version 8 → 9.
- `agents/change-code-reviewer.md`: an edit the project's conventions let a change fold in, made as they direct, is not a `scope` finding; one failing a condition is. A folded-in edit is reviewed for correctness like the rest of the diff. The cold-run fixture gains a folded-in commit.
- `skills/backlog/SKILL.md`, **record**: test the work against the project's fold-in rule first, and write no entry for work that meets it unless the operator still wants one.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `session-workflow`: two new requirements, *Small adjacent work is folded into the change that found it* and *A change takes the backlog entries it can fold in*. *A second change surfacing in a session is recorded in the backlog* is limited to work not folded in, and requires the routing itself to state recording as the obligation.
- `change-code-review`: *Out-of-scope edits are reported as scope* exempts folded-in edits made as the project's conventions direct.
- `backlog-maintenance`: *Record writes an entry the file can be relied on for* applies the fold-in test before writing.

## Impact

- `rules/development-workflow.md` (version 8 → 9). Every adopting project sees version skew on its next run.
- `agents/change-code-reviewer.md` (body only, so the cold-run check is re-run and the trigger check is not) and `agents/change-code-reviewer.checks.yaml` (fixture recipe and pass criteria).
- `skills/backlog/SKILL.md` (body only; description and trigger fixtures unchanged).
- `tests/coverage.md`; new cases from the derived-tests step.
- `docs/backlog.md` (this repository): `fold-small-work-in` and `state-recording-as-the-obligation` are both completed by this change and deleted at its archive.
