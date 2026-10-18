# Lessons

Three arguments in this change's `design.md` were wrong on a first pass and corrected before it archived. `design.md` records the corrected form; this file records the correction, which is the part worth keeping. Carried over from the unpushed `add-development-workflow-skill` handoff when that change was dropped.

## The branch topology

The first design cut the record's branch from the work branch's tip, justified by confirmations being stranded otherwise. That reasoning was self-refuting — the record branch is created after the merge, so nothing can be stranded — and it reintroduced the defect it cited to reject its own alternative. It was then withdrawn entirely in favour of one branch per change.

## The stage vocabulary's derivability

The first version claimed every stage derivable and supplied a mechanism covering only verdicts received. The transient/persistent split is what made the claim true rather than merely stated.

## The documentation paths

Two attempts edited `AGENTS.md` and `rules/README.md` away from a `toolkit-structure` requirement the change did not amend. Both were reverted. The lesson generalises: editing documentation away from an unamended specification is how a change acquires a contradiction nothing validates.
