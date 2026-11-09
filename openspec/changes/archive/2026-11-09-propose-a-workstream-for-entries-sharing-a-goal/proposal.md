## Why

Entries pile up under `workstream: none` while they share goals among themselves. On 2026-11-08 and 2026-11-09 in commerce-ops, 40 of 123 entries named `none`; three abandoned workstreams had just detached 18 of them with a note deferring the read, and only the operator asking twice made a session look for goals the entries shared. It found three, eleven entries were placed, and several had sat under `none` for weeks (`handoff.md` holds the record). Every rule that chooses an entry's workstream reads only the *open* workstreams; none reads the `none` entries against each other, and none puts the decision to open a workstream in front of the operator.

**Workstream**: `complete-the-workstream-loop`. Its Goal includes a workstream being unambiguous about which changes are its own, and `match-backlog-entries-to-a-workstream` made `none` follow a search of the open workstreams. This change takes the next step, from "is there an open workstream?" to "should there be one?", and is added to its steps in this plan's commit.

## What Changes

- **The workstream rules oblige the proposal.** `rules/workstreams.md` keeps opening a workstream the operator's decision, and states that a session finding a goal no open workstream holds and more than one change or entry needs, among the entries naming `none` or the changes it proposes, proposes opening one: naming them and a draft Goal, opening none unasked, and proposing none for a goal one change meets. The workflow's **draft** sentence already defers to that file, so the obligation is stated once.
- **Recording runs the read.** `rules/backlog.md`'s `workstream` key adds that before `none` is written the other entries naming `none` are read for a goal shared with the new one; where one is found, a workstream is proposed as the workstreams rules direct, and `none` is written meanwhile. The **record** operation reads their bodies, not the repository, and says what it proposed or that no shared goal was found.
- **Detaching runs it too, and cannot be deferred.** `rules/workstreams.md`'s detaching reads entries detached together alongside those already naming `none`. Each detached entry is re-pointed, cleared after the read, or deleted on a ground the backlog's rules give; a note deferring the read is not a detach. **sweep** runs the read over the entries an archived workstream detaches.
- **Audit looks across ranges.** After merging the agents' verdicts, **audit** reads every entry naming `none` together and adds a section of groups sharing a goal, each with a draft Goal, proposed as workstreams and applied only on the operator's word.
- **Versions.** `backlog` rises to `1.3.0`, `workstreams` to `2.2.0` and the plugin to `2.4.0`. Neither asks a project to edit anything by hand.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `backlog-maintenance`: *Record writes an entry the file can be relied on for*, *Sweep performs the archive step's re-read* and *Audit verifies every entry independently and changes nothing without the operator*.
- `project-bootstrap`: *A workstream register is seeded where none exists* and *The backlog's rules are written where none exist*.

## Impact

- `rules/backlog.md`, `rules/workstreams.md` and `rules/changelog`.
- `skills/backlog/SKILL.md` (**record**, **sweep**, **audit**) and `skills/backlog/references/audit.md`.
- `.claude-plugin/plugin.json`.
- This repository's `docs/backlog/AGENTS.md` and `docs/workstreams/AGENTS.md`, through `scripts/project-update`, and `docs/workstreams/complete-the-workstream-loop.md`.
- `tests/coverage.md` and derived cases; cases pinning the edited paragraphs' phrases are kept where the wording survives.
- Consumers: `scripts/project-update` replaces an unedited block and prints the changelog lines. Entries already under `none` in a project are met by the next record, detach or audit.
