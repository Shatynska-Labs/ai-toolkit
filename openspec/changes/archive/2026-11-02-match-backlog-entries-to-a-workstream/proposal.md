## Why

Backlog entries reach the wrong place, or no place, in a workstream's plan. On 2026-11-02 in commerce-ops, two sessions showed both gaps (`handoff.md` holds the record):

- **The value was wrong.** Four entries were written `workstream: none` while two open workstreams fit them. The session wrote them by hand and never loaded the `backlog` skill, and neither the skill nor `rules/backlog.md` asks for the open workstreams' Goals to be read before `none` is written.
- **The value was right and the entry was still not in the plan.** Eight entries named their workstream correctly and no step named them. The rules let placement wait until the archive, and the sweep that runs at that deadline does not look for such entries. The operator noticed both times.

**Workstream**: `complete-the-workstream-loop`. Its Goal includes a workstream being unambiguous about which changes are its own, and an entry naming a workstream that no step names is exactly that ambiguity. This change takes a step in it, added in this plan's commit.

## What Changes

- **`none` becomes the end of a search.** `rules/backlog.md` requires reading the Goal and Not in scope of every open workstream before writing `none`, which only the operator's word excuses. The **record** operation does that read, says what it chose and why, and asks where more than one Goal is served.
- **An entry is placed when recorded.** `rules/workstreams.md` requires an entry to be placed among the steps when it is recorded, or left for the archive with the reason said. The archive stays the deadline, and placing one recorded entry owes nothing for the others.
- **Detaching re-points before it clears.** The rules define detaching, and an entry outside its workstream goes to another open workstream whose Goal it serves and whose Not in scope admits it, `none` only where there is none, a workstream's archive included.
- **Only a step's own name places anything.** The rules define it as the backticked name a numbered step begins with. A mention in a step's description, Context or Decisions places nothing.
- **The sweep looks at the deadline.** It gathers the entries unplaced in the change's open workstream, reusing the **workstreams** operation's read over the working tree too, so the change's own entries are among them.
- **The workflow binds the skill.** Both workflow fragments gain Claude Code bindings to `ai-toolkit:backlog`'s **record** and **sweep**, and **archive** names the entries it places as "the entries that name it and that no step names".
- **The skill triggers on follow-ups.** Its description gains phrases for recording follow-ups, and comes back under the 1,024-character limit it currently exceeds, dropping two near-duplicate phrases and details the body states.
- **Versions.** `backlog` rises to `1.1.0`, `workstreams` to `2.1.0`, `development-workflow` to `2.1.0`, `development-workflow-direct` to `1.1.0` and the plugin to `2.1.0`. None asks a project to edit anything by hand.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `backlog-maintenance`: *Record writes an entry the file can be relied on for*, *Sweep performs the archive step's re-read* and *Workstreams reports where each workstream stands*.
- `project-bootstrap`: *A workstream register is seeded where none exists* and *The backlog's rules are written where none exist*.
- `session-workflow`: *A change states the workstream it advances, and archiving re-reads it*, and a new requirement binding recording and sweeping to the skill.

## Impact

- `rules/backlog.md`, `rules/workstreams.md`, `rules/development-workflow.md`, `rules/development-workflow-direct.md` and `rules/changelog`.
- `skills/backlog/SKILL.md`: **record**, **sweep**, the description and the trigger fixtures.
- `.claude-plugin/plugin.json`.
- This repository's `docs/backlog/AGENTS.md` and `docs/workstreams/AGENTS.md`, through `scripts/project-update`, and `docs/workstreams/complete-the-workstream-loop.md`.
- `tests/coverage.md` and derived cases. `manifest-alternative-and-versions.sh` pins the workflow fragments' versions at `2.0.0` and `1.0.0`, and `workstreams-seeded-statements.sh` pins "backlog entry naming no workstream"; those two assertions go obsolete. Other pinned phrases are kept.
- Consumers: `scripts/project-update` replaces an unedited block and prints the changelog lines. Entries already unplaced in a project are picked up by the next archive's sweep.
