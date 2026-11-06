## Why

A board of a project's tasks cannot tell the operator three things at a glance: whether a task is a fix or a change, whether it is required or only desirable, and what holds it up. The operator asked for all three on 2026-11-05, on a prototype of `dev-task-board` fed with commerce-ops, and accepted the prototype's page as informative.

- **Kind and the wait are in the entry, but not in the tool's output.** `scripts/task-board --json` gives `priority` and `waits_on`, not `kind`, `waits_for` or `parked_until`. In commerce-ops, all 131 entries carry `kind`, 24 carry `waits_for` and 10 a named `waits_on`, so most of what holds a task up is missing.
- **Nothing says whether a task is required.** `priority` says how urgent a task is, and in commerce-ops 110 entries are `normal`, 15 `parked` and none `high`. Whether a task is needed for its workstream's goal or is an improvement that can wait is in no field.
- **A wait for a condition is one sentence, and its kind cannot be read.** commerce-ops' 24 `waits_for` run from 48 to 135 characters. Read by hand, they are of five kinds: the operator's decision (6), another person's answer (7), an access grant or setting (5), a release or event in an environment (4), and two change names that belong in `waits_on`. Which of these holds a task decides who acts next, and only the sentence says it.
- **Whether a named wait has already cleared is not reported.** A reader has to look each name up, and an archived change missed in an entry's `waits_on` reads as a live wait.

**Workstream**: `see-a-projects-tasks`. Its Goal is that a project's work stays findable without holding it in memory, and kind, need and wait are what a reader of the board would otherwise hold in memory. This change takes a step in it, added in this plan's commit.

## What Changes

- **An entry states its need.** `rules/backlog.md` gains `need`: `must`, `should` or `could`, measured against the Goal of the entry's workstream, or against harm to the project where it names none; being a step does not make an entry `must`. An entry without it is `should`. A `must` or `could` is the operator's judgement, so **record** proposes it and writes it on the operator's word, as it does `high` and `parked`.
- **A condition states what kind of wait it is.** `rules/backlog.md` gains `waits_for_type`, a list drawn from `decision`, `answer`, `access`, `release` and `event`, present only beside `waits_for`. `waits_for` keeps its meaning and stays a short condition, its reasons in the body. An entry with `waits_for` and no type is valid and reads as untyped.
- **The skill keeps them.** **record** writes both, **pick** lists `must` before `should` before `could` within a priority, and **audit** checks a type against its condition and proposes one where it is missing.
- **The tool reports them.** Each task in `--json` gains `kind`, `need`, `waits_for`, `waits_for_type` and `parked_until` from its entry, and two derived values: `waits_on_done`, the names in `waits_on` already done, and `readiness`, one of `ready`, `blocked`, `waiting` or `parked`. The page shows kind, a need other than `should`, the done names and the typed condition beside the task, and leaves readiness to the board. A named wait the forge could not check is warned of. New fields leave `schema_version` at `1`.
- **Versions.** `backlog` rises to `1.2.0`, with no request to edit anything by hand, and the plugin to `2.3.0`.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `project-bootstrap`: *The backlog's rules are written where none exist*.
- `backlog-maintenance`: *Record writes an entry the file can be relied on for*, *Pick lists what can be taken now*, *Audit verifies every entry independently and changes nothing without the operator* and *Entries in an older shape are reported, not rewritten*.
- `task-board`: *The page carries what a task's entry states* and *The tool reports the board as JSON*.

## Impact

- `rules/backlog.md`, `rules/changelog`, `.claude-plugin/plugin.json`.
- `skills/backlog/SKILL.md` (**record**, **pick**, *Entries missing a key*) and `skills/backlog/references/audit.md`.
- `scripts/task-board`: the entry reader, the page's task row, and the JSON task.
- This repository's `docs/backlog/AGENTS.md`, through `scripts/project-update`, `docs/workstreams/see-a-projects-tasks.md`, and the entry `docs/backlog/report-a-tasks-kind-and-wait.md`, deleted at archive.
- `tests/coverage.md` and derived cases. `scripts/backlog-migrate` is untouched: it writes `waits_for` as before, and no type.
- Consumers: `scripts/project-update` replaces an unedited block; entries already written stay valid, and **audit** proposes types for their conditions. `dev-task-board` reads the new fields once it carries this tool (its `show-a-tasks-kind-and-wait`).
