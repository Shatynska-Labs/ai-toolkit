## Why

A backlog the workflow writes to is never read back against the repository. In commerce-ops it grew from 62 to 95 entries in under three weeks. An audit of 92 entries found that about a fifth of them were done, obsolete, duplicated, stale, or silently unblocked, mostly by changes that were archived while the entry sat unread (see `handoff.md`). Two causes fall within this change. Entries carry no structured status, so whether one can be taken now, is blocked, is a fix, or belongs with others must be dug out of prose. And no step re-reads the backlog when a change is archived. Nor is there a procedure for recording, picking, closing or auditing entries that a session can invoke on demand.

## What Changes

- The backlog `scripts/project-init` seeds gains a structured entry shape. **Kind** (`fix` | `change`, with the reason) and **Waits on** (anything checkable, replacing **Depends on**) are added, along with **Design with** (entries sharing a design) and **Re-checked** (the date last verified). **Recorded by** is kept. The seeded text also states that an entry is kept short, holding pointers but no line numbers, census tables or step plans, and that when a change is archived, the entries it unblocked or made stale are updated.
- `rules/development-workflow.md`'s **archive** step gains one obligation. Before the record's pull request, re-read `docs/backlog.md` for entries the archived change completed, made obsolete, unblocked or made stale, including those naming files it touched, and update them as the file directs, in the archive commit. Version 7 → 8.
- A new skill, `skills/backlog/`, carries five on-demand operations over `docs/backlog.md`: **record**, **pick**, **close**, **sweep** (the archive re-read) and **audit**. The audit is a periodic full check fanned out to parallel read-only agents. It returns a merged report and applies its cleanup only on the operator's word. The skill reads the entry rules from the backlog file and the obligations from the fragment, and restates neither.
- The fold-in rule (handoff sections 1 and 4, plus the reviewer's `scope` exemption) is **not** in this change. It is recorded as the backlog entry `fold-small-work-in`.

## Capabilities

### New Capabilities

- `backlog-maintenance`: the `backlog` skill: its five operations, what each reads and writes, the audit's fan-out and report, and its seam with the fragment and the seeded file.

### Modified Capabilities

- `project-bootstrap`: *A backlog is seeded where none exists*. The seeded statements gain entry brevity, the archive-time update, and obsolescence as a deletion ground. The entry shape gains Kind, Waits on (replacing Depends on), Design with and Re-checked.
- `session-workflow`: a new requirement makes the fragment's archive step re-read the backlog against the archived change, by name and by what it touched. *A rule states an action…* is scoped: a skill performing an operation is not a publication of the fragment's reasoning, and may carry procedure but no obligation of its own.

## Impact

- `scripts/project-init` (seeded heredoc), `tests/cases/backlog-seeded-*.sh` (the `Depends on` assertion goes obsolete), `tests/coverage.md`.
- `rules/development-workflow.md` (version 7 → 8). Every adopting project sees version skew on its next run.
- New `skills/backlog/SKILL.md` and `skills/backlog/references/audit.md`. Adding a skill invalidates the recorded trigger fixtures of the assets it competes with (`project-init`, `project-foundation`), which must be re-run.
- Existing backlogs, including this repository's own, are untouched by the tool. The skill has to tolerate entries in the older shape.
- `docs/backlog.md` (this repository) gains `fold-small-work-in`.
