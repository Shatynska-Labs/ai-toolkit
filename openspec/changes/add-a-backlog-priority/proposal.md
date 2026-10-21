## Why

A backlog entry states whether it can be taken (**Waits on**) but not whether it is worth taking. Every entry with nothing to wait on reads as equally takeable, so an entry the operator has judged not worth doing yet has two outcomes, both wrong: it stays and is offered by **pick** beside urgent work, or it is deleted and the analysis behind it is lost. Writing the condition into **Waits on** misstates it: the entry is not blocked, it is deliberately deferred, and **pick** would report it as blocked.

The case that surfaced this is the infrastructure repository's `detect-host-drift-on-a-schedule` (2026-10-20): its blocker had gone, but every merge already converges both hosts, a 16-day gap had shown no drift, and the sweep would put the converge credentials in an unattended nightly job. The operator wanted it kept, visibly low, with the condition that would make it worth doing. That repository adopted a **Priority** field by hand (Fuperia-IT/infrastructure#67); this change makes it the seeded shape and teaches the `backlog` skill to read it.

## What Changes

- The seeded `docs/backlog.md` entry shape gains **Priority**: `high`, `normal`, or `parked until` a condition that can be checked, with the reason. `high` needs evidence of harm happening now; `parked` is takeable work not worth taking until its condition holds. A parked entry becomes `normal` (or `high`, with evidence) when its condition holds and is not folded into another change before then; a `high` entry whose evidence lapses becomes `normal`. An entry without the field is `normal`, so no existing entry needs rewriting. The preamble's sentence on what an entry states in its own fields names urgency too, and the archive sentence updates the entries a change unparked.
- There is no `low`: an entry not worth taking, with no condition under which it would be, is one the operator has decided will not be made, which is already a deletion ground.
- `skills/backlog/SKILL.md`: **record** sets Priority, defaulting to `normal` and writing `high` or `parked` only where the evidence or the condition is stated and the operator confirms it; **pick** orders `high` first, lists parked entries apart with their condition, and lists a parked entry whose condition holds as takeable once updated; **sweep** also finds entries whose parked condition the change fulfils or whose `high` evidence it removes; **audit** checks each `high` entry's evidence and each `parked` entry's condition, and reports the entries now unparked.
- This repository's own `docs/backlog.md` preamble adopts the field.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `project-bootstrap`: *A backlog is seeded where none exists* — the entry shape names Priority, its three values and the default.
- `backlog-maintenance`: *Record writes an entry the file can be relied on for*, *Pick lists what can be taken now*, *Sweep performs the archive step's re-read* and *Audit verifies every entry independently and changes nothing without the operator* read and maintain Priority; *Entries in an older shape are reported, not rewritten* reads an absent field the file gives a default for as that default.

## Impact

- `scripts/project-init` (seeded text only; an existing backlog is still left byte-for-byte unchanged, so adopting projects add the field by hand, as infrastructure did).
- `skills/backlog/SKILL.md` (body only; description and trigger fixtures unchanged) and `skills/backlog/references/audit.md`.
- `docs/backlog.md` (this repository's preamble).
- `tests/coverage.md`; new cases from the derived-tests step.
- No fragment change: `session-workflow` requires the fragment to name no entry field.
