## Context

`project-bootstrap` owns the backlog's entry rules and states them in the seeded file; `backlog-maintenance` performs operations over the file and reads those rules from it, restating none; `session-workflow` requires the fragment to name no entry field. So the field is defined in the seeded preamble, and the skill's operations refer to it by name and defer to the file for what its values mean.

`project-init` never rewrites an existing backlog. Every adopting project meets the new field only when it edits its own preamble, and the skill already handles a file whose shape lacks a field it names: it skips the step and says so, and never adds a field the file does not define.

## Goals / Non-Goals

**Goals:** an entry can be kept while visibly not worth taking, with the condition that would change that; urgent work can be told from ordinary work; both are read by `pick`, kept current by `sweep` and checked by `audit`.

**Non-Goals:**
- An ordering of the file. The preamble's "the order of entries carries no meaning" stands: ordering is `pick`'s output, not the file's layout.
- A numeric or many-level scale. Each extra level is a judgement to keep current with nothing to check it against.
- Rewriting existing entries in any project. The default makes them `normal` without an edit.
- Any change to the workflow fragment.

## Decisions

**1. Three values, each checkable.** `high` needs evidence of harm happening now — an incident, a measurement, an observation — so `audit` can ask whether the evidence still holds. `parked until <condition>` needs a condition stated as something checkable, the same standard **Waits on** already holds, so `audit` and `sweep` can tell when it holds. `normal` needs nothing and is the default.

**2. No `low`.** An entry not worth taking and with no condition under which it would be is an entry the operator has decided will not be made, which the preamble already makes a deletion ground. A `low` value would hold such entries indefinitely; requiring a condition is what keeps a parked entry from being that.

**3. Parked is not Waits on.** **Waits on** means the entry cannot be taken; **parked** means it can be and is not worth it. They are separate fields because `pick` treats them differently: a waiting entry is blocked, a parked one is deliberately deferred, and an entry may be both. A condition that holds moves a parked entry to `normal` (or `high`, with evidence), as a satisfied wait moves to `nothing`. Waits on governs first: an entry that is both waiting and parked is not offered by pick, under Parked or anywhere else, until its wait is satisfied, as any blocked entry is not.

**4. An absent field is `normal`, stated in the file.** The default lives in the seeded preamble beside the field, not in the skill, so a session reading the file without the skill reads it too, and existing entries need no edit. The skill therefore never reports an entry as unclassified for lacking Priority. That needs a MODIFIED *Entries in an older shape are reported, not rewritten*: a field whose absence the file itself gives a meaning is read as that meaning, and is not a missing field.

**5. The seeded text.** The entry shape gains, between the description and **Kind**:

> **Priority**: `high`, `normal`, or `parked until` a condition that can be checked, and why. `high` needs evidence of harm happening now — an incident, a measurement, an observation; `parked` is an entry that could be taken but is not worth taking until its condition holds, and is not folded into another change before then. When the condition holds the entry becomes `normal`, or `high` with evidence; when a `high` entry's evidence no longer holds it becomes `normal`. An entry without this field is `normal`.

the order sentence becomes:

> The order of entries carries no meaning. What an entry waits on, how urgent it is, and which entries share a design with it, it states in its own fields.

and the archive sentence's "update the entries it unblocked or made stale" becomes "update the entries it unblocked, unparked or made stale".

The transitions out of `parked` and `high` are in the file, not in the skill: they are entry rules, which `project-bootstrap` owns and the skill may not restate, and the fragment's archive re-read updates entries "as the file directs" with or without the skill.

It sits first among the fields because it is the first thing a reader choosing work needs. Infrastructure adopted this exact wording, all three edits, in Fuperia-IT/infrastructure#67, so that project already carries the seeded text.

**6. Who sets it.** `record` writes `normal` unless the session or the operator states the evidence or the condition, and writes `high` or `parked` only once the operator confirms it: urgency and deferral are the operator's judgements about the project's work, not facts a session can verify alone.

**7. A parked entry is not folded in.** `session-workflow`'s apply pickup selects entries by the fold-in conditions and names no field, so a parked fix-sized entry would be folded in despite the operator's deferral, which may rest on risk rather than size, as in the motivating case. The fragment cannot name a field, so the seeded text says it: a parked entry is not folded into another change before its condition holds.

**8. The skill's operations.**
- **pick**: within Takeable, `high` entries first, a Design with group placed by its highest-priority member; parked entries are not Takeable and are listed apart as **Parked**, each with its condition; a parked entry whose condition already holds is listed under Takeable once updated, naming what fulfilled it.
- **sweep**: step 2 also finds entries whose parked condition the change fulfils and entries whose `high` evidence it removes.
- **audit**: the brief asks, for a `high` entry, whether its evidence still holds, and for a `parked` one, whether its condition holds; the merged report's *Now unblocked* section becomes *Now unblocked or unparked*, and a `high` whose evidence no longer holds is reported under *Stale facts*, its Priority corrected as the file directs.
- **record**: a step setting Priority as decision 6 states.
- **close**: unchanged; Priority names no other entry.

Each step applies only where the file's shape names Priority, refers to it by name and to the file for its values, so a file defining it differently still wins, and a file not defining it skips these steps, as the skill's *Before any operation* already directs for a field the file lacks.

## Risks / Trade-offs

- **Priorities go stale faster than facts.** Mitigated by requiring evidence or a condition for the two non-default values, which is what `audit` and `sweep` check; `normal` cannot go stale.
- **Operators may over-use `high`.** The evidence requirement is the guard; `audit` reports a `high` whose evidence no longer holds.
