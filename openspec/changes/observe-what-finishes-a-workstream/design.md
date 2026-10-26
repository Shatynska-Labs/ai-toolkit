## Context

`project-bootstrap` owns the workstream shape and states it in the README that `scripts/project-init` seeds. The workflow fragment, the `backlog` skill and the archive re-read all defer to that README for what finishes a workstream, so only the seeded text changes. This repository's own README is byte-identical to the seeded one and is kept that way.

## Goals / Non-Goals

**Goals:** a session opening a workstream is asked for an effect of its Goal it can observe, and learns why "every step is archived" alone does not do.

**Non-Goals:**
- Checking a workstream's Done when. That is `review-a-workstream-against-its-goal`, a later step of the same workstream.
- Rewriting a consumer's workstreams.
- Changing when a workstream is archived. It is still archived once its Done when holds.

## Decisions

**1. The shape line.** It becomes:

> `**Done when**: an effect of the Goal that can be observed in the repository, the forge or production, and what result means it holds; add "every step is archived" beside it where that is wanted.`

**2. The paragraph.** It goes immediately before the archive paragraph, which opens with "When a workstream's Done when holds", so a reader meets what Done when must be before what follows from it:

> What finishes a workstream is an effect of its Goal that someone can observe: what to look at in the repository, the forge or production, what provokes it where something must, and what result means the Goal holds. "Every step is archived" shows only that the step list was worked through, and a list missing a step meets it all the same. It may stand beside the effect where every step is wanted whatever the effect shows, never in its place.

**3. Alongside, not forbidden.** The entry allows "every step is archived" beside the effect where that is wanted. A workstream whose steps each carry their own value has a reason to require all of them, and forbidding the clause would push that requirement into prose nobody checks.

**4. Tests.** The new statement and the shape line each get a phrase assertion in a derived case, in the style of `workstreams-seeded-statements.sh`. No existing case asserts the old Done when wording (`workstreams-seeded-no-status-field.sh` and `workstreams-seeded-fields-are-a-list.sh` read only the label), so none goes obsolete.

## Risks / Trade-offs

- **An effect can be stated vaguely.** Wording cannot stop a Done when that names an effect nobody can observe. Mitigation: the review step of this workstream checks it.
