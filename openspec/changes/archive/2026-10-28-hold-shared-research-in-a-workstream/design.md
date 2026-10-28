## Context

`project-bootstrap` owns the workstream rules and states them in the README that `scripts/project-init` seeds. The workflow fragment and the `backlog` skill defer to that README, so only the seeded text changes. This repository's own README is byte-identical to the seeded one and is kept that way.

The rule being replaced was set by `add-workstreams` (`openspec/changes/archive/2026-10-24-add-workstreams/design.md`). It gives two reasons, and the new rule has to answer both rather than drop the sentence:

- **Status written by hand goes stale** (its decision 3). commerce-ops's *In flight now* table was correct when written and wrong two weeks later, because progress happens in every session while the table is edited by none.
- **Edits stay rare** (its decisions 2 and 3). One file per workstream, edited only when the plan changes, means parallel sessions seldom edit one file.

## Goals / Non-Goals

**Goals:**
- Research, findings and decisions shared by several steps of a goal have one place, tied to that goal and archived with it.
- The line between what a workstream holds and what a step's design holds can be drawn by a session that reads the README.
- Nothing the widened file holds can be read as progress.

**Non-Goals:**
- Changing how a step's status is derived, the order rule, or how a workstream is archived.
- Moving any project's existing research documents into its workstreams.
- A managed or re-seedable README.
- Changing the workflow fragment or the `backlog` skill.

## Decisions

**1. Two named sections, mirroring a design** (operator, 2026-10-27). After the field list, an optional `## Context` holds research, findings and the options considered with why one was chosen, and an optional `## Decisions` holds the decisions themselves, each with who took it, when and why. A section with nothing in it is omitted. The `Decisions` list item, which only pointed elsewhere, is removed; a decision already recorded in a change's design may still be pointed to from `## Decisions` rather than copied. An answered open question is recorded under `## Decisions`.

Rejected: one free-form `## Context` (decisions become hard to find, and an answered open question has no fixed place), and any headings the author likes (projects drift apart, and the not-progress rule has nothing fixed to attach to). The names match a change's `design.md`, so a reader moving between the two finds the same structure.

**2. The boundary with a step's design.** A decision that shapes one step only belongs in that step's design. One that shapes more than one step, or was taken before any step's proposal existed, belongs in the workstream. A step's design points to the workstream for it rather than copying it, so the two never hold one decision twice.

**3. What it holds is never progress.** Context and Decisions say what is known and decided about the goal. A finding states what is true of the problem, not that a step found or did it, and neither section names a step as done, in flight or merged. This answers the first reason: what the file holds changes when understanding of the goal changes, not when a session advances a step, so it does not drift the way a status table does.

**4. What it holds is current, revised in place** (operator, 2026-10-27). Where a change in the workstream overturns something the workstream holds, it is revised in place, naming the change that overturned it, in that change's plan commit or at the latest at its archive. The file's history keeps what was held before. Rejected: an append-only dated record, which leaves a reader to work out what still holds — the stale table in another form.

The rule binds a change in the workstream, because that is the change a session is sent to the workstream for: the fragment names the workstream in its proposal at `draft` and re-reads it at `archive` "where the change advanced a workstream", "as `docs/workstreams/README.md` directs". The README now directs revising what the change overturned as part of that re-read. The fragment's enumeration (place entries, revise obsolete steps, archive) is left as it is; widening it would restate a workstream rule and raise the fragment's version in every project.

A change outside the workstream that overturns what it holds is not reached, and this is accepted rather than closed. Widening the fragment's trigger to "or overturned something a workstream holds" would not close it either: a session outside the workstream cannot know it overturned something there without reading every open workstream at every archive, which is the cost the trigger would impose. Such a contradiction surfaces when the workstream's next step is planned and its session reads Context against what the repository now shows.

**5. The edit rule widens, and stays tied to events.** "Edit the file only when the plan changes" becomes "only when the plan or what it holds changes", and the list gains "context or a decision added or revised". Edits remain events in the goal's understanding — research done, a decision taken, one overturned — not one per session. This answers the second reason: edits are more frequent than before, but still not per session, and a conflict stays local to one file.

**6. "Keep this file when there is no workstream" stays**, as a sentence of its own, since it was carried by the paragraph being replaced.

**7. The seeded text.** The "Keep a workstream short" paragraph is replaced by:

> Besides its plan, a workstream holds what its steps share. Under `## Context` go the research, findings and options considered that the goal was planned from, with why one option was chosen. Under `## Decisions` go the decisions that shape more than one step, or were taken before any step's proposal existed, each with who took it, when and why; a decision already recorded in a change's design may be pointed to rather than copied. A decision that shapes one step only belongs in that step's design, which points to the workstream for what it shares rather than copying it.
>
> Context and Decisions say what is known and decided about the goal, never how far the work has come. A finding states what is true of the problem, not that a step found or did it, and neither section names a step as done, in flight or merged.
>
> Context and Decisions state what is held now. Where a change in the workstream overturns something they hold, revise it in place and name that change, in its plan commit or at the latest at its archive. The file's history keeps what was held before.
>
> Keep this file when there is no workstream.

The edit sentence becomes:

> Edit the file only when the plan or what it holds changes: a step added, removed, reordered or renamed, the Done when or what is out of scope revised, an open question added or answered, context or a decision added or revised, or the workstream archived.

In the shape, the `Decisions` item is removed, Open questions' answer is "recorded under Decisions", and after the list:

```
## Context

Research, findings and the options considered that the steps share; omit the section where there are none.

## Decisions

**1. A decision.** Who took it and when, what was decided and why, or the change's design that records it; omit the section where there are none.
```

**8. Adoption is by hand** (operator, 2026-10-27). `project-init` leaves an existing README byte-for-byte unchanged, and the README is not a managed block. Each project edits its own copy; commerce-ops's copy already differs from the seed, so a re-seed would not apply cleanly anyway. Moving research documents already under a project's `docs/` into the workstreams they served is that project's adoption work, as `add-workstreams` left commerce-ops's roadmap to it.

**9. Tests.** Three existing cases pin wording this change replaces and go obsolete in part: `workstreams-seeded-statements` asserts "Edit the file only when the plan changes" (line 56), "Keep a workstream short" and "that the file points to" (lines 69–70), and describes them in its header (lines 14 and 19); `workstreams-seeded-fields-are-a-list` expects a `Decisions` list item; `workstreams-seeded-no-status-field` expects a `Decisions` label. `backlog-skill-workstream-rules-not-restated` forbids "keep a workstream short" in the skill (line 35); `workflow-fragment-workstream-rules-not-restated` has no such scan. Both stay green, and a distinctive phrase of the new text may be added to the skill case's forbid list.

## Risks / Trade-offs

- **A Context section used as a log.** A session may write "step x found …" or a dated diary. Mitigation: decision 3's wording names what is forbidden, and `review-a-workstream-against-its-goal`, a step of `complete-the-workstream-loop`, can check it.
- **The file grows long.** It is read whole by every session placing a step. Accepted: the alternative was the same material scattered across `docs/` and handoffs, read less reliably.
- **Revision in place is skipped by a change in the workstream.** Mitigation: the archive re-read, which that change already performs, is the deadline.
- **A change outside the workstream overturns what it holds.** Not reached by the rule (decision 4). Accepted: it surfaces when the next step is planned against the workstream's Context.
- **Existing workstreams carry a `Decisions` item.** This repository's two are migrated here. Other projects' stay valid prose until they adopt.

## Migration Plan

This repository: the README follows the seeded text, and `complete-the-workstream-loop.md` and `see-the-backlog-across-projects.md` move their `Decisions` pointer to a `## Decisions` section. Step 4 of `complete-the-workstream-loop` and the backlog entry `review-a-workstream-against-its-goal` name "the document Decisions names"; both are reworded to the workstream's Decisions in this change, since this change advances no workstream and the workstream re-read will not reach them. Other projects adopt by hand (decision 8). The fragment's version is unchanged, so no project sees a new skew.

## Open Questions

None.
